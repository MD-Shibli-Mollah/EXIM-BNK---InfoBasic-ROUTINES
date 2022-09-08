SUBROUTINE CR.EXIM.E.NOF.MARKUP.INFO(Y.FINAL)
* Modification History :
* Author: (MK, ZHS, JH)
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.Updates
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING AA.Settlement
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING AA.PaymentSchedule
    $USING AA.Limit
    $USING EB.API
    $USING AA.TermAmount
    $USING LI.Config
    $USING  EB.Foundation
     
    
    
    
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
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.AA.ACCT.DET = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCT.DET = ''
    FN.AA.BILL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DET = ''
    FN.AA.ARR.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARR.ACTIVITY = ''
    FN.AA.Limit = 'F.LIMIT.REFERENCE'
    F.AA.Limit = 'LIMIT.REFERENCE'
RETURN
*******
OPENFILES:
*******
    EB.DataAccess.Opf(FN.AA, F.AA)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.AA.ACCT.DET, F.AA.ACCT.DET)
    EB.DataAccess.Opf(FN.AA.BILL.DET, F.AA.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR.ACTIVITY, F.AA.ARR.ACTIVITY)
    EB.DataAccess.Opf(FN.AA.Limit, F.AA.Limit)
RETURN

*******
PROCESS:
*******
    SEL.CMD = 'SELECT ':FN.AA :' WITH PRODUCT.LINE EQ LENDING'
    
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, "", NO.OF.RECORD, RTN.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        Y.CUR.DATE = EB.SystemTables.getToday()
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA, F.AA, ERR.AA)
        Y.PROD.NAM = REC.AA<AA.Framework.Arrangement.ArrProduct>
        Y.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
        ftCreditAcctNo = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
    
        EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, REC.CUS, F.CUS, ERR.CUS)
        Y.CUS.SHORT.NAME = REC.CUS<ST.Customer.Customer.EbCusShortName>
        Y.CUS.SECTOR=REC.CUS<ST.Customer.Customer.EbCusSector>
        
        EB.DataAccess.FRead(FN.AA.ACCT.DET, Y.AA.ID, REC.AA.ACCT.DET, F.AA.ACCT.DET, ERR.AA)
        Y.MAT.DATE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
        Y.TOT.BILL.TYPE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillType>
        Y.TOT.BILL.ID = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillId>
        
        Y.BILL.ID = '' ;* HOLD BILL ID WHICH BILL TYPE IS DISBURSEMENT
        
