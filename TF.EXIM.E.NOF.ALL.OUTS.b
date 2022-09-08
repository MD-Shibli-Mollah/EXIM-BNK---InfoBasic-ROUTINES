* @ValidationCode : MjotMTQ1NDUyNzIzNzpDcDEyNTI6MTU4MjQ1MDc3Mjk1NjpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 23 Feb 2020 15:39:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
*SUBROUTINE TF.EXIM..E.NOF.ALL.OUTS(Y.RETURN.DATA)
*PROGRAM TF.EXIM..E.NOF.ALL.OUTS
SUBROUTINE TF.EXIM.E.NOF.ALL.OUTS(Y.RETURN.DATA)
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
    ST.CompanyCreation.LoadCompany('BNK')
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
    Y.WO.AMT = 0
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

    Y.LI.FDBP = '3651'
    Y.LI.LDBP = '3652'
    Y.LI.MIB = '6611':FM:'6613'
    Y.LI.MPI = '6612':FM:'6614'
    Y.LI.MTR = '6615':FM:'6616'
    Y.LI.WO = '6622':FM:'6632'
    Y.LI.BAIM.SHARE = '6623':FM:'6634'
    Y.LI.BAIM.FO = '6624':FM:'6635'
    Y.LI.BIAM.LDBP = '6627':FM:'6637'
    Y.LI.MUSH.LDBP = '6651'
    Y.LI.BAIM.PC = '6638'
    Y.LI.BAIM.EXP = '6621'
    Y.LI.ECC = '6671':FM:'6672'
    Y.LI.IZARA.HBL = '6742'
    Y.LI.IZARA.Mach = '6743'
    Y.LI.IZARA.TRANS = '6744'
    Y.LI.BAIM.CCH = '6633'
    
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
        
        Y.MTB.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.MPI = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.MTR = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
        Y.WO3.AMT = Y.CURAC.BAL - Y.OUTS.PROFIT + Y.PD.AMT - Y.PART.REBATE + Y.CURAC.BAL
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
        
        FINDSTR Y.LIMIT.REF IN Y.LI.FDBP<1,1> SETTING Y.FDBP.POS THEN
            Y.FDBP = Y.FDBP + Y.CURAC.BAL
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.LDBP<1,1> SETTING Y.LDBP.POS THEN
            Y.LDBP = Y.LDBP + Y.CURAC.BAL
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.MIB<1,1> SETTING Y.MIB.POS THEN
            Y.MIB.AMT += Y.MIB.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.MPI<1,1> SETTING Y.MPI.POS THEN
            Y.MPI += Y.MPI
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.MTR<1,1> SETTING Y.MTR.POS THEN
            Y.MTR = Y.MTR + Y.CURAC.BAL
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.WO<1,1> SETTING Y.WO.POS THEN
            Y.WO.AMT += Y.WO.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BAIM.SHARE<1,1> SETTING Y.BAIM.SHARE.POS THEN
            Y.BAIM.SHARE += Y.BAIM.SHARE
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BAIM.FO<1,1> SETTING Y.BAIM.FO.POS THEN
            Y.BAIM.FO += Y.BAIM.FO
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BIAM.LDBP<1,1> SETTING Y.BIAM.LDBP.POS THEN
            Y.BIAM.LDBP.AMT += Y.BIAM.LDBP.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.MUSH.LDBP<1,1> SETTING Y.MUSH.LDBP.POS THEN
            Y.MUSH.LDBP += Y.MUSH.LDBP
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BAIM.PC<1,1> SETTING Y.BAIM.PC.POS THEN
            Y.BAIM.PC += Y.BAIM.PC
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BAIM.EXP<1,1> SETTING Y.BAIM.EXP.POS THEN
            Y.BAIM.EXP.AMT += Y.BAIM.EXP.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.ECC<1,1> SETTING Y.ECC.POS THEN
            Y.ECC.AMT += Y.ECC.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.IZARA.HBL<1,1> SETTING Y.IZARA.HBL.POS THEN
            Y.IZARA.HBL.AMT += Y.IZARA.HBL.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.IZARA.Mach<1,1> SETTING Y.IZARA.Mach.POS THEN
            Y.IZARA.Mach.AMT += Y.IZARA.Mach.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.IZARA.TRANS<1,1> SETTING Y.IZARA.TRANS.POS THEN
            Y.IZARA.TRANS.AMT += Y.IZARA.TRANS.AMT
        END
        FINDSTR Y.LIMIT.REF IN Y.LI.BAIM.CCH<1,1> SETTING Y.BAIM.CCH.POS THEN
            Y.BAIM.CCH.AMT += Y.BAIM.CCH.AMT
        END
* Y.RETURN.DATA<-1> = Y.AA.ID:'*':Y.CUS.NAME:'*':Y.CUS.ID:'*':Y.FDBP:'*':Y.LDBP:'*':Y.MIB.AMT:'*':Y.MPI:'*':Y.MTR:'*': Y.WO.AMT:'*':Y.BAIM.SHARE:'*':Y.BAIM.FO:'*':Y.BIAM.LDBP.AMT:'*':Y.MUSH.LDBP:'*':Y.BAIM.PC:'*':Y.BAIM.EXP.AMT:'*':Y.ECC.AMT:'*':Y.BAIM.CCH.AMT:'*':Y.TOTAL.FINAL
    REPEAT
    Y.TOTAL1 = Y.FDBP + Y.LDBP + Y.MPI + Y.MTR + Y.WO.AMT + Y.BAIM.SHARE
    Y.TOTAL2 = Y.TOTAL1 + Y.BAIM.FO + Y.BIAM.LDBP.AMT + Y.BAIM.PC + Y.ECC.AMT
    Y.TOTAL3 = Y.TOTAL2 + Y.BAIM.EXP.AMT + Y.IZARA.HBL.AMT + Y.IZARA.Mach.AMT
    Y.TOTAL = Y.TOTAL3 + Y.IZARA.TRANS.AMT
    Y.TOTAL.FINAL = Y.TOTAL2 + Y.BAIM.CCH.AMT + Y.MUSH.LDBP + Y.BAIM.EXP.AMT
*Y.RETURN.DATA =  SORT(Y.RETURN.DATA)
    Y.RETURN.DATA = Y.CUS.NAME:'*':Y.CUS.ID:'*':Y.FDBP:'*':Y.LDBP:'*':Y.MIB.AMT:'*':Y.MPI:'*':Y.MTR:'*': Y.WO.AMT:'*':Y.BAIM.SHARE:'*':Y.BAIM.FO:'*':Y.BIAM.LDBP.AMT:'*':Y.MUSH.LDBP:'*':Y.BAIM.PC:'*':Y.BAIM.EXP.AMT:'*':Y.ECC.AMT:'*':Y.BAIM.CCH.AMT:'*':Y.TOTAL.FINAL
*                       1             2           3          4           5            6         7            8            9                10              11               12               13             14                 15             16                   17
RETURN

END
