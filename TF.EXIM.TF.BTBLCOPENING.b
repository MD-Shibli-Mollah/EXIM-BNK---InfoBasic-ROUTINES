* @ValidationCode : MjotMTM0MDExMDY2NjpDcDEyNTI6MTU3MTg0MTExMjI3NzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjE3X0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 23 Oct 2019 20:31:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
SUBROUTINE TF.EXIM.TF.BTBLCOPENING
*-----------------------------------------------------------------------------
* @author mortoza@datasoft-bd.com
* Check available BTB Entitlement against given JOB ID, If BTB Entitlement is available for the given JOB ID then BTB LC can issue
* AFTER AUTORIZATION OF BTB LC, UPDATE BD.BTB.JOB.REGISTER
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.Foundation
    $USING LC.Contract
    $INSERT I_F.BD.BTB.JOB.REGISTER
    $USING ST.ExchangeRate
    $USING ST.CurrencyConfig
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *FILE INITIALISATION
    GOSUB OPENFILE ; *FILE OPENING
    GOSUB PROCESS ; *BUSINESS LOGIC PROCESS
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>FILE INITIALISATION </desc>
    FN.LC='F.LETTER.OF.CREDIT'
    F.LC=''
    FN.BD.BTB.JOB.REGISTER='F.BD.BTB.JOB.REGISTER'
    F.BD.BTB.JOB.REGISTER=''
    FN.CCY = 'F.CURRENCY'
    F.CCY = ''
    Y.APP = EB.SystemTables.getApplication()
    Y.CUR.VER = EB.SystemTables.getPgmVersion()
    Y.APP.VER.ID = Y.APP:Y.CUR.VER
    Y.FUNC = EB.SystemTables.getVFunction()
    Y.NEW.ID=''
    Y.NEW.ID= EB.SystemTables.getIdNew()
    Y.BTB.CONVERT.AMT=''
    Y.BTB.RNEW.LAST = ''
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPENING </desc>
    EB.DataAccess.Opf(FN.LC, F.LC)
    EB.DataAccess.Opf(FN.BD.BTB.JOB.REGISTER, F.BD.BTB.JOB.REGISTER)
    EB.DataAccess.Opf(FN.CCY,F.CCY)
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>BUSINESS LOGIC PROCESS </desc>
    GOSUB GET.LOC.REF ; *GET LOCAL REFERENCE FIELD & POSITION
    Y.JOB.NO=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)<1,Y.JOB.NO.POS>
    !Y.JOB.CUS.NO=Y.JOB.NO[6,6]
    Y.JOB.CUS.NO=FIELD(Y.JOB.NO,'.',2,1)
    Y.BTB.CUS.NO=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcApplicantCustno)
    Y.BTB.CURRENCY = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLcCurrency)
    Y.BTB.CURRENCY.LAST = EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcLcCurrency)
    Y.LC.LOC.REF.VAL = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)
    Y.BTB.EX.RATE= Y.LC.LOC.REF.VAL<1, Y.JOB.EX.RATE.POS>
*   Y.BTB.EX.RATE = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)<1,Y.JOB.EX.RATE.POS>
    
    Y.BTB.OLD.AMT=EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcLcAmount)
    Y.BTB.AMT=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLcAmount)
    Y.BTB.RNEW.LAST = EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcLcAmount)
    
    Y.BTB.AMT.DIFF = Y.BTB.AMT ;*to find difference between RNew and ROld
    
*    BEGIN CASE
*        CASE Y.BTB.RNEW.LAST EQ ''
*            Y.BTB.AMT.CHG = Y.BTB.AMT
*        CASE Y.BTB.RNEW.LAST NE '' AND Y.BTB.AMT NE Y.BTB.RNEW.LAST
*            Y.BTB.AMT.CHG = Y.BTB.AMT - Y.BTB.RNEW.LAST
*        CASE Y.BTB.RNEW.LAST NE '' AND Y.BTB.AMT EQ Y.BTB.RNEW.LAST
*            Y.BTB.AMT.CHG = Y.BTB.AMT - Y.BTB.RNEW.LAST
*    END CASE
    
    IF Y.BTB.RNEW.LAST EQ '' THEN
        Y.BTB.AMT.CHG = Y.BTB.AMT
    END ELSE
        Y.BTB.AMT.CHG = Y.BTB.AMT - Y.BTB.RNEW.LAST
    END
    
    EB.DataAccess.FRead(FN.BD.BTB.JOB.REGISTER, Y.JOB.NO, R.JOB.REC, F.BD.BTB.JOB.REGISTER, Y.JOB.ERR)
    Y.JOB.CURRENCY=R.JOB.REC<BTB.JOB.JOB.CURRENCY>
    Y.JOB.AVL.BTB.AMT=R.JOB.REC<BTB.JOB.TOT.BTB.AVL.AMT>
