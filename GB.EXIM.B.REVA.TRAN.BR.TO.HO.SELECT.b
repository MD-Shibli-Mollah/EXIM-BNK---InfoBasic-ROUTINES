* @ValidationCode : MjotNjk5MzczMTM5OkNwMTI1MjoxNTc4MjI1MDMxOTEwOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 05 Jan 2020 17:50:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVA.TRAN.BR.TO.HO.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.CURRENCY
    $INSERT I_F.CONSOLIDATE.PRFT.LOSS
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    $INSERT I_F.GB.EXIM.B.REVA.TRAN.BR.TO.HO.COMMON
    
    $USING EB.DataAccess
    $USING RE.Consolidation
    $USING EB.Service
    $USING ST.CurrencyConfig
*-----------------------------------------------------------------------------

    GOSUB SEL.LIST
RETURN
**********
SEL.LIST:
**********
    SEL.CMD="SELECT ":FN.C.P.L:" WITH @ID LIKE PL.53000..."
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN
END
