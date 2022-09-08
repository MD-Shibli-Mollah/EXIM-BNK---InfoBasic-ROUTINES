* @ValidationCode : MjotNTY0MzE0MjEwOkNwMTI1MjoxNTc5Njk1MzU3Mzc5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jan 2020 18:15:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.A.DUE.LPC.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    Y.DATA = 'Start':'*':arrId:'*':balanceAmount:'*':arrProp:'*':arrRes:'*':perDat
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'LPC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

******
INIT:
******
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    Y.COUNT = 1
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.AA,F.AA)
RETURN

********
PROCESS:
********
    Y.AA.ID = arrId
    EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,AA.ER)
    IF R.AA<AA.ARR.ARR.STATUS> NE 'CURRENT' THEN RETURN
    PROP.CLASS = 'PAYMENT.SCHEDULE'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.ALL.PAYMENT.TYPE = R.REC<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
    LOCATE 'DEPOSIT.SAVINGS' IN Y.ALL.PAYMENT.TYPE<1,1> SETTING Y.POS THEN
        Y.INSTALL.AMT = R.REC<AA.PaymentSchedule.PaymentSchedule.PsActualAmt,Y.POS>
    END
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
            Y.COUNT = Y.COUNT + 1
        END
    NEXT I
    Y.INSTALL.AMT = Y.COUNT * Y.INSTALL.AMT
    balanceAmount = Y.INSTALL.AMT*2/100
    Y.DATA = arrId:'*':balanceAmount:'*':arrProp:'*':arrRes:'*':perDat
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'LPC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
RETURN
END
