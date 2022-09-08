* @ValidationCode : MjoyMTI4NDE2ODgxOkNwMTI1MjoxNTg3MDIwMjk5NTg4OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Apr 2020 12:58:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
PROGRAM GB.EXIM.AA.DEPOSIT.CLOSURE.TEST
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
    
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Settlement
    $USING AA.Accounting
    $USING AA.ProductFramework
    $USING AC.SoftAccounting
*-----------------------------------------------------------------------------
*Initialization
*    ST.CompanyCreation.LoadCompany('BNK')
*    ArrangementId = 'AA200201M0GV'
*ArrangementId = c_aalocArrId
    ArrangementId = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActArrangement)
    SettlementAcc = 'BDT1280000010015'
    FnAccountDet = 'F.AA.ACCOUNT.DETAILS'
    FAccountDet = ''
    FnBillDet = 'F.AA.BILL.DETAILS'
    FBillDet = ''
    TotalDueAmt = 0
    TotalPayAmt = 0
    FinalPayAmount = 0
    ActivityId = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActActivity)
    RecordStatus =  EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActRecordStatus)
    AA.Framework.getC_aalocarractivityrec()

*Openfiles
    EB.DataAccess.Opf(FnAccountDet, FAccountDet)
    EB.DataAccess.Opf(FnBillDet, FBillDet)

*process
    EB.DataAccess.FRead(FnAccountDet,ArrangementId,RAccountDet,FAccountDet,AccountDeError)
    
    AA.PaymentSchedule.GetBill(ArrangementId, ARR.ACTIVITY.ID, PAYMENT.DATE, "", BILL.DATE, BILL.TYPE, PAYMENT.METHOD, BILL.STATUS, BILL.SETTLE.STATUS, BILL.AGE.STATUS, BILL.NEXT.AGE.DATE, BILL.REPAYMENT.REFERENCE, BILL.REF, RET.ERROR)

    AllBillId = RAccountDet<AA.PaymentSchedule.AccountDetails.AdBillId>
    AllBillDate = RAccountDet<AA.PaymentSchedule.AccountDetails.AdBillDate>
    AllBillStatus = RAccountDet<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    AllBillPayMethod = RAccountDet<AA.PaymentSchedule.AccountDetails.AdPayMethod>
    AllBillSetStatus = RAccountDet<AA.PaymentSchedule.AccountDetails.AdSetStatus>

*Write Data
    writeData = BILL.REF :'***':AllBillId
    FileName = 'closure.txt'
    FilePath = 'EXIM.DATA'
    OPENSEQ FilePath,FileName TO FileOutput THEN NULL
    ELSE
        CREATE FileOutput ELSE
        END
    END
    WRITESEQ writeData APPEND TO FileOutput ELSE
        CLOSESEQ FileOutput
    END

***********


    CONVERT SM TO VM IN AllBillId
    CONVERT SM TO VM IN AllBillDate
    CONVERT SM TO VM IN AllBillStatus
    CONVERT SM TO VM IN AllBillPayMethod
    CONVERT SM TO VM IN AllBillSetStatus
    
    AllBillCnt = DCOUNT(AllBillId, @VM)
    
*Get All Bill Details
    FOR I = 1 TO AllBillCnt
        IF AllBillSetStatus<1, I> EQ 'UNPAID' AND AllBillStatus<1, I> NE 'SETTLED' THEN
            EB.DataAccess.FRead(FnBillDet,AllBillId<1, I>,RBill,FBillDet,BillError)
            
            BillProperty = RBill<AA.PaymentSchedule.BillDetails.BdProperty>
            BillAmt = RBill<AA.PaymentSchedule.BillDetails.BdOsPropAmount>
            CONVERT @VM TO @SM IN BillProperty
            CONVERT @VM TO @SM IN BillAmt
            OutstandingBills<-1> = AllBillId<1, I> : @VM : AllBillPayMethod<1, I> : @VM : BillProperty : @VM : BillAmt
            IF AllBillPayMethod<1, I> EQ 'DUE' THEN
                TotalDueAmt += BillAmt
            END
            ELSE
                TotalPayAmt += SUM(BillAmt)
            END
        END
    NEXT I
    
    FinalPayAmount = TotalPayAmt - TotalDueAmt
    OutBillCnt = DCOUNT(OutstandingBills, @FM)
    
