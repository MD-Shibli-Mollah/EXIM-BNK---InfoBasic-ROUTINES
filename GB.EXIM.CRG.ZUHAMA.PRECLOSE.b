* @ValidationCode : MjotOTgwMDgxNDg6Q3AxMjUyOjE1ODAxODkyNDc1NjI6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 Jan 2020 11:27:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.CRG.ZUHAMA.PRECLOSE(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Fees
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AC.Fees
    $USING AA.Interest

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = arrId
    Y.ACTIVITY.ID = AA.Framework.getC_aalocactivityid()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    
    FN.AA.ACC.DETAILS = 'FBNK.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    
    FN.BILL.DET = 'F.AA.BILL.DETAILS'
    F.BILL.DET = ''
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.AA.BIL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BIL.DET = ''
    
    FN.ARR.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.ARR.ACTIVITY = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.BILL.DET, F.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.AA.BIL.DET,F.AA.BIL.DET)
    EB.DataAccess.Opf(FN.ARR.ACTIVITY, F.ARR.ACTIVITY)
RETURN

PROCESS:
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    Y.TODAY = EB.SystemTables.getToday()
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
   
    BEGIN CASE
        CASE Y.DAYS LT 360
            balanceAmount = 0
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
        CASE Y.DAYS GE 360 AND Y.DAYS LT 1080
            GOSUB ACTUAL.PROFIT
            GOSUB GET.FIND.INTEREST
            GOSUB GET.BASIC.DETAILS
            balanceAmount = Y.ACT.PROFIT - (Y.TOT.PROFIT+Y.TOT.PRINCIPAL)
    END CASE
RETURN

PROFIT.CALCULATION:
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = Y.INT.RATE
    BaseAmts = Y.TOT.PRINCIPAL
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    RoundAmts = 0
    IntAmts = 0
    AccrDays = 0
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
* Y.PER.REY.PFT = RoundAmts
    Y.TOT.PROFIT = Y.TOT.PROFIT + RoundAmts
RETURN

GET.BASIC.DETAILS:
    Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
    NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
    Y.COUNT = NUM.OF.REPAY
    FOR I = 1 TO NUM.OF.REPAY
        IF Y.COUNT GT 1 THEN
            Y.REPAY.REF.ID.1 = Y.REPAY.REF.TOT<1,I>
            Y.REPAY.REF.ID.2 = Y.REPAY.REF.TOT<1,I+1>
            Y.VALUE.DATE = FIELD(Y.REPAY.REF.ID.1,'-',2)
            Y.TODAY = FIELD(Y.REPAY.REF.ID.2,'-',2)
            Y.REPAY.REFERENCE.ID = FIELD(Y.REPAY.REF.ID.1,'-',1)
            EB.DataAccess.FRead(FN.ARR.ACTIVITY, Y.REPAY.REFERENCE.ID, REC.ARR.ACTI, F.ARR.ACTIVITY, Er.ACTIVITY)
            Y.PER.REPAY.AMT = REC.ARR.ACTI<AA.Framework.ArrangementActivity.ArrActOrigTxnAmt>
            Y.TOT.PRINCIPAL = Y.TOT.PRINCIPAL + Y.PER.REPAY.AMT
            GOSUB PROFIT.CALCULATION
        END ELSE
            Y.REPAY.REF.ID.1 = Y.REPAY.REF.TOT<1,I>
            Y.VALUE.DATE = FIELD(Y.REPAY.REF.ID.1,'-',2)
            Y.TODAY = EB.SystemTables.getToday()
            Y.REPAY.REFERENCE.ID = FIELD(Y.REPAY.REF.ID.1,'-',1)
            EB.DataAccess.FRead(FN.ARR.ACTIVITY, Y.REPAY.REFERENCE.ID, REC.ARR.ACTI, F.ARR.ACTIVITY, Er.ACTIVITY)
            Y.PER.REPAY.AMT = REC.ARR.ACTI<AA.Framework.ArrangementActivity.ArrActOrigTxnAmt>
            Y.TOT.PRINCIPAL = Y.TOT.PRINCIPAL + Y.PER.REPAY.AMT
*GOSUB PROFIT.CALCULATION ;* IF bank wants to pay interest to exact preclose date or last capitalized date
        END
        Y.COUNT = Y.COUNT - 1
    NEXT I
RETURN

ORGINAL.DAYS:
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN

ACTUAL.PROFIT:
    AA.Framework.GetEcbBalanceAmount(Y.ACC.NUM, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = 'ACCDEPOSITPFT'
    AA.Framework.GetPeriodBalances(Y.ACC.NUM, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<2>
    Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN

GET.FIND.INTEREST:
    Y.AA.INT.SAV.ID = 'EXIM.CRPROFIT.MSD.AC-BDT--20040101'
    EB.DataAccess.FRead(FN.AA.INT,Y.AA.INT.SAV.ID,R.AA.INT,F.AA.INT,E.INT.ERR)
    Y.INT.RATE = R.AA.INT<AA.Interest.Interest.IntFixedRate>
RETURN
END
