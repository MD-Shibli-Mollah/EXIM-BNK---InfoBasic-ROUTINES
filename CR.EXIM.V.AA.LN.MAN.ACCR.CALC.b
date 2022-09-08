* @ValidationCode : MjotMTEwMDAzMjc5MjpDcDEyNTI6MTU4NDYwMzI3Mjk3MTp0b3doaWR0aXB1Oi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Mar 2020 13:34:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.AA.LN.MAN.ACCR.CALC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING AA.Interest
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING EB.Foundation
    $USING EB.Display
    $USING AA.ProductManagement
    
    EB.Display.RebuildScreen()
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

INITIALISE:
    FN.ACCOUNT = 'FBNK.ACCOUNT'
    F.ACCOUNT = ''
    FN.INT.ACCR = 'FBNK.AA.INTEREST.ACCRUALS'
    F.INT.ACCR = ''
    FN.AA.ARRANGEMENT = 'FBNK.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    
    prinDecreaseAmt = 0
    accrualAmt = 0
    ftCreditAmt = 0
    remainBal = 0
    WriteFile5 = ''
    
    localFieldsFt = 'LT.FT.ACCR.AMT':@VM: 'LT.FT.PRIN.DECR':@VM: 'LT.FT.ACCR.MARK':@VM: 'LT.VERSION.ID'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    
    accrualAmtPos = localfieldPos<1,1>
    prinDecrAmtPos = localfieldPos<1,2>
    accrualMarkPos = localfieldPos<1,3>
    versionIdPos = localfieldPos<1,4>
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT, F.ACCOUNT)
    EB.DataAccess.Opf(FN.INT.ACCR, F.INT.ACCR)
    EB.DataAccess.Opf(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
RETURN

PROCESS:
    ftCreditAcctNo = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    ftOrCreditAmt = EB.SystemTables.getComi()
    EB.DataAccess.FRead(FN.ACCOUNT, ftCreditAcctNo, R.ACC, F.ACCOUNT, Er)
    arrangementID = R.ACC<AC.AccountOpening.Account.ArrangementId>
    EB.DataAccess.FRead(FN.AA.ARRANGEMENT, arrangementID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Er)
    productGroup = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProductGroup>
    IF productGroup = 'EXIM.MURA.GRP.LN' OR productGroup = 'EXIM.SALM.GRP.LN' OR productGroup = 'EXIM.MUAJ.GRP.LN' THEN
        GOSUB READ.BALANCE.ALL
        GOSUB SET.CR.AMTS
        GOSUB WRITE.VERSION.ID
    END
    ELSE
        ftLocalRef<1,accrualAmtPos> = remainBal
        ftLocalRef<1,accrualMarkPos> = 'NO'
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, ftOrCreditAmt)
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACRP')
        RETURN
    END
RETURN

WRITE.VERSION.ID:
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,versionIdPos> = EB.SystemTables.getPgmVersion()
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
RETURN

SET.CR.AMTS:
    GOSUB READ.ACCRUAL.AMT
    IF totChgPenaltySusBal = 0 OR totChgPenaltySusBal = '' THEN
        IF accrualAmt >= ftOrCreditAmt THEN
            GOSUB WRITE.ACCR.AMT
        END
        ELSE IF accrualAmt = 0 THEN
            GOSUB WRITE.PRIN.AMT
        END
        ELSE
            GOSUB WRITE.ACCR.THN.PRIN.AMT
        END
    END
    ELSE IF totChgPenaltySusBal >= ftOrCreditAmt THEN
        GOSUB WRITE.NO.ACCR.PRIN.AMT
    END
    ELSE
        remainBal = ftOrCreditAmt - totChgPenaltySusBal
        IF remainBal > accrualAmt THEN
            GOSUB WRITE.CHG.ACCR.PRIN.AMT
        END
        ELSE IF remainBal <= accrualAmt THEN
            GOSUB WRITE.CHG.ACCR.AMT
        END
    END
RETURN

READ.ACCRUAL.AMT:
    EB.DataAccess.FRead(FN.ACCOUNT, ftCreditAcctNo, R.ACC, F.ACCOUNT, Er)
    arrangementID = R.ACC<AC.AccountOpening.Account.ArrangementId>
    intAccrualID = arrangementID : '-' : 'MARKUPPROFIT'
    EB.DataAccess.FRead(FN.INT.ACCR, intAccrualID, R.INT.ACCR, F.INT.ACCR, Er)
    intAccrualAmt = R.INT.ACCR<AA.Interest.InterestAccruals.IntAccTotPosAccrAmt>
    repayAccAmt = R.INT.ACCR<AA.Interest.InterestAccruals.IntAccTotRpyAmt>
    accrualAmt = intAccrualAmt - repayAccAmt
RETURN

WRITE.CHG.ACCR.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, totChgPenaltySusBal)
    remainingBal = ftOrCreditAmt - totChgPenaltySusBal
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = remainBal
    ftLocalRef<1,accrualMarkPos> = 'NO'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACRP')
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,prinDecrAmtPos> = 0
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
RETURN

WRITE.CHG.ACCR.PRIN.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, totChgPenaltySusBal)
    remainingBal = ftOrCreditAmt - totChgPenaltySusBal
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = accrualAmt
    ftLocalRef<1,accrualMarkPos> = 'NO'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACRP')
    prinDecreaseAmt = remainingBal - accrualAmt
    IF prinDecreaseAmt > 0 THEN
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    END
RETURN

