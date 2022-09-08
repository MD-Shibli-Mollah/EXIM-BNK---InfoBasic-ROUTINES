* @ValidationCode : MjoxMDYzMDIyMzUyOkNwMTI1MjoxNTgxNDE4NzUwODY0OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Feb 2020 16:59:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.FEMINA.TAX.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* Developed By- S.M. Sayeed
* Designation - Technical Consultant
* Email       - s.m.sayeed@fortress-global.com
* Dated 01/01/2020
* This routine calculate TAX amount based on TIN given or not and attached in CALCULATION.SOUCE
* Condition 1 : If TIN given then Tax will be 10%
* Condition 2 : If TIN not given then Tax will be 15%
* Condition 3 : If Arrangement preclose then interest should be calculate as per bank decision
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
    $USING AA.Account
    $USING EB.LocalReferences
    $USING ST.RateParameters

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = arrId
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
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

PROCESS:
    AC.REC = AC.AccountOpening.Account.Read(Y.ACC.NUM, Error)
    Y.CUS.ID = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
    
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    Y.PRD.START.DATE = Y.VALUE.DATE
    Y.PRD.MATURE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    Y.TODAY = EB.SystemTables.getToday()
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        BEGIN CASE
            CASE Y.DAYS LT 360
                TOT.ACC.AMT = 0
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
            CASE Y.DAYS GE 360 AND Y.DAYS LT 1080
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                START.FORM.I = 1
                NO.OF.LOOP = NUM.OF.REPAY
                GOSUB GET.SVR.FIND.INTEREST
                GOSUB GET.BASIC.DETAILS.NOT.SLAB
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL
*--------------------------------------------AFTER 3 YEARS PROFIT----------------------------------------------
            CASE Y.DAYS GE 1080 AND Y.DAYS LT 1800
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                IF NUM.OF.REPAY GE 36 THEN
                    Y.AA.INT.ID = 'EXIM.PFT.MFMS3Y.DP-BDT--20040101'
                    GOSUB GET.PRD.INTEREST.RATE
                    NO.OF.LOOP = 36
                    START.FORM.I = 1
                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                    Y.REMAINING.REPAY = NUM.OF.REPAY - 36
                    IF Y.REMAINING.REPAY GE 1 THEN
                        Y.TOT.PROFIT = 0
                        NO.OF.LOOP = NUM.OF.REPAY
                        START.FORM.I = 37
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END ELSE
                    GOSUB GET.SVR.FIND.INTEREST
                    GOSUB GET.BASIC.DETAILS.NOT.SLAB
                END
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL
            
*--------------------------------------------AFTER 5 YEARS PROFIT----------------------------------------------
            CASE Y.DAYS GE 1800 AND Y.DAYS LT 2880
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                IF NUM.OF.REPAY GE 60 THEN
                    Y.AA.INT.ID = 'EXIM.PFT.MFMS5Y.DP-BDT--20040101'
                    GOSUB GET.PRD.INTEREST.RATE
                    NO.OF.LOOP = 60
                    START.FORM.I = 1
                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                    Y.REMAINING.REPAY = NUM.OF.REPAY - 60
                    IF Y.REMAINING.REPAY GE 1 THEN
                        Y.TOT.PROFIT = 0
                        NO.OF.LOOP = NUM.OF.REPAY
                        START.FORM.I = 61
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END ELSE
                    IF NUM.OF.REPAY GE 36 THEN
                        Y.AA.INT.ID = 'EXIM.PFT.MFMS3Y.DP-BDT--20040101'
                        GOSUB GET.PRD.INTEREST.RATE
                        NO.OF.LOOP = 36
                        START.FORM.I = 1
                        GOSUB GET.BASIC.DETAILS.WITH.SLAB
                        Y.REMAINING.REPAY = NUM.OF.REPAY - 36
                        IF Y.REMAINING.REPAY GE 1 THEN
                            Y.TOT.PROFIT = 0
                            NO.OF.LOOP = NUM.OF.REPAY
                            START.FORM.I = 37
                            GOSUB GET.SVR.FIND.INTEREST
                            GOSUB GET.BASIC.DETAILS.NOT.SLAB
                        END
                    END ELSE
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL
            
