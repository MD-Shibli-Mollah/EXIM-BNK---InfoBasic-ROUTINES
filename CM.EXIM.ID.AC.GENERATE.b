* @ValidationCode : MjotOTYzMzE3NjE3OkNwMTI1MjoxNTc2MDY0MDIwOTAxOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Dec 2019 17:33:40
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
* <Rating>257</Rating>
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*=================================================================================*
* This subroutine is defined in COMPANY record in field ACCT.CHEKDIG.TYPE,        *
* it is called whenever an account number is entered in any GLOBUS application.   *
* for EXIM, this routine allows to generate automatically the account number*
* when creating a new account. The user will enter the Product Code in the ID     *
* field of the ACCOUNT application, automatically the subroutine will return an   *
* account number with the following structure: LL-PP-SSSSSSSS-C format where:     *
* LL = Two digits of Financial Company Ex : BD0010999 LL would be "01"            *
* where the user is currently logged in)                                          *
* Ex : BD0025000 LL would be '02'                                                 *
* PP = Product Prefix Ex : 11,21,31                                               *
* SSSSSSSS = Sequence No                                                          *
* C = Check Digit                                                                 *
* Developed By- s.azam@fortress-global.com                                        *
*=================================================================================*

*=================================================================================*
*
*
*=================================================================================*
SUBROUTINE CM.EXIM.ID.AC.GENERATE
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.LOCKING
    $INSERT I_F.INTERCO.PARAMETER
    $INSERT I_F.COMPANY
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_AA.APP.COMMON
    $USING ST.CompanyCreation
    
    $USING AA.Account
    $USING EB.DataAccess
    $USING EB.Updates
    $USING EB.API
    $USING AA.Framework
    $USING EB.SystemTables
   
    IF (OFS$BROWSER AND (OFS$OPERATION EQ 'VALIDATE' OR OFS$OPERATION EQ 'PROCESS')) THEN RETURN
    IF BATCH.INFO<3> EQ "AA.DELETE.NAU.ACTIVITIES" THEN RETURN
    IF AA$ARR.PRODUCT.ID AND COMI<2> NE 'NEW' THEN RETURN
    IF APPLICATION NE 'ACCOUNT' THEN RETURN
    IF V$FUNCTION NE 'I' THEN RETURN
    
    GOSUB OPEN.FILES
RETURN

*----------
OPEN.FILES:
*==========
    FN.ACCOUNT$NAU = 'F.ACCOUNT$NAU'
    F.ACCOUNT$NAU = ''
    EB.DataAccess.Opf(FN.ACCOUNT$NAU,F.ACCOUNT$NAU)

    FN.LOCKING = 'F.LOCKING'
    FP.LOCKING = ''
    EB.DataAccess.Opf(FN.LOCKING,FP.LOCKING)
    
    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    EB.DataAccess.Opf( FN.COMPANY, F.COMPANY)
    
    R.ACCOUNT$NAU = ''
    NAU.READ.ERR = ''
    ACCT.ID = EB.SystemTables.getComi()
    LEN.OF.ACCT.ID = 0
    LEN.OF.PROD.CODE = 2
    LEN.OF.BR.CODE = 4
    LEN.OF.CHK.DIG = 0
    TOT.VALUE = 0
    CHK.DIG.QUO = ''
    CHK.DIG.REM = ''

    CHK.DIG = ''
    Y.COMP.LIST = ''
    Y.COMP.POS = ''

  
    IF AA$ARR.PRODUCT.ID THEN   ;* from AA
        Y.AA.PRODUCT.CODE = AA$ARR.PRODUCT.ID
        Y.LT.PROD.PREFIX.POS = ''
        APPLICATION.NAME = 'AA.ARR.ACCOUNT'
        LOCAL.FIELD = 'LT.PROD.PREFIX'
        EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELD,Y.LT.PROD.PREFIX.POS)
        
        Y.PRODUCT.CODE = AA$PROD.PROP.RECORD<AA.AC.LOCAL.REF,Y.LT.PROD.PREFIX.POS>
        
        IF Y.PRODUCT.CODE NE '' THEN
            ACCT.ID = c_aalocLinkedAccount
            GOSUB PROCESS
        END ELSE
            TEXT = "Product Prefix NOT found."
            GOSUB PROGRAM.ERROR
            RETURN
        END
    END ELSE ;* from AC
        IF LEN(EB.SystemTables.getComi()) GE R.INTERCO.PARAMETER<ST.ICP.ACCOUNT.NO.LENGTH> THEN RETURN
        IF LEN(EB.SystemTables.getComi()) EQ LEN.OF.PROD.CODE THEN
            Y.PRODUCT.CODE = EB.SystemTables.getComi()
            GOSUB PROCESS
        END
    END
    
    SEQUENCE.NO = 0
    R.LOCKING = ''

RETURN

