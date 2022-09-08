* @ValidationCode : Mjo5MDQ4MzA2ODpDcDEyNTI6MTU4ODEzOTg2NjQ1ODpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 29 Apr 2020 11:57:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.E.NOF.GR.LIAB.SUM(Y.RETURN)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING AA.Framework
    $USING LI.Config
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING AA.TermAmount
*-----------------------------------------------------------------------------
 
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*****
INIT:
*****
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    FN.LI.REF = 'F.LIMIT.REFERENCE'
    F.LI.REF = ''
RETURN
*-----------------------------------------------------------------------------
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.LI.REF,F.LI.REF)
    
    Y.DISBURSEMENT = 0
    Y.PRIN.OUTSTAND = 0
    Y.PRFT.OUTSTAND = 0
    Y.TOT.OUTSTAND = 0
    Y.LIMIT.AMT = 0
    Y.LI.AVAILABLE.AMT = 0
    Y.PATDUE.AMT = 0
    
RETURN

*-----------------------------------------------------------------------------
********
PROCESS:
********
    
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING Y.CUST.NO.POS THEN
        Y.CUSTOMER.OPD = EB.Reports.getEnqSelection()<3,Y.CUST.NO.POS>
        Y.CUSTOMER = EB.Reports.getEnqSelection()<4,Y.CUST.NO.POS>
    END
    EB.DataAccess.FRead(FN.CUS,Y.CUSTOMER,R.CUS,F.CUS,E.CUS)
    Y.CUS.NAME = R.CUS<ST.Customer.Customer.EbCusShortName>
    Y.CUS.ADD = R.CUS<ST.Customer.Customer.EbCusAddress>
    
    SEL.CMD = 'SELECT ':FN.LI:' WITH @ID LIKE ':Y.CUSTOMER:'...'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, RET.CODE)
    LOOP
        REMOVE Y.LIMIT.ID FROM SEL.LIST SETTING Y.LI.ID.POS
    WHILE Y.LIMIT.ID : Y.LI.ID.POS
        EB.DataAccess.FRead(FN.LI, Y.LIMIT.ID, R.LI, F.LI, E.LI)

        Y.LI.REF.ID = R.LI<LI.Config.Limit.LimitProduct>
        EB.DataAccess.FRead(FN.LI.REF, Y.LI.REF.ID, R.LI.REF, F.LI.REF, E.LI.REF)
        Y.LI.PRO.DES = R.LI.REF<LI.Config.LimitReference.RefShortName>
            
        Y.LIMIT.AMT = R.LI<LI.Config.Limit.InternalAmount>
        Y.LI.AVAILABLE.AMT = R.LI<LI.Config.Limit.AvailAmt>
        Y.LI.ACCOUNT = R.LI<LI.Config.Limit.Account>
        Y.DCOUNT = DCOUNT(Y.LI.ACCOUNT,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.AC.ID = Y.LI.ACCOUNT<1,I>
            EB.DataAccess.FRead(FN.AC, Y.AC.ID, R.AC, F.AC, E.AC)
            Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
                
            PROP.CLASS = 'TERM.AMOUNT'
            AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
            R.REC = RAISE(RETURN.VALUES)
            Y.COMMIT.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
            Y.DISBURSEMENT = Y.DISBURSEMENT + Y.COMMIT.AMT
                
            BaseBalance = 'CURACCOUNT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(Y.AC.ID,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
            Y.CUR.AMT = BalDetails<4>
            Y.PRIN.OUTSTAND = ABS(Y.PRIN.OUTSTAND + Y.CUR.AMT)
                
            BaseBalance = 'DUEACCOUNT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(Y.AC.ID,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
            Y.DUE.AMT = BalDetails<4>
            Y.PATDUE.AMT = ABS(Y.PATDUE.AMT + Y.DUE.AMT)
            Y.TOT.OUTSTAND = ABS(Y.PRIN.OUTSTAND + Y.PRFT.OUTSTAND)
                
        NEXT I
        Y.RETURN<-1> = Y.CUSTOMER:'*':Y.CUS.NAME:'*':Y.CUS.ADD:'*':Y.LI.PRO.DES:'*':Y.LIMIT.ID:'*':Y.DISBURSEMENT:'*':Y.PRIN.OUTSTAND:'*':Y.PRFT.OUTSTAND:'*':Y.TOT.OUTSTAND:'*':Y.LIMIT.AMT:'*':Y.LI.AVAILABLE.AMT:'*':Y.PATDUE.AMT
*                             1             2               3                  4               5                  6                   7                  8                9                   10                   11           12
    REPEAT
    Y.RETURN = Y.RETURN
RETURN
END
