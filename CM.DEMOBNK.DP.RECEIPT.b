* @ValidationCode : Mjo4MzY4NjY3OTQ6Q3AxMjUyOjE1NzI3ODIzMjI3MDI6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 03 Nov 2019 17:58:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.DEMOBNK.DP.RECEIPT(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
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
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----
INIT:
*-----
    Y.AA.ID = EB.Reports.getOData()
*Y.AA.ID = 'AA170805R9Q4'
*
    FN.AA.INT = 'F.AA.ARR.INTEREST'
    F.AA.INT = ''
*
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
*
    FN.ACCOUNT.DET = 'F.AA.ACCOUNT.DETAILS'
    F.ACCOUNT.DET = ''
*
    FN.AA.PRD.GRP = 'F.AA.PRODUCT.GROUP'
    F.AA.PRD.GRP = ''
*
    FN.AA.TRM = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.TRM = ''
*
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
*
    FN.ALT.ACCT = 'F.ALTERNATE.ACCOUNT'
    F.ALT.ACCT = ''
*
    Y.BLNK.LINE = '  '
    Y.BLNK.LINE.1 = ' '
RETURN
*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.ACCOUNT.DET,F.ACCOUNT.DET)
    EB.DataAccess.Opf(FN.AA.TRM, F.AA.TRM)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.ALT.ACCT, F.ALT.ACCT)
