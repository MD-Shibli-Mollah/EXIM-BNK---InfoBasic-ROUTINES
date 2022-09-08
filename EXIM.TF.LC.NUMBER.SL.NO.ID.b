* @ValidationCode : MjoxNjUzMDkwMTM6Q3AxMjUyOjE1NzExMzQxMDQ1Mzk6TUVIRURJOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 15 Oct 2019 16:08:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE EXIM.TF.LC.NUMBER.SL.NO.ID
*-----------------------------------------------------------------------------
    !** FIELD definitions FOR EXIM.TF.LC.NUMBER.SL.NO
*!
* @author youremail@temenos.com
* @stereotype id
* @package infra.eb
* @uses E
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EXIM.TF.LC.NUMBER.SL.NO
*
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Updates
    $USING LC.Contract
    $USING EB.TransactionControl
*
    IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOldLcNumber) NE '' OR EB.SystemTables.getVFunction() NE 'I' THEN
        RETURN
    END
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
* TODO Add logic to validate the id
* TODO Create an EB.ERROR record if you are creating a new error code
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.COMP = 'F.COMPANY'
    F.COMP = ''
    FN.TF.OLD.SL.NO = 'F.EXIM.TF.LC.NUMBER.SL.NO'
    F.TF.OLD.SL.NO = ''
*
    Y.COMPANY.ID = EB.SystemTables.getIdCompany()
    Y.TODAY = EB.SystemTables.getToday()
RETURN
*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.COMP, F.COMP)
    EB.DataAccess.Opf(FN.TF.OLD.SL.NO, F.TF.OLD.SL.NO)
RETURN
*----------
PROCESS:
*----------
    APPLICATION.NAME = 'COMPANY'
    LOCAL.FIELD = 'LT.AD.BR.CODE'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELD,Y.LT.AD.BR.POS)
    EB.DataAccess.FRead(FN.COMP, Y.COMPANY.ID, REC.COMP, F.COMP, COMPANY.ERR)
    Y.AD.CODE = REC.COMP<ST.CompanyCreation.Company.EbComLocalRef,Y.LT.AD.BR.POS>
    IF Y.AD.CODE = '' THEN
        EB.SystemTables.setE('This is only allowed for AD Branches')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    Y.TF.LC.SL.ID = Y.AD.CODE:'.':Y.TODAY[1,4]
    EB.DataAccess.FRead(FN.TF.OLD.SL.NO, Y.TF.LC.SL.ID, REC.TF.OLD.SL.NO, F.TF.OLD.SL.NO, ERR.TF.OLD.SL.NO)
    Y.LC.TYPE = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcLcType)[1,2]
*
    IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOldLcNumber) EQ '' THEN
        IF REC.TF.OLD.SL.NO THEN
            Y.SL.LC.TYPE.CNT = DCOUNT(REC.TF.OLD.SL.NO<OLDLC.SLNO.LC.TYPE>, VM)
            Y.SL.LC.TYPE = REC.TF.OLD.SL.NO<OLDLC.SLNO.LC.TYPE>
*
            FIND Y.LC.TYPE IN Y.SL.LC.TYPE SETTING Y.FM,Y.VM,Y.SM THEN
                Y.CURR.SQ.NO = FMT((REC.TF.OLD.SL.NO<OLDLC.SLNO.SERIAL.NO,Y.VM> + 1), "R%4")
                Y.OLD.LC.NUM = Y.AD.CODE:Y.TODAY[3,2]:Y.LC.TYPE:Y.CURR.SQ.NO
                REC.TF.OLD.SL.NO<OLDLC.SLNO.SERIAL.NO,Y.VM> = Y.CURR.SQ.NO
                WRITE REC.TF.OLD.SL.NO ON F.TF.OLD.SL.NO,Y.TF.LC.SL.ID
                EB.TransactionControl.JournalUpdate('')
                SENSITIVITY = ''
                EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcOldLcNumber, Y.OLD.LC.NUM)
            END ELSE
                Y.OLD.LC.NUM = Y.AD.CODE:Y.TODAY[3,2]:Y.LC.TYPE:'0001'
                REC.TF.OLD.SL.NO<OLDLC.SLNO.LC.TYPE,Y.SL.LC.TYPE.CNT+1> = Y.LC.TYPE
                REC.TF.OLD.SL.NO<OLDLC.SLNO.SERIAL.NO,Y.SL.LC.TYPE.CNT+1> = '0001'
                WRITE REC.TF.OLD.SL.NO ON F.TF.OLD.SL.NO,Y.TF.LC.SL.ID
                EB.TransactionControl.JournalUpdate('')
                SENSITIVITY = ''
                EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcOldLcNumber, Y.OLD.LC.NUM)
            END
        END ELSE
            Y.OLD.LC.NUM = Y.AD.CODE:Y.TODAY[3,2]:Y.LC.TYPE:'0001'
            REC.TF.OLD.SL.NO<OLDLC.SLNO.LC.TYPE> = Y.LC.TYPE
            REC.TF.OLD.SL.NO<OLDLC.SLNO.SERIAL.NO> = '0001'
            EB.SystemTables.setIdNew(Y.TF.LC.SL.ID)
            WRITE REC.TF.OLD.SL.NO ON F.TF.OLD.SL.NO,Y.TF.LC.SL.ID
            EB.TransactionControl.JournalUpdate('')
            SENSITIVITY = ''
            EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcOldLcNumber, Y.OLD.LC.NUM)
        END
    END
RETURN
END
