* @ValidationCode : Mjo3NTc5MDEzNDM6Q3AxMjUyOjE1NzE1NTg3MDE2MzA6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOlIxN19BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Oct 2019 14:05:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
SUBROUTINE TF.EXIM.CR.BTB.ACPT.DEF.VAL
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
    $USING EB.Foundation
    $USING LC.Contract
    $USING EB.Updates
    
    FN.LETTER.OF.CREDIT = 'F.LETTER.OF.CREDIT'
    F.LETTER.OF.CREDIT = ''
    EB.DataAccess.Opf(FN.LETTER.OF.CREDIT, F.LETTER.OF.CREDIT)
    
*Get Local field position from LC and Drawings Application
    FLD.POS = ''
    APPLICATION.NAMES = 'LETTER.OF.CREDIT':FM:'DRAWINGS'
    LOCAL.FIELDS = 'LT.JOB.NUMBER':FM:'LT.TFDR.LC.NO':VM:'LT.TFDR.CUSNO':VM:'LT.JOB.NUMBER'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.LT.LC.JOB.NO.POS = FLD.POS<1,1>
    Y.LT.TFDR.LC.NO.POS = FLD.POS<1,2>
    Y.LT.TFDR.CUSNO.POS = FLD.POS<1,3>
    Y.LT.DR.JOB.NO.POS = FLD.POS<1,4>
    
*Get Local field Value to LC Application
    DRAWING.ID = EB.SystemTables.getIdNew()
    LC.ID = DRAWING.ID[1,LEN(DRAWING.ID)-2]
    EB.DataAccess.FRead(FN.LETTER.OF.CREDIT, LC.ID, REC.LC, F.LETTER.OF.CREDIT, ERR.LC)
    Y.tmpLC = REC.LC<LC.Contract.LetterOfCredit.TfLcLocalRef>
    Y.LT.LC.JOB.NO = Y.tmpLC<1,Y.LT.LC.JOB.NO.POS>

    Y.OLD.LC.NUMBER = REC.LC<LC.Contract.LetterOfCredit.TfLcOldLcNumber>
    Y.APPL.CUST.NO = REC.LC<LC.Contract.LetterOfCredit.TfLcApplicantCustno>
    Y.DAYS = REC.LC<LC.Contract.LetterOfCredit.TfLcDays>
    
*Set Local Field Value to Drawing Application
    tmpDRAWING = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrLocalRef)
    tmpDRAWING<1,Y.LT.TFDR.LC.NO.POS> = Y.OLD.LC.NUMBER
    tmpDRAWING<1,Y.LT.TFDR.CUSNO.POS> = Y.APPL.CUST.NO
    tmpDRAWING<1,Y.LT.DR.JOB.NO.POS> = Y.LT.LC.JOB.NO
    EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef,tmpDRAWING)
    EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTenorDays,Y.DAYS)
    
RETURN

END
