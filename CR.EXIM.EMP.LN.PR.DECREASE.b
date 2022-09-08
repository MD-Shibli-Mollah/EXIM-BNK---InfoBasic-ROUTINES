* @ValidationCode : MjoxODUxMDM5MDQ0OkNwMTI1MjoxNTgxOTI1Mjg1OTYzOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Feb 2020 13:41:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.EMP.LN.PR.DECREASE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.Framework
    $USING FT.Contract
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING AA.PaymentSchedule
*-----------------------------------------------------------------------------
    DEBUG
    arrangementId = AA.Framework.getC_aalocarrid()
    linkedAccount = AA.Framework.getC_aaloclinkedaccount()
    currActivityId = AA.Framework.getC_aalocarractivityid()
    activityRecord = AA.Framework.getC_aalocarractivityrec()
    
    decreasedAmount =  activityRecord<AA.Framework.ArrangementActivity.ArrActTxnAmount>
    txnReference = FIELD(activityRecord<AA.Framework.ArrangementActivity.ArrActTxnContractId>,'\',1)
    txnSystemId = activityRecord<AA.Framework.ArrangementActivity.ArrActTxnSystemId>
    DEBUG
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    BaseBalance = 'CURACCOUNT'
    AA.Framework.GetPeriodBalances(linkedAccount, BaseBalance, RequestType, PaymentDate, PaymentDate, PaymentDate, BalDetails, ErrorMessage)
    closingBal = BalDetails<4>
    DEBUG
    
    applicationName = 'AA.ARR.PAYMENT.SCHEDULE'
    localFields = 'LT.INS.START':@VM:'LT.INS.SIZE'
    EB.Foundation.MapLocalFields(applicationName, localFields, fieldPos)
    installStartPos = fieldPos<1,1>
    installSizePos = fieldPos<1,2>
    DEBUG
    paymentSchLocalData = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsLocalRef)
    installStart = paymentSchLocalData<1,installStartPos>
    installSize = paymentSchLocalData<1,installSizePos>
    DEBUG
    allPayFrequency = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
    payFrequency = allPayFrequency<1,2>
    freqMonth = FIELD(payFrequency,'M',1)
    freqMonth = FIELD(freqMonth,'e',3)
    DEBUG
    prInstallNo = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)
*Second row(Installment Number after decreasing principal)
    prInstallNo = prInstallNo - INT(decreasedAmount / installSize)
    
    
    DEBUG
    writeData = arrangementId :'*': linkedAccount :'*': currActivityId :'*': txnReference :'*': decreasedAmount :'*': txnSystemId :'*': closingBal :'*': installStart :'': installSize :'*': freqMonth :'*': prInstallNo
    
    FileName = 'prdecrease.txt'
    FilePath = 'EXIM.DATA'
    OPENSEQ FilePath,FileName TO FileOutput THEN NULL
    ELSE
        CREATE FileOutput ELSE
        END
    END
    WRITESEQ writeData APPEND TO FileOutput ELSE
        CLOSESEQ FileOutput
    END
RETURN
END
