* @ValidationCode : MjoxNjA4MDM4MjAyOkNwMTI1MjoxNTgzNzQ1MTcxNTYxOnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Mar 2020 15:12:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.AA.LN.ACCR.REALIZE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING AA.Interest
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING EB.Foundation
    
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

INITIALISE:
    FN.ACCOUNT = 'FBNK.ACCOUNT'
    F.ACCOUNT = ''
    FN.INT.ACCR = 'FBNK.AA.INTEREST.ACCRUALS'
    F.INT.ACCR = ''
    prinDecreaseAmt = 0
    accrualAmt = 0
    ftCreditAmt = 0
    
    localFieldsFt = 'LT.FT.PRIN.DECR'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, prinDecrAmtPos)
    
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT, F.ACCOUNT)
    EB.DataAccess.Opf(FN.INT.ACCR, F.INT.ACCR)
RETURN

PROCESS:
    !DEBUG
    ftCreditAcctNo = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    ftOrCreditAmt = EB.SystemTables.getComi()
    
    EB.DataAccess.FRead(FN.ACCOUNT, ftCreditAcctNo, R.ACC, F.ACCOUNT, Er)
    !DEBUG
    arrangementID = R.ACC<AC.AccountOpening.Account.ArrangementId>
    intAccrualID = arrangementID : '-' : 'MARKUPPROFIT'
    EB.DataAccess.FRead(FN.INT.ACCR, intAccrualID, R.INT.ACCR, F.INT.ACCR, Er)
    !DEBUG

    intAccrualAmt = R.INT.ACCR<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
    repayAccAmt = R.INT.ACCR<AA.Interest.InterestAccruals.IntAccTotRpyAmt>
    IF repayAccAmt = '' THEN
        repayAccAmt = 0
    END
    accrualAmt = intAccrualAmt - repayAccAmt
    IF accrualAmt != 0 THEN
        prinDecreaseAmt = ftOrCreditAmt - accrualAmt
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, accrualAmt)
    END
    ELSE
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = ftOrCreditAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    END
RETURN
END