*    Y.JOB.AVL.PC.AMT=R.JOB.REC<BTB.JOB.TOT.PC.AVL.AMT>
*    Y.JOB.AVL.NAU.BTB.AMT=R.JOB.REC<BTB.JOB.TOT.AVAIL.BTB.NAU>

    Y.TEMPA=''
    Y.TEMPA=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)
    Y.TEMPA<1,Y.JOB.CCY.POS>=Y.JOB.CURRENCY
    EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcLocalRef,Y.TEMPA)
    
    EB.DataAccess.FRead(FN.CCY, Y.BTB.CURRENCY, R.BTB.CCY.REC, F.CCY, Y.BTB.CCY.ERR)
    EB.DataAccess.FRead(FN.CCY, Y.JOB.CURRENCY, R.JOB.CCY.REC, F.CCY, Y.JOB.CCY.ERR)
    
    Y.CCY.MKT = '5'
    BEGIN CASE
        CASE Y.BTB.CURRENCY EQ Y.JOB.CURRENCY
            Y.EXC.RATE = '1'
            
        CASE Y.BTB.CURRENCY NE Y.JOB.CURRENCY AND Y.BTB.CURRENCY EQ LCCY
            FIND Y.CCY.MKT IN R.JOB.CCY.REC<ST.CurrencyConfig.Currency.EbCurCurrencyMarket> SETTING Y.CCY.MKT.POS1, Y.CCY.MKT.POS2, Y.CCY.MKT.POS3 THEN
                Y.JOB.CCY.EXC.RATE = R.JOB.CCY.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate, Y.CCY.MKT.POS2>
            END
            Y.EXC.RATE = DROUND((1 / Y.JOB.CCY.EXC.RATE),8)
            
        CASE Y.BTB.CURRENCY NE Y.JOB.CURRENCY AND Y.BTB.CURRENCY NE LCCY
            FIND Y.CCY.MKT IN R.BTB.CCY.REC<ST.CurrencyConfig.Currency.EbCurCurrencyMarket> SETTING Y.CCY.MKT.POS1, Y.CCY.MKT.POS2, Y.CCY.MKT.POS3 THEN
                Y.BTB.CCY.EXC.RATE = R.BTB.CCY.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate, Y.CCY.MKT.POS2>
            END
            FIND Y.CCY.MKT IN R.JOB.CCY.REC<ST.CurrencyConfig.Currency.EbCurCurrencyMarket> SETTING Y.CCY.MKT.POS1, Y.CCY.MKT.POS2, Y.CCY.MKT.POS3 THEN
                Y.JOB.CCY.EXC.RATE = R.JOB.CCY.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate, Y.CCY.MKT.POS2>
            END
            Y.EXC.RATE = DROUND((Y.BTB.CCY.EXC.RATE / Y.JOB.CCY.EXC.RATE),8)
    END CASE

*    IF Y.BTB.EX.RATE EQ '' THEN
    Y.TEMPB=''
    Y.TEMPB=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)
    Y.TEMPB<1,Y.JOB.EX.RATE.POS>=Y.EXC.RATE
    EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcLocalRef,Y.TEMPB)
    Y.BTB.CONVERT.AMT=Y.BTB.AMT.CHG * Y.EXC.RATE
    Y.BTB.AMT.DIFF = Y.BTB.AMT.DIFF * Y.EXC.RATE
*    END ELSE
*        Y.BTB.CONVERT.AMT=Y.BTB.AMT.CHG * Y.BTB.EX.RATE
*        Y.BTB.AMT.DIFF = Y.BTB.AMT.DIFF * Y.BTB.EX.RATE
*    END
    
    IF EB.SystemTables.getVFunction() EQ 'I' THEN
        GOSUB CHECK.BTB.VAL ; *CHECK BTBT LC VALIDATION
        R.JOB.REC<BTB.JOB.TOT.BTB.AVL.AMT> - = Y.BTB.CONVERT.AMT
        R.JOB.REC<BTB.JOB.TOT.AVAIL.BTB.NAU> + = Y.BTB.CONVERT.AMT
        WRITE R.JOB.REC TO F.BD.BTB.JOB.REGISTER,Y.JOB.NO
    END
    IF EB.SystemTables.getVFunction() EQ 'D' THEN
        GOSUB UPDATE.JOB.REGISTER ; *UPDATE JOB REGISTER TOTAL BTB NAU AVAILABLE AMT
    END
    IF EB.SystemTables.getVFunction() EQ 'A' THEN
        GOSUB WRITE.JOB.REG ; *WRITE JOB REGISTER ACCORDING TO BTB LC
    END

RETURN
*** </region>

*** <region name= GET.LOC.REF>
GET.LOC.REF:
*** <desc>GET LOCAL REFERENCE FIELD & POSITION </desc>
    Y.JOB.NO.POS=''
    Y.JOB.EX.RATE.POS=''
    Y.JOB.CCY.POS=''
    FLD.POS = ""
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.JOB.NUMBER":@VM:"LT.TF.JB.EX.RTE":@VM:"LT.TF.JOB.CURR"
    EB.Foundation.MapLocalFields("LETTER.OF.CREDIT", LOCAL.FIELDS, FLD.POS)
    Y.JOB.NO.POS=FLD.POS<1,1>
    Y.JOB.EX.RATE.POS=FLD.POS<1,2>
    Y.JOB.CCY.POS=FLD.POS<1,3>
