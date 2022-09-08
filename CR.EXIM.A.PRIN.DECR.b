* @ValidationCode : MjotMTY1MTQ5MzY5OkNwMTI1MjoxNTgzNDAyMjU1MzIzOnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 05 Mar 2020 15:57:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.A.PRIN.DECR
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.FUNDS.TRANSFER

    $USING EB.SystemTables
    $USING AA.Interest
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING EB.Foundation
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING AA.Framework
    $USING EB.DataAccess

    arrStatus = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActRecordStatus>
    IF arrStatus NE '' THEN
        RETURN
    END
    
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

INITIALISE:
    FN.FT.NAU = 'F.FUNDS.TRANSFER'
    F.FT.NAU = ''
    
    localFieldsFt = 'LT.FT.PRIN.DECR'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, prinDecrAmtPos)
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.FT.NAU, F.FT.NAU)
RETURN

PROCESS:
    ftTxnId =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>
    ftTxnId = FIELD(ftTxnId,'\',1)
    EB.DataAccess.FRead(FN.FT.NAU, ftTxnId, R.FT.NAU, F.FT.NAU, Er)
    
    ftCreditAcctNo = R.FT.NAU<FT.Contract.FundsTransfer.CreditAcctNo>
    ftDebitAcctNo = R.FT.NAU<FT.Contract.FundsTransfer.DebitAcctNo>
    ftCurrency = R.FT.NAU<FT.Contract.FundsTransfer.CreditCurrency>
    ftCrValueDate = R.FT.NAU<FT.Contract.FundsTransfer.CreditValueDate>
    ftDrValueDate = R.FT.NAU<FT.Contract.FundsTransfer.DebitValueDate>
    ftPrinDecreaseAmt = R.FT.NAU<FT.Contract.FundsTransfer.LocalRef><1,prinDecrAmtPos>
    ftOrderingBank = R.FT.NAU<FT.Contract.FundsTransfer.OrderingBank>
    GOSUB OFS.PROCESS
RETURN

OFS.PROCESS:

    GOSUB OFS.STRING
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgId = ''
    ftId = ''
    companyId = EB.SystemTables.getIdCompany()
    
    GOSUB WRITE.FILE
    
    ofsMsg = 'FUNDS.TRANSFER,AA.ACPD.OFS':'/I/PROCESS,//':companyId:',':ftId:',':ofsStr
    EB.Interface.OfsPostMessage(ofsMsg, ofsMsgId, ofsSource, options)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN

OFS.STRING:
    ofsStr = ''
    !ofsStr = 'TRANSACTION.TYPE::=AC':','
    ofsStr := 'CREDIT.ACCT.NO::=':ftCreditAcctNo:','
    ofsStr := 'CREDIT.VALUE.DATE::=':ftCrValueDate:','
    ofsStr := 'CREDIT.CURRENCY::=':ftCurrency:','
    ofsStr := 'CREDIT.AMOUNT::=':ftPrinDecreaseAmt:','
    ofsStr := 'DEBIT.ACCT.NO::=':ftDebitAcctNo:','
    ofsStr := 'DEBIT.VALUE.DATE::=':ftDrValueDate:','
    ofsStr := 'ORDERING.BANK:1:1=':ftOrderingBank
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = ftCreditAcctNo :'-': FN.FT.NAU :'-': ftTxnId :'-': R.FT.NAU
    FileName = 'TEST.csv'
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
