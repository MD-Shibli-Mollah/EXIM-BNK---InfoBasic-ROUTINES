* @ValidationCode : MjozMDU0NjQ4MDM6Q3AxMjUyOjE1Nzk1OTAzOTc3ODQ6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jan 2020 13:06:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.A.DUE.COM.CALC
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
    $INSERT I_F.EXIM.LPC.CHRG
    
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING AC.AccountOpening
    
*-----------------------------------------------------------------------------
    Y.AA.ID = c_aalocArrId
    Y.EXIM.LPC.ID = c_aalocArrId:'-LPC-':AA$PROPERTY.CLASS.ID
   
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

******
INIT:
******
    FN.AA.ARR.TERM.AMOUNT='F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT=''
    FN.LPC.CHRG = 'F.EXIM.LPC.CHRG'
    F.LPC.CHRG = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.AA.ARR.TERM.AMOUNT, F.AA.ARR.TERM.AMOUNT)
    EB.DataAccess.Opf(FN.LPC.CHRG,F.LPC.CHRG)
    EB.DataAccess.Opf(FN.AA,F.AA)
RETURN

********
PROCESS:
********
    EB.DataAccess.FRead(FN.AA,c_aalocArrId,R.AA,F.AA,AA.ER)
    IF R.AA<AA.ARR.ARR.STATUS> NE 'CURRENT' THEN RETURN
    PROP.CLASS = 'PAYMENT.SCHEDULE'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.ALL.PAYMENT.TYPE = R.REC<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
    LOCATE 'DEPOSIT.SAVINGS' IN Y.ALL.PAYMENT.TYPE<1,1> SETTING Y.POS THEN
        Y.INSTALL.AMT = R.REC<AA.PaymentSchedule.PaymentSchedule.PsActualAmt,Y.POS>
    END
    EB.DataAccess.FRead(FN.LPC.CHRG,Y.EXIM.LPC.ID,R.LPC.CHRG,F.LPC.CHRG,LPC.ER)
*************************
    AA.Framework.GetArrangementAccountId(c_aalocArrId, accountId, Currency, ReturnError)
    AA.Framework.GetArrangementProduct(c_aalocArrId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    BaseBalance ='CURACCOUNT'
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
    AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    WORKING.BALANCE =  AC.REC<AC.AccountOpening.Account.WorkingBalance>
*************************
    IF R.LPC.CHRG EQ '' THEN
        Y.INSTALL.AMT = Y.INSTALL.AMT
        Y.LPC.AMT = Y.INSTALL.AMT*2/100
        Y.BALANCE = WORKING.BALANCE
    END ELSE
        Y.INSTALL.AMT = R.LPC.CHRG<LPC.CHRG.AMT> + Y.INSTALL.AMT
        Y.LPC.AMT = R.LPC.CHRG<LPC.DUE.AMT> + Y.INSTALL.AMT*2/100
        Y.BALANCE = WORKING.BALANCE
    END
    Y.DATA = 'After':'*':Y.INSTALL.AMT:'*':Y.LPC.AMT:'*':Y.BALANCE:'*':Y.ALL.PAYMENT.TYPE:'*':Y.POS
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'LPC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
***********
    R.LPC.CHRG<LPC.BALANCE> = Y.BALANCE
    R.LPC.CHRG<LPC.CHRG.AMT> = Y.INSTALL.AMT
    R.LPC.CHRG<LPC.DUE.AMT> = Y.LPC.AMT
    R.LPC.CHRG<LPC.CHRG.STATUS> = AA$PROPERTY.CLASS.ID
    WRITE R.LPC.CHRG ON F.LPC.CHRG,Y.EXIM.LPC.ID
RETURN

RETURN
END
