* @ValidationCode : MjotMjAxMDQ3NDEzNjpDcDEyNTI6MTU4MjAzMTM2Mjg4NDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Feb 2020 19:09:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.LIMIT.UPDATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.IS.CONTRACT
    $INSERT I_F.LIMIT
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.DataAccess
    $USING IS.Purchase
    $USING EB.Updates
    $USING AA.Limit
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
        
*----
INIT:
*----

    FLD.POS = ''
    APPLICATION.NAMES = 'AA.ARRANGEMENT.ACTIVITY':FM:'IS.CONTRACT'
    LOCAL.FIELDS = 'IS.CONTRACT.REF':FM:'LT.LIMIT.ID':VM:'LT.LIMIT.REF'
    EB.Updates.MultiGetLocRef(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
    Y.IS.CONTRACT.REF.POS = FLD.POS<1,1>
    Y.LT.LIMIT.ID.POS = FLD.POS<2,1>
    Y.LT.LIMIT.REF.POS = FLD.POS<2,2>
    
    FN.IS.CONT = 'F.IS.CONTRACT'
    F.IS.CONT = ''
    FN.LI = 'F.LIMIT'
    F.LI = ''
    
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.IS.CONT,F.IS.CONT)
    EB.DataAccess.Opf(FN.LI,F.LI)
RETURN
*-------
PROCESS:
*-------
    Y.IS.LOCAL = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActLocalRef>
    Y.IS.CONTRACT.ID = Y.IS.LOCAL<1,Y.IS.CONTRACT.REF.POS>
    EB.DataAccess.FRead(FN.IS.CONT,Y.IS.CONTRACT.ID,R.IS,F.IS.CONT,E.IS)
    Y.LIMIT.ID = R.IS<IS.Purchase.Contract.IcLocalRef,Y.LT.LIMIT.REF.POS>
    Y.LIMIT.SEQ = FIELD(R.IS<IS.Purchase.Contract.IcLocalRef,Y.LT.LIMIT.ID.POS>,'.',3)
    EB.SystemTables.setRNew(AA.Limit.Limit.LimLimitReference,Y.LIMIT.ID)
    EB.SystemTables.setRNew(AA.Limit.Limit.LimLimitSerial,Y.LIMIT.SEQ)
      
    Y.DATA = 'Limit':'*':Y.IS.LOCAL:'*':Y.IS.CONTRACT.ID:'*':Y.LIMIT.ID:'*':Y.LIMIT.SEQ
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'Limit'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
RETURN
END
