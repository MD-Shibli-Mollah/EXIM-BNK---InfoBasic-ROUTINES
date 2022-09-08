* @ValidationCode : MjotNDU0ODUwMjpDcDEyNTI6MTU3NTY5ODA2NjkwODpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Dec 2019 11:54:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.COMPANY.EDIT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.COM = 'F.COMPANY'
    F.COM = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

********
PROCESS:
********
    SEL.CMD = 'SELECT ':FN.COM
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.REC,SEL.ERR)
    LOOP
        REMOVE Y.COM.ID FROM SEL.LIST SETTING Y.COM.POS
    WHILE Y.COM.ID:Y.COM.POS
        EB.DataAccess.FRead(FN.COM,Y.COM.ID,R.COM,F.COM,COM.ERR)
        R.COM<ST.CompanyCreation.Company.EbComAcctCheckdigType> =  '@CM.EXIM.ID.AC.GENERATE'
        R.COM<ST.CompanyCreation.Company.EbComAccountMask> = '##-##-########-#'
        EB.DataAccess.FWrite(FN.COM,Y.COM.ID,R.COM)
        EB.TransactionControl.JournalUpdate(Y.COM.ID)
    REPEAT
RETURN

END
