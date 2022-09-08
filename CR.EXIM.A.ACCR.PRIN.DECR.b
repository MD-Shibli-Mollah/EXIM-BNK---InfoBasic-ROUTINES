* @ValidationCode : MjoxOTY4OTYzMjg0OkNwMTI1MjoxNTgzOTk1NTcxOTgyOnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Mar 2020 12:46:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.A.ACCR.PRIN.DECR
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
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    
    localFieldsFt = 'LT.FT.ACCR.AMT':@VM: 'LT.FT.PRIN.DECR':@VM:'LT.FT.OR.CR.AMT'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    accrualAmtPos = localfieldPos<1,1>
    prinDecrAmtPos = localfieldPos<1,2>
    orgCrAmtPos = localfieldPos<1,3>
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.FT.NAU, F.FT.NAU)
RETURN

PROCESS:
    GOSUB READ.FT.DATA
    IF ftOrCrAmt > ftCreditAmt THEN
        GOSUB OFS.PROCESS.ACCR
        IF (ftOrCrAmt - (ftCreditAmt + ftAccrAmt)) > 0 AND ftPrinDecreaseAmt != '' THEN
            GOSUB OFS.PROCESS.PRIN.DECR
        END
    END
RETURN

READ.FT.DATA:
    ftTxnId =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>
    ftTxnId = FIELD(ftTxnId,'\',1)
    EB.DataAccess.FRead(FN.FT, ftTxnId, R.FT, F.FT, Er)
    ftCreditAcctNo = R.FT<FT.Contract.FundsTransfer.CreditAcctNo>
    ftCreditAmt = R.FT<FT.Contract.FundsTransfer.CreditAmount>
    ftDebitAcctNo = R.FT<FT.Contract.FundsTransfer.DebitAcctNo>
    ftCurrency = R.FT<FT.Contract.FundsTransfer.CreditCurrency>
    ftCrValueDate = R.FT<FT.Contract.FundsTransfer.CreditValueDate>
    ftDrValueDate = R.FT<FT.Contract.FundsTransfer.DebitValueDate>
    ftAccrAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,accrualAmtPos>
    ftPrinDecreaseAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,prinDecrAmtPos>
    ftOrCrAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,orgCrAmtPos>
    ftOrderingBank = R.FT<FT.Contract.FundsTransfer.OrderingBank>
RETURN

OFS.PROCESS.ACCR:
    GOSUB OFS.STRING.ACCR
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgId = ''
    ftId = ''
    companyId = EB.SystemTables.getIdCompany()
    
    ofsMsgAccr = 'FUNDS.TRANSFER,AA.ACAC.OFS':'/I/PROCESS,//':companyId:',':ftId:',':ofsStrAccr
    GOSUB WRITE.FILE
    EB.Interface.OfsPostMessage(ofsMsgAccr, ofsMsgId, ofsSource, options)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN

OFS.STRING.ACCR:
    ofsStrAccr = ''
    ofsStrAccr := 'CREDIT.ACCT.NO::=':ftCreditAcctNo:','
    ofsStrAccr := 'CREDIT.VALUE.DATE::=':ftCrValueDate:','
    ofsStrAccr := 'CREDIT.CURRENCY::=':ftCurrency:','
    ofsStrAccr := 'CREDIT.AMOUNT::=':ftAccrAmt:','
    ofsStrAccr := 'DEBIT.ACCT.NO::=':ftDebitAcctNo:','
    ofsStrAccr := 'DEBIT.VALUE.DATE::=':ftDrValueDate:','
    ofsStrAccr := 'ORDERING.BANK:1:1=':ftOrderingBank
RETURN

OFS.PROCESS.PRIN.DECR:
    GOSUB OFS.STRING.PRIN.DECR
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgId = ''
    ftId = ''
    companyId = EB.SystemTables.getIdCompany()
    
    ofsMsgPrinDecr = 'FUNDS.TRANSFER,AA.ACPD.OFS':'/I/PROCESS,//':companyId:',':ftId:',':ofsStrPrinDecr
    GOSUB WRITE.FILE
    EB.Interface.OfsPostMessage(ofsMsgPrinDecr, ofsMsgId, ofsSource, options)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN

OFS.STRING.PRIN.DECR:
    ofsStrPrinDecr = ''
    ofsStrPrinDecr := 'CREDIT.ACCT.NO::=':ftCreditAcctNo:','
    ofsStrPrinDecr := 'CREDIT.VALUE.DATE::=':ftCrValueDate:','
    ofsStrPrinDecr := 'CREDIT.CURRENCY::=':ftCurrency:','
    ofsStrPrinDecr := 'CREDIT.AMOUNT::=':ftPrinDecreaseAmt:','
    ofsStrPrinDecr := 'DEBIT.ACCT.NO::=':ftDebitAcctNo:','
    ofsStrPrinDecr := 'DEBIT.VALUE.DATE::=':ftDrValueDate:','
    ofsStrPrinDecr := 'ORDERING.BANK:1:1=':ftOrderingBank
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = ftCreditAcctNo :'-': FN.FT :'-': ftTxnId :'-': R.FT
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
