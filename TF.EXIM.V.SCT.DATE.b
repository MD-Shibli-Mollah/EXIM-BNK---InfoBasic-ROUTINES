* @ValidationCode : Mjo0OTAzNzA1MTE6Q3AxMjUyOjE1NzE3MzUzMTU1OTU6TUVIRURJOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:08:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.V.SCT.DATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.SCT.CAPTURE
*
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.BD.SCT.CAP = 'FBNK.BD.SCT.CAPTURE'
    F.BD.SCT.CAP  = ''
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.BD.SCT.CAP, F.BD.SCT.CAP)
RETURN
*---------
PROCESS:
*---------
    Y.CONT.DT = EB.SystemTables.getRNew(SCT.CONTRACT.DATE)
    Y.SHIP.DT = EB.SystemTables.getRNew(SCT.SHIPMENT.DATE)
    Y.EXP.DT = EB.SystemTables.getRNew(SCT.EXPIRY.DATE)
    BEGIN CASE
        CASE Y.CONT.DT GE Y.SHIP.DT AND Y.SHIP.DT NE ''
            EB.SystemTables.setEtext('Contract date must be less then Shipment date')
            EB.ErrorProcessing.StoreEndError()
            Y.CONT.DT = ''
            Y.SHIP.DT = ''
            RETURN
        CASE Y.SHIP.DT GE Y.EXP.DT AND Y.EXP.DT NE ''
            EB.SystemTables.setEtext('Shipment date must be less then Expiry date')
            EB.ErrorProcessing.StoreEndError()
            Y.SHIP.DT = ''
            Y.EXP.DT = ''
            RETURN
    END CASE
RETURN
END