*Calculate Bill Adjustment
    FieldAndAmt = ''
    FOR X = 1 TO OutBillCnt
        IF OutstandingBills<X,2> EQ 'PAY' AND TotalDueAmt GT 0 THEN
            TempProperties = OutstandingBills<X,3>
            TempAmt = OutstandingBills<X,4>
            CONVERT @SM TO @VM IN TempProperties
            CONVERT @SM TO @VM IN TempAmt
            LOCATE 'ACCOUNT' IN TempProperties<1,1> SETTING AccountPos THEN
                IF TempAmt<1,AccountPos> GE TotalDueAmt THEN
                    NewAcPropAmt = TempAmt<1,AccountPos> - TotalDueAmt
                    FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':AccountPos:@VM:NewAcPropAmt
                    TotalDueAmt = 0
                END
                ELSE
                    LOCATE 'DEPOSITPFT' IN TempProperties<1,1> SETTING ProfitPos THEN
                        FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':AccountPos:@VM:0
                        TotalDueAmt -= TempAmt<1,AccountPos>
                        IF TempAmt<1,ProfitPos> GE TotalDueAmt THEN
                            NewPftPropAmt = TempAmt<1,ProfitPos> - TotalDueAmt
                            FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':ProfitPos:@VM:NewPftPropAmt
                            TotalDueAmt = 0
                        END
                        ELSE
                            FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':ProfitPos:@VM:0
                            TotalDueAmt -= TempAmt<1,ProfitPos>
                        END
                    END
                END
            END
            ELSE
                LOCATE 'DEPOSITPFT' IN TempProperties<1,1> SETTING IndvPftPos THEN
                    IF TempAmt<1,IndvPftPos> GE TotalDueAmt THEN
                        NewPftPropAmt = TempAmt<1,IndvPftPos> - TotalDueAmt
                        FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':IndvPftPos:@VM:NewPftPropAmt
                        TotalDueAmt = 0
                    END
                    ELSE
                        FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':IndvPftPos:@VM:0
                        TotalDueAmt -= TempAmt<1,IndvPftPos>
                    END
                END
            END
        END
        IF OutstandingBills<X,2> EQ 'DUE' THEN
            FieldAndAmt<-1> = 'NEW.PROP.AMT:':X:'.':1:@VM:0
        END
    NEXT X
    
*Build Ofs String
    OfsText = ''
    FieldAndAmtCnt = DCOUNT(FieldAndAmt, @FM)
    
    FOR W = 1 TO FieldAndAmtCnt
        OfsText<-1> = 'FIELD.NAME:1:':W:'=':FieldAndAmt<W,1>:',FIELD.VALUE:1:':W:'=':FieldAndAmt<W,2>
    NEXT W
    CONVERT @FM TO ',' IN OfsText
    OfsString = 'AA.ARRANGEMENT.ACTIVITY,BILL.ADJUST.OFS/I/PROCESS,//'
    OfsString := EB.SystemTables.getIdCompany():',,ARRANGEMENT::=':ArrangementId:',ACTIVITY::=DEPOSITS-ADJUST.BILL-BALANCE.MAINTENANCE,'
    OfsString := 'EFFECTIVE.DATE::=':EB.SystemTables.getToday():',CURRENCY::=BDT,PROPERTY:1:1=BALANCE.MAINTENANCE,'
    OfsString := OfsText
    
    OfsSource = 'EXIM.OFS.ENT'
    OfsMsgId = ''
    Options = ''
    EB.Interface.OfsPostMessage(OfsString, OfsMsgId, OfsSource, Options)
    EB.TransactionControl.JournalUpdate('')
RETURN
END
