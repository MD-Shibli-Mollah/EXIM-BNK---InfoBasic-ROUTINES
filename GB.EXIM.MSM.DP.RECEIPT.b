* @ValidationCode : MjotNzQzMjg4NTE2OkNwMTI1MjoxNTc5Nzc5Mzk0MjU0OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Jan 2020 17:36:34
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
 
SUBROUTINE GB.EXIM.MSM.DP.RECEIPT(Y.RETURN)
*PROGRAM GB.EXIM.MSM.DP.RECEIPT
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
    $USING EB.Foundation
    $USING ST.CompanyCreation
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*_______________INITIALIZATION________________
INIT:
*-----
    Y.AA.ID = EB.Reports.getOData()

    FN.AA.INT = 'FBNK.AA.ARR.INTEREST'
    F.AA.INT = ''

    FN.AA = 'FBNK.AA.ARRANGEMENT'
    F.AA = ''

    FN.ACCOUNT.DET = 'FBNK.AA.ACCOUNT.DETAILS'
    F.ACCOUNT.DET = ''

    FN.AA.PRD.GRP = 'FBNK.AA.PRODUCT.GROUP'
    F.AA.PRD.GRP = ''

    FN.ACCT = 'FBNK.ACCOUNT'
    F.ACCT = ''

    FN.ALT.ACCT = 'FBNK.ALTERNATE.ACCOUNT'
    F.ALT.ACCT = ''

    FN.CUSTOMER = 'FBNK.CUSTOMER'
    F.CUSTOMER = ''
    
    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    
    Y.BLNK.LINE = '  '
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
    EB.DataAccess.Opf(FN.COMPANY, F.COMPANY)
RETURN

*_______________PROCESSING IS STARTED FROM HERE_____
PROCESS:
    LOCATE "AA.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING AA.POS THEN
        Y.AA.ID = EB.Reports.getEnqSelection()<4, AA.POS>
    END
*    Y.AA.ID = 'AA19357BW2KL'
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
*________EFFECTIVE DATE_______
    Y.DATE = REC.AA.ID<AA.Framework.Arrangement.ArrProdEffDate>
*HEADER FOR DATE
* Y.DATE.HEAD = REC.AA.ID<AA.Framework.Arrangement.ArrProdEffDate>[7,2]:REC.AA.ID<AA.Framework.Arrangement.ArrProdEffDate>[5,2]:REC.AA.ID<AA.Framework.Arrangement.ArrProdEffDate>[1,4]
    
*_______MATURITY DATE_________
    EB.DataAccess.FRead(FN.ACCOUNT.DET, Y.AA.ID, REC.ACCT.DET, F.ACCOUNT.DET, ERR.ACCT)
    Y.MAT.DT = ICONV(REC.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>, 'D4')
*____TERM AMOUNT___SAYED_VAI
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.AMT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TRM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
    
    IF Y.TRM EQ "1Y" THEN
        Y.TRM = "12"
    END
    ELSE
        Y.TRM = Y.TRM
    END
*___TERM AMOUNT DONE________

*___LOCAL REF
    Y.CUS.FATHER.NAME.POS=''
    Y.CUS.SPS.NAME.POS=''
    
*___FAHTER'S NAME/ SPOUSE NAME__ SHIBLI FDS______*
    FLD.POS = ""
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CUS.FAR.NAME":@VM:"LT.CUS.SPS.NAME"
    EB.Foundation.MapLocalFields("CUSTOMER", LOCAL.FIELDS, FLD.POS)
    Y.CUS.FATHER.NAME.POS= FLD.POS<1,1>
    Y.CUS.SPS.NAME.POS = FLD.POS<1,2>


