* @ValidationCode : MjotMTE2NTQ3NTM5OTpDcDEyNTI6MTU4ODA2OTc3MDExNzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 28 Apr 2020 16:29:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.E.NOF.GR.LIAB.SUM.POS(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING AA.Framework
    $USING LI.Config
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING AA.Interest
*-----------------------------------------------------------------------------
 
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*****
INIT:
*****
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.BILL = 'F.AA.BILL.DETAILS'
    F.BILL = ''
RETURN
*-----------------------------------------------------------------------------
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.BILL,F.BILL)
    
    Y.DISBURSEMENT = 0
    Y.PRIN.OUTSTAND = 0
    Y.TOT.PRIN.OUTSTAND = 0
    Y.PRFT.OUTSTAND = 0
    Y.TOT.PFT.OUTSTAND = 0
    Y.TOT.OUTSTAND = 0
    Y.PFT.CHARGE = 0
    Y.PRIN.REC.AMT = 0
    Y.PFT.REC.AMT = 0
    Y.PATDUE.AMT = 0
    
RETURN

*-----------------------------------------------------------------------------
********
PROCESS:
********
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING Y.CUST.NO.POS THEN
        Y.CUSTOMER.OPD = EB.Reports.getEnqSelection()<3,Y.CUST.NO.POS>
        Y.CUSTOMER = EB.Reports.getEnqSelection()<4,Y.CUST.NO.POS>
    END
    EB.DataAccess.FRead(FN.CUS,Y.CUSTOMER,R.CUS,F.CUS,E.CUS)
    Y.CUS.NAME = R.CUS<ST.Customer.Customer.EbCusShortName>
    
    SEL.CMD = 'SELECT ':FN.LI:' WITH @ID LIKE ':Y.CUSTOMER:'...'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, RET.CODE)
    LOOP
        REMOVE Y.LIMIT.ID FROM SEL.LIST SETTING Y.LI.ID.POS
    WHILE Y.LIMIT.ID : Y.LI.ID.POS
        EB.DataAccess.FRead(FN.LI, Y.LIMIT.ID, R.LI, F.LI, E.LI)
        Y.LI.ACCOUNT = R.LI<LI.Config.Limit.Account>
        IF Y.LI.ACCOUNT NE '' THEN
            Y.DCOUNT = DCOUNT(Y.LI.ACCOUNT,VM)
            FOR I = 1 TO Y.DCOUNT
                IF I EQ 1 THEN
                    Y.LIMIT.AMT = R.LI<LI.Config.Limit.InternalAmount>
                END ELSE
                    Y.LIMIT.AMT = ''
                END
                Y.AC.ID = Y.LI.ACCOUNT<1,I>
                EB.DataAccess.FRead(FN.AC, Y.AC.ID, R.AC, F.AC, E.AC)
                Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
                AA.Framework.GetArrangementAccountId(Y.AA.ID, accountId, Currency, ReturnError)   ;*To get Arrangement Account
                EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,E.AA.AC)
                Y.MAT.DATE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
                Y.TOT.BILL.ID = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillId>
                Y.TOT.BL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
                Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
                Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
                CONVERT SM TO VM IN Y.TOT.BILL.ID
                CONVERT SM TO VM IN Y.TOT.BL.TYPE
                CONVERT SM TO VM IN Y.TOT.BL.STATUS
                CONVERT SM TO VM IN Y.TOT.SET.STATUS
                Y.COUNT = DCOUNT(Y.TOT.BILL.ID,VM)
                FOR J = 1 TO Y.COUNT
                    Y.BL.ID = Y.TOT.BILL.ID<1,J>
                    Y.BL.TYPE = Y.TOT.BL.TYPE<1,J>
                    Y.SET.STATUS = Y.TOT.SET.STATUS<1,J>
                    EB.DataAccess.FRead(FN.BILL,Y.BL.ID,R.BILL,F.BILL,E.BILL)
                    Y.FINANCE.DATE = R.BILL<AA.PaymentSchedule.BillDetails.BdFinancialDate>
                    IF Y.SET.STATUS EQ 'REPAID' AND Y.BL.TYPE EQ 'INSTALLMENT' THEN
                        Y.PAY.PROPERTY = R.BILL<AA.PaymentSchedule.BillDetails.BdPayProperty>
                        Y.OR.TOT.AMT = R.BILL<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
                        Y.OR.PR.AMT = R.BILL<AA.PaymentSchedule.BillDetails.BdOrPrAmt>
                        LOCATE 'ACCOUNT' IN Y.PAY.PROPERTY SETTING Y.AC.POS THEN
                            Y.PRIN.REC.AMT += Y.OR.PR.AMT<1,Y.AC.POS>
                        END ELSE
                            Y.PFT.REC.AMT += Y.OR.TOT.AMT - Y.PRIN.REC.AMT
                        END
                    END
                NEXT J
                PROP.CLASS = 'TERM.AMOUNT'
                AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
                R.REC = RAISE(RETURN.VALUES)
                Y.DISBURSEMENT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
                
                BaseBalance = 'CURACCOUNT'
                RequestType<2> = 'ALL'
                RequestType<3> = 'ALL'
                RequestType<4> = 'ECB'
                RequestType<4,2> = 'END'
                Y.SYSTEMDATE = EB.SystemTables.getToday()
                AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                Y.PRIN.OUTSTAND = ABS(BalDetails<4>)
                Y.TOT.PRIN.OUTSTAND = ABS(Y.TOT.PRIN.OUTSTAND + Y.PRIN.OUTSTAND)
                BaseBalance = 'DUEACCOUNT'
                RequestType<2> = 'ALL'
                RequestType<3> = 'ALL'
                RequestType<4> = 'ECB'
                RequestType<4,2> = 'END'
                Y.SYSTEMDATE = EB.SystemTables.getToday()
                AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                Y.PATDUE.AMT = ABS(BalDetails<4>)
                    
                BaseBalance = 'MARKUPPROFIT'
                RequestType<2> = 'ALL'
                RequestType<3> = 'ALL'
                RequestType<4> = 'ECB'
                RequestType<4,2> = 'END'
                Y.SYSTEMDATE = EB.SystemTables.getToday()
                AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                Y.MARKUP.AMT = ABS(BalDetails<4>)
                    
                BaseBalance = 'RECMARKUPPROFIT'
                RequestType<2> = 'ALL'
                RequestType<3> = 'ALL'
                RequestType<4> = 'ECB'
                RequestType<4,2> = 'END'
                Y.SYSTEMDATE = EB.SystemTables.getToday()
                AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                Y.REM.MARKUP.AMT = ABS(BalDetails<4>)
                Y.PFT.CHARGE = ABS(Y.MARKUP.AMT - Y.REM.MARKUP.AMT)
                    
                PROP.CLASS.IN = 'INTEREST'
                AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS.IN,PROPERTY,'',RETURN.IDS,RETURN.VALUES.IN,ERR.MSG)
                R.REC.IN = RAISE(RETURN.VALUES.IN)
                Y.INT.RATE = R.REC.IN<AA.Interest.Interest.IntEffectiveRate>
                Y.TOT.OUTSTAND = ABS(Y.PRIN.OUTSTAND + Y.PRFT.OUTSTAND)
                Y.TOT.PFT.OUTSTAND = ABS(Y.TOT.PFT.OUTSTAND + Y.PRFT.OUTSTAND)
                Y.RETURN<-1> = Y.CUSTOMER:'*':Y.CUS.NAME:'*':Y.AA.ID:'*':Y.LIMIT.ID:'*':Y.LIMIT.AMT:'*':Y.FINANCE.DATE:'*':Y.MAT.DATE:'*':Y.INT.RATE:'*':Y.DISBURSEMENT:'*':Y.PFT.CHARGE:'*':Y.PRIN.REC.AMT:'*':Y.PFT.REC.AMT:'*':Y.PRIN.OUTSTAND:'*':Y.PRFT.OUTSTAND:'*':Y.TOT.OUTSTAND:'*':Y.PATDUE.AMT:'*':Y.TOT.PRIN.OUTSTAND:'*':Y.TOT.PFT.OUTSTAND
*                                        1             2           3              4              5                  6             7               8                9                   10                 11               12                   13                  14                15                   16                  17                   18
            NEXT I
        END
    REPEAT
RETURN
END
