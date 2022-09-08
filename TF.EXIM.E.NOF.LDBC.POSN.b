* @ValidationCode : MjotMTkzNDQ5ODA3NzpDcDEyNTI6MTU4MzQwNjYzNTE3ODp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 05 Mar 2020 17:10:35
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

SUBROUTINE TF.EXIM.E.NOF.LDBC.POSN(Y.RET.DATA)
*PROGRAM  ALL.LDBC.POSN
*-----------------------------------------------------------------------------
* This routine is used to make nofile enquiry FOR ALL BRANCH OUTS.LDBC.POSITION


*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
*    $INSERT I_F.LETTER.OF.CREDIT
*    $INSERT I_F.DRAWINGS
*    $INSERT I_F.COMPANY
*    $INSERT I_F.CURRENCY
    $USING LC.Contract
    $USING ST.CompanyCreation
    $USING ST.CurrencyConfig
    $USING EB.DataAccess
    $USING EB.Reports
    $USING LD.Contract
    $USING EB.Foundation
*  $USING EB.LocalReferences

    GOSUB INIT
    GOSUB PROCESS
RETURN

INIT:
*====
*DEBUG
*ST.CompanyCreation.LoadCompany("BNK")
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
*    F1.COMPANY = ''
*    EB.DataAccess.Opf(FN.COMPANY,F1.COMPANY)

    FN.CURR="F.CURRENCY"
    F.CURR=''
    EB.DataAccess.Opf(FN.CURR,F.CURR)

    EB.Foundation.MapLocalFields("DRAWINGS", "LT.SERIAL.NO",Y.LT.SERIAL.NO.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.EXPRT.NME",Y.LT.TF.EXPRT.NME.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.IMPRT.NME",Y.LT.TF.IMPRT.NME.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.EXPT.LCNO",Y.LT.TF.EXPT.LCNO.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TF.ISS.BR",Y.LT.TF.ISS.BR.POS)
    EB.Foundation.MapLocalFields("DRAWINGS", "LT.TENOR",Y.LT.TENOR.POS)

    Y.RECORD = ''
    Y.LINE = ''
    I = 0
RETURN

PROCESS:
*=======
*DEBUG
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

* SEL.COMPANY="SELECT F.COMPANY WITH @ID NE BD0010999"

*    EB.DataAccess.Readlist(SEL.COMPANY,SEL.LIST.COMP,'',NO.OF.COMP,ERR)
*
*    FOR C=1 TO NO.OF.COMP
*        REMOVE Y.COMP FROM SEL.LIST.COMP SETTING POS
*        !WHILE Y.COMP:POS
*        EB.DataAccess.FRead(FN.COMPANY,Y.COMP,R.COMP,F1.COMPANY,Y.ERR.COMP)
*        Y.MNE.COMP = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>

    FN.DRAWINGS = "F.DRAWINGS"
    F1.DRAWINGS = ''
    EB.DataAccess.Opf(FN.DRAWINGS, F1.DRAWINGS)

    FN.LC="F.LETTER.OF.CREDIT"
    F.LC=''
    EB.DataAccess.Opf(FN.LC,F.LC)

    COMPANY = ''

    SEL.CMD=''
    Y.LIST.HIS=''
    Y.AZ.ID=''
    Y.LC.ID=''
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


