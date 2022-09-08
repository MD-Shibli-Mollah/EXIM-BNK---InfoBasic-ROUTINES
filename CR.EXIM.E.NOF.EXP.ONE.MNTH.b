SUBROUTINE CR.EXIM.E.NOF.EXP.ONE.MNTH(Y.FINAL)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : AUTHOR(JHS, MK, JH)
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.Updates
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING AA.Settlement
    $USING AA.Interest
    $USING AA.TermAmount
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.API
    
*ST.CompanyCreation.LoadCompany("BNK")
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*******
INIT:
*******
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    FN.AA.ACCT.DET = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCT.DET = ''
    FN.AA.BILL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DET = ''
    FN.AA.INT.ACC = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INT.ACC = ''
    
    LOCATE 'MATURITY.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING MATURITY.DATE.POS THEN
        Y.MATURITY.DATE = EB.Reports.getEnqSelection()<4,MATURITY.DATE.POS>
    END
    
RETURN
*******
OPENFILES:
*******
    EB.DataAccess.Opf(FN.AA, F.AA)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.AA.ACCT.DET, F.AA.ACCT.DET)
    EB.DataAccess.Opf(FN.AA.BILL.DET, F.AA.BILL.DET)
    EB.DataAccess.Opf(FN.AA.INT.ACC, F.AA.INT.ACC)
RETURN

