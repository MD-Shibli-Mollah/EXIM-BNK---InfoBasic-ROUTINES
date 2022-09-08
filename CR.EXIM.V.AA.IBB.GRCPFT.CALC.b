* @ValidationCode : MjoyMDMyNDA1OTk2OkNwMTI1MjoxNTg5NDM5OTk0Nzk0OnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 May 2020 13:06:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.AA.IBB.GRCPFT.CALC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING EB.Foundation
    $USING EB.API
    $USING EB.Utility
*-----------------------------------------------------------------------------
    Y.AA.ID = c_aalocArrId
    
    PROP.CLASS.TERM = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID, PROP.CLASS.TERM, PROPERTY, '', RETURN.IDS.TERM, RETURN.VALUES.TERM, ERR.MSG.TERM)
    R.TERM.AMT = RAISE(RETURN.VALUES.TERM)

WRITE.FILE:
    WriteData = ''
    !    WriteData = Y.AA.ID:'-':InsStartDtPos:'-':InsStartDt:'-':GraceRecMnth:'-':RETURN.VALUES.TERM
    WriteData = Y.AA.ID:'-':RETURN.VALUES.TERM
    FileName = 'TEST.csv'
    FilePath = 'EXIM.DATA'
    OPENSEQ FilePath,FileName TO FileOutput THEN NULL
    ELSE
        CREATE FileOutput ELSE
        END
    END
    WRITESEQ WriteData APPEND TO FileOutput ELSE
        CLOSESEQ FileOutput
    END
    CLOSESEQ FileOutput
RETURN

END