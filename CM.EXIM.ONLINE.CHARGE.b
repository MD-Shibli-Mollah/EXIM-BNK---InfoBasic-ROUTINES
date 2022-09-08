* @ValidationCode : MjoxOTg1MTk4MTA5OkNwMTI1MjoxNTc0OTI3NTI3ODU1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 28 Nov 2019 13:52:07
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
SUBROUTINE CM.EXIM.ONLINE.CHARGE(Y.CUS.NO,Y.DEAL.AMOUNT,Y.DEAL.CCY,Y.CCY.MKT,Y.CROSS.RATE,Y.CROSS.CCY,Y.DWN.CCY,Y.DATA,Y.CUST.CDN,Y.CHRG.AMT)

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
    
    
    
    DR.COM.CODE = R.NEW(FT.Contract.FundsTransfer.DebitCompCode)
    CR.COM.CODE = R.NEW(FT.Contract.FundsTransfer.CreditCompCode)
    DR.AMT = R.NEW(FT.Contract.FundsTransfer.DebitAmount)
    
            
    EB.DataAccess.FRead(FN.COMPANY, DR.COM.CODE, REC.COMPANY1, F.COMPANY, COMPANY.ERR1)
    DR.ZONE.CODE = REC.COMPANY1<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    
    EB.DataAccess.FRead(FN.COMPANY, CR.COM.CODE, REC.COMPANY2, F.COMPANY, COMPANY.ERR2)
    CR.ZONE.CODE = REC.COMPANY2<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    
    IF DR.ZONE.CODE EQ CR.ZONE.CODE THEN
    
        R.NEW(FT.Contract.FundsTransfer.CommissionCode) = 'WAIVE'
    
    END ELSE
    
        R.NEW(FT.Contract.FundsTransfer.CommissionCode) = 'DEBIT PLUS CHARGES'
        R.NEW(FT.Contract.FundsTransfer.CommissionType) = 'ONLINECHG'
    
        BEGIN CASE
            CASE DR.AMT LE 50000
                Y.CHRG.AMT = 0
            CASE DR.AMT LE 200000
                Y.CHRG.AMT = 50
            CASE DR.AMT LE 500000
                Y.CHRG.AMT = 100
            CASE DR.AMT LE 1000000
                Y.CHRG.AMT = 200
            CASE DR.AMT LE 5000000
                Y.CHRG.AMT = 300
            CASE 1
                Y.CHRG.AMT = 500
        END CASE
    END

RETURN
END