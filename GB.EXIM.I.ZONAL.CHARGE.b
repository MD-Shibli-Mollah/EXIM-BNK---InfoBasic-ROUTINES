* @ValidationCode : MjotMjAzNjA1ODQxMjpDcDEyNTI6MTU3NzE3MDIxNTI5NzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Dec 2019 12:50:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.I.ZONAL.CHARGE
*-----------------------------------------------------------------------------
*Author : s.azam@fortress-global.com
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
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
    $INSERT I_F.ACCOUNT.CLASS
    
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING TT.Contract
    $USING AA.Account
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.Updates
    $USING EB.SystemTables
    $USING ST.ChargeConfig
    $USING AC.Config
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

******
INIT:
******
    
    Y.CHRG.AMT = 0
    DR.COM.CODE = ''
    CR.COM.CODE = ''
    Y.TXN.AMT  = 0
    Y.AC.ID = ''
    Y.AC.CO.CODE = ''
    AC.ZONE.CODE = ''
    TELLER.ZONE.CODE = ''
   
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    FN.COM = 'F.COMPANY'
    F.COM = ''
    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
    
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
    EB.DataAccess.Opf(FN.ACC,F.ACC)
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

**********
PROCESS:
**********
    FLD.POS = ''
    APPLICATION.NAME = 'COMPANY'
    LOCAL.FIELD = 'LT.ZONE.CODE'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME,LOCAL.FIELD,FLD.POS)
    Y.ZONE.CODE.POS = FLD.POS<1,1>
    
    Y.TT.CO.CODE = EB.SystemTables.getIdCompany()
    Y.AC.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
    EB.DataAccess.FRead(FN.ACC,Y.AC.ID,R.ACC,F.ACC,AC.ER)
    Y.CATEGORY = R.ACC<AC.AccountOpening.Account.Category>
    Y.AC.CLASS.ID = 'U-CD.SV.SND'
    EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS,F.AC.CLASS,AC.CLASS.ER)
    Y.CATEG.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>
    LOCATE Y.CATEGORY IN Y.CATEG.LIST<1,1> SETTING Y.CATEG.POS THEN NULL
    IF Y.CATEG.POS EQ '' THEN
        RETURN
    END
    Y.TXN.AMT = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)
    EB.DataAccess.FRead(FN.ACC,Y.AC.ID,R.AC,F.ACC,ACC.ERR1)
    Y.AC.CO.CODE = R.AC<AC.AccountOpening.Account.CoCode>
    EB.DataAccess.FRead(FN.COM,Y.AC.CO.CODE,R.AC.CO.CODE,F.COM,COM.ERR1)
    Y.AC.ZONE.CODE = R.AC.CO.CODE<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    
    EB.DataAccess.FRead(FN.COM,Y.TT.CO.CODE,R.CO.CODE,F.COM,COM.ERR2)
    Y.TT.ZONE.CODE = R.CO.CODE<ST.CompanyCreation.Company.EbComLocalRef,Y.ZONE.CODE.POS,1>
    IF Y.AC.ZONE.CODE EQ Y.TT.ZONE.CODE THEN
        EB.SystemTables.setRNew(TT.Contract.Teller.TeChargeCode,'')
        EB.SystemTables.setRNew(TT.Contract.Teller.TeChrgAmtLocal,'')
        EB.SystemTables.setRNew(TT.Contract.Teller.TeChargeAccount,'')
        EB.SystemTables.setRNew(TT.Contract.Teller.TeWaiveCharges,'YES')
        Y.CHRG.AMT = 0
    END ELSE
        EB.SystemTables.setRNew(TT.Contract.Teller.TeChargeCode,'ONLINECHG')
        Y.FTCT.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeChargeCode)
        EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
        Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
        Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
        CONVERT SM TO VM IN Y.UPTO.AMT
        CONVERT SM TO VM IN Y.MIN.AMT
        Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.AMT = Y.UPTO.AMT<1,I>
            IF Y.TXN.AMT LE Y.AMT THEN
                BREAK
            END
        NEXT I
        Y.CHRG.AMT = Y.MIN.AMT<1,I>
        EB.SystemTables.setRNew(TT.Contract.Teller.TeWaiveCharges,'NO')
    END
    EB.SystemTables.setRNew(TT.Contract.Teller.TeChrgAmtLocal,Y.CHRG.AMT)
    
RETURN

END
