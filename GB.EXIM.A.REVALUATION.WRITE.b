* @ValidationCode : Mjo2OTU3MzA5OTM6Q3AxMjUyOjE1Nzg1Njc3MDQ1MzI6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Jan 2020 17:01:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.A.REVALUATION.WRITE
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
    Y.CO.CODE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CoCode)
    Y.AC.ONLINE.ACTUAL.BALANCE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
    IF Y.AC.ONLINE.ACTUAL.BALANCE EQ '' THEN
        Y.AC.ONLINE.ACTUAL.BALANCE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
    END
    Y.ACCOUNT.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    IF Y.ACCOUNT.ID[1,3] EQ 'BDT' THEN
        Y.ACCOUNT.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    END
    Y.TREASURY.RATE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TreasuryRate)
    EB.DataAccess.FRead(FN.RCC,Y.RCC.ID,R.RCC,F.RCC,RCC.ERR)
    Y.DCOUNT = DCOUNT(R.RCC<EXIM.TXN.DATE>,@VM)+1
    R.RCC<EXIM.TXN.DATE,Y.DCOUNT> = EB.SystemTables.getToday()
    R.RCC<EXIM.FCY.AC.NO,Y.DCOUNT> = Y.ACCOUNT.ID
    R.RCC<EXIM.FCY.EXC.RATE,Y.DCOUNT> = Y.TREASURY.RATE
    R.RCC<EXIM.FCY.AMOUNT,Y.DCOUNT> = Y.AC.ONLINE.ACTUAL.BALANCE
    R.RCC<EXIM.LCY.AMOUNT,Y.DCOUNT> = Y.AC.ONLINE.ACTUAL.BALANCE * Y.TREASURY.RATE
    R.RCC<EXIM.TRNS.REF,Y.DCOUNT> = Y.FT.ID
    EB.DataAccess.FWrite(FN.RCC,Y.RCC.ID,R.RCC)
    EB.TransactionControl.JournalUpdate(Y.RCC.ID)
    SENSITIVITY=''
RETURN
END