*--------------------------------------------AFTER 8 YEARS PROFIT----------------------------------------------
            CASE Y.DAYS GE 2880 AND Y.DAYS LT 3600
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                IF NUM.OF.REPAY GE 96 THEN
                    Y.AA.INT.ID = 'EXIM.PFT.MFMS8Y.DP-BDT--20040101'
                    GOSUB GET.PRD.INTEREST.RATE
                    NO.OF.LOOP = 96
                    START.FORM.I = 1
                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                    Y.REMAINING.REPAY = NUM.OF.REPAY - 96
                    IF Y.REMAINING.REPAY GE 1 THEN
                        Y.TOT.PROFIT = 0
                        NO.OF.LOOP = NUM.OF.REPAY
                        START.FORM.I = 97
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END ELSE
                    IF NUM.OF.REPAY GE 60 THEN
                        Y.AA.INT.ID = 'EXIM.PFT.MFMS5Y.DP-BDT--20040101'
                        GOSUB GET.PRD.INTEREST.RATE
                        NO.OF.LOOP = 60
                        START.FORM.I = 1
                        GOSUB GET.BASIC.DETAILS.WITH.SLAB
                        Y.REMAINING.REPAY = NUM.OF.REPAY - 60
                        IF Y.REMAINING.REPAY GE 1 THEN
                            Y.TOT.PROFIT = 0
                            NO.OF.LOOP = NUM.OF.REPAY
                            START.FORM.I = 61
                            GOSUB GET.SVR.FIND.INTEREST
                            GOSUB GET.BASIC.DETAILS.NOT.SLAB
                        END
                    END ELSE
                        IF NUM.OF.REPAY GE 36 THEN
                            Y.AA.INT.ID = 'EXIM.PFT.MFMS3Y.DP-BDT--20040101'
                            GOSUB GET.PRD.INTEREST.RATE
                            NO.OF.LOOP = 36
                            START.FORM.I = 1
                            GOSUB GET.BASIC.DETAILS.WITH.SLAB
                            Y.REMAINING.REPAY = NUM.OF.REPAY - 36
                            IF Y.REMAINING.REPAY GE 1 THEN
                                Y.TOT.PROFIT = 0
                                NO.OF.LOOP = NUM.OF.REPAY
                                START.FORM.I = 37
                                GOSUB GET.SVR.FIND.INTEREST
                                GOSUB GET.BASIC.DETAILS.NOT.SLAB
                            END
                        END ELSE
                            GOSUB GET.SVR.FIND.INTEREST
                            GOSUB GET.BASIC.DETAILS.NOT.SLAB
                        END
                    END
                END
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL

*--------------------------------------------AFTER 10 YEARS PROFIT----------------------------------------------
            CASE Y.DAYS GE 3600 AND Y.DAYS LT 4320
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                IF NUM.OF.REPAY GE 120 THEN
                    Y.AA.INT.ID = 'EXIM.PFT.MFMS10Y.DP-BDT--20040101'
                    GOSUB GET.PRD.INTEREST.RATE
                    NO.OF.LOOP = 120
                    START.FORM.I = 1
                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                    Y.REMAINING.REPAY = NUM.OF.REPAY - 120
                    IF Y.REMAINING.REPAY GE 1 THEN
                        Y.TOT.PROFIT = 0
                        NO.OF.LOOP = NUM.OF.REPAY
                        START.FORM.I = 121
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END ELSE
                    IF NUM.OF.REPAY GE 96 THEN
                        Y.AA.INT.ID = 'EXIM.PFT.MFMS8Y.DP-BDT--20040101'
                        GOSUB GET.PRD.INTEREST.RATE
                        NO.OF.LOOP = 96
                        START.FORM.I = 1
                        GOSUB GET.BASIC.DETAILS.WITH.SLAB
                        Y.REMAINING.REPAY = NUM.OF.REPAY - 96
                        IF Y.REMAINING.REPAY GE 1 THEN
                            Y.TOT.PROFIT = 0
                            NO.OF.LOOP = NUM.OF.REPAY
                            START.FORM.I = 97
                            GOSUB GET.SVR.FIND.INTEREST
                            GOSUB GET.BASIC.DETAILS.NOT.SLAB
                        END
                    END ELSE
                        IF NUM.OF.REPAY GE 60 THEN
                            Y.AA.INT.ID = 'EXIM.PFT.MFMS5Y.DP-BDT--20040101'
                            GOSUB GET.PRD.INTEREST.RATE
                            NO.OF.LOOP = 60
                            START.FORM.I = 1
                            GOSUB GET.BASIC.DETAILS.WITH.SLAB
                            Y.REMAINING.REPAY = NUM.OF.REPAY - 60
                            IF Y.REMAINING.REPAY GE 1 THEN
                                Y.TOT.PROFIT = 0
                                NO.OF.LOOP = NUM.OF.REPAY
                                START.FORM.I = 61
                                GOSUB GET.SVR.FIND.INTEREST
                                GOSUB GET.BASIC.DETAILS.NOT.SLAB
                            END
                        END ELSE
                            IF NUM.OF.REPAY GE 36 THEN
                                Y.AA.INT.ID = 'EXIM.PFT.MFMS3Y.DP-BDT--20040101'
                                GOSUB GET.PRD.INTEREST.RATE
                                NO.OF.LOOP = 36
                                START.FORM.I = 1
                                GOSUB GET.BASIC.DETAILS.WITH.SLAB
                                Y.REMAINING.REPAY = NUM.OF.REPAY - 36
                                IF Y.REMAINING.REPAY GE 1 THEN
                                    Y.TOT.PROFIT = 0
                                    NO.OF.LOOP = NUM.OF.REPAY
                                    START.FORM.I = 37
                                    GOSUB GET.SVR.FIND.INTEREST
                                    GOSUB GET.BASIC.DETAILS.NOT.SLAB
                                END
                            END ELSE
                                GOSUB GET.SVR.FIND.INTEREST
                                GOSUB GET.BASIC.DETAILS.NOT.SLAB
                            END
                        END
                    END
                END
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL
            
