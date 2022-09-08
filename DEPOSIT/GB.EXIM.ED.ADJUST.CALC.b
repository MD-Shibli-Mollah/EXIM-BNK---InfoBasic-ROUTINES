* @ValidationCode : MjoxMTAzNzMxMTMzOkNwMTI1MjoxNTgzNjY3MTcyODYyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 08 Mar 2020 17:32:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ED.ADJUST.CALC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING FT.Contract
    $USING AC.API
    $USING AC.AccountOpening
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING RE.ConBalanceUpdates
    $USING EB.Foundation
    $USING AA.Settlement
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getToday()[5,2] NE '01' THEN RETURN
    IF c_aalocCurrActivity EQ 'DEPOSITS-SETTLE-SETTLEMENT' AND c_aalocCurrActivity<AA.Framework.ArrangementActivity.ArrActRecordStatus> EQ '' THEN
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
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    ArrangementId = c_aalocArrId
    accountId = c_aalocLinkedAccount
    Y.CCY = c_aalocArrCurrency
    Y.PROPERTY = 'EDFEE'
RETURN


**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.AC,F.AC)
RETURN

********
PROCESS:
********
    EB.DataAccess.FRead(FN.AA.ARR,ArrangementId,R.AA.ARR,F.AA.ARR,ER.AA.ARR)
    Y.REC.STATUS = R.AA.ARR<AA.Framework.Arrangement.ArrArrStatus>
    IF Y.REC.STATUS NE 'CURRENT' THEN
        RETURN
    END
    
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementId,'SETTLEMENT',PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.DEBIT.AC = R.REC<AA.Settlement.Settlement.SetPayinAccount>
    EB.DataAccess.FRead(FN.AC,Y.DEBIT.AC,R.AC,F.AC,ER.ACC)
    Y.W.BALANCE = R.AC<AC.AccountOpening.Account.WorkingBalance>
    Y.WORKING.BALANCE = ABS(Y.W.BALANCE)
    Y.BD.CHG.ID = ArrangementId:'-':Y.PROPERTY
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    Y.DUE.AMT = R.BD.CHG<BD.CHG.DUE.AMT>
    
    IF Y.WORKING.BALANCE GE Y.DUE.AMT AND (Y.DUE.AMT NE '' AND Y.DUE.AMT GT 0 ) THEN
        GOSUB OFS.STRING
        GOSUB OFS.PROCESS
        GOSUB WRITE.BD.CHG
    END
RETURN

***********
OFS.STRING:
***********
    Y.VERSION = 'FUNDS.TRANSFER,AA.ACDF'
    Y.FT.ID = ''
    Y.OFS.STR := 'CREDIT.ACCT.NO::=':accountId
    Y.OFS.STR := ',CREDIT.VALUE.DATE::=':EB.SystemTables.getToday()
    Y.OFS.STR := ',CREDIT.CURRENCY::=':Y.CCY
    Y.OFS.STR := ',CREDIT.AMOUNT::=':Y.DUE.AMT
    Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.AC
    Y.OFS.STR := ',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
    
    Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':EB.SystemTables.getIdCompany():',':Y.FT.ID:',':Y.OFS.STR
RETURN

***********
OFS.PROCESS:
***********
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
