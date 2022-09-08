* @ValidationCode : Mjo0MDk3MTUyODI6Q3AxMjUyOjE1Nzg4MTA4MDIwNDc6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Jan 2020 12:33:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.CHECK.AA.MAT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.Utility
    $USING AA.Interest
    $USING AA.TermAmount
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
*-----------------------------------------------------------------------------

    LinkedAA = EB.SystemTables.getRNew(AA.Interest.Interest.IntLinkedArrangement)
    PropClass = "TERM.AMOUNT"
    AA.Framework.GetArrangementConditions(LinkedAA, PropClass, Idproperty, "", Returnids, ReturnValues, Returnerror)
    RTermConditions = RAISE(ReturnValues)
    LinkedAAMatDate = RTermConditions<AA.TermAmount.TermAmount.AmtMaturityDate>
    
    LoanTerm = EB.SystemTables.getRNew(AA.TermAmount.TermAmount.AmtTerm)
    LoanMatDate = EB.SystemTables.getRNew(AA.TermAmount.TermAmount.AmtMaturityDate)
    EffectiveDate = EB.SystemTables.getRNew(AA.Framework.ArrangementActivity.ArrActEffectiveDate)
    
    IF LoanMatDate EQ "" THEN
        LoanMatDate = EB.Utility.CalendarDay(EffectiveDate, '+', LoanTerm)
    END
    
    IF LinkedAAMatDate LT LoanMatDate THEN
        EB.SystemTables.setText("Linked AA Maturity Date is less than Loan Maturity date")
        OverrideVal = EB.SystemTables.getRNew(V-9)
        OverrideNo = DCOUNT(OverrideVal,@VM) + 1
        EB.OverrideProcessing.StoreOverride(OverrideNo)
    END
END
