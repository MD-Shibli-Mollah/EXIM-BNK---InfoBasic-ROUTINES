* @ValidationCode : MjoxODAxMTI0NDczOkNwMTI1MjoxNTc0NTczNDk2MTQzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 24 Nov 2019 11:31:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.V.FDBP.DISV.DEF.VAL
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 24/11/2019 -                            New   - Ashna Ahmed
*                                                 FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.Updates
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT
    $USING AA.Account
    $USING LC.Contract
    $USING EB.API
    $USING ST.CurrencyConfig
    $INSERT I_F.CURRENCY
  
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
    
RETURN

******
INIT:
******

    FN.DRAWINGS = 'F.DRAWINGS'
    F.DRAWINGS = ''
    FN.ARR.ACC='F.AA.ARR.ACCOUNT'
    F.ARR.ACC=''
    FN.CURRENCY = 'F.CURRENCY'
    F.CNCY = ''
    
    
    FLD.POS = ''
    APPLICATION.NAMES = 'DRAWINGS':FM:'AA.ARR.ACCOUNT'
    LOCAL.FIELDS = 'LT.TFLD.PUR.ID':FM:'LT.MUSK.AGG.ID':VM:'LINKED.TFDR.REF':VM:'LT.DOC.BILL.VAL':VM:'LT.PUR.PERCT':VM:'LT.PUR.FC.AMT':VM:'LT.EXCHG.RATE'
    EB.Updates.MultiGetLocRef(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
    Y.LT.TFLD.PUR.ID.POS = FLD.POS<1,1>
    Y.LT.MUSK.AGG.ID.POS = FLD.POS<2,1>
    Y.LINKED.TFDR.REF.POS = FLD.POS<2,2>
    Y.LT.DOC.BILL.VAL.POS = FLD.POS<2,3>
    Y.LT.PUR.PERCT.POS = FLD.POS<2,4>
    Y.LT.PUR.FC.AMT.POS = FLD.POS<2,5>
    Y.LT.EXCHG.RATE.POS = FLD.POS<2,6>
RETURN

***********
OPENFILES:
***********

    EB.DataAccess.Opf(FN.DRAWINGS, F.DRAWINGS)
    EB.DataAccess.Opf(FN.ARR.ACC, F.ARR.ACC)
    EB.DataAccess.Opf(FN.CURRENCY, F.CNCY)
RETURN

*********
PROCESS:
*********

    TMP.DATA = EB.SystemTables.getRNew(AA.Account.Account.AcLocalRef)
    Y.DRAWING.ID=TMP.DATA<1,Y.LINKED.TFDR.REF.POS>
*Y.LT.PUR.PERCT=TMP.DATA<1,Y.LT.PUR.PERCT.POS>
               
    EB.DataAccess.FRead(FN.DRAWINGS, Y.DRAWING.ID, REC.DRAWING, F.DRAWINGS, ERR.DRAWINGS)
    Y.DOC.AMOUNT = REC.DRAWING<LC.Contract.Drawings.TfDrDocumentAmount>
    Y.DRAWING.CURRENCY = REC.DRAWING<LC.Contract.Drawings.TfDrDrawCurrency>
    
    EB.API.GetStandardSelectionDets(APPLICATION.NAMES, R.SS)
    Y.FIELD.NAME = 'LOCAL.REF'
    LOCATE Y.FIELD.NAME IN R.SS<AA.Account.Account.AcLocalRef> SETTING Y.POS THEN
    END
    
    CALL AA.GET.ACCOUNT.RECORD(R.PROPERTY.RECORD, PROPERTY.ID)
    TMP.DATA = R.PROPERTY.RECORD<1,Y.POS>
    
    Y.LT.PUR.PERCENT = FIELD(TMP.DATA,SM,Y.LT.PUR.PERCT.POS)
    Y.LT.PUR.FC.AMT = (Y.LT.PUR.PERCENT * Y.DOC.AMOUNT)/100
    

    
    EB.DataAccess.FRead(FN.CURRENCY, Y.DRAWING.CURRENCY, REC.CURRENCY, F.CNCY, ERR.CURRENCY)
    
    Y.CUR.MARKET = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurCurrencyMarket>
    Y.CUR.MARKET.POS = '7'
    FIND Y.CUR.MARKET.POS IN Y.CUR.MARKET SETTING Z.POS1,Z.POS2,Z.POS3 THEN
        Y.MID.RATE = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurMidRevalRate,Z.POS2>
    END
    
    
    
    Y.TEMPA=''
    Y.TEMPA=EB.SystemTables.getRNew(AA.Account.Account.AcLocalRef)
    Y.TEMPA<1,Y.LT.DOC.BILL.VAL.POS> = Y.DOC.AMOUNT
    Y.TEMPA<1,Y.LT.PUR.FC.AMT.POS> = Y.LT.PUR.FC.AMT
    Y.TEMPA<1,Y.LT.EXCHG.RATE.POS> = Y.MID.RATE
    
    EB.SystemTables.setRNew(AA.Account.Account.AcLocalRef,Y.TEMPA)
    
RETURN

END