********************************************************
* VALUE SEPERATOR FROM AN ARRAY (BEGIN)
********************************************************
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
**********************************************************
* END

        EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
        Y.FIN.DATE = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdFinancialDate>

        
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(ftCreditAcctNo,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage) ;*Balance left in the balance Type
        Y.TOT.OUTSTANDING = BalDetails<4>

        PaymentDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        BaseBalance1 = 'DUEDEFERREDPFT'
        BaseBalance2 = 'STDDEFERREDPFT'
        BaseBalance3 = 'DUEACCOUNT'
        BaseBalance4 = 'STDACCOUNT'

        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance2, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails2, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance3, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails3, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance4, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails4, ErrorMessage)

        dueDeferreBal = ABS(BalDetails1<4>)
        stdDeferrBal = ABS(BalDetails2<4>)
        dueAccountBal = ABS(BalDetails3<4>)
        stdAccount = ABS(BalDetails4<4>)
        Y.PASTDUE.AMOUNT = dueDeferreBal + stdDeferrBal + dueAccountBal + stdAccount
        
        PaymentDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'

        BaseBalance3 = 'DUEACCOUNT'
        BaseBalance4 = 'STDACCOUNT'

        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance3, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails3, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance4, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails4, ErrorMessage)

        dueAccountBal = ABS(BalDetails3<4>)
        stdAccount = ABS(BalDetails4<4>)
        Y.PDPRINCIPAL = dueAccountBal + stdAccount

        PaymentDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        BaseBalance1 = 'DUEDEFERREDPFT'
        BaseBalance2 = 'STDDEFERREDPFT'


        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance2, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails2, ErrorMessage)

        dueDeferreBal = ABS(BalDetails1<4>)
        stdDeferrBal = ABS(BalDetails2<4>)
        Y.PDPROFIT = dueDeferreBal + stdDeferrBal

        PaymentDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        BaseBalance1 = 'ACCPENALTYPFT'

        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)

        accPenaltyBal = ABS(BalDetails1<4>)

        Y.PEPENALTY = accPenaltyBal

        PaymentDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        BaseBalance1 = 'DUEDEFERREDPFTSP'
        BaseBalance2 = 'STDDEFERREDPFTSP'


        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)
        AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance2, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails2, ErrorMessage)

        dDueDeferrEDPBal = ABS(BalDetails1<4>)
        stdDueDeferrEDPBal = ABS(BalDetails2<4>)
        Y.PD.SUSPENSE = dDueDeferrEDPBal + stdDueDeferrEDPBal


        
        Y.AA.PROP.CL = 'INTEREST'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.EFFECT.RATE = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>

    
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(ftCreditAcctNo,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage) ;*Balance left in the balance Type
        Y.LD.PRINCIPAL = BalDetails<4>

        
        Y.AA.PROP.CL = 'SETTLEMENT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.PAY.OUT.ACCT = R.REC.TA<AA.Settlement.Settlement.SetPayoutAccount>
   
        EB.DataAccess.FRead(FN.ACCT, Y.PAY.OUT.ACCT, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
        Y.PAYOUT.DES = REC.AA.BILL.DET<AC.AccountOpening.Account.ShortTitle>
         
        Y.AA.PROP.CL = 'LIMIT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.LIMIT.REFNO = R.REC.TA<AA.Limit.Limit.LimLimitReference>
        EB.DataAccess.FRead(FN.AA.Limit, Y.LIMIT.REFNO, REC.AA, F.AA.Limit, ERR.AA)
        Y.LIMIT.REFDES = REC.AA<LI.Config.LimitReference.RefShortName>
        Y.AA.PROP.CL = 'AA.ARR.ACCOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.ECONOMIC.CODE ='UA'
        Y.SECURITY.CODE ='UA'
        Y.RSDL.Status='UA'
        Y.Disburse.District='UA'
        Y.Disburse.Upazellaa='UA'
        Y.LEGACYID ='UA'
        Y.JOB.NO='UA'
        Y.DOC.REF='UA'
        Y.T24.DRW.REF='UA'
        Y.LC.REF.NO='UA'
          
        
        
        INPUTTER = REC.CUS<ST.Customer.Customer.EbCusInputter>
        Y.INP.NAME = FIELD(INPUTTER,'_',2)
        AUTHORISER = REC.CUS<ST.Customer.Customer.EbCusAuthoriser>
        Y.AUTH.NAME = FIELD(AUTHORISER,'_',2)
        
        Y.AA.PROP.CL = 'INTEREST'
        Y.PROPERTY = 'DEFERREDPFT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, Y.PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.PD.RATE = R.REC.TA<AA.Interest.Interest.IntEffectiveRate>
        
        
        
  
        Y.AA.PROP.CL = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID, Y.AA.PROP.CL, PROPERTY, '', RETURN.IDS, RET.VALUES, RET.ERROR)
        R.REC.TA = RAISE(RET.VALUES)
        Y.DISBURSEMENT.AMT = R.REC.TA<AA.TermAmount.TermAmount.AmtAmount>
            
        BaseBalance = 'RECMARKUPPROFIT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(ftCreditAcctNo,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage) ;*Balance left in the balance Type
        Y.REMAINING.MARKUP = BalDetails<4>
        
        EB.DataAccess.FRead(FN.AA.ACCT.DET, Y.AA.ID, REC.AA.ACCT.DET, F.AA.ACCT.DET, ERR.AA)
        Y.TOT.BILL.TYPE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillType>
        Y.TOT.BILL.ID = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillId>
        Y.TOT.BILL.DATE = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBillDate>
        
      
        Y.LAST.BILL.DATE = ''

        CONVERT SM TO VM IN Y.TOT.BILL.TYPE
        CONVERT SM TO VM IN Y.TOT.BILL.DATE
       

        Y.DCOUNT = DCOUNT(Y.TOT.BILL.TYPE,@VM)
        Y.FLAG = '1'
        
        Y.CUR.MON.REC = 0
        Y.CUM.REC= 0
        Y.TOT.SETTLE.STATUS = REC.AA.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdSetStatus>
        CONVERT SM TO VM IN Y.TOT.SETTLE.STATUS
        FOR I=1 TO Y.DCOUNT
            Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
            Y.SETTLE.STS = Y.TOT.SETTLE.STATUS<1,I>
            IF Y.BILL.TYPE NE 'DISBURSEMENT' AND (Y.SETTLE.STS EQ 'PAID' OR Y.SETTLE.STS EQ 'UNPAID')THEN
                Y.BILL.ID = Y.TOT.BILL.ID<1,I>
                EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
                Y.TOT.TMP.DISBURSEMENT = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdPaymentAmount>
                CONVERT SM TO VM IN Y.TOT.TMP.DISBURSEMENT
                Y.DCOUNT.TMP.DISBURSEMENT = DCOUNT(Y.TOT.TMP.DISBURSEMENT,@VM)
                FOR J=1 TO Y.DCOUNT.TMP.DISBURSEMENT
                    Y.TP.DIS = Y.TOT.TMP.DISBURSEMENT<1,J>
                    Y.CUR.MON.REC += Y.TP.DIS
                NEXT J
            END
            IF Y.BILL.TYPE NE 'DISBURSEMENT' THEN
                Y.BILL.ID = Y.TOT.BILL.ID<1,I>
                EB.DataAccess.FRead(FN.AA.BILL.DET, Y.BILL.ID, REC.AA.BILL.DET, F.AA.BILL.DET, ERR.AA)
                Y.TOT.TMP.DISBURSEMENT = REC.AA.BILL.DET<AA.PaymentSchedule.BillDetails.BdPaymentAmount>
                CONVERT SM TO VM IN Y.TOT.TMP.DISBURSEMENT
                Y.DCOUNT.TMP.DISBURSEMENT = DCOUNT(Y.TOT.TMP.DISBURSEMENT,@VM)
                FOR J=1 TO Y.DCOUNT.TMP.DISBURSEMENT
                    Y.TP.DIS = Y.TOT.TMP.DISBURSEMENT<1,J>
                    Y.CUM.REC += Y.TP.DIS
                NEXT J
            END
        
        NEXT I
    
        Y.FLAG = '1'
        Y.OLD.DATE = ''
        
        FOR I=1 TO Y.DCOUNT
            Y.BILL.TYPE = Y.TOT.BILL.TYPE<1,I>
            Y.SETTLE.STS = Y.TOT.SETTLE.STATUS<1,I>
            IF Y.BILL.TYPE EQ 'INSTALLMENT' AND Y.SETTLE.STS EQ 'UNPAID' THEN
                Y.TMP.BILL.DATE = Y.TOT.BILL.DATE<1,I>
                IF Y.FLAG EQ '1' THEN
                    Y.OLD.DATE = Y.TMP.BILL.DATE
                    Y.FLAG = '2'
                END
                ELSE
                    IF Y.TMP.BILL.DATE LT Y.OLD.DATE THEN
                        Y.OLD.DATE = Y.TMP.BILL.DATE
                    END
                END
            END
        NEXT
        
        Y.NO.DAYS.OVERDUE = 0
        Y.DAYS = 'C'
        
        IF Y.OLD.DATE THEN
            EB.API.Cdd('', Y.OLD.DATE, Y.CUR.DATE, Y.DAYS)
            Y.NO.DAYS.OVERDUE = Y.DAYS
        END
    
    
        Y.BR.CODE = REC.CUS<ST.Customer.Customer.EbCusCoCode>
            
        Y.TXN.AMT= 0
        FLD.POS = ''
        APPLICATION.NAMES = 'AA.ARRANGEMENT.ACTIVITY'
        LOCAL.FIELDS = 'IS.CONTRACT.REF'
        EB.Foundation.MapLocalFields(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
        Y.IS.CONTRACT.REF.POS = FLD.POS<1,1>

        Y.IS.CONTRACT.REF = Y.TXN.AMT =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActLocalRef,Y.IS.CONTRACT.REF.POS>
         
            
        Y.MARKUP.AMOUNT='UA'
        Y.PARTIAL.REBATE='UA'
        Y.PROFIT.CHARGED='UA'
         
        
        Y.FINAL<-1> = Y.AA.ID : '*' : Y.PROD.NAM : '*' : Y.CUS.ID : '*' : Y.CUS.SHORT.NAME : '*' : Y.FIN.DATE : '*' : Y.MAT.DATE : '*' : Y.EFFECT.RATE : '*' : Y.TOT.OUTSTANDING : '*': Y.PASTDUE.AMOUNT : '*': Y.PDPRINCIPAL : '*':  Y.PDPROFIT  : '*': Y.PEPENALTY : '*': Y.PD.SUSPENSE : '*' : Y.LD.PRINCIPAL : '*' : ftCreditAcctNo : '*' : Y.CUS.SECTOR : '*' : Y.PAY.OUT.ACCT : '*' : Y.LIMIT.REFNO : '*' : Y.LIMIT.REFDES : '*' :Y.PAYOUT.DES : '*' : Y.ECONOMIC.CODE : '*' : Y.SECURITY.CODE : '*' : Y.RSDL.Status : '*' : Y.Disburse.District : '*' : Y.Disburse.Upazellaa : '*' : Y.INP.NAME : '*' : Y.AUTH.NAME : '*' : Y.PD.RATE : '*' : Y.NO.DAYS.OVERDUE : '*' : Y.LEGACYID : '*' : Y.JOB.NO : '*' : Y.DOC.REF : '*' : Y.T24.DRW.REF : '*' : Y.LC.REF.NO: '*' : Y.DISBURSEMENT.AMT : '*' : Y.REMAINING.MARKUP : '*' : Y.CUR.MON.REC : '*' : Y.CUM.REC : '*' : Y.BR.CODE : '*' : Y.IS.CONTRACT.REF : '*' : Y.MARKUP.AMOUNT : '*' : Y.PARTIAL.REBATE : '*' : Y.PROFIT.CHARGED
***************          1                2                   3               4                           5               6                   7                           8                       9                   10                     11               12                      13               14                  15                     16                    17                         18                     19                20                      21                  22                      23                          24                              25                  26                   27               28                 29                         30                31                32                   33                34                     35                         36                      37                     38               39                  40                      41                          42                      43
    REPEAT
 
    Y.FINAL = Y.FINAL
RETURN
*-----------------------------------------------------------------------------


END
