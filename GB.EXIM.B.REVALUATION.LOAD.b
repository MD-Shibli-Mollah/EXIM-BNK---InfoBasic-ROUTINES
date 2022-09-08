* @ValidationCode : Mjo3NjU4NzE3MjY6Q3AxMjUyOjE1Nzg1Njg3MDk1MDM6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Jan 2020 17:18:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.REVALUATION.LOAD
*-----------------------------------------------------------------------------
*This Routine is write for Transfer of Foreign Currency General Account
*Balance to Local currency General Account Balance.
*This Routine will Execute in Batch Statage
*Author : s.azam@fortress-global.com
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
    $USING ST.CurrencyConfig
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPEN
RETURN
******
INIT:
******
    FN.AC='F.ACCOUNT'
    F.AC=''
    FN.CURR = 'F.CURRENCY'
    F.CURR = ''
    FN.RCC = 'F.EXIM.REVA.COMPEN.CALC'
    F.RCC = ''
RETURN
*********
OPEN:
*********
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.CURR,F.CURR)
    EB.DataAccess.Opf(FN.RCC,F.RCC)
RETURN

END
