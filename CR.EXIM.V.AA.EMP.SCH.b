* @ValidationCode : MjotODEyMDYyMjU0OkNwMTI1MjoxNTgyMTg1NDk0NTcwOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Feb 2020 13:58:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.AA.EMP.SCH
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING EB.Foundation
    $USING EB.API
    $USING EB.Utility
    $USING EB.Updates
*-----------------------------------------------------------------------------
    Y.AA.ID = c_aalocArrId
    
    PROP.CLASS.TERM = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID, PROP.CLASS.TERM, PROPERTY, '', RETURN.IDS.TERM, RETURN.VALUES.TERM, ERR.MSG.TERM)
    R.TERM.AMT = RAISE(RETURN.VALUES.TERM)
    
*Map Local fields
    APPLICATION.NAME = 'AA.ARR.PAYMENT.SCHEDULE':FM:'AA.ARR.TERM.AMOUNT'
    LOCAL.FIELDS = 'LT.INS.START':@VM:'LT.INS.SIZE':FM:'LT.PROFIT.REC'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.INS.START.POS = FLD.POS<1,1>
    Y.INS.SIZE.POS = FLD.POS<1,2>
    Y.PFT.REC.POS = FLD.POS<2,1>
*    APPLICATION.NAMES = 'AA.ARR.PAYMENT.SCHEDULE'
*    LOCAL.FIELDS = 'LT.INS.START':@VM:'LT.INS.SIZE'
*    EB.Foundation.MapLocalFields(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
*    Y.INS.START.POS = FLD.POS<1,1>
*    Y.INS.SIZE.POS = FLD.POS<1,2>
    
*Get Payment Schedule AND Term Amount data
    Y.PS.LT.DATA = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsLocalRef)
    Y.INS.START = Y.PS.LT.DATA<1,Y.INS.START.POS>
    Y.INS.SIZE = Y.PS.LT.DATA<1,Y.INS.SIZE.POS>
    IF Y.INS.START EQ '' OR Y.INS.SIZE EQ '' THEN
        RETURN
    END
    Y.COM.AMT = R.TERM.AMT<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM.LT.DATA = R.TERM.AMT<AA.TermAmount.TermAmount.AmtLocalRef>
    Y.PFT.REC = Y.TERM.LT.DATA<1,Y.PFT.REC.POS>
    Y.PAY.FREQ = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
    Y.TEMP.PAY.FREQ = Y.PAY.FREQ
    Y.PAY.FREQ = Y.PAY.FREQ<1,2>
    
*Calculate Number of installment and size and freq
    Y.NUM.OF.INS = INT(Y.COM.AMT / Y.INS.SIZE)
    Y.REMAIN.AMT = MOD(Y.COM.AMT, Y.INS.SIZE)
    Y.FREQ.MONTH = FIELD(Y.PAY.FREQ,'M',1)
    Y.FREQ.MONTH = FIELD(Y.FREQ.MONTH,'e',3)
    Y.ORIG.FRQ = Y.FREQ.MONTH
    Y.FREQ.MONTH = Y.FREQ.MONTH * Y.NUM.OF.INS
    Y.FREQ.MONTH = Y.FREQ.MONTH : 'M'
    EB.Utility.CalendarDay(Y.INS.START, '+', Y.FREQ.MONTH)
    Y.CALC.AMT = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsCalcAmount)
    Y.PRF.INS.NUM = Y.CALC.AMT / Y.INS.SIZE

*Get fields for modification
    Y.SCHL.START = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
    Y.SCHL.NUM = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)
    Y.SCHL.AMT = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
    Y.PAY.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    Y.PAY.METHOD = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)
    Y.PAY.FQ.ALL = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
    Y.PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)
    Y.BILL.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType)
    
*Second row modification
    Y.SCHL.START<1,2> = 'D_' : Y.INS.START
    Y.SCHL.NUM<1,2> = Y.NUM.OF.INS
    Y.SCHL.AMT<1,2> = Y.INS.SIZE
    
*Third Row Modificaiton
    Y.SCHL.START<1,3> = 'D_' : Y.FREQ.MONTH
    Y.SCHL.NUM<1,3> = 1
    Y.SCHL.AMT<1,3> = Y.REMAIN.AMT
    
    
    IF Y.PFT.REC NE 'YES' THEN
*Fourth Row Modification
        Y.SCHL.START<1,4> = 'D_' : Y.FREQ.MONTH
        Y.SCHL.NUM<1,4> = 1
        Y.SCHL.AMT<1,4> = Y.INS.SIZE - Y.REMAIN.AMT
        Y.PAY.TYPE<1,4> = 'CONSTANT'
        Y.PAY.METHOD<1,4> = 'DUE'
        Y.PAY.FQ.ALL<1,4> = Y.PAY.FQ.ALL<1,2>
        Y.PROPERTY<1,4,1> = 'ACCOUNT'
        Y.PROPERTY<1,4,2> = 'DEFERREDPFT'
        Y.BILL.TYPE<1,4> = 'INTEREST'
*Fifth Row Modification
        Y.FREQ.5 = ((Y.ORIG.FRQ * Y.NUM.OF.INS)+Y.ORIG.FRQ) : 'M'
        EB.Utility.CalendarDay(Y.INS.START, '+', Y.FREQ.5)
        Y.MAT.DATE = R.TERM.AMT<AA.TermAmount.TermAmount.AmtMaturityDate>
        IF Y.FREQ.5 LE  Y.MAT.DATE THEN
            EB.Utility.NoOfMonths(Y.FREQ.5,Y.MAT.DATE,Y.NUM.OF.INS.5)
            Y.SCHL.START<1,5> = 'D_' : Y.FREQ.5
*Y.SCHL.NUM<1,5> = Y.NUM.OF.INS.5
            Y.SCHL.AMT<1,5> = Y.INS.SIZE
            Y.PAY.TYPE<1,5> = 'CONSTANT'
            Y.PAY.METHOD<1,5> = 'DUE'
            Y.PAY.FQ.ALL<1,5> = Y.PAY.FQ.ALL<1,2>
            Y.PROPERTY<1,5,1> = 'ACCOUNT'
            Y.PROPERTY<1,5,2> = 'DEFERREDPFT'
            Y.BILL.TYPE<1,5> = 'INTEREST'
        END
    END

*Set data to fields
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate, Y.SCHL.START)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments, Y.SCHL.NUM)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt, Y.SCHL.AMT)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType, Y.PAY.TYPE)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod, Y.PAY.METHOD)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq, Y.PAY.FQ.ALL)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty, Y.PROPERTY)
    EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType, Y.BILL.TYPE)
RETURN
END