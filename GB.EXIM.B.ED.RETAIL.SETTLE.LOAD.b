* @ValidationCode : MjotNjgwNTk3OTMwOkNwMTI1MjoxNTgxNDg0OTkyMjc4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Feb 2020 11:23:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.RETAIL.SETTLE.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.GB.EXIM.B.ED.RETAIL.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.ChargeConfig
    
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'FBNK.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AA,F.AA)
RETURN

END
