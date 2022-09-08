* @ValidationCode : Mjo5OTEyODM3MDk6Q3AxMjUyOjE1ODIxOTI4NjAyMzY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Feb 2020 16:01:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ED.DUE.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
* Developed By- s.azam@fortress-global.com
* Condition  : This Routine will deduct the Excise Duty twice a year as per Payment Schedule frequency
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_GTS.COMMON
    
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING EB.Updates
    $USING EB.API
    $USING AA.TermAmount
    $USING AA.Account
    $USING LI.Config
    $USING AC.Config
    $USING ST.ChargeConfig
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'I' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'A' THEN RETURN
    IF (OFS$OPERATION EQ 'VALIDATE' OR OFS$OPERATION EQ 'PROCESS') AND c_aalocCurrActivity EQ 'LENDING-ISSUEBILL-SCHEDULE*DISBURSEMENT.%' THEN RETURN
 
    FLD.POS = ''
    APPLICATION.NAME = 'LIMIT':FM:'AA.ARR.ACCOUNT'
    LOCAL.FIELDS = 'LT.ED.CHECK':FM:'LT.ED.WAIVE':VM:'LT.ED.APPLY'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.ED.CHECK.POS = FLD.POS<1,1>
    Y.ED.WAIVE.POS = FLD.POS<2,1>
    Y.ED.APPLY.POS = FLD.POS<2,2>
    TMP.DATA = ''
    Y.ED.WAIVE = ''
    Y.ED.APPLY = ''
    APP.NAME = 'AA.ARR.ACCOUNT'
    EB.API.GetStandardSelectionDets(APP.NAME, R.SS)
    Y.FIELD.NAME = 'LOCAL.REF'
    LOCATE Y.FIELD.NAME IN R.SS<AA.Account.Account.AcLocalRef> SETTING Y.POS THEN
    END
    CALL AA.GET.ACCOUNT.RECORD(R.PROPERTY.RECORD, PROPERTY.ID)
    TMP.DATA = R.PROPERTY.RECORD<1,Y.POS>
    Y.ED.WAIVE = FIELD(TMP.DATA,SM,Y.ED.WAIVE.POS)
    Y.ED.APPLY = FIELD(TMP.DATA,SM, Y.ED.APPLY.POS)
    IF Y.ED.WAIVE EQ 'YES' THEN
        RETURN
    END
    GOSUB INIT
    GOSUB OPENFILES
    IF c_aalocCurrActivity EQ 'DEPOSITS-REDEEM-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-CLOSE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-MATURE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
        GOSUB CHRG.PROCESS
    END
    IF c_aalocCurrActivity EQ 'DEPOSITS-ROLLOVER-ARRANGEMENT' THEN
        GOSUB ROLLOVER.PROCESS
    END
    IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' OR c_aalocCurrActivity EQ 'DEPOSITS-MAKEDUE-SCHEDULE' OR c_aalocCurrActivity EQ 'LENDING-MAKEDUE-SCHEDULE' THEN
        GOSUB PROCESS
    END
    
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    Y.MAX.AMT = 0
    
    Y.END.DATE = ''
    Y.START.DATE = ''
    ArrangementId = ''
    PRODUCT.LINE = ''
    Y.BD.CHG.ID = ''
    RequestType = ''
    WORKING.BALANCE = ''
    Y.LIMIT = ''
    Y.LIMIT.ID = ''
    Y.LEN = ''
    Y.ED.CHECK = ''
    Y.MAX.AMT = ''
    Y.MIN.AMT = ''
    CHARGE.AMOUNT = 0
    Y.BD.CHG.ID = ''
    
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
RETURN

