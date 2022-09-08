* @ValidationCode : MjotODc1MzE4ODg5OkNwMTI1MjoxNTcyMzQ4Njk5Mzg0Ok1FSEVESTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 29 Oct 2019 17:31:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.I.DOC.REG.CONT.JOB.VAL
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.SCT.CAPTURE
    $INSERT I_F.BD.BTB.JOB.REGISTER
    $INSERT I_F.LETTER.OF.CREDIT
*
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING LC.Contract
    $USING EB.Updates
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'I' THEN
        GOSUB INIT
        GOSUB OPENFILES
        GOSUB PROCESS
        RETURN
    END
*****
INIT:
*****
    FN.JOB.REG = 'F.BD.BTB.JOB.REGISTER'
    F.JOB.REG = ''
    FN.SCT.CAP = 'F.BD.SCT.CAPTURE'
    F.SCT.CAP = ''
    FLD.POS = ''
    APPLICATION.NAME = 'LETTER.OF.CREDIT'
    LOCAL.FIELD = 'LT.TF.SCONT.ID':VM:'LT.JOB.NUMBER':VM:'LT.TF.JOB.CURR'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME,LOCAL.FIELD,FLD.POS)
    Y.SCONT.ID.POS = FLD.POS<1,1>
    Y.JOB.NUMBER.POS = FLD.POS<1,2>
    Y.JOB.CURR.POS = FLD.POS<1,3>
*
    Y.CUSTOMER = EB.SystemTables.getRNew(TF.LC.BENEFICIARY.CUSTNO)
    Y.LC.CURR = EB.SystemTables.getRNew(TF.LC.LC.CURRENCY)
    Y.LC.AMOUNT = EB.SystemTables.getRNew(TF.LC.LC.AMOUNT)
    Y.SCONT.ID = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)<1,Y.SCONT.ID.POS>
    Y.JOB.REG.ID = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)<1,Y.JOB.NUMBER.POS>
RETURN
***********
OPENFILES:
***********
    EB.DataAccess.Opf(FN.JOB.REG,F.JOB.REG)
    EB.DataAccess.Opf(FN.SCT.CAP,F.SCT.CAP)
RETURN
********
PROCESS:
********
    EB.DataAccess.FRead(FN.SCT.CAP,Y.SCONT.ID,R.SCONT.REC,F.SCT.CAP,E.SCT.CAP)
    Y.SCT.CUS.NO = R.SCONT.REC<SCT.BENEFICIARY.CUSTNO>
    Y.SCT.CURR = R.SCONT.REC<SCT.CURRENCY>
    Y.SCT.AMT = R.SCONT.REC<SCT.CONTRACT.AMT>
    Y.SCT.AMT = R.SCONT.REC<SCT.CONTRACT.AMT>
*Y.TENOR.DAYS = R.SCONT.REC<SCT.TENOR.DAYS>
    EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcDays,Y.TENOR.DAYS)
*******Default JOB no assign to LT.JOB.NUMBER fields *******
***************CHANGE(29-Otc-2019/Mehedi)*******************
*IF Y.JOB.REG.ID EQ '' THEN
    Y.JOB.REG.ID = R.SCONT.REC<SCT.BTB.JOB.NO>
    Y.LOC.JOB=''
    Y.LOC.JOB=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)
    Y.LOC.JOB<1,Y.JOB.NUMBER.POS>=Y.JOB.REG.ID
    EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcLocalRef,Y.LOC.JOB)
*    END ELSE
*        Y.JOB.REG.ID.DEFAULT = R.SCONT.REC<SCT.BTB.JOB.NO>
*        IF Y.JOB.REG.ID.DEFAULT NE Y.JOB.REG.ID THEN
*            EB.SystemTables.setAf(SCT.BTB.JOB.NO)
*            EB.SystemTables.setAv(1)
*            EB.SystemTables.setEtext('JOB no Does not belongs to Sales Contract ID')
*            EB.ErrorProcessing.StoreEndError()
*        END
*    END
**************CHANGE END(29-Oct-2019)**************************
*******End Default JOB no assign to LT.JOB.NUMBER fields*******
*
*******Compare Document Custmer NO and Sales Contract Customer NO are same or not*******
    IF (Y.SCONT.ID NE '' AND Y.SCT.CUS.NO NE Y.CUSTOMER) THEN
        EB.SystemTables.setAf(SCT.BENEFICIARY.CUSTNO)
        EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('Document Customer NO and Contract Customer NO not same')
        EB.ErrorProcessing.StoreEndError()
    END
*******End Compare Document Custmer NO and Sales Contract Customer NO are same*******
*******Compare Document Currency  and Sales Contract Currency  are same or not*******
    IF Y.LC.CURR NE Y.SCT.CURR THEN
        EB.SystemTables.setAf(TF.LC.LC.CURRENCY)
        EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('Document Currency and Contract Currency not same')
        EB.ErrorProcessing.StoreEndError()
    END
******* End Compare Document Currency  and Sales Contract Currency  are same or not*******
*******Compare Document Amount  and Sales Contract Amount  are same or not*******
    IF Y.LC.AMOUNT GT Y.SCT.AMT THEN
        Y.OVERR.ID ='Document Amount Greater than Contract Amount'
        EB.SystemTables.setText(Y.OVERR.ID)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END
*******End Compare Document Amount  and Sales Contract Amount  are same or not*******
    EB.DataAccess.FRead(FN.JOB.REG,Y.JOB.REG.ID,R.JOB.REG,F.JOB.REG,E.JOB.REG)
    Y.JOB.CUS.NO = R.JOB.REG<BTB.JOB.CUSTOMER.NO>
    Y.JOB.CURR = R.JOB.REG<BTB.JOB.JOB.CURRENCY>
*******Compare Document Custmer NO and Job Register Customer NO are same or not*******
    IF (Y.JOB.REG.ID NE '' AND Y.JOB.CUS.NO NE Y.CUSTOMER) THEN
        EB.SystemTables.setAf(BTB.JOB.CUSTOMER.NO)
        EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('Document Customer NO and Job Customer NO not same')
        EB.ErrorProcessing.StoreEndError()
    END
*******End Compare Document Custmer NO and Job Register Customer NO are same or not*******
*******Compare Document Currency NO and Job Register Currency are same or not*******
    IF Y.LC.CURR NE Y.JOB.CURR THEN
        Y.OVERR.ID ='Document Currency and Job Currency not same'
        EB.SystemTables.setText(Y.OVERR.ID)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END
*******End Compare Document Currency NO and Job Register Currency are same or not*******
******Assign Job Currency*****
    Y.LOC.TEMP=''
    Y.LOC.TEMP=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLocalRef)
    Y.LOC.TEMP<1,Y.JOB.CURR.POS>=Y.JOB.CURR
    EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcLocalRef,Y.LOC.TEMP)
RETURN
END