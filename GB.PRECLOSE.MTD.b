* @ValidationCode : MjoxMTU5MDMwODk6Q3AxMjUyOjE1NjkyMjAyNzI0ODg6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 23 Sep 2019 12:31:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0


$PACKAGE IS.ModelBank

*SUBROUTINE GB.PRECLOSE.MTD(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
SUBROUTINE GB.PRECLOSE.MTD
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>
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
    
    
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.LIMIT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.SETTLEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.PERIODIC.INTEREST
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    
   
    
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
    
    
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    
    FN.LIMIT = 'F.LIMIT'
    F.LIMIT = ''
    CALL OPF(FN.LIMIT,F.LIMIT)
    
    FN.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.ACCOUNT.DETAILS = ''
    CALL OPF(FN.ACCOUNT.DETAILS,F.ACCOUNT.DETAILS)
    
    FN.PERIODIC.INTEREST = 'F.PERIODIC.INTEREST'
    F.PERIODIC.INTEREST = ''
    CALL OPF(FN.PERIODIC.INTEREST,F.PERIODIC.INTEREST)
    
    

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>

process:
*** <desc>Main process of calculation </desc>
    DEBUG
*ArrangementId = arrId   ;*Arrangement ID
    ArrangementId =  'AA191928RMBM'

    
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    
    Y.CURRENCY = Currency
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    DEBUG
    R.REC1 = RAISE(Returnconditions1)
*Y.AMOUNT = R.REC1<AA.AMT.AMOUNT>
    Y.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
    Y.LEN = LEN(Y.TERM)
    Y.TERM.DP = Y.TERM[1,Y.LEN-1]
    Y.TERM.DAYS = Y.TERM.DP*30
    
    
    PropertyClass2 = 'INTEREST'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass2, Idproperty, Effectivedate, Returnids, Returnconditions2, Returnerror) ;* Product conditions with activities
    DEBUG
    R.REC2 = RAISE(Returnconditions2)
    Y.PI = R.REC2<AA.Interest.Interest.IntPeriodicIndex>

*    Y.AMOUNT = 5000

    
    AccId = accountId
    AC.REC = AC.AccountOpening.Account.Read(AccId, Error)
    DEBUG
    WORKING.BALANCE = AC.REC<AC.AccountOpening.Account.WorkingBalance>
*    WORKING.BALANCE = 379269.39
    EB.DataAccess.FRead(FN.ACCOUNT.DETAILS,ArrangementId,R.ACCOUNT.DETAILS,F.ACCOUNT.DETAILS , E.AA.ERR)
    DEBUG
    Y.VALUE.DATE = R.ACCOUNT.DETAILS<AA.AD.VALUE.DATE>
    Y.PI.ID = Y.PI:Y.CURRENCY:Y.VALUE.DATE
    CALL F.READ(FN.PERIODIC.INTEREST, Y.PI.ID, R.PI, F.PERIODIC.INTEREST, PI.ERR)
    DEBUG
    Y.PI.VALUE=R.PI<ST.RateParameters.PeriodicInterest.PiRestPeriod>
*Y.PI.DATE='36M'

    Y.DAYS = 'C'
    Y.TODAY = EB.SystemTables.getToday()
    CALL CDD('', Y.VALUE.DATE, Y.TODAY, Y.DAYS)
    DEBUG
*CALL EB.NO.OF.MONTHS(Y.VALUE.DATE, ReqdDate, V$MONTH)
*    V$MONTH = 50
    IF Y.DAYS LT 30 THEN
*NO CALCULATION
        balanceAmount = 0
    END
    IF Y.DAYS GE 30 AND Y.DAYS LT Y.TERM.DAYS THEN
*PREMATURE PROFIT
        GOSUB PREMATURE.PROFIT
        DEBUG
        balanceAmount = WORKING.BALANCE - Y.PRE.PROFIT
    END
    
RETURN
*** </region>

PREMATURE.PROFIT:
    DEBUG
    Y.PRE.PROFIT = DROUND((Y.DAYS * WORKING.BALANCE*(4/100)/360),2)
RETURN

END