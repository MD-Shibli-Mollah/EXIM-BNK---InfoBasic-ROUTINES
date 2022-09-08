* @ValidationCode : Mjo2MjM0OTUyNzQ6Q3AxMjUyOjE1NzYxMzkyNTIwNTU6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Dec 2019 14:27:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.GET.LENDING.REBATE.AMT(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.EXIM.LENDING.REBATE
    $USING AA.Framework
    $USING EB.DataAccess
*-----------------------------------------------------------------------------

    FnLenRebate = 'F.BD.EXIM.LENDING.REBATE'
    FLenRebate = ''
    
    EB.DataAccess.Opf(FnLenRebate, FLenRebate)
    AA.Framework.GetArrangementAccountId(arrId, accountId, Currency, ReturnError)
    EB.DataAccess.FRead(FnLenRebate, accountId, RLenRebate, FLenRebate, LenRebateErr)
    
    RebateAmt = RLenRebate<LN.RBT.REBATE.AMT>
    balanceAmount = SUM(RebateAmt)
RETURN
END
