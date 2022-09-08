* @ValidationCode : MjoxMDUyNTQyODI1OkNwMTI1MjoxNTc4NTY4NzIwNjI4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Jan 2020 17:18:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVALUATION.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CURRENCY
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    $INSERT I_F.GB.EXIM.B.REVALUATION.COMMON
    
    $USING EB.DataAccess
    $USING EB.Service
    $USING ST.CurrencyConfig
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------

    GOSUB SEL.LIST
RETURN
**********
SEL.LIST:
**********
    SEL.CMD="SELECT ":FN.CURR:" WITH @ID NE 'BDT'"
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN
END
