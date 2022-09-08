* @ValidationCode : MjoxNzU2Mjc5NzQyOkNwMTI1MjoxNTgxNTA1NTE0OTk4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Feb 2020 17:05:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.MIS.TAX(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
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
    $USING AA.TermAmount
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING EB.LocalReferences
    $USING AA.Account
    $USING ST.RateParameters

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = AA.Framework.getC_aalocarrid()
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
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
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.ARR.ACCOUNT = ''
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.BILL.DET, F.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.AA.BIL.DET,F.AA.BIL.DET)
    EB.DataAccess.Opf(FN.ARR.ACTIVITY, F.ARR.ACTIVITY)
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.ARR.ACCOUNT, F.ARR.ACCOUNT)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

PROCESS:
    AC.REC = AC.AccountOpening.Account.Read(Y.ACC.NUM, Error)
    Y.CUS.ID = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
    
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    Y.TOT.LAST.RENEW = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
    Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
    IF Y.LAST.RENEW.DT EQ '' THEN
        Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
        IF Y.VALUE.DATE EQ '' THEN
            Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
        END
    END ELSE
        Y.VALUE.DATE = Y.LAST.RENEW.DT
    END
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.PRODUCT.GROUP = R.AA.ARR<AA.Framework.Arrangement.ArrProductGroup>
    IF Y.PRODUCT.GROUP EQ 'EXIM.MMBS.GRP.DP' THEN
        PROP.CLASS = 'INTEREST'
        AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
        REC.INT = RAISE(R.INTEREST.DATA)
        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
    END ELSE
        PROP.CLASS = 'INTEREST'
        AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
        REC.INT = RAISE(R.INTEREST.DATA)
        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntFixedRate>
        IF Y.INT.RATE.MAIN EQ '' THEN
            Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
        END
    END
    Y.TODAY = EB.SystemTables.getToday()
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    
    Y.BILL.TYPE= R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.BILL.STATUS = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    Y.BILL.ID.LIST = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillId>
    Y.BILL.DATE.LIST = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillDate>
    CONVERT SM TO VM IN Y.BILL.TYPE
    CONVERT SM TO VM IN Y.BILL.STATUS
    CONVERT SM TO VM IN Y.BILL.ID.LIST
    CONVERT SM TO VM IN Y.BILL.DATE.LIST
    Y.DCOUNT = DCOUNT(Y.BILL.TYPE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.BILL =  Y.BILL.TYPE<1,I>
        Y.STATUS =  Y.BILL.STATUS<1,I>
        Y.BILL.DAY = Y.BILL.DATE.LIST<1,I>
        IF Y.BILL EQ 'PAYMENT' AND Y.STATUS EQ 'PAY' AND Y.BILL.DAY GT Y.VALUE.DATE THEN
            Y.BILL.ID = Y.BILL.ID.LIST<1,I>
            EB.DataAccess.FRead(FN.BILL.DET, Y.BILL.ID, REC.BILL.DET, F.BILL.DET, Er.BILL)
            Y.BILL.PROPERTY = REC.BILL.DET<AA.PaymentSchedule.BillDetails.BdProperty>
            Y.DEPOSIT.PFT = Y.BILL.PROPERTY<1,1>
            IF Y.DEPOSIT.PFT EQ 'DEPOSITPFT' AND Y.BILL.DAY NE Y.TODAY THEN
                Y.CNT = Y.CNT + 1
            END
        END
    NEXT I
* Y.CNT = Y.CNT-1 ;* for reduce 1 month becouse of when account preclose or mature principal baance shuold be pay
    GOSUB ACTUAL.PROFIT
    GOSUB ONE.MONTH.PROFIT
    Y.TOTAL.PAY.CUS = (Y.ONE.M.PFT * Y.CNT) + LAST.ACCRUDE.INT
    
    IF Y.TAX.RATE EQ '' THEN
        IF Y.TIN.VAL EQ '' THEN
            Y.PER.MONT.TAX = (Y.ONE.M.PFT*15)/100
            Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*15)/100
        END ELSE
            Y.PER.MONT.TAX = (Y.ONE.M.PFT*10)/100
            Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*10)/100
        END
    END ELSE
        Y.PER.MONT.TAX = (Y.ONE.M.PFT*Y.TAX.RATE)/100
        Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*Y.TAX.RATE)/100
    END
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays

    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        BEGIN CASE
            CASE Y.DAYS LT 360
                TOT.ACC.AMT = 0
                balanceAmount = (Y.PER.MONT.TAX * Y.CNT) + Y.BROKEN.M.TAX
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
            CASE Y.DAYS GE 360 AND Y.DAYS LT 1800
                GOSUB GET.SVR.FIND.INTEREST
                GOSUB PREMATURE.PROFIT
                IF Y.TAX.RATE EQ '' THEN
                    IF Y.TIN.VAL EQ '' THEN
                        Y.CUS.PAY.TAX = (Y.PRE.PROFIT*15)/100
                    END ELSE
                        Y.CUS.PAY.TAX = (Y.PRE.PROFIT*10)/100
                    END
                END ELSE
                    Y.CUS.PAY.TAX = (Y.PRE.PROFIT*Y.TAX.RATE)/100
                END
                balanceAmount = (((Y.PER.MONT.TAX * Y.CNT) + Y.BROKEN.M.TAX) - Y.CUS.PAY.TAX)
        END CASE
    END
    
RETURN
ONE.MONTH.PROFIT:
    Y.ONE.M.PFT = DROUND(((30*Y.TERM.AMOUNT*Y.INT.RATE.MAIN)/(100*360)),2)
RETURN
PREMATURE.PROFIT:
    Y.PRE.PROFIT = DROUND(((Y.DAYS*Y.TERM.AMOUNT*Y.INT.RATE)/(100*360)),2)
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
ACTUAL.PROFIT:
*AA.Framework.GetEcbBalanceAmount(Y.ACC.NUM, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = 'ACCDEPOSITPFT'
    AA.Framework.GetPeriodBalances(Y.ACC.NUM, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<2>
*Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN
END
