* @ValidationCode : MjotMTUxOTg4MjA2NTpDcDEyNTI6MTU5NDQ5MDk2NjE5MDp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Jul 2020 00:09:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
* @AUTHOR         : MD SHIBLI MOLLAH

SUBROUTINE GB.EXIM.DEP.MA.7(Y.DATA)
*PROGRAM E.GB.EXIM.DEP.MA.7
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*MATURITY IS LAST 7 DAYS*******
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Account
    $USING AC.AccountOpening
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING AA.ChangeProduct
    $USING EB.API
    $USING EB.Reports
*
    GOSUB INIT
*
    GOSUB OPENFILES
*
    GOSUB PROCESS
RETURN

INIT:
*
    Y.COMP = EB.SystemTables.getIdCompany()
    Y.DATE = EB.SystemTables.getToday()
*    LOCATE 'CUSTOMER.ID' IN D.FIELDS<1> SETTING CUS.ID.POS ELSE
*    END
*    Y.CUS.ID = ENQ.SELECTION<4,CUS.ID.POS>
**  Y.CUS.ID = '100119'
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    
    FN.AC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AC.DETAILS = ''
*
    Y.REPAYMENT.TYPE = ''
    
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AC.DETAILS, F.AC.DETAILS)
    EB.DataAccess.Opf(FN.AA.ARR, F.AA.ARR)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
RETURN

PROCESS:
*
    LOCATE "CUSTOMER.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING CUS.POS THEN
        Y.CUS.ID = EB.Reports.getEnqSelection()<4, CUS.POS>
    END
 
    Y.TOT.DAYS = '+7C'
    Y.DATE = EB.SystemTables.getToday()
    Y.TODAY = Y.DATE
    EB.API.Cdt('',Y.DATE, Y.TOT.DAYS)
    
*----'WITH CUSTOMER EQ ':Y.CUS.ID:'
    SEL.CMD = 'SELECT ':FN.AC.DETAILS:' WITH MATURITY.DATE GT ':Y.TODAY:' AND MATURITY.DATE LE ':Y.DATE
*
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
*
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        EB.DataAccess.FRead(FN.AA.ARR, Y.AA.ID, REC.AA, F.AA.ARR, Er)
*
        Y.PRODUCT.LINE = REC.AA<AA.Framework.Arrangement.ArrProductLine>
        Y.ARR.STATUS = REC.AA<AA.Framework.Arrangement.ArrArrStatus>
        Y.AA.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
        Y.ARR.CO.CODE = REC.AA<AA.Framework.Arrangement.ArrCoCode>
*
*Y.ARR.STATUS EQ 'EXPIRED' OR Y.ARR.STATUS EQ 'PENDING.CLOSURE'
        IF Y.PRODUCT.LINE EQ "DEPOSITS" AND (Y.ARR.STATUS EQ 'EXPIRED' OR Y.ARR.STATUS EQ 'PENDING.CLOSURE') AND Y.AA.CUS.ID EQ Y.CUS.ID AND Y.ARR.CO.CODE EQ Y.COMP THEN
*
            Y.PRODUCT = REC.AA<AA.Framework.Arrangement.ArrProduct>
            Y.CURRENCY = REC.AA<AA.Framework.Arrangement.ArrCurrency>
         
*
*----------------------ACCOUNT PROPERTY READ-----------------------------------------------------------
            PROP.CLASS.1 = 'ACCOUNT'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
            R.ACC.REC = RAISE(RETURN.VALUES.1)
            Y.ACC.NO = R.ACC.REC<AA.Account.Account.AcAccountReference>
            EB.DataAccess.FRead(FN.ACC, Y.ACC.NO, REC.ACC, F.ACC, Er.RRR)
            Y.ACC.CATEGORY = REC.ACC<AC.AccountOpening.Account.Category>
            Y.CO.CODE = REC.ACC<AC.AccountOpening.Account.CoCode>
        
*----------------------------------END----------------------------------------------------
   
*-----------------------Principal--------------------------------
            RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
            RequestType<3> = 'ALL'  ;* Projected Movements requierd
            RequestType<4> = 'ECB'  ;* Balance file to be used
            RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    
            BaseBalance = 'CURACCOUNT'
    
            Y.PAYMENT.DATE = Y.DATE
            AA.Framework.GetPeriodBalances(Y.ACC.NO, BaseBalance, RequestType, Y.PAYMENT.DATE, Y.PAYMENT.DATE, Y.PAYMENT.DATE, BalDetails, ErrorMessage)
*
            Y.CREDIT.MVMT = BalDetails<2>
            Y.DEBIT.MVMT = BalDetails<3>
            Y.AMT = BalDetails<4>
*----------------------------------END----------------------------------------------------
            EB.DataAccess.FRead(FN.AC.DETAILS, Y.AA.ID, REC.ACC.DET, F.AC.DETAILS, Er)
            Y.ACC.VALUE.DATE = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdBaseDate>
            Y.AD.MATURITY.INS = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
*
*----------------------RENEWAL PROPERTY READ-----------------------------------------------------------
            PROP.CLASS.3 = 'CHANGE.PRODUCT'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.3,PROPERTY,'',RETURN.IDS,RETURN.VALUES.3,ERR.MSG)
            R.ACC.TERM = RAISE(RETURN.VALUES.3)
            Y.ROLLLOVER.TERM = R.ACC.TERM<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
*----------------------------------END----------------------------------------------------

            Y.DATA<-1> = Y.ACC.NO:'*':Y.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.INS:'*':Y.ROLLLOVER.TERM:'*':Y.CO.CODE
*                          1              2              3             4          5               6                  7                     8                  9
        END
    REPEAT

RETURN
END