* @ValidationCode : MjotMTczNDgyOTI3MzpDcDEyNTI6MTU3ODM3ODgwMDY2MTp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Jan 2020 12:33:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.IS.GET.DEFAULT.DATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AA.Framework
    IF EB.SystemTables.getComi() EQ '' THEN
        EB.SystemTables.setComi(EB.SystemTables.getToday())
    END
RETURN
END
