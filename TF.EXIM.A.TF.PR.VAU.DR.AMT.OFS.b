* @ValidationCode : MjoyNzU5NzM1NDQ6Q3AxMjUyOjE1NzE5MTkzODQzMTA6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Oct 2019 18:16:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.A.TF.PR.VAU.DR.AMT.OFS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING ST.CurrencyConfig
    $USING LC.Contract
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING AC.API
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING FT.Contract

*IF EB.SystemTables.getVFunction() NE 'A' THEN RETURN

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*****
INIT:
*****
    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    FN.CURR = "F.CURRENCY"
    F.CURR = ""
    FN.DRAWINGS = "F.DRAWINGS"
    F.DRAWINGS = ""
    FN.DRAWINGS = "F.DRAWINGS"
    F.DRAWINGS = ""
    Y.FT.OFS.VERSION = 'FUNDS.TRANSFER,BD.BTB.SETTLE'
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.ACCOUNT, F.ACCOUNT)
    EB.DataAccess.Opf(FN.CURR, F.CURR)
    EB.DataAccess.Opf(FN.DRAWINGS, F.DRAWINGS)
RETURN

********
PROCESS:
********
* to get Document Amout
    YR.DOC.AMT = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDocumentAmount)
    EB.Foundation.MapLocalFields('DRAWINGS', 'LT.TF.PRF.AMT', LT.TF.PRF.AMT.POS)
    EB.Foundation.MapLocalFields('DRAWINGS', 'LT.TF.FCY.CHG', LT.TF.FCY.CHG.POS)
    EB.Foundation.MapLocalFields('FUNDS.TRANSFER', 'LT.FT.DR.REFNO', LT.FT.DR.REFNO.POS)

* to get total profit amount in FC
    Y.DR.LF = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrLocalRef)
    YR.NET.AMT = Y.DR.LF<1, LT.TF.PRF.AMT.POS>
    YR.FCY.CHG = Y.DR.LF<1,LT.TF.FCY.CHG.POS>
* to get Dcument Currency, Drawing Type & Document Aceptance Date
    Y.CCY = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawCurrency)
    Y.DR.TYPE = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawingType)
    Y.VALUE.DATE = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrValueDate)
    
*-------------FOR CREDIT(PAYMENT A/C)----------
    YR.ACCT.CR = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrPaymentAccount)
    EB.DataAccess.FRead(FN.ACCOUNT, YR.ACCT.CR, R.CR.ACCOUNT, F.ACCOUNT, Y.ERROR)
    YR.CR.CCY = R.CR.ACCOUNT<AC.AccountOpening.Account.Currency>
    YR.CR.CCY.MKT = R.CR.ACCOUNT<AC.AccountOpening.Account.CurrencyMarket>
 
*-------------FOR DEBIT(DRAW DOWN A/C)----------
    YR.ACCT.DR = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawdownAccount)
    EB.DataAccess.FRead(FN.ACCOUNT, YR.ACCT.DR, R.DR.ACCOUNT, F.ACCOUNT, Y.ERROR)
    YR.DR.CCY = R.DR.ACCOUNT<AC.AccountOpening.Account.Currency>
    YR.DR.CCY.MKT = R.DR.ACCOUNT<AC.AccountOpening.Account.CurrencyMarket>

    Y.CONV.RATE = ''
    Y.SPREAD = ''
    Y.BILL.CCY = Y.CCY
    Y.CR.CCY = YR.CR.CCY
    Y.DR.CCY = YR.DR.CCY
    CALL TF.EXIM.I.DR.EXRATE.ADAMT(Y.BILL.CCY,Y.DR.TYPE,Y.CR.CCY,Y.DR.CCY,Y.CONV.RATE,Y.SPREAD)
    YR.CR.RATE = Y.CONV.RATE
*---------------Edited by Shafiul-----------------------
    IF Y.CCY NE LCCY THEN
        YR.TOTAL.CHG.FCY =  YR.NET.AMT + YR.FCY.CHG
    END
*------------CUSTOMER A/C TO NOSTRO A/C-----------------
    IF YR.NET.AMT OR YR.FCY.CHG THEN
        R.REC<FT.Contract.FundsTransfer.TransactionType> = 'AC'
        R.REC<FT.Contract.FundsTransfer.CreditAcctNo> = YR.ACCT.CR
        R.REC<FT.Contract.FundsTransfer.CurrencyMktCr> = YR.CR.CCY.MKT
        R.REC<FT.Contract.FundsTransfer.CreditAmount> = YR.TOTAL.CHG.FCY
        R.REC<FT.Contract.FundsTransfer.CreditCurrency> = YR.CR.CCY
        R.REC<FT.Contract.FundsTransfer.TreasuryRate> = YR.CR.RATE
        R.REC<FT.Contract.FundsTransfer.DebitAcctNo> = YR.ACCT.DR     ;*Customer account
        R.REC<FT.Contract.FundsTransfer.DebitCurrency> = YR.DR.CCY
        R.REC<FT.Contract.FundsTransfer.LocalRef,LT.FT.DR.REFNO.POS>=EB.SystemTables.getIdNew()
        R.REC<FT.Contract.FundsTransfer.OrderingBank> = 'EXIM'
        GOSUB OFS.PROCESS
    END
        
RETURN
************
OFS.PROCESS:
************
    EB.Foundation.OfsBuildRecord('FUNDS.TRANSFER','I','PROCESS',Y.FT.OFS.VERSION,'',0,TRANSACTION.ID,R.REC,Y.OFS.RECORD)
    CALL ofs.addLocalRequest(Y.OFS.RECORD,'APPEND',Y.ERR.OFS)
    
RETURN
END
