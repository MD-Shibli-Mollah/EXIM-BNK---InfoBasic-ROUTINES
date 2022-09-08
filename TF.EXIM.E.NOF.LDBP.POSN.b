* @ValidationCode : MjotNjEyNTMyMzY0OkNwMTI1MjoxNTgzNDA3MjkxNTE0OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 05 Mar 2020 17:21:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
* @AUTHOR         : MD SHIBLI MOLLAH

SUBROUTINE TF.EXIM.E.NOF.LDBP.POSN(Y.RET.DATA)
*-----------------------------------------------------------------------------
* <Rating>1459</Rating>
*-----------------------------------------------------------------------------

* This routine is used to make nofile enquiry FOR ALL BRANCH OUTS.LDBP.POSITION

    $INSERT I_COMMON
    $INSERT I_EQUATE
*  $INSERT I_F.LD.LOANS.AND.DEPOSITS
*   $INSERT I_F.DRAWINGS
*$INSERT I_F.COMPANY
*$INSERT I_F.CUSTOMER
    $INSERT I_ENQUIRY.COMMON
* $INSERT I_F.EB.CONTRACT.BALANCES

***FURTHER DISCUSS WITH EXIM TF TEAM***********
*  $INSERT ISB.BP I_F.IS.H.CONTRACTS
  
* $INSERT I_F.PD.PAYMENT.DUE
    $USING IS.Purchase
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING LD.Contract
    $USING ST.Customer
    $USING RE.ConBalanceUpdates
    $USING PD.Contract
    $USING LC.Contract
* $USING IS.Purchase
    
    GOSUB INIT
    GOSUB PROCESS
    
RETURN

INIT:
*====
*DEBUG
*  ST.CompanyCreation.LoadCompany("BNK")
    Y.CUST.NO.POS=''
    Y.CUST.OPD=''
    Y.CUST=''
    Y.VAL.DT.POS=''
    Y.VAL.OPD=''
    Y.VAL.DT=''
    Y.START.DATE=''
    Y.END.DATE=''
    SEL.COMPANY=''
    NO.OF.COMP=''
    Y.COMP=''
    R.COMP=''

*    FN.COMPANY = 'F.COMPANY'
*    F.COMPANY = ''
    
*EB.DataAccess.Opf(FN.COMPANY,F.COMPANY)
*NEW 20121008

    FN.CUST="F.CUSTOMER"
    F.CUST=''
    EB.DataAccess.Opf(FN.CUST,F.CUST)
*/NEW 20121008

    Y.RECORD = ''
    Y.LINE = ''
    I = 0
RETURN

PROCESS:
*=======
*DEBUG
    LOCATE "CUSTOMER.NO" IN ENQ.SELECTION<2,1> SETTING Y.CUST.NO.POS THEN
        Y.CUST.OPD = ENQ.SELECTION< 3,Y.CUST.NO.POS>
        Y.CUST = ENQ.SELECTION<4, Y.CUST.NO.POS>
    END
    LOCATE "VALUE.DATE" IN ENQ.SELECTION<2,1> SETTING Y.VAL.DT.POS THEN
        Y.VAL.OPD = ENQ.SELECTION<3,Y.VAL.DT.POS>
        Y.VAL.DT = ENQ.SELECTION<4,Y.VAL.DT.POS>
    END
    IF Y.VAL.OPD EQ 'RG' THEN
        Y.START.DATE = Y.VAL.DT[1,8]
        Y.END.DATE = Y.VAL.DT[10,8]
    END

*  SEL.COMPANY="SELECT F.COMPANY WITH @ID NE BD0010999"

* EB.DataAccess.Readlist(SEL.COMPANY,SEL.LIST.COMP,'',NO.OF.COMP,ERR)

*    FOR C=1 TO NO.OF.COMP
*        REMOVE Y.COMP FROM SEL.LIST.COMP SETTING POS
*        !WHILE Y.COMP:POS
*        EB.DataAccess.FRead(FN.COMPANY,Y.COMP,R.COMP,F.COMPANY,Y.ERR.COMP)
*        Y.MNE.COMP = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>
*
    FN.DRAWINGS = "F.DRAWINGS"
    F1.DRAWINGS = ''
    EB.DataAccess.Opf(FN.DRAWINGS, F1.DRAWINGS)

    FN.LD="F.LD.LOANS.AND.DEPOSITS"
    F.LD=''
    EB.DataAccess.Opf(FN.LD,F.LD)

    FN.CONTRACT="F.IS.CONTRACT"
    F.CONTRACT=''
    EB.DataAccess.Opf(FN.CONTRACT, F.CONTRACT)

    FN.CON.BAL="F.EB.CONTRACT.BALANCES"
    F.CON.BAL=''
    EB.DataAccess.Opf(FN.CON.BAL,F.CON.BAL)

    FN.PD.PAY="F.PD.PAYMENT.DUE"
    F.PD.PAY=''
    EB.DataAccess.Opf(FN.PD.PAY,F.PD.PAY)

    COMPANY = ''

