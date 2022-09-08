* @ValidationCode : MjotNzM1MjU3MDA0OkNwMTI1MjoxNTg0MzQ5OTQxNzE3OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Mar 2020 15:12:21
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

SUBROUTINE TF.EXIM.E.NOF.FDBP.POSN.AA(Y.RET.DATA)
*PROGRAM  ALL.FDBP.POSN
*-----------------------------------------------------------------------------
* This routine is used to make nofile enquiry FOR ALL BRANCH OUTS.FDBP.POSITION

*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.Framework
* $INSERT I_F.AA.ACCOUNT
* $INSERT I_F.ACCOUNT
*$INSERT I_F.AA.LIMIT
*    $INSERT I_F.AA.ACCOUNT.DETAILS
*    $INSERT I_F.DRAWINGS
*    $INSERT I_F.COMPANY
    $USING AA.PaymentSchedule
    $USING LC.Contract
    $USING ST.CurrencyConfig
    $USING EB.DataAccess
    $USING EB.Reports
    $USING LD.Contract
*  $USING EB.LocalReferences
    $USING AA.Account
    $USING AC.AccountOpening
    $USING EB.API
    $USING LI.Config
    $USING AA.Limit
    $USING ST.CompanyCreation
    $USING EB.Foundation
*
    GOSUB INIT
*
    GOSUB OPENFILES
*
    GOSUB PROCESS
RETURN
*
*====
INIT:
*====
*ST.CompanyCreation.LoadCompany("BNK")
*
    FN.ACC = 'F.AA.ACCOUNT'
    F.ACC = ''
    FN.ARR.ACC='F.AA.ARR.ACCOUNT'
    F.ARR.ACC=''
    FN.DRAWINGS = "F.DRAWINGS"
    F.DRAWINGS = ''
    FN.AA="F.AA.ARRANGEMENT"
    F.AA=''
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.LI='F.AA.ARR.LIMIT'
    F.LI=''
    I=0
    
* EB.Foundation.MapLocalFields("DRAWINGS", "PRESENTOR.REF",Y.PRESENTOR.REF.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.EXPRT.NME",Y.LT.TF.EXPRT.NME.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.IMPRT.NME",Y.LT.TF.IMPRT.NME.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.EXPT.LCNO",Y.LT.TF.EXPT.LCNO.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.ISS.BR",Y.LT.TF.ISS.BR.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TENOR",Y.LT.TENOR.POS)
*
    EB.Foundation.MapLocalFields("AA.ARR.ACCOUNT", "LINKED.TFDR.REF",Y.LINKED.TFDR.REF.POS)
    EB.Foundation.MapLocalFields("AA.ARR.ACCOUNT", "LT.PUR.FC.AMT",Y.LT.PUR.FC.AMT.POS)
    EB.Foundation.MapLocalFields("AA.ARR.ACCOUNT", "LT.DOC.BILL.VAL",Y.LT.DOC.BILL.VAL.POS)

RETURN

*=========
OPENFILES:
*=========
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.DRAWINGS,F.DRAWINGS)
    EB.DataAccess.Opf(FN.ACC,F.ACC)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.LI,F.LI)
RETURN

*=======
PROCESS:
*=======
    LOCATE "CUSTOMER.NO" IN EB.Reports.getEnqSelection()<2,1> SETTING Y.CUST.NO.POS THEN
        Y.CUST.OPD=EB.Reports.getEnqSelection()<3,Y.CUST.NO.POS>
        Y.CUST=EB.Reports.getEnqSelection()<4,Y.CUST.NO.POS>
    END
    LOCATE "VALUE.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING Y.VAL.DT.POS THEN
        Y.VAL.OPD=EB.Reports.getEnqSelection()<3,Y.VAL.DT.POS>
        Y.VAL.DT=EB.Reports.getEnqSelection()<4,Y.VAL.DT.POS>
    END
    IF Y.VAL.OPD EQ 'RG' THEN
        Y.START.DATE=Y.VAL.DT[1,8]
        Y.END.DATE=Y.VAL.DT[10,8]
    END
    EB.API.Juldate(Y.VAL.DT,JUL.DATE)
    EB.API.Juldate(Y.START.DATE,START.JUL.DATE)
*
    IF Y.VAL.DT NE '' AND Y.CUST EQ '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
****-----------PRODUCT CHANGED TO EXIM.AS.SRF.FDBP.LN---------------********
            SEL.CMD = "SELECT ":FN.AA:" WITH @ID LIKE ":"AA":START.JUL.DATE[3,5]:"...":" AND PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CO.CODE EQ ":ID.COMPANY
        END ELSE
            SEL.CMD = "SELECT ":FN.AA:" WITH @ID LIKE ":"AA":JUL.DATE[3,5]:"...":" AND PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CO.CODE EQ ":ID.COMPANY
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST NE '' THEN
        SEL.CMD = "SELECT ":FN.AA:" WITH PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CUSTOMER ":Y.CUST.OPD:" ":Y.CUST:" ":"AND CO.CODE EQ ":ID.COMPANY
    END
    ELSE IF Y.VAL.DT NE '' AND Y.CUST NE '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
            SEL.CMD = "SELECT ":FN.AA:" WITH @ID LIKE ":"AA":START.JUL.DATE[3,5]:"...":" AND PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CUSTOMER ":Y.CUST.OPD:" ":Y.CUST:" ":"AND CO.CODE EQ ":ID.COMPANY
        END ELSE
            SEL.CMD = "SELECT ":FN.AA:" WITH @ID LIKE ":"AA":JUL.DATE[3,5]:"...":" AND PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CUSTOMER ":Y.CUST.OPD:" ":Y.CUST:" ":"AND CO.CODE EQ ":ID.COMPANY
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST EQ '' THEN
        SEL.CMD = "SELECT ":FN.AA:" WITH PRODUCT EQ EXIM.AS.SRF.FDBP.LN ":"AND CO.CODE EQ ":ID.COMPANY
    END
