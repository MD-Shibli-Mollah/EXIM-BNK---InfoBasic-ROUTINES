* @ValidationCode : Mjo3NDA5NjkwNDg6Q3AxMjUyOjE1NzgyMjQ5NzE4Njc6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 05 Jan 2020 17:49:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVA.TRAN.BR.TO.HO.LOAD
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
    $USING ST.CurrencyConfig
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPEN
RETURN
******
INIT:
******
    FN.C.P.L='F.CONSOLIDATE.PRFT.LOSS'
    F.C.P.L=''
    FN.CURR = 'F.CURRENCY'
    F.CURR = ''
RETURN
*********
OPEN:
*********
    EB.DataAccess.Opf(FN.C.P.L,F.C.P.L)
    EB.DataAccess.Opf(FN.CURR,F.CURR)
    
RETURN

END