*****FOR LD*************************************
    SEL.CMD=''
    Y.LIST.HIS=''
    Y.LD.ID=''
    R.LD.REC=''
    LD.CUST.ID=''
    LD.VAL.DATE=''
    LD.FIN.MAT.DT=''
    LD.DRAW.NO=''
    LD.PUR.FC.AMT=''
    LD.DOC.VAL=''
    LD.NO=''
    LD.PROFIT.RATE=''
    LD.AMT=''
*NEW 20121008

    CUST.ID=''
    R.CUST.REC=''
    Y.ERR.CUST=''
    CUST.NAME=''
*/NEW 20121008

*****FOR IS.H.CONTRACTS**************************
    LD.LINK.REF=''
    Y.IS.NO=''
    DISB.AMT=''
    R.IS.REC=''

*****/FOR LD*************************************
    SEL.CMD1=''
    Y.AZ.ID=''
    BILL.DATE=''
    BILL.NO=''
    EXPORTER=''
    IMPORTER=''
    TF.DRAW.NO=''
    DRAW.TYPE=''
    EXP.LC.NO=''
    LC.ISS.BANK=''
    CURR=''
    DOC.VAL.FC=''
    BILL.AMT.BDT=''
    LC.TENOR=''
    MAT.DATE=''
    PART.REBATE=0
    PRIN.AMT=0
    NET.OUTS=0

*****/FOR EB.CONTRACT.BALANCE*************************************
    Y.LD.CONTRACT.ID= ''
    R.EB.CONTRACT.BALANCES=''
    Y.ERR.EB.CONTRACT.BALANCES=''
    Y.LD.OPEN.CNT=''
    Y.LD.OPEN.BAL=0
    Y.LD.DEBIT.MVMNT=0
    Y.LD.CREDIT.MVMNT=0
    Y.LD.SUSPENSE.AMT=0
    P.DATA=0
    OS.PROFIT=0

*****/FOR PD.PAYMENT.DUE*************************************
    PD.AMT=0
    Y.PD.PAY.ID=''
    R.PD.PAY=''
    Y.ERR.PD.PAY=''


*DEBUG
    IF Y.VAL.DT NE '' AND Y.CUST EQ '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
            SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') AND VALUE.DATE GE ":Y.START.DATE:" AND VALUE.DATE LE ":Y.END.DATE:"  BY @ID"
        END ELSE
            SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') AND VALUE.DATE ":Y.VAL.OPD:" ":Y.VAL.DT:" BY @ID"
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST NE '' THEN
        SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') AND CUSTOMER.ID ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
    END
    ELSE IF Y.VAL.DT NE '' AND Y.CUST NE '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
            SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') AND VALUE.DATE GE ":Y.START.DATE:" AND VALUE.DATE LE ":Y.END.DATE:" AND CUSTOMER.ID ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
        END ELSE
            SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') AND VALUE.DATE ":Y.VAL.OPD:" ":Y.VAL.DT:" AND CUSTOMER.ID ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST EQ '' THEN
        SEL.CMD = "SELECT ":FN.LD:" WITH  AMOUNT NE '0.00' AND (CATEGORY EQ '21071' OR CATEGORY EQ '21074') AND (LIMIT.REFERENCE LIKE '6627...' OR LIMIT.REFERENCE LIKE '6637...' OR LIMIT.REFERENCE LIKE '6651...') BY @ID"
    END
    EB.DataAccess.Readlist(SEL.CMD,Y.LIST.HIS,'',NO.OF.REC,ERR.CODE)
    I=0
    LOOP
    WHILE Y.LIST.HIS DO
        Y.LD.ID = Y.LIST.HIS<1> ; DEL Y.LIST.HIS<1>
        I =I + 1
        EB.DataAccess.FRead(FN.LD,Y.LD.ID,R.LD.REC,F.LD,Y.LD.ERR)
        LD.CUST.ID=R.LD.REC<LD.Contract.LoansAndDeposits.CustomerId>

