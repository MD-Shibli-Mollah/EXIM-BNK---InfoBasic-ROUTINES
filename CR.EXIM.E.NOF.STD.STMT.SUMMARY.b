* @ValidationCode : MjoyMTk5OTU1ODI6Q3AxMjUyOjE1ODk3OTY4Nzg0NTk6bmFkaWE6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 May 2020 16:14:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nadia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.E.NOF.STD.STMT.SUMMARY(Y.DATA)
    
    
    
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.Account
    $USING AC.AccountOpening
    $USING AA.Customer
    $USING ST.Customer
    $USING ST.Config
    $USING EB.Reports
    $USING RE.ConBalanceUpdates
    $USING ST.CompanyCreation

*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.ECB = "F.EB.CONTRACT.BALANCES"
    F.ECB = ""
    FN.ACC = "F.ACCOUNT"
    F.ACC = ""
    FN.AA = "F.AA.ARRANGEMENT"
    F.AA = ""
RETURN
**********
OPENFILES:
**********

    EB.DataAccess.Opf(FN.ECB, F.ECB)
    EB.DataAccess.Opf(FN.ACC,F.ACC)
    EB.DataAccess.Opf(FN.AA,F.AA)
RETURN
********
PROCESS:
********
    SEL.CMD = "SELECT ":FN.ECB
    EB.DataAccess.Readlist(SEL.CMD, THE.LIST, '', NO.OF.REC, RET.CODE)
    LOOP
        REMOVE Y.AC.ID FROM THE.LIST SETTING GROUP.POS
    WHILE Y.AC.ID:GROUP.POS
        EB.DataAccess.FRead(FN.ACC,Y.AC.ID,R.ACC,F.ACC,ACC.ERR)
        Y.ARRANGEMENT.ID = R.ACC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA,Y.ARRANGEMENT.ID,R.AA,F.AA,AA.ERR)
        Y.PRODUCT.NAME = R.AA<AA.Framework.Arrangement.ArrProduct>
        EB.DataAccess.FRead(FN.ECB,Y.AC.ID,R.ECB,F.ECB,ECB.ERR)
        Y.TYPE.SYSDATE = R.ECB<RE.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate>
        Y.OPEN.BALANCE = R.ECB<RE.ConBalanceUpdates.EbContractBalances.EcbOpenBalance>
        Y.CREDIT.MVT = R.ECB<RE.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt>
        Y.DEBIT.MVT = R.ECB<RE.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt>
        Y.DCOUNT = DCOUNT(Y.TYPE.SYSDATE,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.TYPE = Y.TYPE.SYSDATE<1,I>
            Y.OP.BL = Y.OPEN.BALANCE<1,I>
            Y.CREDIT = Y.CREDIT.MVT<1,I>
            Y.DEBIT = Y.DEBIT.MVT<1,I>
            FINDSTR 'STDACCOUNT' IN Y.TYPE SETTING Y.POS.1,Y.POS.2,Y.POS.3 THEN
                Y.OP.BALANCE = FIELD(Y.OP.BL,FM,Y.POS.2)
                Y.CR.MOVE = FIELD(Y.CREDIT,FM,Y.POS.2)
                Y.DR.MOVE = FIELD(Y.DEBIT,FM,Y.POS.2)
                Y.CLOSE.BAL1 = Y.OP.BALANCE + Y.CR.MOVE
                Y.CLOSE.BALANCE = Y.CLOSE.BAL1 + Y.DR.MOVE
                Y.CLOSE.BALANCE1 = 0
                Y.DATA.FINAL<-1> =Y.PRODUCT.NAME:"*":Y.ARRANGEMENT.ID:"*":Y.CR.MOVE:"*":Y.DR.MOVE:"*":Y.CLOSE.BALANCE
            END
            
        NEXT I
    REPEAT
    Y.DATA = Y.DATA.FINAL
RETURN

END