*******
PROCESS:
*******
    SEL.CMD = 'SELECT ':FN.AA.ACCT.DET
    
    IF(Y.MATURITY.DATE) THEN
        SEL.CMD := " AND MATURITY.DATE EQ ": Y.MATURITY.DATE
    END
    ELSE
        Y.CUR.DATE = EB.SystemTables.getToday()
        Y.CUR.DATE.AS = Y.CUR.DATE
        EB.API.Cdt('', Y.CUR.DATE.AS, '+30C')
        SEL.CMD := " AND (MATURITY.DATE GE ": Y.CUR.DATE : " AND MATURITY.DATE LE ": Y.CUR.DATE.AS : ")"
    END
    
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, "", NO.OF.RECORD, RTN.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA, F.AA, ERR.AA)
   
        Y.PROD.LINE = REC.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.PROD.LINE EQ 'LENDING' THEN
    
            Y.PROD.NAM = REC.AA<AA.Framework.Arrangement.ArrProduct>
            Y.ACCT.ID = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
            Y.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
    
            EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, REC.CUS, F.CUS, ERR.CUS)
            Y.CUS.SHORT.NAME = REC.CUS<ST.Customer.Customer.EbCusShortName>
        
            EB.DataAccess.FRead(FN.AA.ACCT.DET, Y.AA.ID, REC.AA.ACCT.DET, F.AA.ACCT.DET, ERR.AA)
            Y.TOT.BILL.TYPE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillType>
            Y.TOT.BILL.ID = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillId>
            Y.BILL.ID = '' ;* HOLD BILL ID WHICH BILL TYPE IS DISBURSEMENT

            CONVERT SM TO VM IN Y.TOT.BILL.TYPE
            CONVERT SM TO VM IN Y.TOT.BILL.ID
        
            Y.DCOUNT = DCOUNT(Y.TOT.BILL.TYPE,@VM)
            FOR I=1 TO Y.DCOUNT
                Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
                IF Y.BILL.TYPE = 'DISBURSEMENT' THEN
                    Y.BILL.ID = Y.TOT.BILL.ID<1,I>
                    BREAK
                END
            NEXT I

            EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
            Y.FIN.DATE = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdFinancialDate>
        
            EB.DataAccess.FRead(FN.AA.ACCT.DET, Y.AA.ID, REC.AA.ACCT.DET, F.AA.ACCT.DET, ERR.AA)
            Y.MAT.DATE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
        
            Y.AA.PROP.CL = 'INTEREST'
            AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.EFFECT.RATE.TOT = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>
        
            Y.EFFECT.RATE = ''
            CONVERT SM TO VM IN Y.EFFECT.RATE.TOT
            Y.ER.DCOUNT = DCOUNT(Y.EFFECT.RATE.TOT,@VM)
            FOR I=1 TO Y.ER.DCOUNT
                Y.EFFECT.RATE = Y.EFFECT.RATE.TOT<1,I>
                IF Y.EFFECT.RATE THEN
                    Y.EFFECT.RATE = Y.EFFECT.RATE<1,I>
                    BREAK
                END
            NEXT I

            Y.ACCRUED.PROFIT.TOTAL = 0
            SEL.CMD.ACP = 'SELECT ' : FN.AA.INT.ACC : ' WITH @ID LIKE ' : Y.AA.ID : '-...'
            EB.DataAccess.Readlist(SEL.CMD.ACP, SEL.LIST.ACP, "", NO.OF.RECORD, RTN.CODE)
            LOOP
                REMOVE Y.AA.NEW.ID FROM SEL.LIST.ACP SETTING POS
            WHILE Y.AA.NEW.ID:POS
                EB.DataAccess.FRead(FN.AA.INT.ACC, Y.AA.NEW.ID, REC.AA, F.AA.INT.ACC, ERR.MSG)
                Y.ACCRUED.TOT = REC.AA<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
                CONVERT SM TO VM IN Y.ACCRUED.TOT
                Y.ACR.DCOUNT = DCOUNT(Y.ACCRUED.TOT,@VM)
                FOR I=1 TO Y.ACR.DCOUNT
                    Y.TMP = Y.ACCRUED.TOT<1,I>
                    Y.ACCRUED.PROFIT.TOTAL += Y.TMP
                NEXT I
            REPEAT
    
            Y.AA.PROP.CL = 'TERM.AMOUNT'
            AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.DISBURSEMENT.AMT = R.REC.TA<AA.TermAmount.TermAmount.AmtAmount>
        
            PaymentDate = EB.SystemTables.getToday()
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            BaseBalance1 = 'RECMARKUPPROFIT'
            BaseBalance2 = 'DUEVAT'
            BaseBalance3 = 'DUEPRCSFEE'
            BaseBalance4 = 'DUESTMPJUD'
            BaseBalance5 = 'DUEREBATEFEE'
            BaseBalance6 = 'DUEAMCFEE'
            BaseBalance7 = 'DUEEDFEE'
            BaseBalance8 = 'DUEPAYOFFFEE'
            BaseBalance9 = 'DUECIBCOLFEE'
            BaseBalance10 = 'DUESTMPOTH'
            BaseBalance11 = 'DUEOTHCHG'
            BaseBalance12 = 'DUESTMPCOURT'
            BaseBalance13 = 'DUESTMPREV'
            BaseBalance14 = 'ACCPFTONOD'
            BaseBalance15 = 'ACCPENALTYPFT'
            BaseBalance16 = 'ACCSUSPFT'
            BaseBalance17 = 'DUEMARKUPPROFIT'
            BaseBalance18 = 'STDMARKUPPROFIT'
            BaseBalance19 = 'NABMARKUPPROFIT'
            BaseBalance20 = 'DUEACCOUNT'
            BaseBalance21 = 'STDACCOUNT'
            BaseBalance22 = 'NABACCOUNT'
        
            ftCreditAcctNo = Y.ACCT.ID ;* ACCOUNT ID IN FIRST PARAMETER
        
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance2, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails2, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance3, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails3, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance4, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails4, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance5, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails5, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance6, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails6, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance7, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails7, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance8, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails8, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance9, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails9, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance10, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails10, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance11, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails11, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance12, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails12, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance13, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails13, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance14, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails14, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance15, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails15, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance16, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails16, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance17, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails17, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance18, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails18, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance19, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails19, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance20, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails20, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance21, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails21, ErrorMessage)
            AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance22, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails22, ErrorMessage)
            recMarkupBal = ABS(BalDetails1<4>)
            dueVatBal = ABS(BalDetails2<4>)
            dueProcessBal = ABS(BalDetails3<4>)
            dueDueStmpjudBal = ABS(BalDetails4<4>)
            dueRebateBal = ABS(BalDetails5<4>)
            dueAmcBal = ABS(BalDetails6<4>)
            dueEdBal = ABS(BalDetails7<4>)
            duePayoffBal = ABS(BalDetails8<4>)
            dueCibColBal = ABS(BalDetails9<4>)
            dueStmpOthBal = ABS(BalDetails10<4>)
            dueOthChgBal = ABS(BalDetails11<4>)
            dueStmpCourtBal = ABS(BalDetails12<4>)
            dueStmpRevBal = ABS(BalDetails13<4>)
            accPftBal = ABS(BalDetails14<4>)
            accPenaltyBal = ABS(BalDetails15<4>)
            accSusPftBal = ABS(BalDetails16<4>)
            dueMarkupProfit = ABS(BalDetails17<4>)
            stdMarkupProfit = ABS(BalDetails18<4>)
            nabMarkupProfit = ABS(BalDetails19<4>)
            dueAccount = ABS(BalDetails20<4>)
            stdAccount = ABS(BalDetails21<4>)
            nabAccount = ABS(BalDetails22<4>)
        
            Y.totChgPenaltySusBal = dueVatBal + dueProcessBal + dueDueStmpjudBal + dueRebateBal + dueAmcBal + dueEdBal + duePayoffBal + duePayoffBal + dueCibColBal + dueStmpOthBal + dueOthChgBal + dueStmpCourtBal + dueStmpRevBal + accPftBal + accPenaltyBal + accSusPftBal + dueMarkupProfit + stdMarkupProfit + nabMarkupProfit + dueAccount + stdAccount + nabAccount
        
            BaseBalance = 'CURACCOUNT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(ftCreditAcctNo,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage) ;*Balance left in the balance Type
        
            Y.NET.OUTSTAND.BAL = BalDetails<4>
        
            Y.AA.PROP.CL = 'SETTLEMENT'
            AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
            R.REC.TA = RAISE(RET.VALUES)
            Y.PAY.IN.ACCT = R.REC.TA<AA.Settlement.Settlement.SetPayinAccount>
        
        
            Y.FINAL<-1> = Y.AA.ID : '*' : Y.PROD.NAM : '*' : Y.CUS.ID : '*' : Y.CUS.SHORT.NAME : '*' : Y.FIN.DATE : '*' : Y.MAT.DATE : '*' : Y.EFFECT.RATE : '*' : Y.ACCRUED.PROFIT.TOTAL : '*' :  Y.DISBURSEMENT.AMT : '*' : Y.totChgPenaltySusBal : '*' : Y.NET.OUTSTAND.BAL : '*' : Y.PAY.IN.ACCT
        END
    REPEAT

    Y.FINAL= Y.FINAL
RETURN
*-----------------------------------------------------------------------------
END
