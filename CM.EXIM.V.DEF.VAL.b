* @ValidationCode : MjotMTI2MTg1MjI5OkNwMTI1MjoxNTcxMzE4NTU0NjkzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Oct 2019 19:22:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.EXIM.V.DEF.VAL
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    
    
    $USING AA.Framework
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    
    GOSUB initialise ;*Opens and Initialise variables
    GOSUB process ;*Main process of calculation
    
RETURN

*** <region name= initialise>
initialise:
    Y.PRODUCT.ID = ''
    

*** <desc>Opens and Initialise variables </desc>

RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Main process of calculation </desc>
    DEBUG
    Y.PRODUCT.ID = EB.SystemTables.getRNew(AA.ARR.ACT.PRODUCT)

    IF Y.PRODUCT.ID = 'EXIM.MURA.EDF.LN' THEN
    
        EB.SystemTables.setRNew(AA.ARR.ACT.CURRENCY, 'USD')

        RETURN
*** </region>

    END