RETURN
*** </region>

*** <region name= CHECK.BTB.VAL>
CHECK.BTB.VAL:
*** <desc>CHECK BTBT LC VALIDATION </desc>
    IF Y.BTB.CUS.NO NE Y.JOB.CUS.NO THEN
        EB.SystemTables.setAf(LC.Contract.LetterOfCredit.TfLcLocalRef)
        EB.SystemTables.setAv(Y.JOB.NO.POS)
        EB.SystemTables.setEtext("JOB NO CUSTOMER ID AND APPLICANT CUSTOMER ID NOT SAME")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    IF Y.BTB.CURRENCY.LAST NE '' THEN
        IF Y.BTB.CURRENCY NE Y.BTB.CURRENCY.LAST THEN
            EB.SystemTables.setAf(LC.Contract.LetterOfCredit.TfLcLcCurrency)
*EB.SystemTables.setAv(Y.JOB.NO.POS)
            EB.SystemTables.setEtext("Currency Cannot Change")
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END

*************Huraira*****************
    IF Y.BTB.CONVERT.AMT GT Y.JOB.AVL.BTB.AMT THEN
*    IF Y.TOT.NAU.AVL.BTB.AMT GT Y.JOB.AVL.BTB.AMT THEN
*        EB.SystemTables.setAf(LC.Contract.LetterOfCredit.TfLcLcAmount)
*        EB.SystemTables.setEtext("BTB LC AMOUNT MUST BE LESS THAN OR EQUAL TO THE ASSIGN JOB NO AVAILABLE BTB ENTITLEMENT AMOUNT")
*        EB.ErrorProcessing.StoreEndError()
        EB.SystemTables.setText('BTB LC AMOUNT Exceeds Available JOB Entitlement')
        Y.OVERRIDE.NO = DCOUNT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOverride),VM)
        Y.OVERRIDE.NO +=1
        EB.OverrideProcessing.StoreOverride(Y.OVERRIDE.NO)
*****************end*****************
    END




RETURN
*** </region>

*** <region name= UPDATE.JOB.REGISTER>
UPDATE.JOB.REGISTER:
*** <desc>UPDATE JOB REGISTER TOTAL BTB NAU AVAILABLE AMT </desc>
    R.JOB.REC<BTB.JOB.TOT.BTB.AVL.AMT> + = Y.BTB.AMT.DIFF
    R.JOB.REC<BTB.JOB.TOT.AVAIL.BTB.NAU> - = Y.BTB.AMT.DIFF
    WRITE R.JOB.REC TO F.BD.BTB.JOB.REGISTER,Y.JOB.NO
RETURN
*** </region>

*** <region name= WRITE.JOB.REG>
WRITE.JOB.REG:
*** <desc>WRITE JOB REGISTER ACCORDING TO BTB LC </desc>
    Y.JOB.BTB.CNT=DCOUNT(R.JOB.REC<BTB.JOB.BTB.TF.REFNO>,@VM)+1
    IF Y.JOB.BTB.CNT > 1 THEN
        R.JOB.REC<BTB.JOB.BTB.TF.REFNO,Y.JOB.BTB.CNT>=Y.NEW.ID
        R.JOB.REC<BTB.JOB.BTB.ENTLMNT,Y.JOB.BTB.CNT>=Y.BTB.AMT.DIFF
        R.JOB.REC<BTB.JOB.TOT.BTB.USE.AMT> + = Y.BTB.AMT.DIFF
***************Huraira.20190928****************************
*        R.JOB.REC<BTB.JOB.TOT.BTB.AVL.AMT> - = Y.BTB.CONVERT.AMT
***************end*****************************************
        R.JOB.REC<BTB.JOB.TOT.AVAIL.BTB.NAU> - = Y.BTB.AMT.DIFF
        WRITE R.JOB.REC TO F.BD.BTB.JOB.REGISTER,Y.JOB.NO
    END ELSE
        R.JOB.REC<BTB.JOB.BTB.TF.REFNO>=Y.NEW.ID
        R.JOB.REC<BTB.JOB.BTB.ENTLMNT>=Y.BTB.AMT.DIFF
        R.JOB.REC<BTB.JOB.TOT.BTB.USE.AMT> + = Y.BTB.AMT.DIFF
***************Huraira.20190928****************************
*        R.JOB.REC<BTB.JOB.TOT.BTB.AVL.AMT> - = Y.BTB.CONVERT.AMT
***************end*****************************************
        R.JOB.REC<BTB.JOB.TOT.AVAIL.BTB.NAU> - = Y.BTB.AMT.DIFF
        WRITE R.JOB.REC TO F.BD.BTB.JOB.REGISTER,Y.JOB.NO
    END
RETURN
*** </region>

END
