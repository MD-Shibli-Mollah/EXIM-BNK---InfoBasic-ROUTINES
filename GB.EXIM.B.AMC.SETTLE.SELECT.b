* @ValidationCode : MjoyMDYwODc1OTQ1OkNwMTI1MjoxNTgxNDE1MDMxOTc4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Feb 2020 15:57:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.AMC.SETTLE.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.GB.EXIM.B.AMC.SETTLE.COMMON
    
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
    SEL.CMD="SELECT ":FN.AA:" WITH PRODUCT.GROUP EQ EXIM.AWCD.GRP.AC EXIM.MSD.GRP.AC EXIM.SND.GRP.AC"
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN

END
