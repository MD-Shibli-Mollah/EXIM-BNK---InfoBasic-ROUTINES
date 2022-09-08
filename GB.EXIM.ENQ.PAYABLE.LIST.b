* @ValidationCode : MjoxNjkzNDY2MjEyOkNwMTI1MjoxNTg1NDc2Mjk4NTE2OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2020 16:04:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ENQ.PAYABLE.LIST(Y.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING AA.PaymentSchedule
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Account
    $USING AA.Interest
    $USING EB.LocalReferences
    $USING AC.AccountOpening
    $USING AA.ChangeProduct

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
INIT:
    LOCATE 'BRANCH.ID' IN D.FIELDS<1> SETTING BR.ID.POS ELSE
    END
    LOCATE 'DATE.ID' IN D.FIELDS<1> SETTING DATE.ID.POS ELSE
    END
    Y.BR.ID = ENQ.SELECTION<4,BR.ID.POS>
    Y.DATE = ENQ.SELECTION<4,DATE.ID.POS>
    Y.DT.LEN = LEN(Y.DATE)
    IF Y.DT.LEN GT 8 THEN
        Y.DATE.1 = Y.DATE[1,8]
        Y.DATE.2 = Y.DATE[10,8]
    END ELSE
        Y.DATE.3 = Y.DATE
    END
    FN.AC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AC.DETAILS = ''
    
    FN.AA.BILL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DET = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AC.DETAILS, F.AC.DETAILS)
    EB.DataAccess.Opf(FN.AA.BILL.DET, F.AA.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR, F.AA.ARR)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
RETURN

PROCESS:
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.FILED.NAME = 'LT.SPCL.INSTRC'
    Y.FIELD.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.FILED.NAME,Y.FIELD.POS)
    SEL.CMD = 'SELECT ':FN.AA.BILL.DET:' WITH PAYMENT.METHOD EQ PAY AND PAYMENT.TYPE EQ INTEREST AND OS.PROP.AMOUNT GT 0'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
    SEL.LIST = SORT(SEL.LIST)
    LOOP
        REMOVE Y.BIL.ID FROM SEL.LIST SETTING POS
    WHILE Y.BIL.ID:POS
        
        EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BIL.ID, REC.BILL, F.AA.BILL.DET, Er)
        Y.ARR.ID = REC.BILL<AA.PaymentSchedule.BillDetails.BdArrangementId>
        Y.PROPERTY = REC.BILL<AA.PaymentSchedule.BillDetails.BdProperty>
        Y.ORG.AMT = REC.BILL<AA.PaymentSchedule.BillDetails.BdOrPropAmount>
        Y.OS.AMT = REC.BILL<AA.PaymentSchedule.BillDetails.BdOsPropAmount>
        Y.REPAY.AMT = REC.BILL<AA.PaymentSchedule.BillDetails.BdRepayAmount>
        Y.PAY.DATE = REC.BILL<AA.PaymentSchedule.BillDetails.BdPaymentDate>
        EB.DataAccess.FRead(FN.AA.ARR, Y.ARR.ID, REC.ARR, F.AA.ARR, Er)
        Y.ACC.NO = REC.ARR<AA.Framework.Arrangement.ArrLinkedApplId>
        Y.COM = REC.ARR<AA.Framework.Arrangement.ArrCoCode>
        EB.DataAccess.FRead(FN.ACC, Y.ACC.NO, REC.ACC, F.ACC, Er)
        Y.ACC.TITLE = REC.ACC<AC.AccountOpening.Account.AccountTitleOne>
        PROP.CLASS.1 = 'ACCOUNT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
        R.ACC.REC = RAISE(RETURN.VALUES.1)
        Y.SPECIAL.INS.VAL = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.FIELD.POS>
        
        IF Y.DATE.3 NE '' THEN
            GOSUB DATE.SINGLE
        END
        ELSE
            GOSUB DATE.DOUBLE
        END
        
    REPEAT
RETURN
DATE.SINGLE:
    IF Y.BR.ID EQ '' AND Y.PAY.DATE LE Y.DATE.3 THEN
        Y.DATA<-1> = Y.COM:'*':Y.ACC.NO:'*':Y.ACC.TITLE:'*':Y.PROPERTY:'*':Y.ORG.AMT:'*':Y.OS.AMT:'*':Y.REPAY.AMT:'*':Y.PAY.DATE:'*':Y.SPECIAL.INS.VAL
*                      1           2             3              4                 5           6             7            8               9
    END
    ELSE
        IF Y.BR.ID EQ Y.COM AND Y.PAY.DATE LE Y.DATE.3 THEN
            Y.DATA<-1> = Y.COM:'*':Y.ACC.NO:'*':Y.ACC.TITLE:'*':Y.PROPERTY:'*':Y.ORG.AMT:'*':Y.OS.AMT:'*':Y.REPAY.AMT:'*':Y.PAY.DATE:'*':Y.SPECIAL.INS.VAL
*                          1           2             3              4                 5           6             7            8               9
        END
    END
RETURN
DATE.DOUBLE:
    IF Y.BR.ID EQ '' THEN
        IF Y.PAY.DATE GE Y.DATE.1 AND Y.PAY.DATE LE Y.DATE.2 THEN
            Y.DATA<-1> = Y.COM:'*':Y.ACC.NO:'*':Y.ACC.TITLE:'*':Y.PROPERTY:'*':Y.ORG.AMT:'*':Y.OS.AMT:'*':Y.REPAY.AMT:'*':Y.PAY.DATE:'*':Y.SPECIAL.INS.VAL
*                          1           2             3              4                 5           6             7            8               9
        END
    END
    ELSE
        IF Y.BR.ID EQ Y.COM THEN
            IF Y.PAY.DATE GE Y.DATE.1 AND Y.PAY.DATE LE Y.DATE.2 THEN
                Y.DATA<-1> = Y.COM:'*':Y.ACC.NO:'*':Y.ACC.TITLE:'*':Y.PROPERTY:'*':Y.ORG.AMT:'*':Y.OS.AMT:'*':Y.REPAY.AMT:'*':Y.PAY.DATE:'*':Y.SPECIAL.INS.VAL
*                              1           2             3              4                 5           6             7            8               9
            END
        END
    END
RETURN

END