*NEW 20121008
        IF LD.CUST.ID NE '' THEN
            CUST.ID = LD.CUST.ID
            EB.DataAccess.FRead(FN.CUST,CUST.ID,R.CUST.REC,F.CUST,Y.ERR.CUST)
*CUST.NAME=R.CUST.REC<EB.CUS.SHORT.NAME>:',':R.CUST.REC<EB.CUS.NAME.2>:',':R.CUST.REC<EB.CUS.STREET>:',':R.CUST.REC<EB.CUS.ADDRESS>:',':R.CUST.REC<EB.CUS.TOWN.COUNTRY>
            CUST.NAME = R.CUST.REC<ST.Customer.Customer.EbCusShortName>
        END
*/NEW 20121008


        LD.VAL.DATE=R.LD.REC<LD.Contract.LoansAndDeposits.ValueDate>
*LD.FIN.MAT.DT=R.LD.REC<LD.FIN.MAT.DATE>
        LD.FIN.MAT.DT=R.LD.REC<LD.Contract.LoansAndDeposits.FinMatDate>
            
        LD.PROFIT.RATE=R.LD.REC<LD.Contract.LoansAndDeposits.LocalRef,16,1>
        IF R.LD.REC<LD.Contract.LoansAndDeposits.CustomerRef> NE '' THEN
            LD.DRAW.NO=R.LD.REC<LD.Contract.LoansAndDeposits.CustomerRef>
        END
        ELSE
            LD.DRAW.NO=R.LD.REC<LD.Contract.LoansAndDeposits.LocalRef,112,1>
        END
        LD.PUR.FC.AMT=R.LD.REC<LD.Contract.LoansAndDeposits.LocalRef,89,1>
        LD.DOC.VAL=R.LD.REC<LD.Contract.LoansAndDeposits.LocalRef,93,1>
        LD.NO=Y.LD.ID
        LD.LINK.REF=R.LD.REC<LD.Contract.LoansAndDeposits.LinkReference>
        LD.AMT=R.LD.REC<LD.Contract.LoansAndDeposits.Amount>
        PART.REBATE=R.LD.REC<LD.Contract.LoansAndDeposits.LocalRef,111,1>

        IF R.LD.REC<LD.Contract.LoansAndDeposits.Category> EQ '21071' THEN
            Y.IS.NO = LD.LINK.REF
            EB.DataAccess.FRead(FN.CONTRACT,Y.IS.NO,R.IS.REC,F.CONTRACT,Y.ERR.CON)
*      DISB.AMT=R.IS.REC<IS.CON.NET.COST>
***************EXIM_TEAM**********CONFIRMATION NEEDED************************

            DISB.AMT = R.IS.REC<IS.Purchase.Contract.IcTotPurchasePrice>
*DISB.AMT=R.IS.REC<IS.Purchase>
********EB.CONTRACT.BAL***************************************
            Y.LD.CONTRACT.ID=LD.NO
            EB.DataAccess.FRead(FN.CON.BAL,Y.LD.CONTRACT.ID,R.EB.CONTRACT.BALANCES,F.CON.BAL,Y.ERR.EB.CONTRACT)
            IF R.EB.CONTRACT.BALANCES THEN
                Y.SP.CNT=DCOUNT(R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate>,VM)
                Y.SP.CTR=1
                LOOP
                WHILE (Y.SP.CTR LE Y.SP.CNT)
                    IF R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate,Y.SP.CTR>[1,5] EQ '51500' AND R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate,Y.SP.CTR>[6,2] NE 'SP' THEN
                        Y.LD.OPEN.CNT = DCOUNT(R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbOpenBalance,Y.SP.CTR>,@SM)
                        Y.LD.OPEN.CTR = 1
                        LOOP
                            WHILE(Y.LD.OPEN.CTR LE Y.LD.OPEN.CNT)
                            Y.LD.OPEN.BAL+=R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbOpenBalance,Y.SP.CTR,Y.LD.OPEN.CTR>
                            Y.LD.OPEN.CTR += 1
                        REPEAT
                        Y.LD.DBT.CNT = DCOUNT(R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt,Y.SP.CTR>,@SM)
                        Y.LD.DBT.CTR = 1
                        LOOP
                            WHILE(Y.LD.DBT.CTR LE Y.LD.DBT.CNT)
                            Y.LD.DEBIT.MVMNT+=R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt,Y.SP.CTR,Y.LD.DBT.CTR>
                            Y.LD.DBT.CTR +=1
                        REPEAT
                        Y.LD.CRT.CNT = DCOUNT(R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt,Y.SP.CTR>,@SM)
                        Y.LD.CRT.CTR = 1
                        LOOP
                            WHILE(Y.LD.CRT.CTR LE Y.LD.CRT.CNT)
                            Y.LD.CREDIT.MVMNT+=R.EB.CONTRACT.BALANCES<RE.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt,Y.SP.CTR,Y.LD.CRT.CTR>
                            Y.LD.CRT.CTR += 1
                        REPEAT
                    END
                    Y.SP.CTR+=1
                REPEAT
                P.DATA = Y.LD.OPEN.BAL+Y.LD.DEBIT.MVMNT+Y.LD.CREDIT.MVMNT
                R.EB.CONTRACT.BALANCES=''
                Y.ERR.EB.CONTRACT.BALANCES=''
                Y.LD.OPEN.BAL=''
                Y.LD.DEBIT.MVMNT=''
                Y.LD.CREDIT.MVMNT=''
            END