*____CREDIT ACCT_RECEIVED FROM____
    Y.CR.ACC = REC.AA.ID<AA.Framework.Arrangement.ArrCustomer>
    EB.DataAccess.FRead(FN.CUSTOMER, Y.CR.ACC, REC.CUS, F.CUSTOMER, ERROR.CUS)

    Y.CUS.NAME = REC.CUS<ST.Customer.Customer.EbCusGivenNames>
    Y.CUS.NAME.2 = REC.CUS<ST.Customer.Customer.EbCusShortName>
    Y.BRANCH = REC.CUS<ST.Customer.Customer.EbCusCoCode>
*
    Y.TOTAL.LT= REC.CUS<ST.Customer.Customer.EbCusLocalRef>
    Y.CUS.FAT.NAME = Y.TOTAL.LT<1,Y.CUS.FATHER.NAME.POS>
    Y.CUS.SPS.NAME = Y.TOTAL.LT<1.Y.CUS.SPS.NAME.POS>
    
*_________EITHER FATHERS NAME OR SPOUSE NAME______*
    IF Y.CUS.FAT.NAME EQ "" THEN
        Y.CUS.FAT.NAME = Y.CUS.SPS.NAME
    END

*_____COMPANY_CODE_BRANCH_NAME SHIBLI FDS____*
    EB.DataAccess.FRead(FN.COMPANY, Y.BRANCH, REC.COM, F.COMPANY, ERROR.COM)
    Y.COM.BR = REC.COM<ST.CompanyCreation.Company.EbComCompanyName>
        
*________EFFECTIVE DATE__________CONV____
    Y.DATE = ICONV(Y.DATE, 'D4')
    Y.DATE = OCONV(Y.DATE, 'D')
    Y.MAT.DT = OCONV(Y.MAT.DT, 'D')
*
    Y.CUS.FAT.NAME.LEN = LENGTH(Y.CUS.FAT.NAME)
    Y.CUS.SPS.NAME.LEN = LENGTH(Y.CUS.SPS.NAME)
    
    IF Y.CUS.FAT.NAME.LEN GE "14" THEN
        Y.CUS.FAT.NAME.1 = Y.CUS.FAT.NAME[1,14]
    END
    IF Y.CUS.FAT.NAME.LEN LT "14" THEN
        Y.CUS.FAT.NAME.1 = Y.CUS.FAT.NAME
    END
    IF Y.CUS.SPS.NAME.LEN GE "14" THEN
        Y.CUS.FAT.NAME.1 = Y.CUS.SPS.NAME[1,14]
    END
    IF Y.CUS.FAT.NAME.1 EQ "" THEN
        Y.CUS.FAT.NAME.1 = Y.CUS.SPS.NAME
    END
*PRINT AREA

    Y.DATE.1 =    "|||||||||||||||||||||||||||||||||||||||||||||":Y.COM.BR:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.DATE
    Y.COM.BR =    "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.COM.BR
    Y.CUS.NAME.1 ="||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.DATE:"||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.NAME
    Y.CUS.NAME.2 ="|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.NAME.2
    Y.CUS.FAT.NAME = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.FAT.NAME
    Y.CUS.FAT.NAME.1="|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.CUS.FAT.NAME.1
    GOSUB CONVT.AMT.TO.WORD1
    Y.AMT.WRD.1 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1
    Y.TRM =       "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.TRM:"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.TRM:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.MAT.DT
    Y.MAT.DT.1 =  "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.MAT.DT
    Y.AMT.1 =     "||||||||||||||||||||||||||||||||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')
    Y.AMT.2 =     "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')

    Y.RETURN = Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.DATE.1:"^":Y.COM.BR:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.CUS.NAME.1:"^":Y.BLNK.LINE:'^':Y.CUS.NAME.2:"^":Y.CUS.FAT.NAME:"^":Y.BLNK.LINE:'^':Y.CUS.FAT.NAME.1:'^':Y.AMT.WRD.1:'^':Y.TRM:"^":Y.MAT.DT.1:"^":Y.AMT.1:"^":Y.BLNK.LINE:"^":Y.AMT.2
    CONVERT '^' TO CHAR(10) IN Y.RETURN
    
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
        TXTVAR1=TXTVAR1:" ":INTREST:" "

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