*--------------------------------------------AFTER 12 YEARS PROFIT----------------------------------------------
            CASE Y.DAYS GE 4320 AND Y.DAYS LT 7200
                Y.REPAY.REF.TOT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdRepayReference>
                NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
                IF NUM.OF.REPAY GE 144 THEN
                    Y.AA.INT.ID = 'EXIM.PFT.MFMS12Y.DP-BDT--20040101'
                    GOSUB GET.PRD.INTEREST.RATE
                    NO.OF.LOOP = 144
                    START.FORM.I = 1
                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                    Y.REMAINING.REPAY = NUM.OF.REPAY - 144
                    IF Y.REMAINING.REPAY GE 1 THEN
                        Y.TOT.PROFIT = 0
                        NO.OF.LOOP = NUM.OF.REPAY
                        START.FORM.I = 145
                        GOSUB GET.SVR.FIND.INTEREST
                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                    END
                END ELSE
                    IF NUM.OF.REPAY GE 120 THEN
                        Y.AA.INT.ID = 'EXIM.PFT.MFMS10Y.DP-BDT--20040101'
                        GOSUB GET.PRD.INTEREST.RATE
                        NO.OF.LOOP = 120
                        START.FORM.I = 1
                        GOSUB GET.BASIC.DETAILS.WITH.SLAB
                        Y.REMAINING.REPAY = NUM.OF.REPAY - 120
                        IF Y.REMAINING.REPAY GE 1 THEN
                            Y.TOT.PROFIT = 0
                            NO.OF.LOOP = NUM.OF.REPAY
                            START.FORM.I = 121
                            GOSUB GET.SVR.FIND.INTEREST
                            GOSUB GET.BASIC.DETAILS.NOT.SLAB
                        END
                    END ELSE
                        IF NUM.OF.REPAY GE 96 THEN
                            Y.AA.INT.ID = 'EXIM.PFT.MFMS8Y.DP-BDT--20040101'
                            GOSUB GET.PRD.INTEREST.RATE
                            NO.OF.LOOP = 96
                            START.FORM.I = 1
                            GOSUB GET.BASIC.DETAILS.WITH.SLAB
                            Y.REMAINING.REPAY = NUM.OF.REPAY - 96
                            IF Y.REMAINING.REPAY GE 1 THEN
                                Y.TOT.PROFIT = 0
                                NO.OF.LOOP = NUM.OF.REPAY
                                START.FORM.I = 97
                                GOSUB GET.SVR.FIND.INTEREST
                                GOSUB GET.BASIC.DETAILS.NOT.SLAB
                            END
                        END ELSE
                            IF NUM.OF.REPAY GE 60 THEN
                                Y.AA.INT.ID = 'EXIM.PFT.MFMS5Y.DP-BDT--20040101'
                                GOSUB GET.PRD.INTEREST.RATE
                                NO.OF.LOOP = 60
                                START.FORM.I = 1
                                GOSUB GET.BASIC.DETAILS.WITH.SLAB
                                Y.REMAINING.REPAY = NUM.OF.REPAY - 60
                                IF Y.REMAINING.REPAY GE 1 THEN
                                    Y.TOT.PROFIT = 0
                                    NO.OF.LOOP = NUM.OF.REPAY
                                    START.FORM.I = 61
                                    GOSUB GET.SVR.FIND.INTEREST
                                    GOSUB GET.BASIC.DETAILS.NOT.SLAB
                                END
                            END ELSE
                                IF NUM.OF.REPAY GE 36 THEN
                                    Y.AA.INT.ID = 'EXIM.PFT.MFMS3Y.DP-BDT--20040101'
                                    GOSUB GET.PRD.INTEREST.RATE
                                    NO.OF.LOOP = 36
                                    START.FORM.I = 1
                                    GOSUB GET.BASIC.DETAILS.WITH.SLAB
                                    Y.REMAINING.REPAY = NUM.OF.REPAY - 36
                                    IF Y.REMAINING.REPAY GE 1 THEN
                                        Y.TOT.PROFIT = 0
                                        NO.OF.LOOP = NUM.OF.REPAY
                                        START.FORM.I = 37
                                        GOSUB GET.SVR.FIND.INTEREST
                                        GOSUB GET.BASIC.DETAILS.NOT.SLAB
                                    END
                                END ELSE
                                    GOSUB GET.SVR.FIND.INTEREST
                                    GOSUB GET.BASIC.DETAILS.NOT.SLAB
                                END
                            END
                        END
                    END
                END
                GOSUB GET.TOTAT.REPAY.AMT
                TOT.ACC.AMT =(Y.TOT.PROFIT+Y.TOT.PRINCIPAL.INT.AMT+AFTER.MATURE.PRIN) - Y.TOT.REPAY.PRINCIPAL
        END CASE
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
        GOSUB GET.TOTAT.REPAY.AMT
        TOT.ACC.AMT = Y.ACT.PROFIT - Y.TOT.REPAY.PRINCIPAL
