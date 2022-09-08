* @ValidationCode : MjoxNTI1NzMxMTU5OkNwMTI1MjoxNTg5Nzc5NTU3NzI1Om5hZGlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 May 2020 11:25:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nadia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.E.NOF.STD.STMT.DETAILS(Y.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
   
   
   
    $USING EB.DataAccess
    $USING AA.Account
    $USING AC.AccountOpening
    $USING AA.Customer
    $USING ST.Customer
    $USING ST.Config
    $USING EB.Reports
    $USING RE.ConBalanceUpdates
    $USING ST.CompanyCreation

    ST.CompanyCreation.LoadCompany("BNK")
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
    FN.CUS.AC = "F.CUSTOMER.ACCOUNT"
    F.CUS.AC =""
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.ECB, F.ECB)
    EB.DataAccess.Opf(FN.CUS.AC, F.CUS.AC)
RETURN
********
PROCESS:
********
    LOCATE 'AC.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING Y.AC.NO.POS THEN
        Y.AC.OPD = EB.Reports.getEnqSelection()<3,Y.AC.NO.POS>
        Y.AC.ID = EB.Reports.getEnqSelection()<4,Y.AC.NO.POS>
    END
   
    LOCATE 'CUS.NO' IN EB.Reports.getEnqSelection()<2,1>SETTING Y.CUS.NO.POS THEN
        Y.CUS.OPD = EB.Reports.getEnqSelection()<3,Y.CUS.NO.POS>
        Y.CUS.ID = EB.Reports.getEnqSelection()<4,Y.CUS.NO.POS>
    END
    IF Y.CUS.ID NE '' THEN
        Y.TOT.AC = AC.AccountOpening.CustomerAccount.Read(Y.CUS.ID, Error)
        Y.DCOUNT = DCOUNT(Y.TOT.AC,FM)
        FOR I = 1 TO Y.DCOUNT
            Y.AC.NO = Y.TOT.AC<I>
            GOSUB PROCESS.REPORT
        NEXT I
    END ELSE
        GOSUB PROCESS.REPORT
    END
    
RETURN
    
**************
PROCESS.REPORT:
**************
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
            Y.DATE =  FIELD(Y.TYPE, '-', 2)
            Y.TY = FIELD(Y.TYPE,FM,Y.POS.2)
            Y.OP.BALANCE = FIELD(Y.OP.BL,FM,Y.POS.2)
            Y.CR.MOVE = FIELD(Y.CREDIT,FM,Y.POS.2)
            Y.DR.MOVE = FIELD(Y.DEBIT,FM,Y.POS.2)
            Y.CLOSE.BAL1 = Y.OP.BALANCE + Y.CR.MOVE
            Y.CLOSE.BALANCE = Y.CLOSE.BAL1 + Y.DR.MOVE
            Y.CLOSE.BALANCE1 = 0
            Y.DATA.FINAL<-1> = Y.DATE:"*":Y.OP.BALANCE:"*":Y.CR.MOVE:"*":Y.DR.MOVE:"*":Y.CLOSE.BALANCE
        END
    NEXT I
    Y.DATA = Y.DATA.FINAL
RETURN
END