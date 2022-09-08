* @ValidationCode : MjotMzg1NDU3NjQwOkNwMTI1MjoxNTgwMzg5OTc4NzA2OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Jan 2020 19:12:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.ED.TERM.SETTLE.LOAD
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
    $INSERT I_F.GB.EXIM.B.ED.TERM.SETTLE.COMMON
    
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
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
RETURN

END
