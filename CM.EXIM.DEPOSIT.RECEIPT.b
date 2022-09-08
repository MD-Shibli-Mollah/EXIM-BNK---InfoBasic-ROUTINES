* @ValidationCode : MjoxMTk2MjM0MzQ4OkNwMTI1MjoxNTc3MTA1MDc1NTk2OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Dec 2019 18:44:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.EXIM.DEPOSIT.RECEIPT(Y.RETURN)
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
    Y.BLNK.LINE= " "
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
*HEADER FOR DATE
    Y.DATE.HEAD = REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[7,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[8,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[5,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[6,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[1,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[2,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[3,1]:"|||||":REC.FT.ID<FT.Contract.FundsTransfer.DebitValueDate>[4,1]
    Y.AMT = REC.FT.ID<FT.Contract.FundsTransfer.LocAmtCredited>
    Y.CR.ACC = REC.FT.ID<FT.Contract.FundsTransfer.CreditAcctNo>
    Y.DR.ACC = REC.FT.ID<FT.Contract.FundsTransfer.DebitAcctNo>
    EB.DataAccess.FRead(FN.ACCT, Y.CR.ACC, REC.ACCT, F.ACCT, ERROR.ACCT)
    Y.ACCT.NAME = REC.ACCT<AC.AccountOpening.Account.ShortTitle>
    Y.ACCT.NAME.2 = REC.ACCT<AC.AccountOpening.Account.ShortTitle>[1,10]
    
    EB.DataAccess.FRead(FN.ACCT, Y.DR.ACC, REC.ACCT, F.ACCT, ERROR.ACCT)
    
    Y.ACCT.DR.NAME = REC.ACCT<AC.AccountOpening.Account.ShortTitle>
    Y.ACCT.DR.NAME.2 = REC.ACCT<AC.AccountOpening.Account.ShortTitle>[1,10]
    Y.DATE = ICONV(Y.DATE, 'D4')
    Y.DATE = OCONV(Y.DATE, 'D')
*PRINT AREA
    
    Y.DATE.HEAD.1 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.DATE.HEAD
    Y.ACCT.NAME.1 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||": Y.ACCT.NAME
    Y.DATE.HEAD.2= "|||":Y.DATE:"||||||||||||||||||||||||":Y.DATE
* Y.ACCT.NAME.2 ="||||||||||||||":Y.ACCT.NAME.2:"||||||||||||||||||||||||":Y.ACCT.NAME.2
    Y.ACCT.DR.NAME.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.ACCT.DR.NAME
    Y.AMT.2 =           "|||":FMT(Y.AMT, 'R2,#19'):"||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')
    Y.ACCT.DR.NAME.2 = "||||||||":Y.ACCT.DR.NAME.2:"||||||||||||||||||||||||||||||||||||||":Y.ACCT.DR.NAME.2
    Y.AMT.1 = "|||||":Y.ACCT.NAME.2:"|||||||||||||||||||||||||||||":Y.ACCT.NAME.2:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":FMT(Y.AMT, 'R2,#19')
    Y.DATE.2 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":Y.DATE
    GOSUB CONVT.AMT.TO.WORD1
    
****PRINTING IN DIFFERENT LINE IF LENGTH OVERLAPS*******
    Y.AMT.WRD.LEN = LENGTH(TXTVAR1)
    Y.AMT.WRD.POS = TXTVAR1[57,1]
    IF LENGTH(TXTVAR1) LE '56' OR Y.AMT.WRD.POS EQ ' ' THEN
        Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[1,56]
        IF Y.AMT.WRD.LEN GT '56' AND Y.AMT.WRD.POS EQ ' ' THEN
            Y.AMT.WRD.2 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[57,(Y.AMT.WRD.LEN-56)]
        END
    END ELSE
        IF Y.AMT.WRD.POS NE ' ' THEN
            I = 56
            LOOP WHILE I>= 1 DO
                IF TXTVAR1[I-1,1] EQ ' ' THEN
                    Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[1,I-1]
                    Y.AMT.WRD.2 = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1[I,Y.AMT.WRD.LEN-I+1]
                    BREAK
                END
                I--
            REPEAT
        END
    END
    
***DONE ALHAMDULILLAH SHIBLI FDS
    
* Y.AMT.WRD.1 = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||":TXTVAR1:"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    
    IF Y.AMT.WRD.2 EQ '' THEN
        Y.RETURN = Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.DATE.HEAD.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:'^':Y.BLNK.LINE:"^":Y.ACCT.NAME.1:'^':Y.DATE.HEAD.2:'^':Y.AMT.WRD.1:'^':Y.AMT.1:"^":Y.ACCT.DR.NAME.1:"^":Y.AMT.2:"^":Y.ACCT.DR.NAME.2:"^":Y.DATE.2
    END ELSE
        Y.RETURN = Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:"^":Y.DATE.HEAD.1:"^":Y.BLNK.LINE:"^":Y.BLNK.LINE:'^':Y.BLNK.LINE:"^":Y.ACCT.NAME.1:'^':Y.DATE.HEAD.2:'^':Y.AMT.WRD.1:'^':Y.AMT.WRD.2:"^":Y.AMT.1:"^":Y.ACCT.DR.NAME.1:"^":Y.AMT.2:"^":Y.ACCT.DR.NAME.2:"^":Y.BLNK.LINE:"^":Y.DATE.2
    END
    
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