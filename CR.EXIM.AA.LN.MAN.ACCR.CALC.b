* @ValidationCode : MjoxMzMzODU3NDAxOkNwMTI1MjoxNTgzOTI4MDkwMTA4OnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Mar 2020 18:01:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.AA.LN.MAN.ACCR.CALC
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
    
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

INITIALISE:
    FN.ACCOUNT = 'FBNK.ACCOUNT'
    F.ACCOUNT = ''
    FN.INT.ACCR = 'FBNK.AA.INTEREST.ACCRUALS'
    F.INT.ACCR = ''
    prinDecreaseAmt = 0
    accrualAmt = 0
    ftCreditAmt = 0
    
    localFieldsFt = 'LT.FT.ACCR.AMT':@VM: 'LT.FT.PRIN.DECR'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    
    accrualAmtPos = localfieldPos<1,1>
    prinDecrAmtPos = localfieldPos<1,2>
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT, F.ACCOUNT)
    EB.DataAccess.Opf(FN.INT.ACCR, F.INT.ACCR)
RETURN

PROCESS:
    GOSUB READ.ORG.CR.AMT
    GOSUB READ.BALANCE.ALL
    GOSUB SET.CR.AMTS
RETURN

READ.ORG.CR.AMT:
    ftCreditAcctNo = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    ftOrCreditAmt = EB.SystemTables.getComi()
RETURN

SET.CR.AMTS:
    IF totChgPenaltySusBal >= ftOrCreditAmt THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, ftOrCreditAmt)
    END
    ELSE
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAmount, totChgPenaltySusBal)
        remainingBal = ftOrCreditAmt - totChgPenaltySusBal
        GOSUB READ.ACCRUAL.AMT
        GOSUB WRITE.ACCR.PRIN.AMT
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

WRITE.ACCR.PRIN.AMT:
    ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
    ftLocalRef<1,accrualAmtPos> = accrualAmt
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    prinDecreaseAmt = remainingBal - accrualAmt
    IF prinDecreaseAmt > 0 THEN
        ftLocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        ftLocalRef<1,prinDecrAmtPos> = prinDecreaseAmt
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, ftLocalRef)
    END
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
    BaseBalance15 = 'ACCSUSPFT'
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
    totChgPenaltySusBal = dueVatBal + dueProcessBal + dueDueStmpjudBal + dueRebateBal + dueAmcBal + dueEdBal + duePayoffBal + duePayoffBal + dueCibColBal + dueStmpOthBal + dueOthChgBal + dueStmpCourtBal + dueStmpRevBal + accPftBal + accPenaltyBal + accSusPftBal
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = 'ChargeAmount': '-' : totChgPenaltySusBal : '-' : 'OrCreditAmt' : '-' : ftOrCreditAmt : '-' : 'RemainingBal': '-' : remainingBal : '-' : 'AccruedAmt': '-' : accrualAmt : '-' : 'PrincipalDecrAmt': '-' : prinDecreaseAmt
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
