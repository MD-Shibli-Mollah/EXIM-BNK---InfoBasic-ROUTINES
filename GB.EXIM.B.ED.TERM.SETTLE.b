* @ValidationCode : MjotMjM3NjgwOTQ2OkNwMTI1MjoxNTgwNjQzODYzNjk4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 02 Feb 2020 17:44:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.TERM.SETTLE(Y.AA.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.GB.EXIM.B.ED.TERM.SETTLE.COMMON
    
    $USING AA.Framework
    $USING AA.TermAmount
    $USING EB.Service
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.ChargeConfig
    $USING EB.Interface
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------

    GOSUB PROCESS
RETURN

********
PROCESS:
********
    Y.PROPERTY = 'EDFEE'
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
   
    EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,AA.ERR)
    Y.AA.CURRENCY = R.AA<AA.Framework.Arrangement.ArrCurrency>
    Y.AA.COMPANY = R.AA<AA.Framework.Arrangement.ArrCoCode>
    AA.Framework.GetArrangementAccountId(Y.AA.ID,accountId,Currency,ReturnError)
    AA.Framework.GetBaseBalanceList(Y.AA.ID,Y.PROPERTY,ReqdDate,ProductId,BaseBalance)
    BaseBalance = 'CURACCOUNT'
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
    Y.MAX.AMT = MAXIMUM(ABS(BalDetails<4>))

    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)
    Y.CUR.BALANCE = BalDetails<4>
    Y.PROFIT = Y.CUR.BALANCE - Y.TERM.AMT
    Y.FTCT.ID = 'EDCHG'
    EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
    Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
    Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
    CONVERT SM TO VM IN Y.UPTO.AMT
    CONVERT SM TO VM IN Y.MIN.AMT
    Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.AMT = Y.UPTO.AMT<1,I>
        IF Y.MAX.AMT LE Y.AMT THEN
            BREAK
        END
    NEXT I
    CHARGE.AMOUNT = Y.MIN.AMT<1,I>
    PROP.CLASS = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.TERM.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>

    Y.PROFIT = Y.CUR.BALANCE - Y.TERM.AMT
    Y.BD.ID = Y.AA.ID:'-':Y.PROPERTY
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.ID,R.BD.CHG,F.BD.CHG,E.BD.RR)
    Y.DUE.AMOUNT = R.BD.CHG<BD.CHG.DUE.AMT>
    Y.TOTAL.CHG.AMT =  CHARGE.AMOUNT + Y.DUE.AMOUNT
    IF Y.PROFIT GE Y.TOTAL.CHG.AMT AND Y.TOTAL.CHG.AMT NE 0 THEN
        GOSUB OFS.STRING
        GOSUB OFS.PROCESS
        GOSUB WRITE.BD.CHG
    END ELSE
        GOSUB UPDATE.BD.CHG
    END
RETURN

************
OFS.STRING:
************
    Y.VERSION = 'FUNDS.TRANSFER,ED.APPLY'
    Y.FT.ID = ''
    Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
    Y.OFS.STR := ',DEBIT.ACCT.NO::=':accountId
    Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.AA.CURRENCY
    Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.TOTAL.CHG.AMT
    Y.OFS.STR := ',CREDIT.ACCT.NO::=':'BDT1280000010999'
    Y.OFS.STR := ',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
    Y.OFS.STR := ',ORDERING.BANK::=':'EXIM'
    Y.OFS.STR := ',DEBIT.THEIR.REF::=Excise duty'
    Y.OFS.STR := ',CREDIT.THEIR.REF::=Excise duty'
    Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.AA.COMPANY:',':Y.FT.ID:',':Y.OFS.STR
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

*************
WRITE.BD.CHG:
*************
    Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.CHG.TXN.DATE >,@VM) + 1
    R.BD.CHG<BD.CHG.CHG.TXN.DATE ,Y.DCOUNT> = EB.SystemTables.getToday()
    R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = Y.CUR.BALANCE
    R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
    R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
    R.BD.CHG<BD.CHG.DUE.AMT> = ''
    R.BD.CHG<BD.CHG.CO.CODE> = Y.AA.COMPANY
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate('')
RETURN

*************
UPDATE.BD.CHG:
*************
    Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.CHG.TXN.DATE >,@VM) + 1
    R.BD.CHG<BD.CHG.CHG.TXN.DATE ,Y.DCOUNT> = EB.SystemTables.getToday()
    R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = Y.CUR.BALANCE
    R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
    R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
    R.BD.CHG<BD.CHG.DUE.AMT> = R.BD.CHG<BD.CHG.DUE.AMT> + CHARGE.AMOUNT
    R.BD.CHG<BD.CHG.CO.CODE> = Y.AA.COMPANY
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate('')
    
RETURN

END
