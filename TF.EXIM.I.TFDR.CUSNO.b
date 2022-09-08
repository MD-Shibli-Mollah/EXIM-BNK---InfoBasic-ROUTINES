* @ValidationCode : MjotMTE3ODYwNDM1NDpDcDEyNTI6MTU3MTgzMjk4ODEzNjpNRUhFREk6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Oct 2019 18:16:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.I.TFDR.CUSNO
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $USING LC.Contract
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING LC.Config
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.LC = 'F.LETTER.OF.CREDIT'
    F.LC = ''
*
    FN.LC.TYPE = 'F.LC.TYPES'
    F.LC.TYPE = ''
*
    APPLICATION.NAME = ''
    LOCAL.FIELD = ''
    Y.LC.LT.FLD.POS = ''
RETURN

*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.LC, F.LC)
    EB.DataAccess.Opf(FN.LC.TYPE, F.LC.TYPE)
RETURN
*----------
PROCESS:
*----------
    Y.DRAWING.ID = EB.SystemTables.getIdNew()
    Y.DRW.ID.LEN = LEN(Y.DRAWING.ID)
    Y.TF.ID = LEFT((Y.DRAWING.ID),Y.DRW.ID.LEN-2)
    EB.DataAccess.FRead(FN.LC, Y.TF.ID, R.TF.REC, F.LC, Y.TF.ERR)
    Y.LC.TYPE = R.TF.REC<LC.Contract.LetterOfCredit.TfLcLcType>
    EB.DataAccess.FRead(FN.LC.TYPE, Y.LC.TYPE, REC.LC.TYPE, F.LC.TYPE, ERR.LC.TYPE)
    Y.IMP.EXP = REC.LC.TYPE<LC.Config.Types.TypImportExport>
*
    APPLICATION.NAME ='DRAWINGS'
    LOCAL.FIELD = 'LT.TFDR.CUSNO':@VM:'LT.TFDR.LC.NO'
    EB.Foundation.MapLocalFields(APPLICATION.NAME, LOCAL.FIELD, Y.LC.LT.FLD.POS)
    Y.TFDR.CUSNO.POS = Y.LC.LT.FLD.POS<1,1>
    Y.LT.OLD.LC.POS = Y.LC.LT.FLD.POS<1,2>
    BEGIN CASE
        CASE Y.IMP.EXP EQ 'I'
            Y.DR.LOC.VAL<1,Y.TFDR.CUSNO.POS> = R.TF.REC<LC.Contract.LetterOfCredit.TfLcApplicantCustno>
            Y.DR.LOC.VAL<1,Y.LT.OLD.LC.POS> = R.TF.REC<LC.Contract.LetterOfCredit.TfLcOldLcNumber>
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef, Y.DR.LOC.VAL)
        CASE Y.IMP.EXP EQ 'E'
            Y.DR.LOC.VAL<1,Y.TFDR.CUSNO.POS> = R.TF.REC<LC.Contract.LetterOfCredit.TfLcBeneficiaryCustno>
            Y.DR.LOC.VAL<1,Y.LT.OLD.LC.POS> = R.TF.REC<LC.Contract.LetterOfCredit.TfLcOldLcNumber>
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef, Y.DR.LOC.VAL)
    END CASE
RETURN
END
*