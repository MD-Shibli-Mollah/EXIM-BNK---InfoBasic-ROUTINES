* @ValidationCode : Mjo0NDUyNjgyNDc6Q3AxMjUyOjE1ODY0MTQ2NjAwMzA6dG93aGlkdGlwdTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Apr 2020 12:44:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.WRITE.LENDING.REBATE.AMT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.BD.EXIM.LENDING.REBATE
    $USING EB.DataAccess
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AA.Interest
    $USING AC.EntryCreation
    
    $USING AC.ModelBank
*-----------------------------------------------------------------------------
    recordStatus =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActRecordStatus>
    activityDes =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActActivity>
    
    IF recordStatus = '' OR recordStatus = 'RNAU' THEN
        GOSUB INITIALISE
        GOSUB OPENFILE
        GOSUB PROCESS
    END
INITIALISE:
    fnLenRebate = 'F.BD.EXIM.LENDING.REBATE'
    fLenRebate = ''
    fnIntAccr = 'FBNK.AA.INTEREST.ACCRUALS'
    fIntAccr = ''
    fnAAArrAct = 'FBNK.AA.ARRANGEMENT.ACTIVITY'
    fAAArrAct = ''
    
    accountId = c_aalocLinkedAccount
    arrangementId = c_aalocArrId
    effctDate = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActEffectiveDate>
RETURN

OPENFILE:
    EB.DataAccess.Opf(fnLenRebate, fLenRebate)
    EB.DataAccess.Opf(fnIntAccr, fIntAccr)
    EB.DataAccess.Opf(fnAAArrAct, fAAArrAct)
RETURN
    
PROCESS:
    GOSUB REBATE.AMT.CALC
    IF masterActDes != 'LENDING-APPLYPAYMENT-PR.PRINCIPAL.DECREASE' THEN
        RETURN
    END
    EB.DataAccess.FRead(fnLenRebate, accountId, rLenRebate, fLenRebate, lenRebateErr)
    IF rLenRebate EQ '' THEN
        IF accrAdjAmt <= 0 THEN
            RETURN
        END
        rLenRebate<LN.RBT.ARRANGEMENT.ID> = arrangementId
        rPayDate = rLenRebate<LN.RBT.PAYMENT.DATE>
        rPayAmt = rLenRebate<LN.RBT.PAYMENT.AMT>
        rRebateAmt = rLenRebate<LN.RBT.REBATE.AMT>
        rActivityId = rLenRebate<LN.RBT.ACTIVITY.ID>
        rPayDate<1,1> = effctDate
        rPayAmt<1,1> = txnAmount
        rRebateAmt<1,1> = accrAdjAmt
        rActivityId<1,1> = masterActId
        rLenRebate<LN.RBT.PAYMENT.DATE,1,1> = rPayDate
        rLenRebate<LN.RBT.PAYMENT.AMT,1,1> = rPayAmt
        rLenRebate<LN.RBT.REBATE.AMT,1,1> = rRebateAmt
        rLenRebate<LN.RBT.ACTIVITY.ID,1,1> = rActivityId
        WRITE rLenRebate TO fLenRebate, accountId
    END
    ELSE
        rPayDate = rLenRebate<LN.RBT.PAYMENT.DATE>
        rPayAmt = rLenRebate<LN.RBT.PAYMENT.AMT>
        rRebateAmt = rLenRebate<LN.RBT.REBATE.AMT>
        rActivityId = rLenRebate<LN.RBT.ACTIVITY.ID>
        existingRecCnt = DCOUNT(rPayDate,@VM)

        IF recordStatus = 'RNAU' THEN
            CONVERT @VM TO @FM IN rActivityId
            CONVERT @SM TO @FM IN rActivityId
            FIND masterActId:'-REVE' IN rActivityId SETTING posActFM, posActVM, posActSM THEN
                IF posActFM != '' THEN
                    RETURN
                END
            END
            FIND masterActId IN rActivityId SETTING posFM, posVM, posSM THEN
                accrAdjAmt = (rLenRebate<LN.RBT.REBATE.AMT,posFM>) * (-1)
                masterActId = masterActId:'-REVE'
            END
        END
        rPayDate<1,existingRecCnt+1> = effctDate
        rPayAmt<1,existingRecCnt+1> = txnAmount
        rRebateAmt<1,existingRecCnt+1> = accrAdjAmt
        rActivityId<1,existingRecCnt+1> = masterActId
        rLenRebate<LN.RBT.PAYMENT.DATE> = rPayDate
        rLenRebate<LN.RBT.PAYMENT.AMT> = rPayAmt
        rLenRebate<LN.RBT.REBATE.AMT> = rRebateAmt
        rLenRebate<LN.RBT.ACTIVITY.ID> = rActivityId
        GOSUB WRITE.FILE
        WRITE rLenRebate TO fLenRebate, accountId
    END
RETURN

REBATE.AMT.CALC:
    masterActId = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActMasterAaa>
    EB.DataAccess.FRead(fnAAArrAct, masterActId, rAAArrAct, fAAArrAct, Er)
    txnAmount = rAAArrAct<AA.Framework.ArrangementActivity.ArrActTxnAmountLcy>
    masterActDes = rAAArrAct<AA.Framework.ArrangementActivity.ArrActActivity>
    IF recordStatus = '' THEN
        intAccrualID = arrangementId : '-' : 'MARKUPPROFIT'
        EB.DataAccess.FRead(fnIntAccr, intAccrualID, rIntAccr, fIntAccr, Er)
        newPrftAmt = rIntAccr<AA.Interest.InterestAccruals.IntAccProfitAmt,1,1>
        lastPrftAmt = rIntAccr<AA.Interest.InterestAccruals.IntAccProfitAmt,1,2>
        IF lastPrftAmt = '' THEN
            lastPrftAmt = rIntAccr<AA.Interest.InterestAccruals.IntAccProfitAmt,2,1>
        END
        accrAdjAmt = lastPrftAmt - newPrftAmt
    END
RETURN

WRITE.FILE:
    WriteData = ''
*    WriteData = childActivityId:'-':stmtNo: '-' : activityDes : '-' : rLenRebate:'-':accountId:'-':effctDate:'-':newPrftAmt:'-':lastPrftAmt:'-':accrAdjAmt
    WriteData = masterActId:'-': activityDes : '-' : rLenRebate:'-':accountId:'-':effctDate:'-'::'-'::'-':accrAdjAmt:'-':c_aalocArrActivityRec
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