PROCESS:
*=======
    
    
    EB.DataAccess.FRead(FN.ACCOUNT$NAU,ACCT.ID,R.ACCOUNT$NAU,F.ACCOUNT$NAU,NAU.READ.ERR)
    IF NOT(NAU.READ.ERR) THEN RETURN
    Y.PRODUCT.CODE = Y.PRODUCT.CODE
    COMPANY.ID = EB.SystemTables.getIdCompany()
    EB.DataAccess.FRead(FN.COMPANY, COMPANY.ID, REC.COMPANY, F.COMPANY, COMPANY.ERR)
    FIN.COMPANY = REC.COMPANY<ST.CompanyCreation.Company.EbComFinancialCom>
*FIN.COMPANY = 'GB0010001'
    Y.COMP.LIST = R.INTERCO.PARAMETER<ST.CompanyCreation.IntercoParameter.IcpCompany>
    
    FIND FIN.COMPANY IN Y.COMP.LIST<1,1> SETTING FIN.COM.POS1,FIN.COM.POS2,FIN.COM.POS3 THEN
        LEAD.COMPANY = FIN.COMPANY[4,2] 'R%2'
    END ELSE
        Y.COMP.POS = ''
        EB.SystemTables.setText('Company record ':EB.SystemTables.getIdCompany():' missing in INTERCO.PARAMETER file')
        GOSUB PROGRAM.ERROR
        RETURN
    END
 
    LOCKING.ID = 'ACCOUNT.':Y.PRODUCT.CODE
    READU R.LOCKING FROM FP.LOCKING,LOCKING.ID LOCKED
        SLEEP 100
        RETURN
    END  ELSE
        R.LOCKING<EB.SystemTables.Locking.LokContent> = 0
    END
    
    ACCT.GAP = 1
    
    EB.SystemTables.LockingLock(LOCKING.ID,R.LOCKING, ERR.LOCKING, '', '')
    IF R.LOCKING THEN
        SEQUENCE.NO = R.LOCKING<EB.SystemTables.Locking.LokContent>
        SEQUENCE.NO = SEQUENCE.NO + ACCT.GAP
        R.LOCKING<EB.SystemTables.Locking.LokContent> = SEQUENCE.NO
    END ELSE
        EB.DataAccess.FRead(FN.LOCKING,LOCKING.ID,R.LOCKING,F.LOCK,Y.LOC.ERR)
        R.LOCKING<EB.SystemTables.Locking.LokContent> = R.LOCKING<EB.SystemTables.Locking.LokContent> + ACCT.GAP
        SEQUENCE.NO = R.LOCKING<EB.SystemTables.Locking.LokContent>
    END
    SEQUENCE.NO = SEQUENCE.NO  'R%8'
    R.LOCKING<EB.SystemTables.Locking.LokContent> = SEQUENCE.NO
    WRITE R.LOCKING ON FP.LOCKING,LOCKING.ID
    ACCT.ID = LEAD.COMPANY:Y.PRODUCT.CODE:SEQUENCE.NO
    LEN.OF.ACCT.ID = LEN(ACCT.ID)
    FOR I = 1 TO LEN.OF.ACCT.ID
        IF MOD(I,2) NE 0 THEN
            Y.CAL.DIG = 0
            Y.CAL.DIG = ACCT.ID[I,1] * 2
            IF LEN(Y.CAL.DIG) GT 1 THEN
                TOT.VALUE += Y.CAL.DIG[1,1] + Y.CAL.DIG[1]
            END ELSE
                TOT.VALUE += Y.CAL.DIG
            END
        END ELSE
            Y.CAL.DIG = 0
            Y.CAL.DIG = ACCT.ID[I,1]
            IF LEN(Y.CAL.DIG) GT 1 THEN
                TOT.VALUE += Y.CAL.DIG[1,1] + Y.CAL.DIG[1]
            END ELSE
                TOT.VALUE += Y.CAL.DIG
            END
        END
    NEXT I
    IF LEN(TOT.VALUE) GT 2 THEN
        IF TOT.VALUE[3,1] GE 5 THEN
            TOT.VALUE = TOT.VALUE[1,2] + TOT.VALUE[3,1]
        END ELSE
            TOT.VALUE = TOT.VALUE[1,2]
        END
    END
    CHK.DIG.R = MOD(TOT.VALUE,10)

    IF CHK.DIG.R = 0 THEN
        CHK.DIG = 1
    END ELSE
        CHK.DIG = 10 - CHK.DIG.R
    END
    Y.ID = LEAD.COMPANY:Y.PRODUCT.CODE:SEQUENCE.NO:CHK.DIG
    EB.SystemTables.setComi(LEAD.COMPANY:Y.PRODUCT.CODE:SEQUENCE.NO:CHK.DIG)
RETURN
PROGRAM.ERROR:
*=============
    CALL REM
    CALL RECORDID.INPUT
RETURN
END
