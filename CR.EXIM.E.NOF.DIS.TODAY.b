SUBROUTINE CR.EXIM.E.NOF.DIS.TODAY(Y.FINAL)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* Author: (MK, MRT, JH)
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.Updates
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING AA.Settlement
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING AA.PaymentSchedule
    
*ST.CompanyCreation.LoadCompany("BNK")
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*******
INIT:
*******
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.AA.ACCT.DET = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCT.DET = ''
    FN.AA.BILL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DET = ''
RETURN
*******
OPENFILES:
*******
    EB.DataAccess.Opf(FN.AA, F.AA)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.AA.ACCT.DET, F.AA.ACCT.DET)
    EB.DataAccess.Opf(FN.AA.BILL.DET, F.AA.BILL.DET)
RETURN

*******
PROCESS:
*******
    SEL.CMD = 'SELECT ':FN.AA.ACCT.DET
    
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, "", NO.OF.RECORD, RTN.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA, F.AA, ERR.AA)
    
        Y.PROD.LINE = REC.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.PROD.LINE EQ 'LENDING' THEN
            
            Y.PROD.NAM = REC.AA<AA.Framework.Arrangement.ArrProduct>
            Y.ACCT.ID = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
            Y.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
    
            EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, REC.CUS, F.CUS, ERR.CUS)
            Y.CUS.SHORT.NAME = REC.CUS<ST.Customer.Customer.EbCusShortName>
    
            EB.DataAccess.FRead(FN.ACCT, Y.ACCT.ID, REC.ACCT, F.ACCT, ERR.ACCT)
            Y.ACC.WB = REC.ACCT<AC.AccountOpening.Account.WorkingBalance>
        
        
            EB.DataAccess.FRead(FN.AA.ACCT.DET, Y.AA.ID, REC.AA.ACCT.DET, F.AA.ACCT.DET, ERR.AA)
            Y.MAT.DATE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
            Y.TOT.BILL.TYPE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillType>
            Y.TOT.BILL.ID = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillId>
            Y.TOT.PAY.METHOD = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdPayMethod>
        
            Y.BILL.ID = '' ;* HOLD BILL ID WHICH BILL TYPE IS DISBURSEMENT
            Y.TOT.DUE.AMT = 0 ;* HOLD TOTAL DUE AMOUNT
        
********************************************************
* VALUE SEPERATOR FROM AN ARRAY (BEGIN)
********************************************************
            CONVERT SM TO VM IN Y.TOT.BILL.TYPE
            CONVERT SM TO VM IN Y.TOT.BILL.ID
        
            Y.DCOUNT = DCOUNT(Y.TOT.BILL.TYPE,@VM)
        
            FOR I=1 TO Y.DCOUNT
                Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
                IF Y.BILL.TYPE = 'DISBURSEMENT' THEN
                    Y.BILL.ID = Y.TOT.BILL.ID<1,I>
                    BREAK
                END
            NEXT I
**********************************************************
* END
**********************************************************
        
            EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
            Y.FIN.DATE = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdFinancialDate>
            Y.OR.TOT.AMT = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
        
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
        
            Y.AA.PROP.CL = 'INTEREST'
            AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.EFFECT.RATE = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>
    
            Y.AA.PROP.CL = 'SETTLEMENT'
            AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.PAY.IN.ACCT = R.REC.TA<AA.Settlement.Settlement.SetPayinAccount>
            Y.FINAL<-1> = Y.AA.ID : '*' : Y.PROD.NAM : '*' : Y.CUS.ID : '*' : Y.CUS.SHORT.NAME : '*' : Y.FIN.DATE : '*' : Y.MAT.DATE : '*' : Y.EFFECT.RATE : '*' : Y.OR.TOT.AMT : '*' :  Y.ACC.WB : '*' : Y.PAY.IN.ACCT : '*' : Y.TOT.DUE.AMT
        END
    REPEAT
    Y.FINAL = Y.FINAL
RETURN
*-----------------------------------------------------------------------------
END
