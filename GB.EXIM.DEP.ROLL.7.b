* @ValidationCode : MjotOTc3NzkyNDk4OkNwMTI1MjoxNTg1OTExODc2NDE0OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 03 Apr 2020 17:04:36
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

SUBROUTINE GB.EXIM.DEP.ROLL.7(Y.DATA)
*PROGRAM GB.EXIM.DEP.MA.7.P
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Account
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING EB.API
*
    GOSUB INIT
*
    GOSUB OPENFILES
*
    GOSUB PROCESS
RETURN

INIT:
*
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
    
    Y.REPAYMENT.TYPE = ''
    
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AC.DETAILS, F.AC.DETAILS)
    EB.DataAccess.Opf(FN.AA.ARR, F.AA.ARR)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
RETURN

PROCESS:
*
    Y.TOT.DAYS = '-7C'
    Y.DATE = EB.SystemTables.getToday()
    EB.API.Cdt('',Y.DATE, Y.TOT.DAYS)
*
    SEL.CMD = 'SELECT ':FN.AC.DETAILS:' WITH LAST.RENEW.DATE GE ':Y.DATE
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
   
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        EB.DataAccess.FRead(FN.AA.ARR, Y.AA.ID, REC.AA, F.AA.ARR, Er)
        Y.PRODUCT.LINE = REC.AA<AA.Framework.Arrangement.ArrProductLine>
        Y.ARR.STATUS = REC.AA<AA.Framework.Arrangement.ArrArrStatus>
        
        IF Y.PRODUCT.LINE EQ "DEPOSITS" AND Y.ARR.STATUS EQ "CURRENT" THEN
            Y.PRODUCT = REC.AA<AA.Framework.Arrangement.ArrProduct>
            Y.CURRENCY = REC.AA<AA.Framework.Arrangement.ArrCurrency>
            Y.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
        
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
    
            AA.Framework.GetPeriodBalances(Y.ACC.NO, BaseBalance, RequestType, Y.PAYMENT.DATE, Y.PAYMENT.DATE, Y.PAYMENT.DATE, BalDetails, ErrorMessage)
*
            Y.CREDIT.MVMT = BalDetails<2>
            Y.DEBIT.MVMT = BalDetails<3>
            Y.AMT = BalDetails<4>
*----------------------------------END----------------------------------------------------
            EB.DataAccess.FRead(FN.AC.DETAILS, Y.AA.ID, REC.ACC.DET, F.AC.DETAILS, Er)
            Y.ACC.VALUE.DATE = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdBaseDate>
            Y.AD.MATURITY.DATE = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
*
*---------------------------INTEREST PROPERTY READ-----------------------------------------------
            PROP.CLASS.2 = 'INTEREST'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.2,PROPERTY,'',RETURN.IDS,RETURN.VALUES.2,ERR.MSG)
            R.ACC.INT = RAISE(RETURN.VALUES.2)
            Y.INTEREST.RATE = R.ACC.INT<AA.Interest.Interest.IntEffectiveRate>
*--------------------------------------------------------------------------------------------------
 
            Y.DATA<-1> = Y.ACC.NO:'*':Y.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.DATE:'*':Y.INTEREST.RATE:'*':Y.CO.CODE
*                          1              2            3             4            5               6                  7                        8              9
        END
    REPEAT
*
RETURN
END