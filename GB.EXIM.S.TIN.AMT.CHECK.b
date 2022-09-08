* @ValidationCode : MjotMjA1NjkyMjUwMDpDcDEyNTI6MTU3OTQyMDIzMzE0NDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Jan 2020 13:50:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.S.TIN.AMT.CHECK( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
*-----------------------------------------------------------------------------
* This routine calculate TAX amount based on TIN given or not and attached in CALC.ROUTINE field of TAX Application
* Developed By- s.azam@fortress-global.com
* Condition 1 : If TIN given then Tax will be 10%
* Condition 2 : If TIN not given and maximum balance less than One lac during Capitalisation period then Tax will be 10%
* Condition 3 : If TIN not given and maximum balance grater than One lac during Capitalisation period then Tax will be 15%
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $USING AA.Framework
    $USING EB.API
    $USING ST.Customer
    $USING AC.AccountOpening
    $INSERT I_F.ACCOUNT
    $USING AA.Customer
    $INSERT I_F.AA.CUSTOMER
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.CUS= 'F.AA.ARR.CUSTOMER'
    F.CUS = ''
    REC.CUS = ''

    FN.SS= 'F.STANDARD.SELECTION'
    F.SS = ''
    R.SS = ''
    
    SYSTEM.DATE=EB.SystemTables.getToday()
    Y.MAX.AMT.ORIG=''
    Y.MAX.AMT.TEMP=''
    Y.TIN.AMOUNT=100000
    Y.ETIN = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.SS,F.SS)
RETURN

********
PROCESS:
********
    Y.CUS.NO = c_aalocArrangementRec<AA.Framework.Arrangement.ArrCustomer>
    EB.DataAccess.FRead(FN.CUS,Y.CUS.NO,R.CUS,F.CUS, E.CUS)
    Y.TIN.VAL=R.CUS<ST.Customer.Customer.EbCusTaxId>

    Y.TIN.LEN = LEN(Y.TIN.VAL)
    Y.TIN.NUM = NUM(Y.TIN.VAL)

    IF (Y.TIN.LEN EQ 12) AND Y.TIN.NUM THEN
        Y.ETIN = 'Y'
    END
    Y.END.DATE = EB.SystemTables.getToday()
    Y.END.MNTH = Y.END.DATE[5,2] 'R%2'
    IF Y.END.MNTH LE '06' THEN
        Y.START.DATE = Y.END.DATE[1,4]:'0101'
    END ELSE
        Y.START.DATE = Y.END.DATE[1,4]:'0701'
    END
    
    ArrangementId = PASS.CUSTOMER<5>

    AA.Framework.GetArrangementAccountId(ArrangementId, AccountId, Currency, ReturnError)
    AA.Framework.GetArrAccountProductLine(AccountId, ProductLine, ReturnError)
    Y.PRODUCT.LINE = ProductLine
    BaseBalance = 'CURBALANCE'
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(AccountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)
    Y.MAX.AMT.ORIG = MAXIMUM(BalDetails<4>)
***********************************************************
    IF Y.ETIN EQ 'Y' THEN
        TAX.AMOUNT=(PASS.DEAL.AMOUNT*10)/100
    END
    ELSE
        BEGIN CASE
            CASE Y.ETIN EQ '' AND ( Y.MAX.AMT.ORIG GT Y.TIN.AMOUNT )
                TAX.AMOUNT=(PASS.DEAL.AMOUNT*15)/100
            CASE Y.ETIN EQ '' AND ( Y.MAX.AMT.ORIG LE Y.TIN.AMOUNT )
                TAX.AMOUNT=(PASS.DEAL.AMOUNT*10)/100
        END CASE
    END
    
RETURN
END
