* @ValidationCode : MjoxMjE2NzU0MzEzOkNwMTI1MjoxNTg2NzcxMDQwNjg2OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2020 15:44:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE AFTER.UNAUTH.RTN
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT  I_COMMON
    $INSERT  I_EQUATE
    
    
    $USING FT.Contract
    $USING EB.SystemTables
    
    EB.SystemTables.getApplication()
    EB.SystemTables.getPgmVersion()
    
    IF EB.SystemTables.getApplication() = "FUNDS.TRANSFER" AND EB.SystemTables.getPgmVersion() = ",MBL.AA.ACDF.ED" AND EB.SystemTables.getVFunction() =    'I' THEN
        INPUT.BUFFER = C.U:" ":EB.SystemTables.getApplication():EB.SystemTables.getPgmVersion():" I ":C.F
    END
RETURN
END


END
