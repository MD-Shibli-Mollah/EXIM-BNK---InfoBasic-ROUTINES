* @ValidationCode : MjotMTQzMDAyMTMzOkNwMTI1MjoxNTc5MDc2Mjg0ODY3OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 15 Jan 2020 14:18:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
*PROGRAM GB.EXIM.B.REV.TRAN.BR.TO.HO
SUBROUTINE GB.EXIM.B.REV.TRAN.BR.TO.HO
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EXIM.REVA.COMPEN.CALC
    
    $USING EB.DataAccess
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.CAT.L.DAY='F.CATEG.ENT.LWORK.DAY'
    F.CAT.L.DAY=''
    FN.CAT.TODAY='F.CATEG.ENT.TODAY'
    F.CAT.TODAY=''
    FN.CAT='F.CATEG.ENTRY'
    F.CAT=''
    FN.COM='F.COMPANY'
    F.COM=''
    
    Y.AMT = 0
    
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.CAT.L.DAY,F.CAT.L.DAY)
    EB.DataAccess.Opf(FN.CAT.TODAY,F.CAT.TODAY)
    EB.DataAccess.Opf(FN.CAT,F.CAT)
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

********
PROCESS:
********
    Y.DIR = 'EXIM.DATA'
    Y.FILE.NAME = 'Y.CAT.TODAY.ID'
    Y.FILE.NAME.L = 'Y.CAT.TODAY.ID.L'

    SEL.CMD.CE = 'SELECT ':FN.CAT.TODAY:' WITH @ID LIKE 53000...'
    EB.DataAccess.Readlist(SEL.CMD.CE,SEL.LIST.CE,'',NO.OF.REC.CE,RET.CE)
    LOOP
        REMOVE Y.CAT.TODAY.ID FROM SEL.LIST.CE SETTING POS
    WHILE Y.CAT.TODAY.ID:POS
        Y.DATA = Y.CAT.TODAY.ID
        OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
        WRITESEQ Y.DATA APPEND TO F.DIR ELSE
            CRT "Unable to write"
            CLOSESEQ F.DIR
        END
    REPEAT

    SEL.CMD.CEL = 'SELECT ':FN.CAT.L.DAY:' WITH @ID LIKE 53000...'
    EB.DataAccess.Readlist(SEL.CMD.CEL,SEL.LIST.CEL,'',NO.OF.REC.CEL,RET.CEL)
    LOOP
        REMOVE Y.CAT.TODAY.ID.L FROM SEL.LIST.CEL SETTING POS
    WHILE Y.CAT.TODAY.ID.L:POS
        Y.DATA = Y.CAT.TODAY.ID.L
        OPENSEQ Y.DIR,Y.FILE.NAME.L TO F.DIR THEN NULL
        WRITESEQ Y.DATA APPEND TO F.DIR ELSE
            CRT "Unable to write"
            CLOSESEQ F.DIR
        END
    REPEAT

    SEL.COM = "SELECT ":FN.COM:" WITH LT.AD.BR.CODE NE ''"
    EB.DataAccess.Readlist(SEL.COM,SEL.LIST.COM,'',NO.OF.REC.COM,RET.AC.CODE)
    
    FOR J = 1 TO NO.OF.REC.COM
    
        SEL.CMD = 'SELECT ':FN.CAT.L.DAY:' WITH @ID LIKE 53000...'
        EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.REC,RET.AC.CODE)
        LOOP
            REMOVE Y.CAT.TODAY.ID FROM SEL.LIST SETTING POS
        WHILE Y.CAT.TODAY.ID:POS
            EB.DataAccess.FRead(FN.CAT.L.DAY,Y.CAT.TODAY.ID,R.CAT.TODAY.REC,F.CAT.L.DAY,Y.ERR)
            Y.CURRENCY = FIELD(Y.CAT.TODAY.ID,'-',3)
            Y.REC.COUNT = DCOUNT(R.CAT.TODAY.REC,@FM)
            FOR I = 1 TO Y.REC.COUNT
                Y.CATEG.ID = R.CAT.TODAY.REC<I>
                EB.DataAccess.FRead(FN.CAT,Y.CATEG.ID,R.CAT,F.CAT,CAT.ERR)
                Y.CO.CODE = R.CAT<AC.EntryCreation.CategEntry.CatCompanyCode>
                Y.J.COM = SEL.LIST.COM<J>
                IF Y.CO.CODE EQ Y.J.COM THEN
                    Y.AMT = Y.AMT + R.CAT<AC.EntryCreation.CategEntry.CatAmountLcy>
                END
            NEXT I
        REPEAT
        GOSUB OFS.PROCESS
        Y.AMT = 0
    NEXT J
     
RETURN

************
OFS.PROCESS:
************
    Y.TXN.CURRENCY = 'BDT'
    OFS.SOURCE = 'EXIM.OFS.ENT'
    Y.OFS.MSG.ID = ''
    Y.VERSION = 'FUNDS.TRANSFER,FCY.PL.TO.H.O.GL'
    Y.FT.ID = ''
    IF Y.AMT GT 0 THEN
        Y.DEBIT.ACCT.NO = 'PL53000'
        Y.DEBIT.AMOUNT = Y.AMT
        Y.CREDIT.ACCT.NO = 'BDT1628100010999'

        Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
        Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
        Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.TXN.CURRENCY
        Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
        Y.OFS.STR :=',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
        Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.TXN.CURRENCY
        Y.OFS.STR := ',CREDIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',PROFIT.CENTRE.DEPT::=':'1'
        Y.OFS.STR :=",IN.SWIFT.MSG::=":Y.J.COM
        Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
        Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.J.COM:',':Y.FT.ID:',':Y.OFS.STR
                
        EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
        EB.TransactionControl.JournalUpdate(Y.FT.ID)
    END
  
    IF Y.AMT LT 0 THEN
        IF Y.AMT EQ '' THEN RETURN
        Y.DEBIT.ACCT.NO = 'BDT1628100010999'
        Y.DEBIT.AMOUNT = ABS(Y.AMT)
        Y.CREDIT.ACCT.NO = 'PL53000'

        Y.OFS.STR = 'TRANSACTION.TYPE::=':'AC'
        Y.OFS.STR := ',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO
        Y.OFS.STR := ',DEBIT.CURRENCY::=':Y.TXN.CURRENCY
        Y.OFS.STR := ',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT
        Y.OFS.STR :=',DEBIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO
        Y.OFS.STR :=',CREDIT.CURRENCY::=':Y.TXN.CURRENCY
        Y.OFS.STR := ',CREDIT.VALUE.DATE::=':EB.SystemTables.getToday()
        Y.OFS.STR := ',PROFIT.CENTRE.DEPT::=':'1'
        Y.OFS.STR :=",IN.SWIFT.MSG::=":Y.J.COM
        Y.OFS.STR := ',ORDERING.CUST::=':'EXIM'
        Y.MESSAGE = Y.VERSION :'/I/PROCESS,//':Y.J.COM:',':Y.FT.ID:',':Y.OFS.STR
                
        EB.Interface.OfsPostMessage(Y.MESSAGE,Y.OFS.MSG.ID,OFS.SOURCE,OPTIONS)
        EB.TransactionControl.JournalUpdate(Y.FT.ID)
    END
RETURN
END
