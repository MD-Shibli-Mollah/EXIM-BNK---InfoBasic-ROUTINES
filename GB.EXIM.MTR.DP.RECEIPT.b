* @ValidationCode : MjotMzE4Mzk2MzY4OkNwMTI1MjoxNTc3MDg4MDAyODg2OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Dec 2019 14:00:02
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
 
SUBROUTINE GB.EXIM.MTR.DP.RECEIPT(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : REPORT GENERATION FOR EXIM BANK PAYMENT ORDER
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_ENQUIRY.COMMON
*
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING AA.Interest
    $USING AA.TermAmount
    
    $USING AC.AccountOpening
    $USING AA.PaymentSchedule
    $USING EB.Updates
    $USING AA.Account
    $USING AA.ChangeProduct
    $USING ST.Customer
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*_______________INITIALIZATION________________
INIT:
*-----
    Y.AA.ID = EB.Reports.getOData()
*Y.AA.ID = 'AA170805R9Q4'
*
    FN.AA.INT = 'FBNK.AA.ARR.INTEREST'
    F.AA.INT = ''
*
    FN.AA = 'FBNK.AA.ARRANGEMENT'
    F.AA = ''
*
    FN.ACCOUNT.DET = 'FBNK.AA.ACCOUNT.DETAILS'
    F.ACCOUNT.DET = ''
*
    FN.AA.PRD.GRP = 'FBNK.AA.PRODUCT.GROUP'
    F.AA.PRD.GRP = ''
*
*
    FN.ACCT = 'FBNK.ACCOUNT'
    F.ACCT = ''
*
    FN.ALT.ACCT = 'FBNK.ALTERNATE.ACCOUNT'
    F.ALT.ACCT = ''
*
    FN.CUSTOMER = 'FBNK.CUSTOMER'
    F.CUSTOMER = ''
    
    Y.BLNK.LINE = ' '
RETURN
*_________________DONE INITIALIZATION_________________

*_________________OPENING FILES___________________
OPENFILES:
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.ACCOUNT.DET,F.ACCOUNT.DET)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.ALT.ACCT, F.ALT.ACCT)
    EB.DataAccess.Opf(FN.CUSTOMER, F.CUSTOMER)
RETURN

*_______________PROCESSING IS STARTED FROM HERE_____
PROCESS:
    LOCATE "AA.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING AA.POS THEN
        Y.AA.ID = EB.Reports.getEnqSelection()<4, AA.POS>
    END
