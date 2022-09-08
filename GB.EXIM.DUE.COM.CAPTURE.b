* @ValidationCode : MjoxMTIwNzMyNTI4OkNwMTI1MjoxNTc5NTk1NTI5NzcyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Jan 2020 14:32:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.DUE.COM.CAPTURE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING AA.TermAmount
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.EXIM.LPC.CHRG
    $USING EB.OverrideProcessing
*-----------------------------------------------------------------------------
    
    Y.AA.ID = c_aalocArrId
    AA.Framework.GetArrangementAccountId(Y.AA.ID, Y.AC.N0, Currency, ReturnError)
    Y.TXN.AMT =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActOrigTxnAmt>
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
******
INIT:
******
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.LPC.CHRG = 'F.EXIM.LPC.CHRG'
    F.LPC.CHRG = ''
    Y.TOT.DUE.AMT = 0
    Y.EXIM.LPC.ID = c_aalocArrId:'-LPC-OVERDUE'
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.LPC.CHRG,F.LPC.CHRG)
RETURN

********
PROCESS:
********
    EB.DataAccess.FRead(FN.LPC.CHRG,Y.EXIM.LPC.ID,R.LPC.CHRG,F.LPC.CHRG,LPC.ER)
    IF R.LPC.CHRG EQ '' THEN RETURN
    IF R.LPC.CHRG<LPC.DUE.AMT> EQ 0 THEN
        RETURN
    END ELSE
        Y.TOT.LPC.AMT = R.LPC.CHRG<LPC.DUE.AMT>
        PROP.CLASS = 'TERM.AMOUNT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.INSTALL.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,AA.AC.ERROR)
        Y.TOT.BL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
        Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
        Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
        CONVERT SM TO VM IN Y.TOT.BL.TYPE
        CONVERT SM TO VM IN Y.TOT.BL.STATUS
        CONVERT SM TO VM IN Y.TOT.SET.STATUS
        Y.DCOUNT = DCOUNT(Y.TOT.BL.TYPE,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.BL.TYPE = Y.TOT.BL.TYPE<1,I>
            Y.BL.STATUS = Y.TOT.BL.STATUS<1,I>
            Y.SET.STATUS = Y.TOT.SET.STATUS<1,I>
            IF Y.BL.TYPE EQ 'EXPECTED' AND Y.BL.STATUS EQ 'AGING' AND Y.SET.STATUS EQ 'UNPAID' THEN
                Y.TOT.DUE.AMT = Y.TOT.DUE.AMT +  Y.INSTALL.AMT
            END
        NEXT I
        Y.TOT.REPAY.AMT = Y.TOT.DUE.AMT + Y.TOT.LPC.AMT
        IF Y.TOT.REPAY.AMT LE Y.TXN.AMT THEN
            R.LPC.CHRG<LPC.DUE.AMT> = 0
            WRITE R.LPC.CHRG ON F.LPC.CHRG,Y.EXIM.LPC.ID
        END ELSE
            GOSUB OVERRIDE.PROCESS
        END
    END
RETURN

*****************
OVERRIDE.PROCESS:
*****************
    Y.OVERR.ID = 'AC ':c_aalocLinkedAccount:' due amount is ': Y.TOT.DUE.AMT:' and LPC Charge is ':Y.TOT.LPC.AMT
    EB.SystemTables.setText(Y.OVERR.ID)
    Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
    Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
    EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
RETURN

RETURN
END