********EB.CONTRACT.BAL***************************************
            OS.PROFIT=P.DATA
********PD.PAYMENT.DUE****************************************
*DEBUG
            Y.PD.PAY.ID="PD":LD.NO
            EB.DataAccess.FRead(FN.PD.PAY,Y.PD.PAY.ID,R.PD.PAY,F.PD.PAY,Y.ERR.PD.PAY)
            IF R.PD.PAY THEN
*PD.AMT=R.PD.PAY<PD.TOTAL.AMT.TO.REPAY>
                PD.AMT = R.PD.PAY<PD.Contract.PaymentDue.TotalAmtToRepay>
            END
********PD.PAYMENT.DUE****************************************

            PRIN.AMT = DISB.AMT
            NET.OUTS = LD.AMT-OS.PROFIT + PD.AMT-PART.REBATE

        END
        ELSE
            PRIN.AMT = LD.AMT
            NET.OUTS = LD.AMT
        END

        Y.AZ.ID=LD.DRAW.NO
        EB.DataAccess.FRead(FN.DRAWINGS,Y.AZ.ID,R.AZ.REC.HIS,F1.DRAWINGS,Y.ERR.HIS)

*BILL.DATE=R.AZ.REC.HIS<TF.DR.VALUE.DATE>
        BILL.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrValueDate>
        BILL.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,3,1>
        EXPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,7,1>
        IMPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,8,1>
        TF.DRAW.NO=Y.AZ.ID
*DRAW.TYPE=R.AZ.REC.HIS<TF.DR.DRAWING.TYPE>
        DRAW.TYPE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawingType>
        EXP.LC.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,5,1>
        LC.ISS.BANK=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,12>
        IF LC.ISS.BANK[1,1] EQ "*" THEN
            LC.ISS.BANK=LC.ISS.BANK[2,LEN(LC.ISS.BANK)]
        END
*CURR=R.AZ.REC.HIS<TF.DR.DRAW.CURRENCY>
        CURR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawCurrency>
*DOC.VAL.FC=R.AZ.REC.HIS<TF.DR.DOCUMENT.AMOUNT>
        DOC.VAL.FC=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocumentAmount>
        IF R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawCurrency> NE 'BDT' THEN
*BILL.AMT.BDT=R.AZ.REC.HIS<TF.DR.DOC.AMT.LOCAL>
            BILL.AMT.BDT=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocAmtLocal>
        END
        ELSE
*BILL.AMT.BDT=R.AZ.REC.HIS<TF.DR.DOCUMENT.AMOUNT>
            BILL.AMT.BDT=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocumentAmount>
        END
        LC.TENOR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,10,1>
*MAT.DATE=R.AZ.REC.HIS<TF.DR.TRACE.DATE>
        MAT.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrTraceDate>
        Y.MNE.COMP = ID.COMPANY
        Y.RET.DATA<-1> =Y.MNE.COMP:"*":I:"*":LD.NO:"*":LD.CUST.ID:"*":LD.VAL.DATE:"*":LD.FIN.MAT.DT:"*":LD.DRAW.NO:"*":LD.PUR.FC.AMT:"*":LD.DOC.VAL:"*":BILL.NO:"*":BILL.DATE:"*":EXPORTER:"*":IMPORTER:"*":TF.DRAW.NO:"*":DRAW.TYPE:"*":EXP.LC.NO:"*":LC.ISS.BANK:"*":CURR:"*":DOC.VAL.FC:"*":BILL.AMT.BDT:"*":LC.TENOR:"*":MAT.DATE:"*":LD.PROFIT.RATE:"*":PRIN.AMT:"*":NET.OUTS:"*":CUST.NAME
    REPEAT
*    NEXT
RETURN
END