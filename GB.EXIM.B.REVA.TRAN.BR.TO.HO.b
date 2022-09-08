* @ValidationCode : Mjo2NTM0MDQxODY6Q3AxMjUyOjE1NzgyMjU3MTI4MDY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 05 Jan 2020 18:01:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVA.TRAN.BR.TO.HO(Y.P.C.L.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.CURRENCY
    $INSERT I_F.CONSOLIDATE.PRFT.LOSS
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    $INSERT I_F.GB.EXIM.B.REVA.TRAN.BR.TO.HO.COMMON
    
    $USING EB.DataAccess
    $USING RE.Consolidation
    $USING EB.Service
    $USING ST.CurrencyConfig
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING EB.Interface
*-----------------------------------------------------------------------------

    EB.DataAccess.FRead(FN.C.P.L,Y.C.P.L.ID,R.C.P.L,F.C.P.L,C.P.L.ERR)
    Y.BALANCE = R.C.P.L<RE.Consolidation.ConsolidatePrftLoss.PtlBalance>
    Y.CURRENCY = R.C.P.L<RE.Consolidation.ConsolidatePrftLoss.PtlCurrency>
    EB.DataAccess.FRead(FN.CURR,Y.CURRENCY,R.CURRENCY,F.CURR,CURRENCY.ERR)
    Y.MID.RATE = R.CURRENCY<ST.CurrencyConfig.Currency.EbCurMidRevalRate,1>
   
    OFS.SOURCE = 'EXIM.OFS.ENT'
    Y.OFS.MSG.ID = ''
    Y.VERSION = 'FUNDS.TRANSFER,FCY.GL.AC.NULLIFYING'
    Y.FT.ID = ''
    IF Y.BALANCE GT 0 THEN
        Y.DEBIT.ACCT.NO = 'PL53000'
        Y.DEBIT.CURRENCY = Y.CURRENCY
        Y.DEBIT.AMOUNT = Y.BALANCE
        Y.CREDIT.ACCT.NO = 'BDT162810001'
        Y.CREDIT.CURRENCY = 'BDT'

        Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
        Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
        Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.DEBIT.CURRENCY
        Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
        Y.OFS.STR :=',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
        Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.CREDIT.CURRENCY
        Y.OFS.STR := ',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR :=",TREASURY.RATE::=":Y.MID.RATE
        Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
        Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':EB.SystemTables.getIdCompany():',':Y.FT.ID:',':Y.OFS.STR
                
        EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
        EB.TransactionControl.JournalUpdate('')
    END
  
    IF Y.BALANCE LT 0 THEN
        Y.DEBIT.ACCT.NO = 'BDT162810001'
        Y.DEBIT.CURRENCY = 'BDT'
        Y.DEBIT.AMOUNT = Y.BALANCE
        Y.CREDIT.ACCT.NO = 'PL53000'
        Y.CREDIT.CURRENCY = Y.CURRENCY

        Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
        Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
        Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.DEBIT.CURRENCY
        Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
        Y.OFS.STR :=',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
        Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.CREDIT.CURRENCY
        Y.OFS.STR := ',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR :=",TREASURY.RATE::=":Y.MID.RATE
        Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
        Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':EB.SystemTables.getIdCompany():',':Y.FT.ID:',':Y.OFS.STR
                
        EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
        EB.TransactionControl.JournalUpdate('')
    END
RETURN
END
