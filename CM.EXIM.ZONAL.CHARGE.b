* @ValidationCode : MjotMTAxMjc1OTkyNDpDcDEyNTI6MTU3NTUyNDA2NjM1MDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 05 Dec 2019 11:34:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
*-----------------------------------------------------------------------------
* <Rating>77</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE CM.EXIM.ZONAL.CHARGE(Y.CUS.NO,Y.DEAL.AMOUNT,Y.DEAL.CCY,Y.CCY.MKT,Y.CROSS.RATE,Y.CROSS.CCY,Y.DWN.CCY,Y.DATA,Y.CUST.CDN,Y.CHRG.AMT)
SUBROUTINE CM.EXIM.ZONAL.CHARGE

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DRAWINGS
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.CURRENCY
    $INSERT I_F.CURRENCY.MARKET
    $INSERT I_GTS.COMMON
    $INSERT I_F.LETTER.OF.CREDIT
    $INSERT I_F.LC.TYPES
    $INSERT I_F.TELLER
    $INSERT I_F.ACCOUNT
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING TT.Contract
    $USING AA.Account
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.Updates
    $USING EB.SystemTables


    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN


*----------
INITIALISE:
*----------

    Y.CHRG.AMT = 0
    DR.COM.CODE = ''
    CR.COM.CODE = ''
    Y.AMT  = 0
    Y.AC.ID = ''
    Y.AC.CO.CODE = ''
    AC.ZONE.CODE = ''
    TELLER.ZONE.CODE = ''
   
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    CALL OPF(FN.FTCT,F.FTCT)
    R.FTCT.REC = ''
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    EB.DataAccess.Opf( FN.ACCOUNT, F.ACCOUNT)
    
    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    EB.DataAccess.Opf( FN.COMPANY, F.COMPANY)

RETURN

*-------
PROCESS:
*-------



    FLD.POS = ''
    APPLICATION.NAME = 'COMPANY'
    LOCAL.FIELD = 'LT.ZONE.CODE'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME,LOCAL.FIELD,FLD.POS)
    Y.ZONE.CODE.POS = FLD.POS<1,1>
    
    
    
    TELLER.COM.CODE = EB.SystemTables.getIdCompany()
    Y.AC.ID = R.NEW(TT.Contract.Teller.TeAccountTwo)
*Y.AC.ID = '111000000918'
    Y.AMT = R.NEW(TT.Contract.Teller.TeAmountLocalOne)
    
            
    EB.DataAccess.FRead(FN.ACCOUNT, Y.AC.ID, REC.AC1, F.ACCOUNT, ACC.ERR1)
    Y.AC.CO.CODE = REC.AC1<AC.AccountOpening.Account.CoCode>
    
    EB.DataAccess.FRead(FN.COMPANY, Y.AC.CO.CODE, REC.COMPANY1, F.COMPANY, COMPANY.ERR1)
    AC.ZONE.CODE = REC.COMPANY1<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    
    EB.DataAccess.FRead(FN.COMPANY, TELLER.COM.CODE, REC.COMPANY2, F.COMPANY, COMPANY.ERR2)
    TELLER.ZONE.CODE = REC.COMPANY2<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    
    IF AC.ZONE.CODE EQ TELLER.ZONE.CODE THEN
        R.NEW(TT.Contract.Teller.TeChargeCode) = ''
        R.NEW(TT.Contract.Teller.TeChrgAmtLocal) = ''
        R.NEW(TT.Contract.Teller.TeChargeAccount) = ''
        R.NEW(TT.Contract.Teller.TeWaiveCharges) = 'YES'
*Y.CHRG.AMT = 0
    
    END ELSE
        
        !R.NEW(TT.Contract.Teller.TeChargeCode) = 'ONLINECHG'
*R.NEW(TT.Contract.Teller.TeChgType) = 'DEBIT PLUS CHARGES'
        BEGIN CASE
            CASE Y.AMT LE 50000
                Y.CHRG.AMT = 0
            CASE Y.AMT LE 200000
                Y.CHRG.AMT = 50
            CASE Y.AMT LE 500000
                Y.CHRG.AMT = 100
            CASE Y.AMT LE 1000000
                Y.CHRG.AMT = 200
            CASE Y.AMT LE 5000000
                Y.CHRG.AMT = 300
            CASE 1
                Y.CHRG.AMT = 500
        END CASE
        !R.NEW(TT.Contract.Teller.TeChrgAmtLocal) = Y.CHRG.AMT
    END
RETURN
END