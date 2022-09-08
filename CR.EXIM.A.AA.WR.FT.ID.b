* @ValidationCode : MjoxMjYwMzg4MTQzOkNwMTI1MjoxNTg1NzIwNzcyMjYzOnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 01 Apr 2020 11:59:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.A.AA.WR.FT.ID
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.TransactionControl

    IF V$FUNCTION NE 'I' THEN
        RETURN
    END

    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS

INITIALISE:
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    
    localFieldsFt = 'LT.FT.MASTER.ID': @VM :'LT.FT.ACCR.ID'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    masterFtPos = localfieldPos<1,1>
    accrualFtPos = localfieldPos<1,2>
RETURN

OPENFILE:
    EB.DataAccess.Opf(FN.FT, F.FT)
RETURN

PROCESS:
    ftId = EB.SystemTables.getIdNew()
    masterFt = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,masterFtPos>
    EB.DataAccess.FRead(FN.FT, masterFt, R.FT, F.FT, Er)
    R.FT<FT.Contract.FundsTransfer.LocalRef,accrualFtPos> = ftId
    EB.DataAccess.FWrite(FN.FT, masterFt, R.FT)
RETURN
END
