* @ValidationCode : MjotMTI2NjAwMjgzMDpDcDEyNTI6MTU3NTcxNDIxMDUwODpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Dec 2019 16:23:30
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
*                                         New   - Ashna Ahmed
*                                                 FDS Pvt Ltd
***This routine is added in AA.SOURCE.CALC.TYPE for calculating preclosure charge in Term Deposit
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
    $USING EB.API
    
    
    
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
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.ARRANGEMENT
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
    

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>

process:
*** <desc>Main process of calculation </desc>
    
    ArrangementId = arrId   ;*Arrangement ID
*ArrangementId =  'AA19115PZ5X8'

    
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    
    Y.CURRENCY = Currency
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    
    R.REC1 = RAISE(Returnconditions1)

    Y.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
    Y.LEN = LEN(Y.TERM)
    Y.TERM.DP = Y.TERM[1,Y.LEN-1]
    Y.TERM.DAYS = Y.TERM.DP*30
   
    
    Y.AA.INT.ID = 'EXIM.CRPROFIT.MSD.AC-BDT--20040101'
    EB.DataAccess.FRead(FN.AA.INT,Y.AA.INT.ID,R.AA.INT,F.AA.INT,E.INT.ERR)
    Y.INT.RATE = R.AA.INT<AA.INT.FIXED.RATE>
    
    AccId = accountId
    AC.REC = AC.AccountOpening.Account.Read(AccId, Error)
    
    WORKING.BALANCE = AC.REC<AC.AccountOpening.Account.WorkingBalance>


    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,ArrangementId,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,ArrangementId,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    
    
    Y.ORIG.CONTRACT.DATE = R.AA.ARR<AA.ARR.ORIG.CONTRACT.DATE>
    
    IF Y.ORIG.CONTRACT.DATE THEN
        Y.VALUE.DATE = R.AA.ARR<AA.ARR.ORIG.CONTRACT.DATE>
    END ELSE
        Y.VALUE.DATE = R.AA.AC.REC<AA.AD.BASE.DATE>
    END
    
    
    PropertyClass2 = 'INTEREST';
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass2, Idproperty,Effectivedate, Returnids, Returnconditions2, Returnerror) ;* Product conditions with activities
    R.REC2 = RAISE(Returnconditions2)
    Y.PI = R.REC2<AA.Interest.Interest.IntPeriodicIndex>;
    Y.PI.ID = Y.PI:Y.CURRENCY:Y.VALUE.DATE
    EB.DataAccess.FRead(FN.PERIODIC.INTEREST, Y.PI.ID, R.PI, F.PERIODIC.INTEREST, PI.ERR)
    Y.PI.VALUE=R.PI<ST.RateParameters.PeriodicInterest.PiBidRate>
    
    CONVERT SM TO VM IN Y.PI.VALUE
    Y.P.RATE = FIELD(Y.PI.VALUE,VM,1)
    
*    Y.DEP.ARR.ID = ArrangementId:"-DEPOSITPFT"
*    EB.DataAccess.FRead(FN.AA.INT.ACCR,Y.DEP.ARR.ID,R.AA.INT.ACCR,F.AA.INT.ACCR,Y.ERR2)
*
*    Y.TOT.INT.ACCR.AMT = R.AA.INT.ACCR<AA.INT.ACC.TOT.ACCR.AMT>
*    Y.INT.ACCR.END.DATES = R.AA.INT.ACCR<AA.INT.ACC.PERIOD.END>
*    Y.INT.ACCR.CNT = DCOUNT(Y.TOT.INT.ACCR.AMT,VM)
*    Y.TOT.INT.AMT = '0'
*    FOR II = 1 TO Y.INT.ACCR.CNT
*        Y.INT.ACCR.EDATE = Y.INT.ACCR.END.DATES<1,II>
*        IF Y.INT.ACCR.EDATE GT Y.VALUE.DATE THEN
*
*            Y.INT.ACCR.AMT = Y.TOT.INT.ACCR.AMT<1,II>
*            Y.TOT.INT.AMT = Y.TOT.INT.AMT + Y.INT.ACCR.AMT
*        END
*    NEXT II
*
*    Y.TOT.INT.ACCR.AMT = Y.TOT.INT.AMT
    

    
    Y.DAYS = 'C'
    
    Y.TODAY = EB.SystemTables.getToday()
    
    EB.API.Cdd('', Y.VALUE.DATE, Y.TODAY, Y.DAYS)
    

    IF Y.DAYS LT 30 THEN
*NO CALCULATION
        balanceAmount = 0
    END
    IF Y.DAYS GE 30 AND Y.DAYS LT Y.TERM.DAYS THEN
*PREMATURE PROFIT
        GOSUB PREMATURE.PROFIT
        
        balanceAmount = DROUND((Y.ACT.PROFIT - Y.PRE.PROFIT),2)
    END
    
RETURN
*** </region>

PREMATURE.PROFIT:
    
    
    Y.PRE.PROFIT = Y.DAYS * WORKING.BALANCE*(Y.INT.RATE/100)/360
    Y.ACT.PROFIT = (Y.DAYS/360) * WORKING.BALANCE * (Y.P.RATE/100)

RETURN

END