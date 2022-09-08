SUBROUTINE CR.EXIM.E.NOF.CUSTOMER.LIMIT.LIABILITY(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
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
    ST.CompanyCreation.LoadCompany("BNK")

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
    LOCATE 'CUSTOMER' IN EB.Reports.getEnqSelection()<2,1> SETTING CUSTOMER.POS THEN
        CUSTOMER = EB.Reports.getEnqSelection()<4,CUSTOMER.POS>
    END
RETURN

*******
OPENFILES:
    EB.DataAccess.Opf(FN.AA, F.AA)
    EB.DataAccess.Opf(FN.AA.BILL,F.AA.BILL)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.AA.INT.ACC,F.AA.INT.ACC)
    
*******
RETURN

*******
PROCESS:
*******

    IF(CUSTOMER)THEN
        SEL.CMD = 'SELECT ':FN.AA:' WITH PRODUCT.LINE EQ ':'LENDING':' AND CO.CODE EQ ': EB.SystemTables.getIdCompany():' AND CUSTOMER EQ ':CUSTOMER
       
    END
    ELSE
        SEL.CMD = 'SELECT ':FN.AA:' WITH PRODUCT.LINE EQ ':'LENDING':' AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    END
   
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
*    CRT KUDDUS
    
   

    LOOP
        REMOVE Y.PRODUCT FROM Y.PROD.LST SETTING Y.PRODUCT.POS
    WHILE Y.PRODUCT : Y.PRODUCT.POS
*        CRT Y.PRODUCT
        IF(CUSTOMER)THEN
            SEL.CMD.PR = 'SELECT ':FN.AA:' WITH PRODUCT.LINE EQ ':'LENDING':' AND CO.CODE EQ ':EB.SystemTables.getIdCompany():' AND CUSTOMER EQ ':CUSTOMER:' AND PRODUCT EQ ':Y.PRODUCT
       
        END
        ELSE
            SEL.CMD.PR = 'SELECT ':FN.AA:' WITH PRODUCT.LINE EQ ':'LENDING':' AND CO.CODE EQ ':EB.SystemTables.getIdCompany():' AND PRODUCT EQ ':Y.PRODUCT
        END
        
        EB.DataAccess.Readlist(SEL.CMD.PR, SEL.PR.LIST, '', NO.OF.REC, RET.CODE)
        LOOP
            REMOVE Y.AA.ID.PR FROM SEL.PR.LIST SETTING POS
        WHILE Y.AA.ID.PR :POS
            LOCATE Y.PRODUCT IN Y.PROD.ARR SETTING FOUND ELSE FOUND = 0
            IF(FOUND EQ 0) THEN
            
                Y.PROD.ARR := Y.PRODUCT:FM
                
            END
        
            ELSE
                Y.PRODUCT=''
            END
            EB.DataAccess.FRead(FN.AA.AC , Y.AA.ID.PR, REC.AA.AC, F.AA.AC, Y.AA.AC.ER)
            EB.DataAccess.FRead(FN.AA, Y.AA.ID.PR, REC.AA, F.AA, E.AA)
            Y.CUSTOMER.ID=REC.AA<AA.Framework.Arrangement.ArrCustomer>
            EB.DataAccess.FRead(FN.AA.INT.ACC, Y.AA.ID.PR:"-CRPROFIT", REC.AA.INT.ACC, F.AA.INT.ACC, E.AA.INT.ACC)
            Y.PROFIT.AMOUNT=REC.AA.INT.ACC<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
            Y.DISB.DATE=REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdValueDate>
*            CRT Y.DISB.DATE
            Y.EXP.DATE=REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
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
********************************************************
* VALUE SEPERATOR FROM AN ARRAY (BEGIN)
********************************************************
*            CONVERT SM TO VM IN Y.TOT.BILL.TYPE
*            CONVERT SM TO VM IN Y.TOT.BILL.ID
**
*            Y.DCOUNT = DCOUNT(Y.TOT.BILL.TYPE,@VM)
**
*            FOR I=1 TO Y.DCOUNT
*                Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
*                IF Y.BILL.TYPE = 'DISBURSEMENT' THEN
*                    Y.BILL.ID = Y.TOT.BILL.ID<1,I>
*                    BREAK
*                END
*            NEXT I
***********************************************************
** END
***********************************************************
**
*            EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
*            Y.DISB.AMT = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
*
            Y.AA.PROP.CL = 'TERM.AMOUNT'
            AA.Framework.GetArrangementConditions(Y.AA.ID.PR, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.DISB.AMT  = R.REC.TA<AA.TermAmount.TermAmount.AmtAmount>
            
            BaseBalance = 'CURACCOUNT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(Y.AC.ID,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
            Y.CUR.AMT = BalDetails<4>
            Y.PRIN.OUTSTAND = ABS(Y.PRIN.OUTSTAND + Y.CUR.AMT)

            Y.AA.PROP.CL = 'INTEREST'
            AA.Framework.GetArrangementConditions(Y.AA.ID.PR, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.PROFIT.RATE = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>

*            Y.AA.PROP.CL = 'INTEREST'
*            AA.Framework.GetArrangementConditions(Y.AA.ID.PR, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
*            R.REC.PR = RAISE(RET.VALUES)
*            Y.PROFIT.AMOUNT= R.REC.PR<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>

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
            Y.TOT.PAY.METHOD =REC.AA.AC<AA.PaymentSchedule.AccountDetails.AdPayMethod>
            CONVERT SM TO VM IN Y.TOT.PAY.METHOD
            Y.DCOUNT = DCOUNT(Y.TOT.PAY.METHOD,@VM)

            FOR J=1 TO Y.DCOUNT
                Y.PAY.TYPE = Y.TOT.PAY.METHOD<1,J>
                IF Y.PAY.TYPE = 'DUE' THEN
                    Y.BILL.ID = Y.TOT.BILL.ID<1,J>
                    EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
                    Y.TOT.DUE = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdPaymentAmount>
                    Y.TOT.TMP = 0
                    CONVERT SM TO VM IN Y.TOT.DUE
                    Y.TP.DCOUNT = DCOUNT(Y.TOT.DUE,@VM)
                    FOR K=1 TO Y.TP.DCOUNT
                        Y.DUE = Y.TOT.DUE<1,K>
                        Y.TOT.TMP = Y.TOT.TMP + Y.DUE
                    NEXT K
                    Y.TOT.DUE.AMT = Y.TOT.DUE.AMT + Y.TOT.TMP
                END
            NEXT J

            Y.RETURN<-1>= Y.DISB.DATE :'*':Y.EXP.DATE:'*':Y.PROFIT.RATE:'*':Y.DISB.AMT:'*':Y.PRIN.OUTSTAND :'*':Y.PROFIT.AMOUNT :'*':Y.NET.OUTSTAND.BAL:'*':Y.TOT.DUE.AMT:'*':Y.PRODUCT:'*':Y.AA.ID.PR

        REPEAT
    REPEAT
RETURN
RETURN
END
END