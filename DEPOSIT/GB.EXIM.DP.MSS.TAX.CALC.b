* @ValidationCode : MjoxNDEwNTU3MzgyOkNwMTI1MjoxNTgxMjQwMDU3Njc4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Feb 2020 15:20:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.DP.MSS.TAX.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* Developed By- S.M. Sayeed
* Designation - Technical Consultant
* Email       - s.m.sayeed@fortress-global.com
* Dated 01/01/2020
* This routine calculate TAX amount based on TIN given or not and attached in CALC.ROUTINE field of TAX Application
* Condition 1 : If TIN given then Tax will be 10%
* Condition 2 : If TIN not given then Tax will be 15%
* Condition 3 : If Arrangement preclose then interest should be calculate as per bank decision
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING AA.Account
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING EB.API
    $USING AC.Fees
    $USING ST.Customer
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.LocalReferences
    $USING ST.RateParameters
 
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
    
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

process:
    ArrangementId = arrId   ;*Arrangement ID
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    
    Y.CURRENCY = Currency
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    
    R.REC1 = RAISE(Returnconditions1)

    Y.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
    
     
    AccId = accountId
    AC.REC = AC.AccountOpening.Account.Read(AccId, Error)
    Y.CUS.ID = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>

    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,ArrangementId,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,ArrangementId,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
     
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    GOSUB GET.SVR.FIND.INTEREST
    Y.PRODUCT.GROUP = R.AA.ARR<AA.Framework.Arrangement.ArrProductGroup>
    Y.TODAY = EB.SystemTables.getToday()
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        IF Y.PRODUCT.GROUP EQ 'EXIM.MDBS.GRP.DP' THEN
            BEGIN CASE
                CASE Y.DAYS LT 360
                    TOT.ACC.AMT = 0
                CASE Y.DAYS GE 360 AND Y.DAYS LT 1080
*PREMATURE PROFIT more than 1Y but less than 3Y savings rate + .75%
                    Y.INT.RATE = Y.INT.RATE + 0.75
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
                CASE Y.DAYS GE 1080 AND Y.DAYS LT 3330
*PREMATURE PROFIT more than 3Y but less than 9Y savings rate + 1%
                    Y.INT.RATE = Y.INT.RATE + 1
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
            END CASE
        END ELSE
            BEGIN CASE
                CASE Y.DAYS LT 360
                    TOT.ACC.AMT = 0
                CASE Y.DAYS GE 360 AND Y.DAYS LT 1080
*PREMATURE PROFIT more than 1Y but less than 3Y savings rate + .75%
                    Y.INT.RATE = Y.INT.RATE + 0.75
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT =Y.PRE.PROFIT
                CASE Y.DAYS GE 1080 AND Y.DAYS LT 1800
*PREMATURE PROFIT more than 3Y but less than 5Y savings rate + 1%
                    Y.INT.RATE = Y.INT.RATE + 1
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT =Y.PRE.PROFIT
                CASE Y.DAYS GE 1800 AND Y.DAYS LT 2880
*PREMATURE PROFIT more than 5Y but less than 8Y savings rate + 1.5%
                    Y.INT.RATE = Y.INT.RATE + 1.50
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
                CASE Y.DAYS GE 2880 AND Y.DAYS LT 5130
*PREMATURE PROFIT more than 8 savings rate + 2%
                    Y.INT.RATE = Y.INT.RATE + 2
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
            END CASE
        END
        IF Y.TAX.RATE EQ '' THEN
            IF Y.TIN.VAL EQ '' THEN
                balanceAmount = (TOT.ACC.AMT*15)/100
            END ELSE
                balanceAmount = (TOT.ACC.AMT*10)/100
            END
        END ELSE
            balanceAmount = (TOT.ACC.AMT*Y.TAX.RATE)/100
        END
    END
    IF Y.ACTIVITY.ID EQ 'DEPOSITS-MATURE-ARRANGEMENT' THEN
        GOSUB ACTUAL.PROFIT
        TOT.ACC.AMT = Y.ACT.PROFIT - Y.AMOUNT
        IF Y.TAX.RATE EQ '' THEN
            IF Y.TIN.VAL EQ '' THEN
                balanceAmount = (TOT.ACC.AMT*15)/100
            END ELSE
                balanceAmount = (TOT.ACC.AMT*10)/100
            END
        END ELSE
            balanceAmount = (TOT.ACC.AMT*Y.TAX.RATE)/100
        END
    END
RETURN

PREMATURE.PROFIT:
    Y.PRE.PROFIT = DROUND(((Y.DAYS * Y.AMOUNT*(Y.INT.RATE))/(360*100)),2)
RETURN

ACTUAL.PROFIT:
    AA.Framework.GetEcbBalanceAmount(AccId, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = 'ACCDEPOSITPFT'
    AA.Framework.GetPeriodBalances(AccId, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<2>
    Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN

ORGINAL.DAYS: ;* this portion used only for calculate days or age of deposits product
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN
GET.SVR.FIND.INTEREST:
    Y.SRC.ID = '4BDT' ;* 4BDT FIXED FOR SAVINGS ACCOUNT INTEREST
    Y.PRD.DATE = Y.VALUE.DATE
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
