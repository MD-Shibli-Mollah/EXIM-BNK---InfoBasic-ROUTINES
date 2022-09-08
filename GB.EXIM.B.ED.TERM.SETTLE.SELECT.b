* @ValidationCode : MjoxNzcxMzg2MDpDcDEyNTI6MTU4MDM5MDA0MDY2NTpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Jan 2020 19:14:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.TERM.SETTLE.SELECT
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
    $INSERT I_F.GB.EXIM.B.ED.TERM.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.Service
    $USING EB.DataAccess
    $USING ST.ChargeConfig
*-----------------------------------------------------------------------------

    GOSUB SEL.LIST
RETURN

*********
SEL.LIST:
*********
    SEL.CMD="SELECT ":FN.AA:" WITH PRODUCT.GROUP EQ EXIM.MTD.GRP.DP"
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN

END
