SUBROUTINE CR.EXIM.E.NOF.CUSTOMER.PERFORMANCE(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $USING EB.Reports
    $USING EB.Updates
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING AA.Settlement
    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING AC.AccountOpening
    $USING ST.Customer
    ST.CompanyCreation.LoadCompany("BNK")
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
*******
INIT:
*******
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.SET = 'F.AA.ARR.SETTLEMENT'
    F.SET = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.AA.BILL = 'F.AA.BILL.DETAILS'
    F.AA.BILL= ''
    FN.AA.INT.ACC='F.AA.INTEREST.ACCRUALS'
    F.AA.INT.ACC=''
    FN.CUS='F.CUSTOMER'
    F.CUS=''
    LOCATE 'CUSTOMER' IN EB.Reports.getEnqSelection()<2,1> SETTING CUSTOMER.POS THEN
        CUSTOMER = EB.Reports.getEnqSelection()<4,CUSTOMER.POS>
    END
    LOCATE 'START.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING START.DATE.POS THEN
        Y.START.DATE = EB.Reports.getEnqSelection()<4,START.DATE.POS>
    END
    LOCATE 'END.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING END.DATE.POS THEN
        Y.END.DATE = EB.Reports.getEnqSelection()<4,END.DATE.POS>
    END
RETURN
*******
OPENFILES:
    EB.DataAccess.Opf(FN.AA, F.AA)
    EB.DataAccess.Opf(FN.AA.BILL,F.AA.BILL)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.AA.INT.ACC,F.AA.INT.ACC)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
*******
RETURN
*******
PROCESS:
*******
    SEL.CMD = 'SELECT ':FN.AA:' WITH PRODUCT.LINE EQ ':'LENDING':' AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    IF(CUSTOMER)THEN
        SEL.CMD :=' AND CUSTOMER EQ ':CUSTOMER
    END
    IF(Y.START.DATE)THEN
        SEL.CMD :=' AND MATURITY.DATE GE ':Y.START.DATE
    END
    IF(Y.END.DATE)THEN
        SEL.CMD :=' AND MATURITY.DATE LE ':Y.END.DATE
    END
*
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, RET.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING Y.AA.ID.POS
    WHILE Y.AA.ID : Y.AA.ID.POS
*
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA, F.AA, E.AA)
        Y.PROD.NAM = REC.AA<AA.Framework.Arrangement.ArrProduct>
*
        LOCATE Y.PROD.NAM IN Y.PROD.LST SETTING FOUND ELSE FOUND = 0
*
        IF(FOUND EQ 0) THEN
            Y.PROD.LST := Y.PROD.NAM:FM
        END
    REPEAT
*
    LOOP
        REMOVE Y.PRODUCT FROM Y.PROD.LST SETTING Y.PRODUCT.POS
    WHILE Y.PRODUCT : Y.PRODUCT.POS

        SEL.CMD.PR = SEL.CMD :' AND PRODUCT EQ ':Y.PRODUCT

*
        EB.DataAccess.Readlist(SEL.CMD.PR, SEL.PR.LIST, '', NO.OF.REC, RET.CODE)
        LOOP
            REMOVE Y.AA.ID.PR FROM SEL.PR.LIST SETTING POS
        WHILE Y.AA.ID.PR :POS
            LOCATE Y.PRODUCT IN Y.PROD.ARR SETTING FOUND ELSE FOUND = 0
            IF(FOUND EQ 0) THEN
*
                Y.PROD.ARR := Y.PRODUCT:FM
*
            END
*
            ELSE
                Y.PRODUCT=''
            END
        
            EB.DataAccess.FRead(FN.AA.AC , Y.AA.ID.PR, REC.AA.AC, F.AA.AC, Y.AA.AC.ER)
            EB.DataAccess.FRead(FN.AA, Y.AA.ID.PR, REC.AA, F.AA, E.AA)
            Y.CUSTOMER.ID=REC.AA<AA.Framework.Arrangement.ArrCustomer>
            EB.DataAccess.FRead(FN.CUS,Y.CUSTOMER.ID,REC.CUS,F.CUS,CUS.ERR)
            Y.CUS.NAME=REC.CUS<ST.Customer.Customer.EbCusShortName>
            EB.DataAccess.FRead(FN.AA.INT.ACC, Y.AA.ID.PR:"-CRPROFIT", REC.AA.INT.ACC, F.AA.INT.ACC, E.AA.INT.ACC)
            Y.PROFIT.AMOUNT=REC.AA.INT.ACC<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
            Y.DISB.DATE=REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdValueDate>
