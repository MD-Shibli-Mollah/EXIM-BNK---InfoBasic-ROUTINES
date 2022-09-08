* @ValidationCode : MjotMTI0Nzc4NTk4ODpDcDEyNTI6MTU3NDE1NjUyMDU2MDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Nov 2019 15:42:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.V.GET.CUS.TITLE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.Customer
    $USING AA.Officers
    $USING ST.Customer
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Account
*-----------------------------------------------------------------------------

    FN.CUS = 'FBNK.CUSTOMER'
    F.CUS = ''
    Y.AA.ID = c_aalocArrId
*PROP.CLASS = 'CUSTOMER'
*CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
*R.REC.CUS = RAISE(RETURN.VALUES)
*Y.CUS.ID = R.REC.CUS<AA.Customer.Customer.CusCustomer>
    Y.CUS.ID = EB.SystemTables.getComi()

    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS, F.CUS, Y.CUS.ERR)
    
    Y.CUS.NAME = R.CUS<ST.Customer.Customer.EbCusShortName>

    EB.SystemTables.setRNew(AA.Account.Account.AcAccountTitleOne, Y.CUS.NAME)

END