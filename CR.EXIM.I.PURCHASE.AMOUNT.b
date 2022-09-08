* @ValidationCode : MjotMjc1MzU2NjQzOkNwMTI1MjoxNTg2MTc3Njc3OTk1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2020 18:54:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.I.PURCHASE.AMOUNT
*-----------------------------------------------------------------------------
* Developed By- s.azam@fortress-global.com
* Condition  : This Routine Validate Total Purchase Amount GT Sanctioned Amount
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LIMIT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUSTOMER.LIABILITY
        
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING ST.Customer
    $USING IS.Purchase
    $USING LI.Config
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.Foundation
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

******
INIT:
******
    

*This section initialises local variables
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.IS.C = 'F.IS.CONTRACT'
    F.IS.C = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.CUS.LIAB = 'F.CUSTOMER.LIABILITY'
    F.CUS.LIAB = ''
    
    APPLICATION.NAME = 'IS.CONTRACT'
    LOCAL.FIELDS = 'LT.LIMIT.REF':VM:'LT.LIMIT.ID'
    EB.Foundation.MapLocalFields(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.LIMIT.REF.POS = FLD.POS<1,1>
    Y.LIMIT.ID.POS = FLD.POS<1,2>
RETURN

**********
OPENFILES:
**********
*This section open local applications
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.IS.C,F.IS.C)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.CUS.LIAB,F.CUS.LIAB)
RETURN


********
PROCESS:
********
*Validation Total Purchase Amount GT Sanctioned Amount
*Y.TOT.PURCHASE.AMT = EB.SystemTables.getRNew(IS.CON.TOT.PURCHASE.PRICE)
*Y.CUS.ID = EB.SystemTables.getRNew(IS.CON.CUSTOMER)
*Y.LIMIT.REF = EB.SystemTables.getRNew(IS.CON.LOCAL.REF)<1,Y.LIMIT.REF.POS>
    
    Y.TOT.PURCHASE.AMT = EB.SystemTables.getRNew(IS.Purchase.Contract.IcTotPurchasePrice)
    Y.LIMIT.REF = EB.SystemTables.getRNew(IS.Purchase.Contract.IcLocalRef)<1,Y.LIMIT.REF.POS>
    Y.LIMIT.ID = EB.SystemTables.getRNew(IS.Purchase.Contract.IcLocalRef)<1,Y.LIMIT.ID.POS>
    Y.CUS.ID = EB.SystemTables.getRNew(IS.Purchase.Contract.IcCustomer)
    IF Y.LIMIT.ID EQ '' THEN
        GOSUB LI.ASSIGN.CHECK
    END ELSE
        IF FIELD(Y.LIMIT.ID,'.',4) EQ '' THEN
            GOSUB LI.ASSIGN
        END
    END
    
    EB.DataAccess.FRead(FN.CUS,Y.CUS.ID,R.CUS,F.CUS,ER.CUS)
    Y.CUS.LIAB.ID = R.CUS<ST.Customer.Customer.EbCusCustomerLiability>
    EB.DataAccess.FRead(FN.CUS.LIAB,Y.CUS.LIAB.ID,R.CUS.LIAB,F.CUS.LIAB,ER.CUS.LIAB)
    
    Y.SIS.CONCERN = FIELD(Y.LIMIT.ID,'.',4)
    IF R.CUS.LIAB EQ Y.CUS.LIAB.ID OR FIELD(Y.LIMIT.ID,'.',4) EQ '' THEN
        GOSUB CUSPROCESS
        RETURN
    END ELSE
        GOSUB PRODUCTPROCESS
        RETURN
    END


