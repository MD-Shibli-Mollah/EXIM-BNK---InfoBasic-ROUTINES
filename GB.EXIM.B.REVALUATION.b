* @ValidationCode : MjotMTE0NDIwMTA4MTpDcDEyNTI6MTU3ODU2OTMzMTM4MTpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Jan 2020 17:28:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVALUATION(Y.CURRENCY)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CURRENCY
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    $INSERT I_F.GB.EXIM.B.REVALUATION.COMMON
    $INSERT I_BATCH.FILES
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Interface
    $USING ST.CurrencyConfig
    $USING AC.AccountOpening
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------

    Y.AC.ID = Y.CURRENCY:'12800...'
    SEL.AC.ID = "SELECT ":FN.AC:" WITH ":"@ID LIKE ":Y.AC.ID :" AND ONLINE.ACTUAL.BAL NE 0"
    EB.DataAccess.Readlist(SEL.AC.ID,SEL.AC.LIST,'',NO.OF.AC.REC,RET.AC.CODE)
    IF NO.OF.AC.REC GT 0 THEN
        EB.DataAccess.FRead(FN.CURR,Y.CURRENCY,R.CURRENCY,F.CURR,CURRENCY.ERR)
        Y.MID.RATE = R.CURRENCY<EB.CUR.MID.REVAL.RATE,1>

        LOOP
            REMOVE Y.ACCOUNT.ID FROM SEL.AC.LIST SETTING POS
        WHILE Y.ACCOUNT.ID:POS
            EB.DataAccess.FRead(FN.AC,Y.ACCOUNT.ID,R.ACCOUNT,F.AC,ACCOUNT.ERR)
            Y.AC.ONLINE.ACTUAL.BALANCE = R.ACCOUNT<AC.AccountOpening.Account.OnlineActualBal>
            Y.CO.CODE = R.ACCOUNT<AC.AccountOpening.Account.CoCode>
            Y.ORDERING.CUST = 'EXIM'
            Y.CREDIT.VALUE.DATE = EB.SystemTables.getToday()
            Y.DEBIT.VALUE.DATE = EB.SystemTables.getToday()
            Y.TREASURY.RATE =  Y.MID.RATE
            OFS.SOURCE = 'EXIM.OFS.ENT'
            Y.OFS.MSG.ID = ''
            Y.VERSION = 'FUNDS.TRANSFER,FCY.GL.AC.NULLIFYING'
            Y.FT.ID = ''

            IF Y.AC.ONLINE.ACTUAL.BALANCE GT 0 THEN
                Y.DEBIT.ACCT.NO = Y.ACCOUNT.ID
                Y.DEBIT.CURRENCY = Y.CURRENCY
                Y.DEBIT.AMOUNT = Y.AC.ONLINE.ACTUAL.BALANCE
                Y.CREDIT.ACCT.NO = 'BDT':Y.ACCOUNT.ID[4,13]
                Y.CREDIT.CURRENCY = 'BDT'

                Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
                Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
                Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.DEBIT.CURRENCY
                Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
                Y.OFS.STR :=',DEBIT.VALUE.DATE::=':Y.DEBIT.VALUE.DATE
                Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
                Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.CREDIT.CURRENCY
                Y.OFS.STR := ',CREDIT.VALUE.DATE::=':Y.CREDIT.VALUE.DATE
                Y.OFS.STR :=",TREASURY.RATE::=":Y.TREASURY.RATE
                Y.OFS.STR :=",IN.SWIFT.MSG::=":Y.CO.CODE
                Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
                Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.CO.CODE:',':Y.FT.ID:',':Y.OFS.STR
                
                EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
                EB.TransactionControl.JournalUpdate(Y.FT.ID)
            END
            IF Y.AC.ONLINE.ACTUAL.BALANCE LT 0 THEN
                
                IF Y.AC.ONLINE.ACTUAL.BALANCE EQ '' THEN RETURN
                
                Y.AC.ONLINE.ACTUAL.BALANCE = ABS (Y.AC.ONLINE.ACTUAL.BALANCE)
                Y.DEBIT.ACCT.NO = 'BDT':Y.ACCOUNT.ID[4,13]
                Y.DEBIT.CURRENCY = 'BDT'
                Y.CREDIT.ACCT.NO = Y.ACCOUNT.ID
                Y.CREDIT.CURRENCY = Y.CURRENCY
                Y.CREDIT.AMOUNT = Y.AC.ONLINE.ACTUAL.BALANCE

                Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
                Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
                Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.DEBIT.CURRENCY
                Y.OFS.STR :=',DEBIT.VALUE.DATE::=':Y.DEBIT.VALUE.DATE
                Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
                Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.CREDIT.CURRENCY
                Y.OFS.STR :=',CREDIT.AMOUNT::=':Y.CREDIT.AMOUNT
                Y.OFS.STR := ',CREDIT.VALUE.DATE::=':Y.CREDIT.VALUE.DATE
                Y.OFS.STR :=",TREASURY.RATE::=":Y.TREASURY.RATE
                Y.OFS.STR :=",IN.SWIFT.MSG::=":Y.CO.CODE
                Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
                Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.CO.CODE:',':Y.FT.ID:',':Y.OFS.STR
          
                EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
                EB.TransactionControl.JournalUpdate(Y.FT.ID)
            END
        REPEAT
    END
RETURN
END