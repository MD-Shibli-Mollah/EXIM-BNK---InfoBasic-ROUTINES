* @ValidationCode : Mjo2NTE2MjgwNjU6Q3AxMjUyOjE1Nzg4OTU5MDQ4NDc6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Jan 2020 12:11:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.B.COMPEN.TRAN.BR.TO.HO
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    $INSERT I_F.ACCOUNT.CLASS
    
    $USING EB.DataAccess
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING EB.Interface
    $USING AC.Config
    $USING AC.AccountOpening
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.AC='F.ACCOUNT'
    F.AC=''
    FN.RCC = 'F.EXIM.REVA.COMPEN.CALC'
    F.RCC = ''
    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.RCC,F.RCC)
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
RETURN

********
PROCESS:
********
    SEL.AC.ID = "SELECT ":FN.AC:" WITH ":" @ID LIKE BDT...":" AND WORKING.BALANCE GT 0"
    EB.DataAccess.Readlist(SEL.AC.ID,SEL.AC.LIST,'',NO.OF.AC.REC,RET.AC.CODE)
    LOOP
       
        REMOVE Y.AC.ID FROM SEL.AC.LIST SETTING POS
    WHILE Y.AC.ID:POS
        EB.DataAccess.FRead(FN.AC,Y.AC.ID,R.AC,F.AC,AC.ER)
        Y.AMT = R.AC<AC.AccountOpening.Account.WorkingBalance>
        Y.TXN.CURRENCY = R.AC<AC.AccountOpening.Account.Currency>
        Y.COMPANY = R.AC<AC.AccountOpening.Account.CoCode>
        Y.CATEGORY = R.AC<AC.AccountOpening.Account.Category>
        Y.AC.CLASS.ID = 'U-COMPEN.CATEG'
        EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS,F.AC.CLASS,AC.CLASS.ER)
        Y.CATEG.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>
        LOCATE Y.CATEGORY IN Y.CATEG.LIST<1,1> SETTING Y.CATEG.POS THEN
            IF Y.COMPANY NE 'BD0010999' THEN
                GOSUB OFS.PROCESS
            END
        END
    REPEAT
RETURN


************
OFS.PROCESS:
************
    OFS.SOURCE = 'EXIM.OFS.ENT'
    Y.OFS.MSG.ID = ''
    Y.VERSION = 'FUNDS.TRANSFER,EXIM.COMPEN.TO.H.O.GL'
    Y.FT.ID = ''
        
    Y.DEBIT.ACCT.NO = Y.AC.ID
    Y.DEBIT.AMOUNT = Y.AMT
    Y.CREDIT.ACCT.NO = Y.TXN.CURRENCY:Y.AC.ID[4,9]:'0999'

    Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
    Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
    Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.TXN.CURRENCY
    Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
    Y.OFS.STR :=',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
    Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
    Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.TXN.CURRENCY
    Y.OFS.STR := ',CREDIT.VALUE.DATE::=':EB.SystemTables.getToday()
    Y.OFS.STR := ',PROFIT.CENTRE.DEPT::=':'1'
    Y.OFS.STR :=",IN.SWIFT.MSG::=":Y.COMPANY
    Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
    Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.COMPANY:',':Y.FT.ID:',':Y.OFS.STR
                
    EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
    EB.TransactionControl.JournalUpdate(Y.FT.ID)
RETURN

END