****************
LI.ASSIGN.CHECK:
****************
    Y.LIMIT.PAR.ID = Y.CUS.ID:'.':INT(Y.LIMIT.REF/10)*10 'R%7' :'01'
    EB.DataAccess.FRead(FN.LI,Y.LIMIT.PAR.ID, R.P.LI, F.LI, LI.ERROR)
    IF R.P.LI EQ '' THEN
        EB.SystemTables.setText('Limit not assigned in Sub Product Level')
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END ELSE
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.PAR.ID, R.PAR.LI, F.LI, LI.PAR.ERROR)
        Y.LIMIT.AMT = R.PAR.LI<LI.Config.Limit.InternalAmount>
        Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
        IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
            EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
            Y.OVERR.ID = 'Limit Exceed in Sub Product Level by TK.  '
            Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
            EB.SystemTables.setText(Y.OVERR.ID.LI)
            EB.ErrorProcessing.StoreEndError()
        END
    END
    Y.LIMIT.H.PAR.ID = Y.CUS.ID:'.':INT(Y.LIMIT.REF/100)*100 'R%7' :'01'
    EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.H.P.LI, F.LI, LI.ERROR)
    IF R.H.P.LI EQ '' THEN
        EB.SystemTables.setText('Limit not assigned in Product Level')
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END ELSE
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.H.PAR.ID, R.H.PAR.LI, F.LI, LI.PAR.ERROR)
        Y.LIMIT.AMT = R.PAR.LI<LI.Config.Limit.InternalAmount>
        Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
        IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
            EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
            Y.OVERR.ID = 'Limit Exceed in Sub Product Level by TK.  '
            Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
            EB.SystemTables.setText(Y.OVERR.ID.LI)
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN

**********
LI.ASSIGN:
**********
    EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
    Y.RESTRIC.CUS = R.LI<LI.Config.Limit.AllowedCust>
    LOCATE FIELD(Y.LIMIT.ID,'.',1) IN Y.RESTRIC.CUS<1,1> SETTING Y.COM.POS THEN
        Y.OVERR.ID = 'Customer  ':FIELD(Y.LIMIT.ID,'.',1):' is restricted to use this Limit'
        Y.OVERR.ID.LI = Y.OVERR.ID
        EB.SystemTables.setText(Y.OVERR.ID.LI)
        EB.ErrorProcessing.StoreEndError()
    END
    Y.RESTRIC.COM = R.LI<LI.Config.Limit.AllowedComp>
    LOCATE EB.SystemTables.getIdCompany() IN Y.RESTRIC.COM<1,1> SETTING Y.COM.POS THEN
        Y.OVERR.ID = 'Company ':EB.SystemTables.getIdCompany():' is restricted to use this Limit'
        Y.OVERR.ID.LI = Y.OVERR.ID
        EB.SystemTables.setText(Y.OVERR.ID.LI)
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
***********
CUSPROCESS:
***********
    EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
    IF R.LI EQ '' THEN
        EB.SystemTables.setText('Limit not assigned in Multi Product Level')
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END
    IF R.LI NE '' THEN
        Y.LIMIT.AMT = R.LI<LI.Config.Limit.InternalAmount>
        Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
        IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
            EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
            Y.OVERR.ID = 'Limit Exceed in Multi Product Level by TK.  '
            Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
            EB.SystemTables.setText(Y.OVERR.ID.LI)
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END
        Y.LIMIT.PAR.ID = R.LI<LI.Config.Limit.RecordParent>
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.PAR.ID, R.PAR.LI, F.LI, LI.PAR.ERROR)
        IF R.PAR.LI EQ '' THEN
            EB.SystemTables.setText('Limit not assigned in Sub product Level')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.LIMIT.AMT = R.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.P.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Limit Exceed in Sub Product Level by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.P.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
        Y.LIMIT.H.PAR.ID = R.PAR.LI<LI.Config.Limit.RecordParent>
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.H.PAR.ID, R.H.PAR.LI, F.LI, LI.H.PAR.ERROR)
        IF R.H.PAR.LI EQ '' THEN
            EB.SystemTables.setText('Limit not assigned in Product Level')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.LIMIT.AMT = R.H.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.H.P.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Limit Exceed in Product Level by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.H.P.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
    END
RETURN

