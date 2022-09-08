* @ValidationCode : Mjo5MzQwMjk5MDE6Q3AxMjUyOjE1ODI0NjQzMTAyNTY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 23 Feb 2020 19:25:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.TEST(Y.RETURN.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.CUSTOMER
     
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING AA.Interest
    $USING EB.Reports
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING EB.SystemTables
    $USING AA.TermAmount
    $USING AA.Limit
  
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----
INIT:
*----
    Y.CUS.OP = EB.Reports.getEnqSelection()<3,1>
    Y.CUS.ID = EB.Reports.getEnqSelection()<4,1>
    Y.INST.SIZE = 0
    Y.PD.AMT = 0
    Y.FDBP = 0
    Y.LDBP = 0
    Y.MIB.AMT = 0
    Y.MPI = 0
    Y.MTR = 0
    Y.WO3.AMT = 0
    Y.BAIM.SHARE = 0
    Y.BAIM.FO = 0
    Y.BIAM.LDBP.AMT = 0
    Y.MUSH.LDBP = 0
    Y.BAIM.PC = 0
    Y.BAIM.EXP.AMT = 0
    Y.ECC.AMT = 0
    Y.IZARA.HBL.AMT = 0
    Y.IZARA.Mach.AMT = 0
    Y.IZARA.TRANS.AMT = 0
    Y.BAIM.CCH.AMT = 0
    Y.TOTAL.FINAL = 0
    

    Y.LI.REF = '3651':FM:'3652':FM:'6611':VM:'6613':FM:'6612':VM:'6614':FM'6615':VM:'6616':FM:'6622':VM:'6632':FM:'6623':VM:'6634':FM:'6624':VM:'6635':FM:'6627':VM:'6637':FM:  '6651' :FM: '6638'   :FM:'6621'  :FM:'6671':VM:'6672':FM:  '6742'   :FM: '6743'     :FM:'6744'       :FM:'6633'
*               <FDBP>  <LDBP> <      MIB       >    <       MPI     >  <      MTR      >  <       WO.AMT   >  <    BAIM.SHARE    >   <   BAIM.FO    >   < BIAM.LDBP.AMT >     <MUSH.LDBP> <BAIM.PC>   <BAIM.EXP>    <   ECC        >    <IZARA.HBL>    <IZARA.Mach>    <IZARA.TRANS>    <BAIM.CCH>
    Y.RETURN.DATA = Y.CUS.NAME:'*':Y.CUS.ID:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0:'*':0
    FN.AA='F.AA.ARRANGEMENT'
    F.AA=''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.BILL = 'F.AA.BILL.DETAILS'
    F.BILL = ''
    FN.AA.INT.AC = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INT.AC = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
RETURN

*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.BILL,F.BILL)
    EB.DataAccess.Opf(FN.AA.INT.AC,F.AA.INT.AC)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
RETURN

