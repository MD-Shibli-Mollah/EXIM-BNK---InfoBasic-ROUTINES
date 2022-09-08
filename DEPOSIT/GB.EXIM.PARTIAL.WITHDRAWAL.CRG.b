* @ValidationCode : MjotMzM2MzcwNzQ1OkNwMTI1MjoxNTgxMzM0MzM4NjExOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Feb 2020 17:32:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.PARTIAL.WITHDRAWAL.CRG(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.Interest
    $USING AC.Fees
    $INSERT I_AA.LOCAL.COMMON

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
INIT:
    Y.ARR.ID = AA.Framework.getC_aalocarrid()
    Y.ACTIVITY.ID = AA.Framework.getC_aalocactivityid()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    Y.TODAY = EB.SystemTables.getToday()
    
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    
    FN.ARR.INT = 'F.AA.ARR.INTEREST'
    F.ARR.INT = ''
RETURN
OPENFILES:
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.ARR.INT, F.ARR.INT)
RETURN

PROCESS:
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    Y.DR.VALUE = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnAmount> ;* get Partial withdrawal amount
    AA.Framework.GetEcbBalanceAmount(Y.ACC.NUM, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError) ;* After renewal total current amt
    
    PROP.CLASS = 'INTEREST'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.INT.REC = RAISE(RETURN.VALUES)
    Y.INT.RATE =R.INT.REC<AA.Interest.Interest.IntPeriodicRate>
    
    Y.TOT.LAST.RENEW = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
    Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
    Y.TOT.PRINCIPAL = TOT.CUR.AMT
    GOSUB ACTUAL.PROFIT
    Y.AFTER.WITHDRL.PRIN = TOT.CUR.AMT - Y.DR.VALUE
    GOSUB AFTER.WITHDRAWAL.PROFIT
    balanceAmount = Y.MAIN.PROFIT - Y.AFTER.WITH.PROFIT
    
RETURN

ACTUAL.PROFIT:
    StartDate = Y.LAST.RENEW.DT
    EndDate = Y.TODAY
    Rates = Y.INT.RATE
    BaseAmts = Y.TOT.PRINCIPAL
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    RoundAmts = 0
    IntAmts = 0
    AccrDays = 0
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
    Y.MAIN.PROFIT = RoundAmts
RETURN

AFTER.WITHDRAWAL.PROFIT:
    StartDate = Y.LAST.RENEW.DT
    EndDate = Y.TODAY
    Rates = Y.INT.RATE
    BaseAmts = Y.AFTER.WITHDRL.PRIN
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    RoundAmts = 0
    IntAmts = 0
    AccrDays = 0
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
    Y.AFTER.WITH.PROFIT = RoundAmts
RETURN
END
