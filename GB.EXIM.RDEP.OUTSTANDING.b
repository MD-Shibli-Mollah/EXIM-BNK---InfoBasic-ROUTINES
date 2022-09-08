* @ValidationCode : MjoxNjA0MzMyNjg0OkNwMTI1MjoxNTg3NDE0NzQ3ODM4OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2020 02:32:27
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

SUBROUTINE GB.EXIM.RDEP.OUTSTANDING(Y.DATA)
*PROGRAM GB.EXIM.RDEP.OUTSTANDING
*-----------------------------------------------------------------------------
*List of Outstanding RD(RECURRING DEPOSITS) Installments
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
    $USING EB.Reports
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
    LOCATE "AA.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING AA.POS THEN
        Y.AA.ID = EB.Reports.getEnqSelection()<4, AA.POS>
    END
*
*___________ID____________
    IF Y.AA.ID[1,2] NE 'AA' THEN
        EB.DataAccess.FRead(FN.ACCT,Y.AA.ID, REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        IF REC.ACCT.ID EQ '' THEN
            EB.DataAccess.FRead(FN.ALT.ACCT,Y.AA.ID, REC.ALT.ACCT, F.ALT.ACCT, ERR.ALT.ACCT.ID)
            Y.AA.ID = REC.ALT.ACCT<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber>
            EB.DataAccess.FRead(FN.ACCT,Y.AA.ID  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        END
        Y.AA.ID = REC.ACCT.ID<AC.AccountOpening.Account.ArrangementId>
    END
*****------------------END--------------------*****************
*
** Y.AA.ID = 'AA20013SZHY6'

***---------READ AA ACCOUNT DETAILS--------------------------------******
    EB.DataAccess.FRead(FN.AC.DETAILS, Y.AA.ID, R.AA.AC, F.AC.DETAILS, ERR.AC.DETAILS)
    Y.TOT.BILL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.TOT.PAY.METHOD = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdPayMethod>
*
    Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    Y.TOT.BILL.ID = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillId>
    Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
    
    CONVERT SM TO VM IN Y.TOT.BL.STATUS
    CONVERT SM TO VM IN Y.TOT.BILL.ID
    CONVERT SM TO VM IN Y.TOT.SET.STATUS
    Y.DCOUNT = DCOUNT(Y.TOT.BL.STATUS,@VM)
***------LOOP FOR Y.PAY.METHOD EQ 'DUE' AND Y.BILL.TYPE EQ 'EXPECTED' AND Y.SET.STATUS EQ 'UNPAID'---****
    FOR I = 1 TO Y.DCOUNT
        Y.SET.STATUS = Y.TOT.SET.STATUS<1,I>
        Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
        Y.PAY.METHOD = Y.TOT.PAY.METHOD<1,I>
        
        IF Y.PAY.METHOD EQ 'DUE' AND Y.BILL.TYPE EQ 'EXPECTED' AND Y.SET.STATUS EQ 'UNPAID' THEN
            Y.BL.ID = Y.TOT.BILL.ID<1,I>
*
            EB.DataAccess.FRead(FN.AA.BILL.DET,Y.BL.ID, R.BILL, F.AA.BILL.DET, Er)
            Y.BILL.AMT = R.BILL<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
            Y.DEBIT.VALUE.DATE = R.BILL<AA.PaymentSchedule.BillDetails.BdBillDate>
            Y.BL.AA.ID = R.BILL<AA.PaymentSchedule.BillDetails.BdArrangementId>
*
            EB.DataAccess.FRead(FN.AA.ARR, Y.BL.AA.ID, REC.ARR, F.AA.ARR, Er)
            Y.DEBIT.ACCT.NO = REC.ARR<AA.Framework.Arrangement.ArrLinkedApplId>
        END
    NEXT I
***-------------END-----------------------------------********

    Y.DEBIT.AMOUNT = Y.BILL.AMT
    Y.CREDIT.THEIR.REF = ''
************-------------DATE CONVERSION-----------------------****************
    Y.DEBIT.VALUE.DATE = ICONV(Y.DEBIT.VALUE.DATE,'D4')
    Y.DEBIT.VALUE.DATE = OCONV(Y.DEBIT.VALUE.DATE,'D')
*
    Y.DATA<-1> = Y.AA.ID:'*':Y.DEBIT.ACCT.NO:'*':Y.DEBIT.AMOUNT:'*':Y.DEBIT.VALUE.DATE:'*':Y.CREDIT.THEIR.REF
*                       1                2                  3                   4                       5
RETURN
END