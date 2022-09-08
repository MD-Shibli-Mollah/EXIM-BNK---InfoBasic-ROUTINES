* @ValidationCode : MjoxMjI2MjIzODUwOkNwMTI1MjoxNTgxNDkyODA5OTk4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Feb 2020 13:33:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.RETAIL.SETTLE(Y.AA.ID)
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
    $INSERT I_BATCH.FILES
    $INSERT I_GTS.COMMON
    $INSERT I_F.GB.EXIM.B.ED.RETAIL.SETTLE.COMMON
    $INSERT I_F.BD.CHG.INFORMATION
    
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    GOSUB PROCESS
RETURN

********
PROCESS:
********
    Y.BD.CHG.ID = Y.AA.ID:'-':'EDFEE'
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,E.BD.RR)
    Y.DUE.AMOUNT = R.BD.CHG<BD.CHG.DUE.AMT>
    IF Y.DUE.AMOUNT EQ '' OR Y.DUE.AMOUNT EQ 0 THEN RETURN
    Y.COMPANY = R.BD.CHG<BD.CHG.CO.CODE>
    AA.Framework.GetArrangementAccountId(Y.AA.ID,accountId,Currency,ReturnError)   ;*To get Arrangement Account
    AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    WORKING.BALANCE =  AC.REC<AC.AccountOpening.Account.WorkingBalance>
    Y.CURRENCY =  AC.REC<AC.AccountOpening.Account.Currency>
    R.BD.CHG<BD.CHG.AVG.BAL.AMT> = WORKING.BALANCE
    IF  WORKING.BALANCE GT 0 THEN
        IF WORKING.BALANCE GE Y.DUE.AMOUNT THEN
            R.BD.CHG<BD.CHG.REALIZE.AMT> = R.BD.CHG<BD.CHG.REALIZE.AMT> + Y.DUE.AMOUNT
            R.BD.CHG<BD.CHG.DUE.AMT> = 0
            CHARGE.AMOUNT = Y.DUE.AMOUNT
        END
        GOSUB OFS.PROCESS
        EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    END
RETURN

************
OFS.PROCESS:
************
    GOSUB OFS.STRING
    OFS.SOURCE = 'EXIM.OFS.ENT'
    OFS.MSG.ID = ''
    Y.FT.ID = ''
    OFS.MSG = 'FUNDS.TRANSFER,ED.RETAIL':'/I/PROCESS,//':Y.COMPANY:',':Y.FT.ID:',':Y.OFS.STR
    EB.Interface.OfsPostMessage(OFS.MSG, OFS.MSG.ID, OFS.SOURCE, OPTIONS)
    EB.TransactionControl.JournalUpdate('')
RETURN

***********
OFS.STRING:
***********
    Y.ORDERING.BANK = 'EXIM'
    Y.CR.ACC.N0 = 'BDT1280000010999'
    Y.OFS.STR = ''
    Y.OFS.STR = 'TRANSACTION.TYPE::=AC':','
    Y.OFS.STR := 'DEBIT.CURRENCY::=':Y.CURRENCY:','
    Y.OFS.STR := 'DEBIT.ACCT.NO::=':accountId:','
    Y.OFS.STR := 'DEBIT.AMOUNT::=':Y.DUE.AMOUNT:','
    Y.OFS.STR := 'DEBIT.VALUE.DATE::=':EB.SystemTables.getToday():','
    Y.OFS.STR := 'CREDIT.ACCT.NO::=':Y.CR.ACC.N0:','
    Y.OFS.STR := 'CREDIT.VALUE.DATE::=':EB.SystemTables.getToday():','
    Y.OFS.STR := 'ORDERING.BANK:1:1=':Y.ORDERING.BANK
RETURN

END