********
PROCESS:
********
    
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
    
    
    
    ArrangementId = arrId
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    AA.Framework.GetArrangementProduct(ArrangementId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    PRODUCT.LINE = ArrRecord<AA.Framework.Arrangement.ArrProductLine>
    PRODUCT.GROUP = ArrRecord<AA.Framework.Arrangement.ArrProductGroup>
    AA.Framework.GetBaseBalanceList(ArrangementId, arrProp, ReqdDate, ProductId, BaseBalance)
    
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.START.DATE,Y.END.DATE,SystemDate,BalDetails,ErrorMessage)
    WORKING.BALANCE = BalDetails<4>
    
    Y.CATEGORY = AC.REC<AC.AccountOpening.Account.Category>
    IF PRODUCT.LINE EQ 'LENDING' THEN
        WORKING.BALANCE = ABS(WORKING.BALANCE)
    END
    Y.CUSTOMER = AC.REC<AC.AccountOpening.Account.Customer>
    Y.LIMIT = AC.REC<AC.AccountOpening.Account.LimitRef>
    IF Y.LIMIT NE '' THEN
        IF LEN(Y.LIMIT) LE 7 THEN
            Y.LIMIT = Y.LIMIT 'R%10'
        END ELSE
            Y.LEN = LEN(Y.LIMIT)+3
            Y.LIMIT = Y.LIMIT 'R%Y.LEN'
        END
    END
* This part is for Product wise lending Product Excise Duty Calculation
    IF Y.ED.APPLY EQ 'PRODUCT' THEN
        Y.LIMIT.ID = Y.CUSTOMER:'.':Y.LIMIT
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
        READU R.LI FROM F.LI,Y.LIMIT.ID LOCKED
            SLEEP 10
            RETURN
        END ELSE
            EB.DataAccess.FRelease(FN.LI,Y.LIMIT.ID,F.LI)
        END
        Y.ED.CHECK =  R.LI<LI.Config.Limit.LocalRef,Y.ED.CHECK.POS>

        IF Y.ED.CHECK EQ '' OR Y.ED.CHECK NE EB.SystemTables.getToday() THEN
            Y.LIMIT.ACCOUNT = R.LI<LI.Config.Limit.Account>
            Y.COUNT = DCOUNT(Y.LIMIT.ACCOUNT,VM)
            FOR I = 1 TO Y.COUNT
                Y.AC.ID = Y.LIMIT.ACCOUNT<1,I>
