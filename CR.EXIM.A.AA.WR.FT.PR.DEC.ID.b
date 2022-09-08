* @ValidationCode : MjotNDIwNTIxNTI6Q3AxMjUyOjE1ODU3MjA3NTgxMTA6dG93aGlkdGlwdTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Apr 2020 11:59:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.A.AA.WR.FT.PR.DEC.ID
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
    
    localFieldsFt = 'LT.FT.MASTER.ID': @VM :'LT.FT.PR.DEC.ID'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    masterFtPos = localfieldPos<1,1>
    prinDecrFtPos = localfieldPos<1,2>
RETURN

OPENFILE:
    EB.DataAccess.Opf(FN.FT, F.FT)
RETURN

PROCESS:
    ftId = EB.SystemTables.getIdNew()
    masterFt = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,masterFtPos>
    EB.DataAccess.FRead(FN.FT, masterFt, R.FT, F.FT, Er)
    R.FT<FT.Contract.FundsTransfer.LocalRef,prinDecrFtPos> = ftId
    EB.DataAccess.FWrite(FN.FT, masterFt, R.FT)
RETURN

END
