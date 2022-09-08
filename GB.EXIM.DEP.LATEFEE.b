* @ValidationCode : MjoxMzUxNzM3MTM2OkNwMTI1MjoxNTg3NTM5MjgwMjYyOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Apr 2020 13:08:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
* @AUTHOR         : MD SHIBLI MOLLAH

SUBROUTINE GB.EXIM.DEP.LATEFEE(Y.DATA)
*PROGRAM GB.EXIM.DEP.LATEFEE
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
    $USING ST.CompanyCreation

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
INIT:
*
    ST.CompanyCreation.LoadCompany('BNK')
    
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
*
    SEL.CMD = 'SELECT ':FN.AA.BILL.DET:' WITH PROPERTY EQ LPCFEE WITH BILL.STATUS EQ DUE WITH SETTLE.STATUS EQ UNPAID'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
*
    SEL.LIST = SORT(SEL.LIST)
    LOOP
        REMOVE Y.BIL.ID FROM SEL.LIST SETTING POS
    WHILE Y.BIL.ID:POS
    
        EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BIL.ID, REC.BILL, F.AA.BILL.DET, Er)
        Y.ARR.ID = REC.BILL<AA.PaymentSchedule.BillDetails.BdArrangementId>
        Y.DEBIT.VALUE.DATE = REC.BILL<AA.PaymentSchedule.BillDetails.BdBillDate>
        Y.DEBIT.AMOUNT = REC.BILL<AA.PaymentSchedule.BillDetails.BdOsTotalAmount>
        
        EB.DataAccess.FRead(FN.AA.ARR, Y.ARR.ID, REC.ARR, F.AA.ARR, Er)
        Y.DEBIT.ACCT.NO = REC.ARR<AA.Framework.Arrangement.ArrLinkedApplId>
       
*        EB.DataAccess.FRead(FN.ACC, Y.ACC.NO, REC.ACC, F.ACC, Er)
*        Y.ACC.TITLE = REC.ACC<AC.AccountOpening.Account.AccountTitleOne>
************-------------Property Read-----------------------****************
        PROP.CLASS.1 = 'ACCOUNT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
        R.ACC.REC = RAISE(RETURN.VALUES.1)
*
       
        Y.CREDIT.ACCT.NO = ''
        Y.CREDIT.THEIR.REF = ''
************-------------DATE CONVERSION-----------------------****************
        Y.DEBIT.VALUE.DATE = ICONV(Y.DEBIT.VALUE.DATE,'D4')
        Y.DEBIT.VALUE.DATE = OCONV(Y.DEBIT.VALUE.DATE,'D')
*
        Y.DATA<-1> = Y.ARR.ID:'*':Y.DEBIT.ACCT.NO:'*':Y.DEBIT.AMOUNT:'*':Y.DEBIT.VALUE.DATE:'*':Y.CREDIT.ACCT.NO:'*':Y.CREDIT.THEIR.REF
*                       1                2                  3                   4                       5                   6
    REPEAT
RETURN
END