*            CRT Y.DISB.DATE
            Y.MAT.DATE=REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
*            CRT Y.EXP.DATE
            Y.ACCT.ID = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
*            CRT Y.ACCT.ID
            Y.TOT.BILL.TYPE = REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
*            CRT Y.BILL.TYPE
            Y.TOT.BILL.ID = REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillId>
*            CRT Y.BILL.ID
            Y.BILL.ID = '' ;* HOLD BILL ID WHICH BILL TYPE IS DISBURSEMENT
            Y.TOT.DUE.AMT = 0 ;* HOLD TOTAL DUE AMOUNT
*
*******************************************************
*            VALUE SEPERATOR FROM AN ARRAY (BEGIN)
*******************************************************
            CONVERT SM TO VM IN Y.TOT.BILL.TYPE
            CONVERT SM TO VM IN Y.TOT.BILL.ID
            Y.DCOUNT = DCOUNT(Y.TOT.BILL.ID,@VM)
            Y.PRIN.RECOV = 0
            Y.PROFIT.RECOV = 0
            Y.OTHER.RECOV = 0
*
            FOR I=1 TO Y.DCOUNT
                Y.BILL.ID = Y.TOT.BILL.ID<1,I>
                EB.DataAccess.FRead(FN.AA.BILL, Y.BILL.ID, REC.AA.BILL.DETT, F.AA.BILL, ERR.AA)
                Y.TOT.PROP.BILL=REC.AA.BILL.DETT<AA.PaymentSchedule.BillDetails.BdPayProperty>
                Y.TOT.PROP.OS=REC.AA.BILL.DETT<AA.PaymentSchedule.BillDetails.BdOsPrAmt>
                Y.TOT.PROP.OR=REC.AA.BILL.DETT<AA.PaymentSchedule.BillDetails.BdOrPrAmt>
*
                Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
                IF Y.BILL.TYPE = 'INSTALLMENT' THEN
                    CONVERT SM TO VM IN Y.TOT.PROP.BILL
                    CONVERT SM TO VM IN Y.TOT.PROP.OS
                    CONVERT SM TO VM IN Y.TOT.PROP.OR
                    Y.DCOUNT.PROP = DCOUNT(Y.TOT.PROP.BILL,@VM)
*
                    FOR J=1 TO Y.DCOUNT
                        Y.PAY.PROP = Y.TOT.PROP.BILL<1,J>
                        IF Y.PAY.PROP = 'ACCOUNT' THEN
                            Y.PRIN.RECOV=Y.PRIN.RECOV + Y.TOT.PROP.OS<1,J>
                        END
                        ELSE
                            IF Y.PAY.PROP = 'PENALTYINT' THEN
                                Y.PROFIT.RECOV=Y.PROFIT.RECOV + Y.TOT.PROP.OR<1,J>
                            END
                            ELSE
                                Y.OTHER.RECOV=Y.OTHER.RECOV + Y.TOT.PROP.OR<1,J>
                            END
                        END
                    NEXT J
                END
            NEXT I
*
            EB.DataAccess.FRead(FN.AA.BILL, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL, ERR.AA)
            Y.FIN.DATE = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdFinancialDate>
*
            Y.AA.PROP.CL = 'TERM.AMOUNT'
            AA.Framework.GetArrangementConditions(Y.AA.ID.PR, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.DISB.AMT  = R.REC.TA<AA.TermAmount.TermAmount.AmtAmount>
*
            Y.AA.PROP.CL = 'INTEREST'
            AA.Framework.GetArrangementConditions(Y.AA.ID.PR, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.PROFIT.RATE = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>
*
            ftCreditAcctNo = Y.ACCT.ID
            BaseBalance = 'CURACCOUNT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(ftCreditAcctNo,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage) ;*Balance left in the balance Type
*
            Y.NET.OUTSTAND.BAL = BalDetails<4>
*
            Y.RETURN<-1> = Y.FIN.DATE :'*':Y.MAT.DATE:'*':Y.PROFIT.RATE:'*':Y.DISB.AMT:'*':Y.PRIN.RECOV:'*':Y.PROFIT.RECOV:'*':Y.OTHER.RECOV:'*':ABS(Y.NET.OUTSTAND.BAL):'*':Y.PRODUCT:'*':Y.AA.ID.PR:'*':Y.CUSTOMER.ID:'*':Y.CUS.NAME
*END
           
        REPEAT
    REPEAT
RETURN
RETURN
END
END