*                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)
*                Y.MIN.AMT += MINIMUM(BalDetails<4>)
*                Y.MAX.AMT = ABS(Y.MIN.AMT)
                BaseBalance1 = BaseBalance
                BaseBalance2 = 'DUEACCOUNT'
                BaseBalance3 = 'UNDACCOUNT'
                BaseBalance4 = 'SUBACCOUNT'
                BaseBalance5 = 'STDACCOUNT'
                BaseBalance6 = 'SMAACCOUNT'
                BaseBalance7 = 'DOFACCOUNT'
                BaseBalance8 = 'DUEACCOUNT'
                BaseBalance9 = 'GRCACCOUNT'
                BaseBalance10 = 'DELACCOUNT'
                BaseBalance11 = 'NABACCOUNT'
                BaseBalance12 = 'PAYACCOUNT'
                BaseBalance13 = 'ACCDEFERREDPFT'
                BaseBalance14 = 'ACCGRACEPFT'
                BaseBalance15 = 'ACCGRCDEFERREDPFT'
                BaseBalance16 = 'ACCPENALTYPFT'
                BaseBalance17 = 'ACCPRINCIPALPFT'
                BaseBalance18 = 'ACCSUSPFT'
                BaseBalance19 = 'DUEPRINCIPALPFT'
                BaseBalance20 = 'GRCPRINCIPALPFT'
                BaseBalance21 = 'NABPRINCIPALPFT'
            
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance1, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails1, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance2, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails2, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance3, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails3, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance4, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails4, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance5, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails5, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance6, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails6, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance7, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails7, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance8, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails8, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance9, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails9, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance10, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails10, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance11, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails11, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance12, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails12, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance13, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails13, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance14, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails14, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance15, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails15, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance16, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails16, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance17, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails17, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance18, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails18, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance19, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails19, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance20, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails20, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance21, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails21, ErrorMessage);
          
            
                balanceAmount1 =   ABS(MINIMUM(BalDetails1<4>))
                balanceAmount2 =   ABS(MINIMUM(BalDetails2<4>))
                balanceAmount3 =   ABS(MINIMUM(BalDetails3<4>))
                balanceAmount4 =   ABS(MINIMUM(BalDetails4<4>))
                balanceAmount5 =   ABS(MINIMUM(BalDetails5<4>))
                balanceAmount6 =   ABS(MINIMUM(BalDetails6<4>))
                balanceAmount7 =   ABS(MINIMUM(BalDetails7<4>))
                balanceAmount8 =   ABS(MINIMUM(BalDetails8<4>))
                balanceAmount9 =   ABS(MINIMUM(BalDetails9<4>))
                balanceAmount10 =   ABS(MINIMUM(BalDetails10<4>))
                balanceAmount11 =   ABS(MINIMUM(BalDetails11<4>))
                balanceAmount12 =   ABS(MINIMUM(BalDetails12<4>))
                balanceAmount13 =   ABS(MINIMUM(BalDetails13<4>))
                balanceAmount14 =   ABS(MINIMUM(BalDetails14<4>))
                balanceAmount15 =   ABS(MINIMUM(BalDetails15<4>))
                balanceAmount16 =   ABS(MINIMUM(BalDetails16<4>))
                balanceAmount17 =   ABS(MINIMUM(BalDetails17<4>))
                balanceAmount18 =   ABS(MINIMUM(BalDetails18<4>))
                balanceAmount19 =   ABS(MINIMUM(BalDetails19<4>))
                balanceAmount20 =   ABS(MINIMUM(BalDetails20<4>))
                balanceAmount21 =   ABS(MINIMUM(BalDetails21<4>))
            
                Y.MIN.AMT += balanceAmount1 + balanceAmount2 + balanceAmount3 + balanceAmount4 + balanceAmount5 + balanceAmount6 + balanceAmount7 + balanceAmount8 + balanceAmount9 + balanceAmount10 + balanceAmount11 + balanceAmount12 + balanceAmount13 + balanceAmount14 + balanceAmount15 + balanceAmount16 + balanceAmount17 + balanceAmount18 + balanceAmount19 + balanceAmount20 + balanceAmount21
                Y.MAX.AMT = Y.MIN.AMT
            NEXT I
            GOSUB EDPROCESS
            Y.ED.CHECK = EB.SystemTables.getToday()
            R.LI<LI.Config.Limit.LocalRef,Y.ED.CHECK.POS> = Y.ED.CHECK
            EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
            EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
        END
    END ELSE
        AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
        Y.MAX.AMT = ABS(MAXIMUM(BalDetails<4>))
        IF PRODUCT.LINE EQ 'LENDING' THEN
