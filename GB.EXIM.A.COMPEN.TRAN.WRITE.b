* @ValidationCode : MjotNzY0ODgyMjc1OkNwMTI1MjoxNTc4ODE1MTAzNDEzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Jan 2020 13:45:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.A.COMPEN.TRAN.WRITE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    
    $USING EB.DataAccess
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.RCC = 'F.EXIM.REVA.COMPEN.CALC'
    F.RCC = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.RCC,F.RCC)
RETURN

********
PROCESS:
********
    Y.RCC.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InSwiftMsg):'-':EB.SystemTables.getToday()
    Y.FT.ID = EB.SystemTables.getIdNew()
    Y.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
    IF Y.AMT EQ '' THEN
        Y.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
    END
    EB.DataAccess.FRead(FN.RCC,Y.RCC.ID,R.RCC,F.RCC,RCC.ERR)
    Y.DCOUNT = DCOUNT(R.RCC<EXIM.COMPEN.TRN.BR>,@VM)+1
    R.RCC<EXIM.COMPEN.TRN.BR,Y.DCOUNT> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InSwiftMsg)
    R.RCC< EXIM.COMPEN.TRNS.REF,Y.DCOUNT> = Y.FT.ID
    R.RCC<EXIM.COMPEN.TRNS.AMT,Y.DCOUNT> = Y.AMT
    
    EB.DataAccess.FWrite(FN.RCC,Y.RCC.ID,R.RCC)
    EB.TransactionControl.JournalUpdate(Y.RCC.ID)
    SENSITIVITY=''
RETURN
END
