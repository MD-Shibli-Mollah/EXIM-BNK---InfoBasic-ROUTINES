* @ValidationCode : MjoxNTUyNjk0NDQ5OkNwMTI1MjoxNTczNDcxMTE2NTc0Ok1FSEVESTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Nov 2019 17:18:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.EXIM.DP.RECEIPT(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_ENQUIRY.COMMON
*
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.Updates
    $USING FT.Contract
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----
INIT:
*-----
*Y.FT.ID = EB.Reports.getOData()
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
*
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
*
    Y.COMM.AMT = ""
    Y.BLNK.LINE= ""
RETURN
*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.FT, F.FT)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
RETURN
*---------
PROCESS:
*---------
*Y.FT.ID = 'FT1920601234'
*Y.FT.ID = ENQ.SELECTION<4,1>
    LOCATE "FT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING FT.POS THEN
        Y.FT.ID = EB.Reports.getEnqSelection()<4, FT.POS>
    END
    EB.DataAccess.FRead(FN.FT, Y.FT.ID, REC.FT.ID, F.FT, ERR.FT.ID)
    Y.DATE = REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>
    Y.AMT = REC.FT.ID<FT.Contract.FundsTransfer.LocAmtCredited>
    Y.CR.ACC = REC.FT.ID<FT.Contract.FundsTransfer.CreditAcctNo>
    EB.DataAccess.FRead(FN.ACCT, Y.CR.ACC, REC.ACCT, F.ACCT, ERROR.ACCT)
    Y.ACCT.NAME = REC.ACCT<AC.AccountOpening.Account.ShortTitle>
    Y.DATE = ICONV(Y.DATE, 'D4')
    Y.DATE = OCONV(Y.DATE, 'D')
    Y.DATE.1 =  "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.DATE
    Y.ACCT.NAME = "|||": Y.ACCT.NAME
    Y.AMT.1 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.AMT
    Y.DATE.2 = "||||||":Y.DATE
    GOSUB CONVT.AMT.TO.WORD1
    Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||":TXTVAR1
    Y.RETURN = Y.DATE.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:'^':Y.ACCT.NAME:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:Y.AMT.1:"^":Y.BLNK.LINE:"^":Y.DATE.2
    CONVERT '^' TO CHAR(10) IN Y.RETURN
RETURN
*------------------
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
*
        TXTVAR1=TXTVAR1:" ":INTREST:" ":"Taka"

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