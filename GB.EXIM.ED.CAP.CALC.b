* @ValidationCode : MjotNjI2OTA4ODpDcDEyNTI6MTU3NzM2NTg4NDI1NDp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 26 Dec 2019 19:11:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ED.CAP.CALC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.CHG.INFORMATION
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING FT.Contract
    $USING AC.API
    $USING AC.AccountOpening
    $USING AA.TermAmount
    $USING EB.Interface
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    IF c_aalocCurrActivity EQ 'DEPOSITS-CAPITALISE-SCHEDULE' AND c_aalocCurrActivity<AA.Framework.ArrangementActivity.ArrActRecordStatus> EQ 'INAU' THEN
        RETURN
    END
    IF c_aalocCurrActivity EQ 'DEPOSITS-CAPITALISE-SCHEDULE' AND c_aalocCurrActivity<AA.Framework.ArrangementActivity.ArrActRecordStatus> EQ '' THEN
        GOSUB INIT
        GOSUB OPENFILES
        GOSUB PROCESS
    END
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    ArrangementId = c_aalocArrId
    accountId = c_aalocLinkedAccount
    Y.CURRENCY = c_aalocArrCurrency
    Y.PROPERTY = 'EDFEE'
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
RETURN

********
PROCESS:
********
    Y.BD.CHG.ID = ArrangementId:'-':Y.PROPERTY
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    Y.DUE.AMT = R.BD.CHG<BD.CHG.DUE.AMT>
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementId,'TERM.AMOUNT',PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.COMMIT.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
    
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    BaseBalance = 'CURACCOUNT'
    PaymentDate = EB.SystemTables.getToday()
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails, ErrorMessage)
    CurAcBalance = BalDetails<4>
    
    IF (CurAcBalance - Y.COMMIT.AMT) GE Y.DUE.AMT AND Y.DUE.AMT NE '' AND Y.DUE.AMT NE 0 THEN
        GOSUB OFS.STRING
        GOSUB OFS.PROCESS
        GOSUB WRITE.BD.CHG
    END
    
RETURN

***********
OFS.STRING:
***********
    Y.VERSION = 'FUNDS.TRANSFER,ED.APPLY'
    Y.FT.ID = ''
    Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
    Y.OFS.STR := ',DEBIT.ACCT.NO::=':accountId
    Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.CURRENCY
    Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DUE.AMT
    Y.OFS.STR := ',CREDIT.ACCT.NO::=':'BDT1624800010999'
    Y.OFS.STR := ',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
    Y.OFS.STR := ',ORDERING.BANK::=':'EXIM'
    Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':EB.SystemTables.getIdCompany():',':Y.FT.ID:',':Y.OFS.STR
RETURN

************
OFS.PROCESS:
************
    OFS.SOURCE = 'EXIM.OFS.ENT'
    OFS.MSG.ID = ''
    OPTIONS = ''
    EB.Interface.OfsPostMessage(Y.MESSAGE, OFS.MSG.ID, OFS.SOURCE, OPTIONS)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN

************
WRITE.BD.CHG:
************
    R.BD.CHG<BD.CHG.DUE.AMT> = ''
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate('')
RETURN

END
