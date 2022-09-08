* @ValidationCode : MjotOTA1MTcwNDE6Q3AxMjUyOjE1NzIzMjY2OTI1OTI6TUVIRURJOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 29 Oct 2019 11:24:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.A.FT.UPDT.TO.DR
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $USING LC.Contract
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Contract
    $USING EB.Updates
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.DRAW = 'FBNK.DRAWINGS'
    F.DRAW = ''
    FN.FT = 'FBNK.FUNDS.TRANSFER'
    F.FT = ''
RETURN
**********
OPENFILES:
**********
    APPLICATION.NAMES = 'DRAWINGS':FM:'FUNDS.TRANSFER'
    LOCAL.FIELDS = 'LT.FT.REF.NO':FM:'LT.FT.DR.REFNO'
    EB.Updates.MultiGetLocRef(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
    Y.FT.REF.NO.POS = FLD.POS<1,1>
    Y.FT.DR.REFNO.POS = FLD.POS<2,1>
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.DRAW,F.DRAW)
RETURN
********
PROCESS:
********
    Y.FT.ID = EB.SystemTables.getIdNew()
    EB.DataAccess.FRead(FN.FT,Y.FT.ID,R.FT,F.FT,FT.ERR)
    Y.FT.LOC.FLD.VAL = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    Y.DR.ID = Y.FT.LOC.FLD.VAL<1,Y.FT.DR.REFNO.POS>
    EB.DataAccess.FRead(FN.DRAW,Y.DR.ID,DR.REC,F.DRAW,E.DR)
    DR.REC<LC.Contract.Drawings.TfDrLocalRef,Y.FT.REF.NO.POS> = Y.FT.ID
    WRITE DR.REC ON F.DRAW,Y.DR.ID
RETURN
END
