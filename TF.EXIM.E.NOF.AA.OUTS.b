* @ValidationCode : MjoxMTM3Nzk4NTY2OkNwMTI1MjoxNTgyNTMyODc5MDg2OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 24 Feb 2020 14:27:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.E.NOF.AA.OUTS(Y.RETURN.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.CUSTOMER
     
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----
INIT:
*----
    FN.AA='F.AA.ARRANGEMENT'
    F.AA=''
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    
    Y.TOTAL.AMT = 0
RETURN

*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
RETURN

*-------
PROCESS:
*-------
    SEL.CMD = 'SELECT ':FN.AA:" WITH ACTIVE.PRODUCT EQ EXIM.AS.SRF.FDBP.LN AND CO.CODE EQ ":EB.SystemTables.getIdCompany()
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',TOT.REC,RET.CODE)
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING Y.POS
    WHILE Y.AA.ID:Y.POS
    
        EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,E.AA)
        Y.CUS.ID = R.AA<AA.Framework.Arrangement.ArrCustomer>

        EB.DataAccess.FRead(FN.CUS,Y.CUS.ID,R.CUS,F.CUS,E.CUS)
        Y.CUS.NAME = R.CUS<ST.Customer.Customer.EbCusShortName>
    
        AA.Framework.GetArrangementAccountId(Y.AA.ID,accountId,Currency,ReturnError)
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.CURAC.BAL = BalDetails<4>
        Y.TOTAL.AMT = Y.TOTAL.AMT + Y.CURAC.BAL
        Y.RETURN.DATA<-1> = Y.CUS.NAME:'*':Y.CUS.ID:'*':Y.CURAC.BAL
*                                  1           2             3
    REPEAT
    Y.RETURN.DATA = Y.RETURN.DATA

RETURN

END