*            Y.MIN.AMT = MINIMUM(BalDetails<4>)
*            Y.MAX.AMT = ABS(Y.MIN.AMT)
            BaseBalance1 = BaseBalance
            BaseBalance2 = 'DUEACCOUNT'
            BaseBalance3 = 'UNDACCOUNT'
            BaseBalance4 = 'SUBACCOUNT'
            BaseBalance5 = 'STDACCOUNT'
            BaseBalance6 = 'SMAACCOUNT'
            BaseBalance7 = 'DOFACCOUNT'
            BaseBalance8 = 'DUEACCOUNT'
            BaseBalance9 = 'GRCACCOUNT'
            BaseBalance10 = 'DELACCOUNT'
            BaseBalance11 = 'NABACCOUNT'
            BaseBalance12 = 'PAYACCOUNT'
            BaseBalance13 = 'ACCDEFERREDPFT'
            BaseBalance14 = 'ACCGRACEPFT'
            BaseBalance15 = 'ACCGRCDEFERREDPFT'
            BaseBalance16 = 'ACCPENALTYPFT'
            BaseBalance17 = 'ACCPRINCIPALPFT'
            BaseBalance18 = 'ACCSUSPFT'
            BaseBalance19 = 'DUEPRINCIPALPFT'
            BaseBalance20 = 'GRCPRINCIPALPFT'
            BaseBalance21 = 'NABPRINCIPALPFT'
            
            AA.Framework.GetPeriodBalances(accountId, BaseBalance1, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails1, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance2, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails2, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance3, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails3, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance4, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails4, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance5, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails5, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance6, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails6, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance7, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails7, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance8, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails8, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance9, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails9, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance10, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails10, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance11, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails11, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance12, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails12, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance13, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails13, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance14, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails14, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance15, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails15, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance16, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails16, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance17, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails17, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance18, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails18, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance19, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails19, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance20, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails20, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance21, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails21, ErrorMessage);
          
            
            balanceAmount1 =   ABS(MINIMUM(BalDetails1<4>))
            balanceAmount2 =   ABS(MINIMUM(BalDetails2<4>))
            balanceAmount3 =   ABS(MINIMUM(BalDetails3<4>))
            balanceAmount4 =   ABS(MINIMUM(BalDetails4<4>))
            balanceAmount5 =   ABS(MINIMUM(BalDetails5<4>))
            balanceAmount6 =   ABS(MINIMUM(BalDetails6<4>))
            balanceAmount7 =   ABS(MINIMUM(BalDetails7<4>))
            balanceAmount8 =   ABS(MINIMUM(BalDetails8<4>))
            balanceAmount9 =   ABS(MINIMUM(BalDetails9<4>))
            balanceAmount10 =   ABS(MINIMUM(BalDetails10<4>))
            balanceAmount11 =   ABS(MINIMUM(BalDetails11<4>))
            balanceAmount12 =   ABS(MINIMUM(BalDetails12<4>))
            balanceAmount13 =   ABS(MINIMUM(BalDetails13<4>))
            balanceAmount14 =   ABS(MINIMUM(BalDetails14<4>))
            balanceAmount15 =   ABS(MINIMUM(BalDetails15<4>))
            balanceAmount16 =   ABS(MINIMUM(BalDetails16<4>))
            balanceAmount17 =   ABS(MINIMUM(BalDetails17<4>))
            balanceAmount18 =   ABS(MINIMUM(BalDetails18<4>))
            balanceAmount19 =   ABS(MINIMUM(BalDetails19<4>))
            balanceAmount20 =   ABS(MINIMUM(BalDetails20<4>))
            balanceAmount21 =   ABS(MINIMUM(BalDetails21<4>))
                
            Y.MAX.AMT  = balanceAmount1 + balanceAmount2 + balanceAmount3 + balanceAmount4 + balanceAmount5 + balanceAmount6 + balanceAmount7 + balanceAmount8 + balanceAmount9 + balanceAmount10 + balanceAmount11 + balanceAmount12 + balanceAmount13 + balanceAmount14 + balanceAmount15 + balanceAmount16 + balanceAmount17 + balanceAmount18 + balanceAmount19 + balanceAmount20 + balanceAmount21
        END
        GOSUB EDPROCESS
    END
RETURN

**********
EDPROCESS:
**********
    Y.FTCT.ID = 'EDCHG'
    EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
    Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
    Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
    CONVERT SM TO VM IN Y.UPTO.AMT
    CONVERT SM TO VM IN Y.MIN.AMT
    Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.AMT = Y.UPTO.AMT<1,I>
        IF Y.MAX.AMT LE Y.AMT THEN
            BREAK
        END
    NEXT I
    CHARGE.AMOUNT = Y.MIN.AMT<1,I>
