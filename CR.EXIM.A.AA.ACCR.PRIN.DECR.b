* @ValidationCode : MjoxMTkyNzExMzQ5OkNwMTI1MjoxNTg1NzMyNjc0ODUyOnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 01 Apr 2020 15:17:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.A.AA.ACCR.PRIN.DECR
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
    
    IF arrStatus = '' OR arrStatus = 'RNAU' THEN
        GOSUB INITIALISE
        GOSUB OPENFILES
        GOSUB PROCESS
    END

INITIALISE:
    !FN.FT = 'F.FUNDS.TRANSFER$NAU'
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    FN.FT.NAU = 'F.FUNDS.TRANSFER$NAU'
    F.FT.NAU = ''
    FN.FT.HIS = 'F.FUNDS.TRANSFER$HIS'
    F.FT.HIS = ''
    R.FT = ''
    
    localFieldsFt = 'LT.FT.ACCR.AMT' :@VM: 'LT.FT.PRIN.DECR' :@VM: 'LT.FT.OR.CR.AMT' :@VM: 'LT.VERSION.ID' :@VM: 'LT.FT.MASTER.ID' : @VM : 'LT.FT.ACCR.ID' : @VM : 'LT.FT.PR.DEC.ID'
    EB.Foundation.MapLocalFields("FUNDS.TRANSFER", localFieldsFt, localfieldPos)
    accrualAmtPos = localfieldPos<1,1>
    prinDecrAmtPos = localfieldPos<1,2>
    orgCrAmtPos = localfieldPos<1,3>
    versionIdPos = localfieldPos<1,4>
    masterFtPos = localfieldPos<1,5>
    accrFtIdPos = localfieldPos<1,6>
    princDecFtIdPos = localfieldPos<1,7>
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.FT, F.FT)
    EB.DataAccess.Opf(FN.FT.NAU, F.FT.NAU)
    EB.DataAccess.Opf(FN.FT.HIS, F.FT.HIS)
RETURN

PROCESS:
    GOSUB READ.FT.DATA
    IF ftVersionId != '' AND ftVersionId = ',EXIM.IS.AA.ACRP.LN' AND arrStatus != 'RNAU' THEN
        IF (ftAccrAmt != '' AND ftAccrAmt > 0) OR (ftPrinDecreaseAmt > 0 AND ftPrinDecreaseAmt != '') THEN
            IF ftAccrAmt > 0 AND ftAccrAmt != '' AND ftAccrAmt != ftCreditAmt THEN
                GOSUB OFS.PROCESS.ACCR
            END
            IF ftPrinDecreaseAmt > 0 AND ftPrinDecreaseAmt != '' THEN
                GOSUB OFS.PROCESS.PRIN.DECR
            END
        END
    END
    ELSE IF ftAccrFtId != '' OR ftPrinDecFtId != '' THEN
        IF ftAccrFtId != '' THEN
            GOSUB REV.ACC.RFT
        END
        IF ftPrinDecFtId != '' THEN
            GOSUB REV.PRIN.DECR.FT
        END
    END
    ELSE
        RETURN
    END
RETURN

READ.FT.DATA:
    ftTxnId =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>
    ftTxnId = FIELD(ftTxnId,'\',1)
    EB.DataAccess.FRead(FN.FT, ftTxnId, R.FT, F.FT, Er)
    ft.app = FN.FT
    IF R.FT = '' THEN
        EB.DataAccess.FRead(FN.FT.NAU, ftTxnId, R.FT, F.FT.NAU, Er)
        ft.app = FN.FT.NAU
    END
    IF R.FT = '' THEN
        EB.DataAccess.FRead(FN.FT.HIS, ftTxnId, R.FT, F.FT.HIS, Er)
        ft.app = FN.FT.HIS
    END
    ftTxnType = R.FT<FT.Contract.FundsTransfer.TransactionType>
    ftCreditAcctNo = R.FT<FT.Contract.FundsTransfer.CreditAcctNo>
    ftCreditAmt = R.FT<FT.Contract.FundsTransfer.CreditAmount>
    ftDebitAcctNo = R.FT<FT.Contract.FundsTransfer.DebitAcctNo>
    ftCurrency = R.FT<FT.Contract.FundsTransfer.CreditCurrency>
    ftCrValueDate = R.FT<FT.Contract.FundsTransfer.CreditValueDate>
    ftDrValueDate = R.FT<FT.Contract.FundsTransfer.DebitValueDate>
    ftAccrAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,accrualAmtPos>
    ftPrinDecreaseAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,prinDecrAmtPos>
    ftOrCrAmt = R.FT<FT.Contract.FundsTransfer.LocalRef><1,orgCrAmtPos>
    ftVersionId = R.FT<FT.Contract.FundsTransfer.LocalRef><1,versionIdPos>
    ftOrderingBank = R.FT<FT.Contract.FundsTransfer.OrderingBank>
    ftStatus = R.FT<FT.Contract.FundsTransfer.Status>
    ftAccrFtId = R.FT<FT.Contract.FundsTransfer.LocalRef><1,accrFtIdPos>
    ftPrinDecFtId = R.FT<FT.Contract.FundsTransfer.LocalRef><1,princDecFtIdPos>
RETURN

OFS.PROCESS.ACCR:
    GOSUB OFS.STRING.ACCR
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgId = ''
    ftId = ''
    companyId = EB.SystemTables.getIdCompany()
    ofsMsgAccr = 'FUNDS.TRANSFER,AA.ACAC.OFS':'/I/PROCESS,//':companyId:',':ftId:',':ofsStrAccr
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
    ofsStrAccr := 'LT.FT.MASTER.ID::=':ftTxnId:','
    ofsStrAccr := 'ORDERING.BANK:1:1=':ftOrderingBank
RETURN

OFS.PROCESS.PRIN.DECR:
    GOSUB OFS.STRING.PRIN.DECR
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgId = ''
    ftId = ''
    companyId = EB.SystemTables.getIdCompany()
    ofsMsgPrinDecr = 'FUNDS.TRANSFER,AA.ACPD.OFS':'/I/PROCESS,//':companyId:',':ftId:',':ofsStrPrinDecr
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
    ofsStrPrinDecr := 'LT.FT.MASTER.ID::=':ftTxnId:','
    ofsStrPrinDecr := 'ORDERING.BANK:1:1=':ftOrderingBank
RETURN

REV.ACC.RFT:
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgAcId = ''
    ftId = ftAccrFtId
    companyId = EB.SystemTables.getIdCompany()
    ofsMsgAccr = 'FUNDS.TRANSFER,AA.ACAC.OFS':'/R/PROCESS,//':companyId:',':ftId
    EB.Interface.OfsPostMessage(ofsMsgAccr, ofsMsgAcId, ofsSource, options)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
RETURN

REV.PRIN.DECR.FT:
    ofsSource = 'EXIM.OFS.ENT'
    ofsMsgPrDecId = ''
    ftId = ftPrinDecFtId
    companyId = EB.SystemTables.getIdCompany()
    ofsMsgAccr = 'FUNDS.TRANSFER,AA.ACPD.OFS':'/R/PROCESS,//':companyId:',':ftId
    EB.Interface.OfsPostMessage(ofsMsgAccr, ofsMsgPrDecId, ofsSource, options)
    EB.TransactionControl.JournalUpdate('')
    SENSITIVITY=''
    
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = V$FUNCTION : '-' : ft.app : '-' : arrStatus: '-' : ftAccrFtId: '-' : ftPrinDecFtId : '-' : ftTxnId : '-' : ofsMsgId
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