***************
PRODUCTPROCESS:
***************
*****************************************START CHILD**********************************************************
    EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
    IF R.LI EQ '' THEN
        EB.SystemTables.setText('Limit of this Child not assigned in Multi-product')
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END ELSE
        Y.LIMIT.AMT = R.LI<LI.Config.Limit.InternalAmount>
        Y.PAR.LIMIT.ID = R.LI<LI.Config.Limit.RecordParent>
        
        EB.DataAccess.FRead(FN.LI,Y.PAR.LIMIT.ID, R.PAR.LI, F.LI, LI.ERROR)
        Y.H.PAR.LIMIT.ID = R.PAR.LI<LI.Config.Limit.RecordParent>
        
        EB.DataAccess.FRead(FN.LI,Y.PAR.LIMIT.ID, R.H.PAR.LI, F.LI, LI.ERROR)
        
        Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
        IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
            EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
            Y.OVERR.ID = 'Limit of this Child Exceed in Multi-product by TK.  '
            Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
            EB.SystemTables.setText(Y.OVERR.ID.LI)
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END
        
        IF FIELD(Y.LIMIT.ID,'.',1):FIELD(Y.LIMIT.ID,'.',2):FIELD(Y.LIMIT.ID,'.',3) EQ '' THEN
            EB.SystemTables.setText('Parent Limit not Assigned in Multi Product')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.P.LIMIT.ID = FIELD(Y.LIMIT.ID,'.',1):'.':FIELD(Y.LIMIT.ID,'.',2):'.':FIELD(Y.LIMIT.ID,'.',3)
            EB.DataAccess.FRead(FN.LI,Y.P.LIMIT.ID, R.P.LI, F.LI, LI.ERROR)
            Y.LIMIT.AMT = R.P.LI<LI.Config.Limit.InternalAmount>
            Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Parent Limit Exceed in Multi Product by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
*******************************************END**************************************************************
*******************************************START.PARENT**************************************************************
        IF Y.PAR.LIMIT.ID EQ '' THEN
            EB.SystemTables.setText('Limit of this Child not assigned in Sub-product')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.PAR.LIMIT.AMT = R.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.PAR.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.PAR.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.PAR.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Limit of this Child Exceed in Sub-product by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.PAR.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
        IF FIELD(Y.PAR.LIMIT.ID,'.',1):'.':FIELD(Y.PAR.LIMIT.ID,'.',2):'.':FIELD(Y.PAR.LIMIT.ID,'.',3) EQ '' THEN
            EB.SystemTables.setText('Parent Limit not Assigned in Sub Product')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.P.PAR.LIMIT.ID = FIELD(Y.PAR.LIMIT.ID,'.',1):'.':FIELD(Y.PAR.LIMIT.ID,'.',2):'.':FIELD(Y.PAR.LIMIT.ID,'.',3)
            EB.DataAccess.FRead(FN.LI, Y.P.PAR.LIMIT.ID, R.P.PAR.LI, F.LI, LI.ERROR)
            Y.LIMIT.AMT = R.P.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Parent Limit Exceed in Sub Product by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
*******************************************END******************************************************************
*******************************************START HEAD PARENT****************************************************
        IF Y.H.PAR.LIMIT.ID EQ '' THEN
            EB.SystemTables.setText('Limit of this Child not assigned in Product')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.H.PAR.LIMIT.AMT = R.H.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.H.PAR.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.H.PAR.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.H.PAR.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Limit of this Child Exceed in Product by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.H.PAR.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
        IF FIELD(Y.H.PAR.LIMIT.ID,'.',1):'.':FIELD(Y.H.PAR.LIMIT.ID,'.',2):'.':FIELD(Y.H.PAR.LIMIT.ID,'.',3) EQ '' THEN
            EB.SystemTables.setText('Parent Limit not Assigned in Product')
            Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
            Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
            EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        END ELSE
            Y.H.P.PAR.LIMIT.ID = FIELD(Y.H.PAR.LIMIT.ID,'.',1):'.':FIELD(Y.H.PAR.LIMIT.ID,'.',2):'.':FIELD(Y.H.PAR.LIMIT.ID,'.',3)
            EB.DataAccess.FRead(FN.LI, Y.H.P.PAR.LIMIT.ID, R.H.P.PAR.LI, F.LI, LI.ERROR)
            Y.LIMIT.AMT = R.H.P.PAR.LI<LI.Config.Limit.InternalAmount>
            Y.LI.AMT.EXCEED = Y.TOT.PURCHASE.AMT - Y.LIMIT.AMT
            IF Y.TOT.PURCHASE.AMT GT Y.LIMIT.AMT THEN
                EB.SystemTables.setAf(IS.CON.TOT.PURCHASE.PRICE)
                Y.OVERR.ID = 'Parent Limit Exceed in Product by TK.  '
                Y.OVERR.ID.LI = Y.OVERR.ID : Y.LI.AMT.EXCEED
                EB.SystemTables.setText(Y.OVERR.ID.LI)
                Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
                Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
                EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
            END
        END
*******************************************END******************************************************************
    END
RETURN
END