*-----------------------15% TAX DEDUCTION------------------------------------
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
    Y.TOT.PROFIT = Y.TOT.PROFIT + RoundAmts
    
RETURN
SLAB.PROFIT.CALCULATION:
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = Y.INT.RATE
    BaseAmts = Y.TOT.PRINCIPAL.INT.AMT
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    RoundAmts = 0
    IntAmts = 0
    AccrDays = 0
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
       
RETURN
GET.BASIC.DETAILS.WITH.SLAB:
    FOR I = START.FORM.I TO NO.OF.LOOP
        Y.REPAY.REF.ID.1 = Y.REPAY.REF.TOT<1,I>
        Y.REPAY.REF.ID.2 = Y.REPAY.REF.TOT<1,I+1>
        Y.VALUE.DATE = FIELD(Y.REPAY.REF.ID.1,'-',2)
        Y.TODAY = FIELD(Y.REPAY.REF.ID.2,'-',2)
        Y.REPAY.REFERENCE.ID = FIELD(Y.REPAY.REF.ID.1,'-',1)
        EB.DataAccess.FRead(FN.ARR.ACTIVITY, Y.REPAY.REFERENCE.ID, REC.ARR.ACTI, F.ARR.ACTIVITY, Er.ACTIVITY)
        Y.PER.REPAY.AMT = REC.ARR.ACTI<AA.Framework.ArrangementActivity.ArrActOrigTxnAmt>
        Y.TOT.PRINCIPAL.INT.AMT = Y.TOT.PRINCIPAL.INT.AMT + Y.PER.REPAY.AMT + RoundAmts
        Y.TOT.PRINCIPAL = Y.TOT.PRINCIPAL + Y.PER.REPAY.AMT
        GOSUB SLAB.PROFIT.CALCULATION
*        Y.COUNT = Y.COUNT - 1
    NEXT I
    Y.TOT.PRINCIPAL.INT.AMT = Y.TOT.PRINCIPAL.INT.AMT + RoundAmts
RETURN
GET.BASIC.DETAILS.NOT.SLAB:
    FOR I = START.FORM.I TO NO.OF.LOOP
        IF I LT NUM.OF.REPAY THEN
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
            GOSUB PROFIT.CALCULATION ;* IF bank wants to pay interest to exact preclose date or last capitalized date
        END
        AFTER.MATURE.PRIN = AFTER.MATURE.PRIN + Y.PER.REPAY.AMT
*        Y.COUNT = Y.COUNT - 1
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

GET.SVR.FIND.INTEREST:
    Y.SRC.ID = '4BDT' ;* 4BDT FIXED FOR SAVINGS ACCOUNT INTEREST
    Y.PRD.DATE = Y.PRD.START.DATE
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
GET.PRD.INTEREST.RATE:
    EB.DataAccess.FRead(FN.AA.INT,Y.AA.INT.ID,R.AA.INT,F.AA.INT,E.INT.ERR)
    Y.INT.RATE = R.AA.INT<AA.Interest.Interest.IntFixedRate>
RETURN
GET.TOTAT.REPAY.AMT:
    NUM.OF.REPAY = DCOUNT(Y.REPAY.REF.TOT,VM)
    FOR I = 1 TO NUM.OF.REPAY
        Y.REPAY.REF.ID.1 = Y.REPAY.REF.TOT<1,I>
        Y.REPAY.REFERENCE.ID = FIELD(Y.REPAY.REF.ID.1,'-',1)
        EB.DataAccess.FRead(FN.ARR.ACTIVITY, Y.REPAY.REFERENCE.ID, REC.ARR.ACTI, F.ARR.ACTIVITY, Er.ACTIVITY)
        Y.PER.REPAY.AMT = REC.ARR.ACTI<AA.Framework.ArrangementActivity.ArrActOrigTxnAmt>
        Y.TOT.REPAY.PRINCIPAL = Y.TOT.REPAY.PRINCIPAL + Y.PER.REPAY.AMT
    NEXT I
RETURN
END