WRITE.NO.ACCR.PRIN.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, ftOrCreditAmt)
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = 0
    ftLocalRef<1,accrualMarkPos> = 'NO'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACRP')
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,prinDecrAmtPos> = 0
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
RETURN

WRITE.ACCR.THN.PRIN.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, accrualAmt)
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = accrualAmt
    ftLocalRef<1,accrualMarkPos> = 'YES'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACAC')
    prinDecreaseAmt = ftOrCreditAmt - accrualAmt
    IF prinDecreaseAmt > 0 THEN
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    END
RETURN

WRITE.PRIN.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, ftOrCreditAmt)
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = accrualAmt
    ftLocalRef<1,accrualMarkPos> = 'PRIN'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACPD')
    prinDecreaseAmt = remainingBal
    IF prinDecreaseAmt > 0 THEN
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    END
RETURN

WRITE.ACCR.AMT:
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, ftOrCreditAmt)
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = ftOrCreditAmt
    ftLocalRef<1,accrualMarkPos> = 'YES'
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'ACAC')
    prinDecreaseAmt = 0
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
RETURN

READ.BALANCE.ALL:
    PaymentDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    BaseBalance1 = 'RECMARKUPPROFIT'
    BaseBalance2 = 'DUEVAT'
    BaseBalance3 = 'DUEPRCSFEE'
    BaseBalance4 = 'DUESTMPJUD'
    BaseBalance5 = 'DUEREBATEFEE'
    BaseBalance6 = 'DUEAMCFEE'
    BaseBalance7 = 'DUEEDFEE'
    BaseBalance8 = 'DUEPAYOFFFEE'
    BaseBalance9 = 'DUECIBCOLFEE'
    BaseBalance10 = 'DUESTMPOTH'
    BaseBalance11 = 'DUEOTHCHG'
    BaseBalance12 = 'DUESTMPCOURT'
    BaseBalance13 = 'DUESTMPREV'
    BaseBalance14 = 'ACCPFTONOD'
    BaseBalance15 = 'ACCPENALTYPFT'
    BaseBalance16 = 'ACCSUSPFT'
    BaseBalance17 = 'DUEMARKUPPROFIT'
    BaseBalance18 = 'STDMARKUPPROFIT'
    BaseBalance19 = 'NABMARKUPPROFIT'
    BaseBalance20 = 'DUEACCOUNT'
    BaseBalance21 = 'STDACCOUNT'
    BaseBalance22 = 'NABACCOUNT'
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance1, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails1, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance2, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails2, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance3, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails3, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance4, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails4, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance5, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails5, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance6, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails6, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance7, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails7, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance8, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails8, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance9, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails9, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance10, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails10, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance11, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails11, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance12, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails12, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance13, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails13, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance14, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails14, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance15, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails15, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance16, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails16, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance17, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails17, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance18, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails18, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance19, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails19, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance20, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails20, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance21, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails21, ErrorMessage)
    AA.Framework.GetPeriodBalances(ftCreditAcctNo, BaseBalance22, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails22, ErrorMessage)
    recMarkupBal = ABS(BalDetails1<4>)
    dueVatBal = ABS(BalDetails2<4>)
    dueProcessBal = ABS(BalDetails3<4>)
    dueDueStmpjudBal = ABS(BalDetails4<4>)
    dueRebateBal = ABS(BalDetails5<4>)
    dueAmcBal = ABS(BalDetails6<4>)
    dueEdBal = ABS(BalDetails7<4>)
    duePayoffBal = ABS(BalDetails8<4>)
    dueCibColBal = ABS(BalDetails9<4>)
    dueStmpOthBal = ABS(BalDetails10<4>)
    dueOthChgBal = ABS(BalDetails11<4>)
    dueStmpCourtBal = ABS(BalDetails12<4>)
    dueStmpRevBal = ABS(BalDetails13<4>)
    accPftBal = ABS(BalDetails14<4>)
    accPenaltyBal = ABS(BalDetails15<4>)
    accSusPftBal = ABS(BalDetails16<4>)
    dueMarkupProfit = ABS(BalDetails17<4>)
    stdMarkupProfit = ABS(BalDetails18<4>)
    nabMarkupProfit = ABS(BalDetails19<4>)
    dueAccount = ABS(BalDetails20<4>)
    stdAccount = ABS(BalDetails21<4>)
    nabAccount = ABS(BalDetails22<4>)
    totChgPenaltySusBal = dueVatBal + dueProcessBal + dueDueStmpjudBal + dueRebateBal + dueAmcBal + dueEdBal + duePayoffBal + duePayoffBal + dueCibColBal + dueStmpOthBal + dueOthChgBal + dueStmpCourtBal + dueStmpRevBal + accPftBal + accPenaltyBal + accSusPftBal + dueMarkupProfit + stdMarkupProfit + nabMarkupProfit + dueAccount + stdAccount + nabAccount
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = 'TIPU' : '-' : arrangementID : '-' : productGroup
    FileName = 'TIPU.csv'
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