* Y.AA.ID = "AA19357Q9JYF"
*___________ID____________
    IF Y.AA.ID[1,2] NE 'AA' THEN
        EB.DataAccess.FRead(FN.ACCT,Y.AA.ID  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        IF REC.ACCT.ID EQ '' THEN
            EB.DataAccess.FRead(FN.ALT.ACCT,Y.AA.ID  ,REC.ALT.ACCT, F.ALT.ACCT, ERR.ALT.ACCT.ID)
            Y.AA.ID = REC.ALT.ACCT<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber>
            EB.DataAccess.FRead(FN.ACCT,Y.AA.ID  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        END
        Y.AA.ID = REC.ACCT.ID<AC.AccountOpening.Account.ArrangementId>
    END

    EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA.ID, F.AA, ERR.AA.ID)
*
*________EFFECTIVE DATE_______
    Y.DATE = REC.AA.ID<AA.Framework.Arrangement.ArrProdEffDate>
    
*_______MATURITY DATE_________
    EB.DataAccess.FRead(FN.ACCOUNT.DET, Y.AA.ID, REC.ACCT.DET, F.ACCOUNT.DET, ERR.ACCT)
    Y.MAT.DT = ICONV(REC.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>, 'D4')
*
*____TERM AMOUNT___SAYED_VAI
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
*
    R.REC1 = RAISE(Returnconditions1)
    Y.AMT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TRM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
*___TERM AMOUNT DONE________

*____CREDIT ACCT_RECEIVED FROM____
    Y.CR.ACC = REC.AA.ID<AA.Framework.Arrangement.ArrCustomer>
*
    EB.DataAccess.FRead(FN.CUSTOMER, Y.CR.ACC, REC.CUS, F.CUSTOMER, ERROR.CUS)
    Y.CUS.NAME = REC.CUS<ST.Customer.Customer.EbCusShortName>
* Y.CUS.NAME = REC.CUS<ST.Customer.Customer.EbCusGivenNames>
    Y.CUS.NAME.1 = REC.CUS<ST.Customer.Customer.EbCusShortName>[1,11]
*
        
*________EFFECTIVE DATE__________CONV____
    Y.DATE = ICONV(Y.DATE, 'D4')
    Y.DATE = OCONV(Y.DATE, 'D')
    Y.MAT.DT = OCONV(Y.MAT.DT, 'D')
*
*PRINT AREA

    Y.DATE.1 =    "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.DATE
    Y.MAT.DT.1 =  "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.MAT.DT
    Y.AMT.1 =     "|||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.DATE:"|||||||||||||||||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')
    Y.CUS.NAME.1 ="||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.NAME.1
    Y.CUS.NAME.2 ="||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.NAME
    GOSUB CONVT.AMT.TO.WORD1
    Y.AMT.WRD.1 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1
    Y.AMT.2 =     "||||||||||||||||||||||||||||||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')
    Y.TRM.1 =       "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.TRM
    Y.MAT.DT.2 =  "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.TRM:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.MAT.DT

    Y.RETURN = Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.DATE.1:"^":Y.BLNK.LINE:"^":Y.MAT.DT.1:"^":Y.BLNK.LINE:"^":Y.AMT.1:"^":Y.CUS.NAME.1:"^":Y.CUS.NAME.2:"^":Y.AMT.WRD.1:"^":Y.AMT.2:'^':Y.TRM.1:"^":Y.MAT.DT.2
    CONVERT '^' TO CHAR(10) IN Y.RETURN
*
RETURN

*____________COVERTION OF AMOUNT TO WORD___________

CONVT.AMT.TO.WORD1:
*------------------
    LNGVAR = Y.AMT
*
    TXTOUT = ''
    TXTVAR1=''
    INTVAL=''
    Y.COMI.LEN = LEN(LNGVAR)
    IF Y.COMI.LEN LT 20 THEN
*
        INTVAL = FIELD(LNGVAR,'.',1)
        INTVAL3 = FIELD(LNGVAR,'.',2)
*
        IF INTVAL3 NE 0 THEN
            INTVAL2=INTVAL3
        END ELSE
            INTVAL2=0
        END
*
        CORE=INT(INTVAL / 10000000)
        CALL CM.CALHUND(CORE,INTCORE)
        INTVAL = INT(INTVAL - INT(INTVAL / 10000000) * 10000000)
*
        LAC=INT(INTVAL / 100000)
        CALL CM.CALHUND(LAC,INTLAC)
        INTVAL = INT(INTVAL - INT(INTVAL / 100000) * 100000)
*
        THOUSAND=INT(INTVAL / 1000)
        CALL CM.CALHUND(THOUSAND,INTTHOUSAND)
        INTVAL = INT(INTVAL - INT(INTVAL / 1000) * 1000)
*
        HUNDRED=INT(INTVAL / 100)
        CALL CM.CALHUND(HUNDRED,INTHUNDRED)
        INTVAL = INT(INTVAL - INT(INTVAL / 100) * 100)
*
        REST=INT(INTVAL / 1)
        CALL CM.CALHUND(REST,INTREST)
*
        DES=INT(INTVAL2 / 1)
        CALL CM.CALHUND(DES,INTDES)
*
        IF LEN(INTCORE) EQ 0 THEN
            TXTVAR1=INTCORE:" ":""
        END ELSE
            TXTVAR1=INTCORE:" ":"Crore"
        END
*
        IF LEN(INTLAC) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTLAC:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTLAC:" ":"Lac"
        END
*
        IF LEN(INTTHOUSAND) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:" ":"Thousand"
        END
*
        IF LEN(INTHUNDRED) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:" ":"Hundred"
        END
*TAKA IS ALREADY AT THE RECEIPT - SHIBLI FDS
        TXTVAR1=TXTVAR1:" ":INTREST

        IF LEN(INTDES) EQ 0 THEN
*TXTVAR1=TXTVAR1:""
        END ELSE
            TXTVAR1=TXTVAR1:" ":"and":" ":INTDES:" ":"Paisa"
        END
        TXTOUT = TXTVAR1
*
*EB.Reports.setOData(TXTVAR1)
*
    END
RETURN
END