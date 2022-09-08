* @ValidationCode : MjotMTQ1ODI4ODMxOkNwMTI1MjoxNTgwMjg5Mjg0NDAyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Jan 2020 15:14:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ED.PAY.CALC( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.BD.CHG.INFORMATION
    
    $USING EB.DataAccess
    $USING AA.Framework
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    ArrangementId = PASS.CUSTOMER<5>
    Y.PROPERTY = 'EDFEE'
RETURN


**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
RETURN

********
PROCESS:
********
    Y.BD.CHG.ID = ArrangementId:'-':Y.PROPERTY
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    Y.DUE.AMT = R.BD.CHG<BD.CHG.DUE.AMT>
    
    IF Y.DUE.AMT NE '' OR Y.DUE.AMT GT 0 THEN
        GOSUB WRITE.BD.CHG
    END ELSE
        TAX.AMOUNT = 0
    END
RETURN

************
WRITE.BD.CHG:
************
    TAX.AMOUNT = Y.DUE.AMT
    R.BD.CHG<BD.CHG.DUE.AMT> = ''
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate('')
RETURN

END