*
    EB.DataAccess.Readlist(SEL.CMD,THE.LIST,'',NO.OF.REC,ERR.CODE)
*
    LOOP
        REMOVE Y.AA.ID FROM THE.LIST SETTING Y.AA.POS
    WHILE Y.AA.ID:Y.AA.POS
        I =I + 1
        EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,ERR.AA)
*
        Y.AC.ID = R.AA<AA.Framework.Arrangement.ArrLinkedApplId>
        
        EB.DataAccess.FRead(FN.AC,Y.AC.ID,R.AC,F.AC,ERR.AC)
*
        Y.AMOUNT = R.AC<AC.AccountOpening.Account.WorkingBalance>
        
        EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.AA.ID,R.AA.ACC.DETAILS,F.AA.ACC.DETAILS,ERR.AC.DETAILS)
*
        Y.VAL.DATE=R.AA.ACC.DETAILS<AA.PaymentSchedule.AccountDetails.AdValueDate>
        Y.MAT.DATE=R.AA.ACC.DETAILS<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
*
        PROP.CLASS = 'LIMIT'
*         AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
*        R.REC.LIMIT = RAISE(RETURN.VALUES)
        AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG) ;* Product conditions with activities
        R.REC1 = RAISE(RETURN.VALUES)
        Y.LIMIT.REFERENCE = R.REC1<AA.Limit.Limit.LimLimitReference>[1,4]
        
****------LIMIT REFERENCE IS CHANGED TO '6476>Bai-As-Sarf (FDBP)'--------****
        IF Y.AMOUNT NE '' AND Y.LIMIT.REFERENCE EQ '6476' AND Y.VAL.DATE LE Y.MAT.DATE THEN
            Y.CUST.ID = R.AA<AA.Framework.Arrangement.ArrCustomer>
            
            PROP.CLASS = 'ACCOUNT'
            AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
            R.REC = RAISE(RETURN.VALUES)
            Y.DRAW.NO = R.REC<AA.Account.Account.AcLocalRef,Y.LINKED.TFDR.REF.POS,1>
            Y.PUR.FC.AMT = R.REC<AA.Account.Account.AcLocalRef,Y.LT.PUR.FC.AMT.POS,1>
            Y.DOC.VAL = R.REC<AA.Account.Account.AcLocalRef,Y.LT.DOC.BILL.VAL.POS,1>
            EB.DataAccess.FRead(FN.DRAWINGS,Y.DRAW.NO,R.AZ.REC.HIS,F.DRAWINGS,Y.ERR.HIS)
            BILL.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrValueDate>
            BILL.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrPresentorRef>
            EXPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.EXPRT.NME.POS,1>
            IMPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.IMPRT.NME.POS,1>
            TF.DRAW.NO=Y.DRAW.NO
            DRAW.TYPE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawingType>
            EXP.LC.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.EXPT.LCNO.POS,1>
            LC.ISS.BANK=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.ISS.BR.POS,1>
            IF LC.ISS.BANK[1,1] EQ "*" THEN
                LC.ISS.BANK=LC.ISS.BANK[2,LEN(LC.ISS.BANK)]
            END

            CURR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawCurrency>
            DOC.VAL.FC=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocumentAmount>
            IF R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawCurrency> NE 'BDT' THEN
                BILL.AMT.BDT=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocAmtLocal>
            END ELSE
                BILL.AMT.BDT=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocumentAmount>
            END
            LC.TENOR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TENOR.POS,1>
            MAT.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrTraceDate>
            Y.MNE.COMP = ID.COMPANY
            Y.RET.DATA<-1> =Y.MNE.COMP:"*":I:"*":Y.AA.ID:"*":Y.CUST.ID:"*":Y.VAL.DATE:"*":Y.MAT.DATE:"*":Y.DRAW.NO:"*":Y.PUR.FC.AMT:"*":Y.DOC.VAL:"*":BILL.NO:"*":BILL.DATE:"*":EXPORTER:"*":IMPORTER:"*":TF.DRAW.NO:"*":DRAW.TYPE:"*":EXP.LC.NO:"*":LC.ISS.BANK:"*":CURR:"*":DOC.VAL.FC:"*":BILL.AMT.BDT:"*":LC.TENOR:"*":MAT.DATE:"*":Y.AMOUNT
*                             1          2         3           4            5               6               7           8              9            10               11          12          13              14          15             16           17             18           19            20             21              22          23
        END
    REPEAT
*
RETURN
END