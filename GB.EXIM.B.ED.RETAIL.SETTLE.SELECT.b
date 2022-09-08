* @ValidationCode : Mjo3NzQ3NzU1OTY6Q3AxMjUyOjE1ODE0ODUxMTQ3Mzg6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Feb 2020 11:25:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.RETAIL.SETTLE.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.GB.EXIM.B.ED.RETAIL.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.Service
    $USING EB.DataAccess
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
