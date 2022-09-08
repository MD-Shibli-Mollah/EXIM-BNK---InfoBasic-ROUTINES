* @ValidationCode : MjoyNjU5Mjk1NTM6Q3AxMjUyOjE1NzEzMDAyOTIxNzY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOlIxN19BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Oct 2019 14:18:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
SUBROUTINE TF.EXIM.CR.BILL.TYPE.CHK
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.Foundation
    $USING LC.Contract

    FN.LETTER.OF.CREDIT = 'F.LETTER.OF.CREDIT'
    F.LETTER.OF.CREDIT = ''
    EB.DataAccess.Opf(FN.LETTER.OF.CREDIT,F.LETTER.OF.CREDIT)

    LC.ID = EB.SystemTables.getComi()
    EB.DataAccess.FRead(FN.LETTER.OF.CREDIT, LC.ID, REC.LC, F.LETTER.OF.CREDIT, ERR.LC)
    tmp.LC.CRDT.TYPE = REC.LC<LC.Contract.LetterOfCredit.TfLcLcType>

    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.FDBC.EXREG' AND tmp.LC.CRDT.TYPE NE 'EXST' THEN
        DRAWING.ID = ''
        EB.SystemTables.setIdNew(DRAWING.ID)
        EB.SystemTables.setE("Not FDBC Bill")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.LDBC.EXREG' AND REC.LC<LC.Contract.LetterOfCredit.TfLcLcType> NE 'LCST' THEN
        DRAWING.ID = ''
        EB.SystemTables.setIdNew(DRAWING.ID)
        EB.SystemTables.setE("Not LDBC Bill")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.FDBP.EXREG' AND tmp.LC.CRDT.TYPE NE 'EXST' THEN
        DRAWING.ID = ''
        EB.SystemTables.setIdNew(DRAWING.ID)
        EB.SystemTables.setE("Not FDBP Bill")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.LDBP.EXREG' AND tmp.LC.CRDT.TYPE NE 'LCST' THEN
        DRAWING.ID = ''
        EB.SystemTables.setIdNew(DRAWING.ID)
        EB.SystemTables.setE("Not LDBP Bill")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    
RETURN
END