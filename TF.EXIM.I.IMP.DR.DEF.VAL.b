* @ValidationCode : MjoxOTIwOTc2MjU3OkNwMTI1MjoxNTcxODIxMTgxODQzOk1FSEVESTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 23 Oct 2019 14:59:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.I.IMP.DR.DEF.VAL
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $USING LC.Contract
    $USING EB.Updates
    $USING EB.SystemTables
    $USING EB.DataAccess
*
    IF EB.SystemTables.getVFunction() EQ 'I' THEN
        GOSUB INIT
        GOSUB OPENFILES
        GOSUB PROCESS
    END
RETURN
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.LC = 'FBNK.LETTER.OF.CREDIT'
    F.LC  = ''
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.LC, F.LC)
RETURN
*---------
PROCESS:
*---------
    APPLICATION.NAME = 'DRAWINGS'
    LOCAL.FIELD = 'LT.TFDR.LC.NO'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELD,Y.LT.OLD.LC.POS)
    Y.LC.R.NEW.LOC.REF = EB.SystemTables.getRNewLast(LC.Contract.Drawings.TfDrLocalRef)
    Y.LC.R.OLD.LOC.REF = EB.SystemTables.getROld(LC.Contract.Drawings.TfDrLocalRef)
    Y.LC.R.NEW.VAL = Y.LC.R.NEW.LOC.REF<1,Y.LT.OLD.LC.POS>
    Y.LC.R.OLD.VAL = Y.LC.R.OLD.LOC.REF<1,Y.LT.OLD.LC.POS>
*
    IF Y.LC.R.NEW.VAL EQ '' OR Y.LC.R.OLD.VAL EQ '' THEN
        Y.DRW.ID.LEN = LEN(EB.SystemTables.getIdNew())
        Y.TF.ID = EB.SystemTables.getIdNew()[1,(Y.DRW.ID.LEN-2)]
        EB.DataAccess.FRead(FN.LC, Y.TF.ID, REC.LC, F.LC, ERR.LC)
        DRW.LC.LOC.REF<1,Y.LT.OLD.LC.POS> = REC.LC<LC.Contract.LetterOfCredit.TfLcOldLcNumber>
        EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef, DRW.LC.LOC.REF)
    END
RETURN
END
*