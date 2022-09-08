* @ValidationCode : MjoxMTkwMjI3NjkzOkNwMTI1MjoxNTkxMDg4NTc1NjIxOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 02 Jun 2020 15:02:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.MBL.ACCT.TITLE.UPDATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
*
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.Customer
    $USING EB.Updates
    $USING AA.Account
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*----
INIT:
*----
    FN.CUSTOMER = 'FBNK.CUSTOMER'
    F.CUSTOMER = ''
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.CUSTOMER,F.CUSTOMER)
RETURN
*-------
PROCESS:
*-------
    Y.CUS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActCustomer>
    EB.DataAccess.FRead(FN.CUSTOMER, Y.CUS.ID, R.CUS, F.CUSTOMER, ERR.CUS)
    Y.CUS.NM.1=R.CUS<ST.Customer.Customer.EbCusNameOne>
    Y.CUS.NM.2=R.CUS<ST.Customer.Customer.EbCusNameTwo>
    Y.CUS.SHT.NM=R.CUS<ST.Customer.Customer.EbCusShortName>
    
    EB.SystemTables.setRNew(AA.Account.Account.AcAccountTitleOne,Y.CUS.NM.1)
    EB.SystemTables.setRNew(AA.Account.Account.AcAccountTitleTwo,Y.CUS.NM.2)
    EB.SystemTables.setRNew(AA.Account.Account.AcShortTitle,Y.CUS.SHT.NM)
    
RETURN
END