*DEBUG
    IF Y.VAL.DT NE '' AND Y.CUST EQ '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
            SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH  LC.CREDIT.TYPE EQ 'LCST' AND DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' AND VALUE.DATE GE ":Y.START.DATE:" AND VALUE.DATE LE ":Y.END.DATE:"  BY @ID"
        END ELSE
            SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH  LC.CREDIT.TYPE EQ 'LCST' AND DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' AND VALUE.DATE ":Y.VAL.OPD:" ":Y.VAL.DT:" BY @ID"
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST NE '' THEN
        SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH LC.CREDIT.TYPE EQ 'LCST' AND DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' AND CUSTOMER.LINK ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
    END
    ELSE IF Y.VAL.DT NE '' AND Y.CUST NE '' THEN
        IF Y.VAL.OPD EQ 'RG' THEN
            SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH  LC.CREDIT.TYPE EQ 'LCST' AND  DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' AND VALUE.DATE GE ":Y.START.DATE:" AND VALUE.DATE LE ":Y.END.DATE:" AND CUSTOMER.LINK ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
        END ELSE
            SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH   LC.CREDIT.TYPE EQ 'LCST' AND DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' AND VALUE.DATE ":Y.VAL.OPD:" ":Y.VAL.DT:" AND CUSTOMER.LINK ":Y.CUST.OPD:" ":Y.CUST:" BY @ID"
        END
    END
    ELSE IF Y.VAL.DT EQ '' AND Y.CUST EQ '' THEN
        SEL.CMD = "SELECT ":FN.DRAWINGS:" WITH   LC.CREDIT.TYPE EQ 'LCST' AND DRAWING.TYPE EQ 'CO' 'AC' 'DP' AND LT.LIMIT.PROD EQ 'LCOL' BY @ID"
    END
    EB.DataAccess.Readlist(SEL.CMD,Y.LIST.HIS,'',NO.OF.REC,ERR.CODE)
    I=0
    LOOP
    WHILE Y.LIST.HIS DO
        Y.AZ.ID = Y.LIST.HIS<1> ; DEL Y.LIST.HIS<1>
        I =I + 1
        EB.DataAccess.FRead(FN.DRAWINGS,Y.AZ.ID,R.AZ.REC.HIS,F1.DRAWINGS,Y.ERR.HIS)


        BILL.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrValueDate>
        BILL.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.SERIAL.NO.POS,1>
        EXPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.EXPRT.NME.POS,1>
        IMPORTER=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.IMPRT.NME.POS,1>
        TF.DRAW.NO=Y.AZ.ID
        DRAW.TYPE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawingType>
        EXP.LC.NO=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.EXPT.LCNO.POS,1>

        LC.ISS.BANK=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TF.ISS.BR.POS>
        IF LC.ISS.BANK[1,1] EQ "*" THEN
            LC.ISS.BANK=LC.ISS.BANK[2,LEN(LC.ISS.BANK)]
        END

        CURR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDrawCurrency>
        EB.DataAccess.FRead(FN.CURR,CURR,R.CURR.REC,F.CURR,Y.ERR.CURR)
        IF CURR EQ 'BDT' THEN
            EX.RATE=1
        END ELSE
            IF CURR EQ 'USD' OR CURR EQ 'GBP' OR CURR EQ 'EUR' THEN
                EX.RATE=R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,3,1>
            END ELSE
                IF CURR EQ 'CNY' OR CURR EQ 'JPY' OR CURR EQ 'CHF' OR CURR EQ 'CAD' THEN
                    EX.RATE=R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,2,1>
                END
            END
        END


        DOC.VAL.FC=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrDocumentAmount>

        BILL.AMT.BDT=DOC.VAL.FC * EX.RATE

        LC.TENOR=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrLocalRef,Y.LT.TENOR.POS,1>
        MAT.DATE=R.AZ.REC.HIS<LC.Contract.Drawings.TfDrTraceDate>
              
        Y.MNE.COMP = ID.COMPANY

        Y.RET.DATA<-1> =Y.MNE.COMP:"*":I:"*":BILL.NO:"*":BILL.DATE:"*":EXPORTER:"*":IMPORTER:"*":TF.DRAW.NO:"*":DRAW.TYPE:"*":EXP.LC.NO:"*":LC.ISS.BANK:"*":CURR:"*":DOC.VAL.FC:"*":BILL.AMT.BDT:"*":LC.TENOR:"*":MAT.DATE
    REPEAT
* NEXT
RETURN
END