********Update the Local Template********************************
    Y.BD.CHG.ID = arrId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    IF PRODUCT.LINE EQ 'LENDING' OR PRODUCT.LINE EQ 'ACCOUNTS' THEN
        IF R.BD.CHG EQ '' THEN
            R.BD.CHG<BD.CHG.CHG.TXN.DATE > = EB.SystemTables.getToday()
            IF WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.AVG.BAL.AMT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.DUE.AMT> = 0
            END ELSE
                R.BD.CHG<BD.CHG.AVG.BAL.AMT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.DUE.AMT> = CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
        END ELSE
            Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.CHG.TXN.DATE >,@VM) + 1
            R.BD.CHG<BD.CHG.CHG.TXN.DATE,Y.DCOUNT> = EB.SystemTables.getToday()
            IF WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = R.BD.CHG<BD.CHG.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.DUE.AMT> = R.BD.CHG<BD.CHG.DUE.AMT> + 0
            END ELSE
                R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = R.BD.CHG<BD.CHG.REALIZE.AMT>
                R.BD.CHG<BD.CHG.DUE.AMT> = R.BD.CHG<BD.CHG.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
        END
    END

    IF PRODUCT.LINE EQ 'DEPOSITS' THEN
        Y.AC.CLASS.ID = 'U-ED.DP'
        EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS,F.AC.CLASS,AC.CLASS.ER)
        Y.CATEGORY.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>
        LOCATE Y.CATEGORY IN Y.CATEGORY.LIST<1,1> SETTING Y.CATEG.POS THEN
*********************************************************************************************
            IF R.BD.CHG EQ '' THEN
                R.BD.CHG<BD.CHG.CHG.TXN.DATE > = EB.SystemTables.getToday()
                R.BD.CHG<BD.CHG.AVG.BAL.AMT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = 0
                R.BD.CHG<BD.CHG.DUE.AMT> = CHARGE.AMOUNT
            END ELSE
                Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.CHG.TXN.DATE >,@VM) + 1
                R.BD.CHG<BD.CHG.CHG.TXN.DATE ,Y.DCOUNT> = EB.SystemTables.getToday()
                R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = 0
                R.BD.CHG<BD.CHG.DUE.AMT> = R.BD.CHG<BD.CHG.DUE.AMT> + CHARGE.AMOUNT
            END
        END ELSE ; * Issue 5
            IF R.BD.CHG EQ '' THEN
                R.BD.CHG<BD.CHG.CHG.TXN.DATE > = EB.SystemTables.getToday()
                R.BD.CHG<BD.CHG.AVG.BAL.AMT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = 0
                R.BD.CHG<BD.CHG.DUE.AMT> = CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END ELSE
                Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.CHG.TXN.DATE >,@VM) + 1
                R.BD.CHG<BD.CHG.CHG.TXN.DATE ,Y.DCOUNT> = EB.SystemTables.getToday()
                R.BD.CHG<BD.CHG.AVG.BAL.AMT,Y.DCOUNT> = WORKING.BALANCE
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.CHG.CHG.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.REALIZE.AMT> = R.BD.CHG<BD.CHG.REALIZE.AMT> + 0
                R.BD.CHG<BD.CHG.DUE.AMT> = R.BD.CHG<BD.CHG.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
        END
    END
*********************************************************************************************
    R.BD.CHG<BD.CHG.CO.CODE> = EB.SystemTables.getIdCompany()
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate(Y.BD.CHG.ID)
    balanceAmount = CHARGE.AMOUNT
RETURN


*****************
ROLLOVER.PROCESS:
*****************
    Y.BD.CHG.ID = arrId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    balanceAmount = R.BD.CHG<BD.CHG.DUE.AMT>
RETURN

*************
CHRG.PROCESS:
*************
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
    AA.Framework.GetBaseBalanceList(ArrangementId, arrProp, ReqdDate, ProductId, BaseBalance)
    AA.Framework.GetArrangementAccountId(arrId, accountId, Currency, ReturnError)
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
    Y.MAX.AMT = MAXIMUM(ABS(BalDetails<4>))
    
    Y.FTCT.ID = 'EDCHG'
    EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
    Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
    Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
    CONVERT SM TO VM IN Y.UPTO.AMT
    CONVERT SM TO VM IN Y.MIN.AMT
    Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.AMT = Y.UPTO.AMT<1,I>
        IF Y.MAX.AMT LE Y.AMT THEN
            BREAK
        END
    NEXT I
    CHARGE.AMOUNT = Y.MIN.AMT<1,I>
    Y.DATA = CHARGE.AMOUNT
    Y.BD.CHG.ID = arrId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    balanceAmount = R.BD.CHG<BD.CHG.DUE.AMT> + CHARGE.AMOUNT
RETURN
END
