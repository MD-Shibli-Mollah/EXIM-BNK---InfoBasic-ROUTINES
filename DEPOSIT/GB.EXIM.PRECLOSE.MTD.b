* @ValidationCode : MjotNjgyNDQ4ODA0OkNwMTI1MjoxNTgxMjQwNjU3MjY1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Feb 2020 15:30:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0


*$PACKAGE IS.ModelBank

SUBROUTINE GB.EXIM.PRECLOSE.MTD(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*SUBROUTINE GB.EXIM.PRECLOSE.MTD
    
*** </region>
***Modification History :
*-----------------------------------------------------------------------------
* Developed By- S.M. Sayeed
* Designation - Technical Consultant
* Email       - s.m.sayeed@fortress-global.com
* Dated 01/01/2020
***This routine is added in AA.SOURCE.CALC.TYPE for calculating preclosure charge in Term Deposit
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.Interest
    $USING AA.ActivityCharges
    $USING AC.AccountOpening
    $USING AA.Settlement
    $USING AA.Account
    $USING AA.TermAmount
    $USING ST.RateParameters
    $USING AA.Overdue
    $USING AA.PaymentSchedule
    $USING EB.API
    $USING AC.Fees
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    
   
    
*-----------------------------------------------------------------------------

    GOSUB initialise ;*Opens and Initialise variables
    GOSUB process ;*Main process of calculation

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Opens and Initialise variables </desc>

    arrangementId = ''
    accountId = ''
    requestDate = ''
    balanceAmount = ''
    retError = ''
    UnAccrued = ''
    Rate = ''
    POS = ''
    BaseBalance = ''
    RequestType = ''
    ReqdDate = ''
    EndDate = ''
    SystemDate = ''
    BalDetails = ''
    ErrorMessage = ''
    AccCategory = ''
    CusId = ''
    LimitRef = ''
    CusLiab = ''
    LimitId = ''
    MaxbalanceAmount = ''
    ChargeAmount = ''
    R.REC = ''
    Y.ACC = ''
    AC.REC = ''
    SETT.WORKING.BALANCE = ''
    Y.CNT = 0
    V$MONTH = 0
    Y.PRE.PROFIT = 0
    Y.TOT.ACCRUAL = 0
    Y.MAT.PROFIT   = 0
    Y.ADD.PROFIT = 0
    Y.AMOUNT = 0
    MAT.AMOUNT = 0
    PR.AMOUNT = 0
    WORKING.BALANCE = 0
    Y.ORIG.CONTRACT.DATE = ''
    
    
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)

    FN.AA.INT.ACCR = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INT.ACCR = ''
    EB.DataAccess.Opf(FN.AA.INT.ACCR,F.AA.INT.ACCR)
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    
    FN.PERIODIC.INTEREST = 'F.PERIODIC.INTEREST'
    F.PERIODIC.INTEREST = ''
    EB.DataAccess.Opf(FN.PERIODIC.INTEREST,F.PERIODIC.INTEREST)
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

process:
    ArrangementId = arrId   ;*Arrangement ID
    accountId = AA.Framework.getC_aaloclinkedaccount()
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    
    R.REC1 = RAISE(Returnconditions1)

    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
      
    AccId = accountId
    AC.REC = AC.AccountOpening.Account.Read(AccId, Error)
    Y.CURRENCY = AC.REC<AC.AccountOpening.Account.Currency>
    WORKING.BALANCE = AC.REC<AC.AccountOpening.Account.WorkingBalance>


    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,ArrangementId,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,ArrangementId,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)

    Y.TOT.LAST.RENEW = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
    Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
    Y.RENEW.OR.NOT = Y.LAST.RENEW.DT
    IF Y.LAST.RENEW.DT EQ '' THEN
        Y.LAST.RENEW.DT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END ELSE
        AA.Framework.GetEcbBalanceAmount(AccId, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
        Y.TERM.AMOUNT = TOT.CUR.AMT
    END
    GOSUB GET.SVR.FIND.INTEREST
    Y.TODAY = EB.SystemTables.getToday()
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays

    IF Y.DAYS LT 30 AND Y.RENEW.OR.NOT EQ '' THEN
*Upto 1 MONTH NO CALCULATION TOTAL INTEREST WILL BE CHARGES
        balanceAmount = 0
    END ELSE
        GOSUB ACTUAL.PROFIT
        GOSUB PREMATURE.PROFIT
        balanceAmount = Y.ACT.PROFIT - (Y.PRE.PROFIT+Y.TERM.AMOUNT)
    END

    IF Y.DAYS GE 30 AND Y.DAYS LT 1080 THEN
*PREMATURE PROFIT
        GOSUB ACTUAL.PROFIT
        GOSUB PREMATURE.PROFIT
        balanceAmount = Y.ACT.PROFIT - (Y.PRE.PROFIT+Y.TERM.AMOUNT)
    END
    
RETURN

PREMATURE.PROFIT:
    Y.PRE.PROFIT = DROUND(((Y.DAYS*Y.TERM.AMOUNT*Y.INT.RATE)/(100*360)),2)
RETURN
ORGINAL.DAYS:
    StartDate = Y.LAST.RENEW.DT
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN
ACTUAL.PROFIT:
    LAST.ACCRUDE.INT = 0
    TOT.CUR.AMT = 0
    Y.ACT.PROFIT = 0
    AA.Framework.GetEcbBalanceAmount(AccId, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = 'ACCDEPOSITPFT'
    AA.Framework.GetPeriodBalances(AccId, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<4>
    Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN
GET.SVR.FIND.INTEREST:
    Y.SRC.ID = '4BDT' ;* 4BDT FIXED FOR SAVINGS ACCOUNT INTEREST
    Y.PRD.DATE = Y.LAST.RENEW.DT
    SEL.CMD = 'SELECT ':FN.BASIC.INT:' WITH @ID LIKE ':Y.SRC.ID:'...'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
    FOR I = 1 TO NO.OF.BASIC
        Y.SEPARATE.ID.1 = SEL.LIST<I>
        Y.FIRST.DATE = Y.SEPARATE.ID.1[5,8]
        IF Y.PRD.DATE GE Y.FIRST.DATE THEN
            IF I = NO.OF.BASIC THEN
                Y.SEPARATE.ID.1 = SEL.LIST<I>
                EB.DataAccess.FRead(FN.BASIC.INT, Y.SEPARATE.ID.1, REC.BASIC, F.BASIC.INT, Er.RR.BASIC)
                Y.INT.RATE = REC.BASIC<ST.RateParameters.BasicInterest.EbBinInterestRate>
            END
        END ELSE
            Y.SEPARATE.ID.1 = SEL.LIST<I-1>
            EB.DataAccess.FRead(FN.BASIC.INT, Y.SEPARATE.ID.1, REC.BASIC, F.BASIC.INT, Er.RR.BASIC)
            Y.INT.RATE = REC.BASIC<ST.RateParameters.BasicInterest.EbBinInterestRate>
            BREAK
        END
    NEXT I
RETURN
END