RETURN
*--------
PROCESS:
*--------
    Y.AA.ID = ENQ.SELECTION<4,1>
    IF Y.AA.ID[1,2] NE 'AA' THEN
        EB.DataAccess.FRead(FN.ACCT,Y.AA.ID  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        IF REC.ACCT.ID EQ '' THEN
            EB.DataAccess.FRead(FN.ALT.ACCT,Y.AA.ID  ,REC.ALT.ACCT, F.ALT.ACCT, ERR.ALT.ACCT.ID)
            Y.AA.ID = REC.ALT.ACCT<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber>
            EB.DataAccess.FRead(FN.ACCT,Y.AA.ID  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
        END
        Y.AA.ID = REC.ACCT.ID<AC.AccountOpening.Account.ArrangementId>
    END
*_________________CHANGED_________________________________________________
    EB.DataAccess.FRead(FN.ALT.ACCT,Y.AA.ID  ,REC.AA, F.ALT.ACCT, ERR.ALT.ACCT.ID)
    Y.PRD.NAME = REC.AA<AA.Framework.Arrangement.ArrProductGroup>
    IF Y.PRD.NAME EQ 'IPDC.APS.DP' OR Y.PRD.NAME EQ 'IPDC.CPS.DP' OR Y.PRD.NAME EQ 'IPDC.MPS.DP' OR Y.PRD.NAME EQ 'IPDC.QPS.DP' OR Y.PRD.NAME EQ 'IPDC.HPS.DP' OR Y.PRD.NAME EQ 'IPDC.FDR.DP' THEN
*--------------------For Interest Rate & Period---------------------------
        SEL.CMD = 'SELECT ':FN.AA.INT:" WITH @ID LIKE ":Y.AA.ID:"..."
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, Y.SEL.ERR)
        SEL.LIST = SORT(SEL.LIST)
        Y.INT.ID = SEL.LIST<NO.OF.REC>
        EB.DataAccess.FRead(FN.AA.INT, Y.INT.ID, REC.INT, F.AA.INT, ERR.INT)
        Y.INT.RATE = DROUND(REC.INT<AA.Interest.Interest.IntEffectiveRate>,2):'%'
*Y.INT.RATE.1 = "|||||||||||||||||||||||||||||||":Y.INT.RATE
*Y.PRE.PRE = REC.INT<AA.Interest.Interest.IntPeriodicPeriod>
        EB.DataAccess.FRead(FN.ACCOUNT.DET, Y.AA.ID, REC.ACCT.DET, F.ACCOUNT.DET, ERR.ACCT)
        Y.T24.ACCT.ID = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
        Y.PRD.GRP.ID = REC.AA<AA.Framework.Arrangement.ArrProductGroup>
        EB.DataAccess.FRead(FN.AA.PRD.GRP, Y.PRD.GRP.ID, REC.PRD.GPR, F.AA.PRD.GRP, ERR.PRG.GRP)
        EB.DataAccess.FRead(FN.ACCT,Y.T24.ACCT.ID  ,REC.ACCT, F.ACCT, ERR.ACCT)
*-----------Account Local Field(Title)---------
        LOCAL.FIELDS = 'LT.ACCT.TITLE'
        APPLICATION.NAME.1 = 'AA.ARR.ACCOUNT'
        EB.Updates.MultiGetLocRef(APPLICATION.NAME.1, LOCAL.FIELDS, FLD.POS)
        PROP.CLASS = 'ACCOUNT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.AA.ACT = RAISE(RETURN.VALUES)
        Y.LT.ACCT.NM.POS = FLD.POS<1,1>
        Y.RECVD.FR = R.AA.ACT<AA.Account.Account.AcLocalRef,Y.LT.ACCT.NM.POS>
*Y.RECVD.FR =  REC.ACCT<AC.AccountOpening.Account.AccountTitleOne>
        Y.RECVD.FR.1 = "|||||||||||||||||||||||||||||||||||||||||||":Y.RECVD.FR
*--------------------------------------------
        Y.PRD.DES = REC.PRD.GPR<AA.ProductFramework.ProductGroup.PgDescription>
*-----------------------------Committment Amount--------------------------
        AA.Framework.GetEcbBalanceAmount(Y.T24.ACCT.ID, 'TOTCOMMITMENT', EB.SystemTables.getToday(), Y.COMM.AMT, RetError)
        Y.COMM.AMT.1 = "|||||||||||||||||||||||||||":FMT(Y.COMM.AMT, 'R2,#19')
        GOSUB CONVT.AMT.TO.WORD
        Y.AMT.WRD.LEN = LENGTH(TXTVAR1)
        Y.AMT.WRD.POS = TXTVAR1[81,1]
        IF LENGTH(TXTVAR1) LE '80' OR Y.AMT.WRD.POS EQ ' ' THEN
            Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[1,80]
            IF Y.AMT.WRD.LEN GT '80' AND Y.AMT.WRD.POS EQ ' ' THEN
                Y.AMT.WRD.2 = "|||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[81,(Y.AMT.WRD.LEN-80)]
            END
        END ELSE
            IF Y.AMT.WRD.POS NE ' ' THEN
                I = 80
                LOOP WHILE I>= 1 DO
                    IF TXTVAR1[I-1,1] EQ ' ' THEN
                        Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[1,I-1]
                        Y.AMT.WRD.2 = "|||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[I,Y.AMT.WRD.LEN-I+1]
                        BREAK
                    END
                    I--
                REPEAT
            END
        END
        Y.EFF.DT = ICONV(REC.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdBaseDate>, 'D4')
        Y.EFF.DT.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":OCONV(Y.EFF.DT, 'D')
        Y.MAT.DT = ICONV(REC.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>, 'D4')
        IF Y.MAT.DT EQ '' THEN
            Y.MAT.DT = ICONV(REC.ACCT.DET<AA.PaymentSchedule.AccountDetails.AdRenewalDate>, 'D4')
        END
        Y.MAT.DT.1 = "||||||||||||||||||||||||||||||||||||||||":OCONV(Y.MAT.DT, 'D')
        Y.DES.ACCT.ID = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.PRD.DES:" : ":Y.T24.ACCT.ID
*
        SEL.CMD.TRM = 'SELECT ':FN.AA.TRM:" WITH @ID LIKE ":Y.AA.ID:"..."
        EB.DataAccess.Readlist(SEL.CMD.TRM, SEL.LIST.TRM, '', NO.OF.REC.TRM, Y.SEL.ERR)
        SEL.LIST.TRM = SORT(SEL.LIST.TRM)
        Y.TRM.ID = SEL.LIST.TRM<NO.OF.REC.TRM>
        EB.DataAccess.FRead(FN.AA.TRM, Y.TRM.ID, REC.TRM, F.AA.TRM, ERR.TRM)
        Y.PRE.PRE = REC.TRM<AA.TermAmount.TermAmount.AmtTerm>
        PROP.CLASS.1 = 'CHANGE.PRODUCT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS.1,RETURN.VALUES.1,ERR.MSG.1)
*
        R.AA.ACT = RAISE(RETURN.VALUES.1)
    
        IF Y.PRE.PRE EQ '' THEN
            Y.PRE.PRE = R.AA.ACT<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
        END
        Y.PRE.PRE.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.INT.RATE:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.PRE.PRE
*
        IF Y.AMT.WRD.2 EQ '' THEN
            Y.RETURN = Y.EFF.DT.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:'^':Y.DES.ACCT.ID:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.RECVD.FR.1:"^":Y.BLNK.LINE:"^":Y.AMT.WRD.1:"^":Y.BLNK.LINE:"^":Y.PRE.PRE.1:"^":Y.BLNK.LINE:"^":Y.MAT.DT.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.COMM.AMT.1
        END ELSE
            Y.RETURN = Y.EFF.DT.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:'^':Y.DES.ACCT.ID:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.RECVD.FR.1:"^":Y.BLNK.LINE:"^":Y.AMT.WRD.1:"^":Y.AMT.WRD.2:"^":Y.PRE.PRE.1:"^":Y.BLNK.LINE:"^":Y.MAT.DT.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.COMM.AMT.1
        END
        CONVERT '^' TO CHAR(10) IN Y.RETURN
    END
RETURN
*------------------
CONVT.AMT.TO.WORD:
*------------------
    LNGVAR = Y.COMM.AMT
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

        IF LEN(INTLAC) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTLAC:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTLAC:" ":"Lac"
        END

        IF LEN(INTTHOUSAND) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:" ":"Thousand"
        END

        IF LEN(INTHUNDRED) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:" ":"Hundred"
        END

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