*-------
PROCESS:
*-------
    SEL.CMD = 'SELECT ':FN.AA:" WITH CUSTOMER ":Y.CUS.OP:' ':Y.CUS.ID
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',TOT.REC,RET.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING Y.POS
    WHILE Y.AA.ID:Y.POS
        EB.DataAccess.FRead(FN.CUS,Y.CUS.ID,R.CUS,F.CUS,E.CUS)
        Y.CUS.NAME = R.CUS<ST.Customer.Customer.EbCusShortName>
        AA.Framework.GetArrangementAccountId(Y.AA.ID,accountId,Currency,ReturnError)
        
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.CURAC.BAL = BalDetails<4>
        
        EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,E.RR)
        Y.TOT.BL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
        Y.TOT.BILL.ID = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillId>
        Y.TOT.SET.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdSetStatus>
        CONVERT SM TO VM IN Y.TOT.BL.STATUS
        CONVERT SM TO VM IN Y.TOT.BILL.ID
        CONVERT SM TO VM IN Y.TOT.SET.STATUS
        Y.DCOUNT = DCOUNT(Y.TOT.BL.STATUS,@VM)
        FOR I = 1 TO Y.DCOUNT
            Y.BL.STATUS = Y.TOT.BL.STATUS<1,I>
            Y.SET.STATUS = Y.TOT.SET.STATUS<1,I>
            IF Y.BL.STATUS EQ 'DUE' AND Y.SET.STATUS EQ 'UNPAID' THEN
                Y.BL.ID = Y.TOT.BILL.ID<1,I>
                EB.DataAccess.FRead(FN.BILL,Y.BL.ID,R.BILL,F.BILL,E.BILL)
                Y.BILL.AMT = R.BILL<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
                Y.PD.AMT = Y.PD.AMT + Y.BILL.AMT
            END
        NEXT I
        
        PROP.CLASS.PS = 'PAYMENT.SCHEDULE'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.PS,PROPERTY,'',RETURN.IDS,RETURN.VALUES.PS,ERR.MSG)
        R.REC.PS = RAISE(RETURN.VALUES.PS)
        Y.INST.SIZE = TRIM(R.REC.PS<AA.PaymentSchedule.PaymentSchedule.PsCalcAmount>,']','R')
        IF Y.INST.SIZE EQ '' THEN
            Y.INST.SIZE = TRIM(R.REC.PS<AA.PaymentSchedule.PaymentSchedule.PsActualAmt>,']','R')
        END
        PROP.CLASS.TA = 'TERM.AMOUNT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.TA,PROPERTY,'',RETURN.IDS,RETURN.VALUES.TA,ERR.MSG)
        R.REC.TA = RAISE(RETURN.VALUES.TA)
        Y.COMMITTED.PRIN = R.REC.TA<AA.TermAmount.TermAmount.AmtAmount>

        PROP.CLASS.LI = 'LIMIT'
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.LI,PROPERTY,'',RETURN.IDS,RETURN.VALUES.LI,ERR.MSG)
        R.REC.LI = RAISE(RETURN.VALUES.LI)
        Y.LIMIT.REF = R.REC.LI<AA.Limit.Limit.LimLimitReference>
        
        Y.AA.INT.ID = 'AA19358KQFWK-MARKUPPROFIT'
        EB.DataAccess.FRead(FN.AA.INT.AC,Y.AA.INT.ID,R.AA.INT.AC,F.AA.INT.AC,E.AA.INT.AC)
        
        Y.COMMITTED.PROFIT = R.AA.INT.AC<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
        Y.ACCRUED.PROFIT = ABS(SUM(R.AA.INT.AC<AA.Interest.InterestAccruals.IntAccAccrualAmt>))
        Y.OUTS.PROFIT = ABS(Y.COMMITTED.PROFIT - Y.ACCRUED.PROFIT)
        Y.PART.REBATE = 0
        
        Y.FDBP = Y.FDBP + Y.CURAC.BAL
        Y.LDBP = Y.LDBP + Y.CURAC.BAL
        Y.MIB.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.MPI = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.MTR = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.WO.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BAIM.SHARE = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BAIM.FO = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BIAM.LDBP.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.MUSH.LDBP = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BAIM.PC = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BAIM.EXP.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.ECC.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.IZARA.HBL.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.IZARA.Mach.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.IZARA.TRANS.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.BAIM.CCH.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        
        Y.ALL.AMT = Y.FDBP:FM:Y.LDBP:FM:Y.MIB.AMT:FM:Y.MPI:FM:Y.MTR:FM:Y.WO.AMT:FM:Y.BAIM.SHARE:FM:Y.BAIM.FO:FM:Y.BIAM.LDBP.AMT:FM:Y.MUSH.LDBP:FM:Y.BAIM.PC:FM:Y.BAIM.EXP.AMT:FM:Y.ECC.AMT:FM:Y.BAIM.CCH.AMT:FM:Y.TOTAL.FINAL
        FINDSTR Y.LIMIT.REF IN Y.LI.REF SETTING Y.POS THEN
            Y.RETURN.DATA<2+Y.POS> += Y.ALL.AMT<Y.POS>
        END
    REPEAT
    Y.TOTAL1 = Y.FDBP + Y.LDBP + Y.MPI + Y.MTR + Y.WO.AMT + Y.BAIM.SHARE
    Y.TOTAL2 = Y.TOTAL1 + Y.BAIM.FO + Y.BIAM.LDBP.AMT + Y.BAIM.PC + Y.ECC.AMT
    Y.TOTAL3 = Y.TOTAL2 + Y.BAIM.EXP.AMT + Y.IZARA.HBL.AMT + Y.IZARA.Mach.AMT
    Y.TOTAL = Y.TOTAL3 + Y.IZARA.TRANS.AMT
    Y.TOTAL.FINAL = Y.TOTAL2 + Y.BAIM.CCH.AMT + Y.MUSH.LDBP + Y.BAIM.EXP.AMT
    Y.RETURN.DATA = Y.RETURN.DATA:'*':Y.TOTAL.FINAL
    Y.DATA = Y.RETURN.DATA
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'ENQ'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
RETURN

END
