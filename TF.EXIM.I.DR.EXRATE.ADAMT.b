* @ValidationCode : MjotMTM4NDYwNzg1OTpDcDEyNTI6MTU3MDM0OTI4MzA1NzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Oct 2019 14:08:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
*-----------------------------------------------------------------------------
SUBROUTINE TF.EXIM.I.DR.EXRATE.ADAMT(Y.BILL.CCY,Y.DR.TYPE,Y.CR.CCY,Y.DR.CCY,Y.CONV.RATE,Y.SPREAD)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING LC.Contract
    $USING ST.CurrencyConfig
    $USING EB.SystemTables
    $USING AC.AccountOpening
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.LC = 'F.LETTER.OF.CREDIT'
    F.LC = ''
*
    FN.CURR='F.CURRENCY'
    F.CURR = ''
*
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
*
RETURN
*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.LC, F.LC)
    EB.DataAccess.Opf(FN.CURR, F.CURR)
    EB.DataAccess.Opf(FN.AC, F.AC)
RETURN
*----------
PROCESS:
*----------
*    DEBUG
    Y.DR.AC = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawdownAccount)
    EB.DataAccess.FRead(FN.AC,Y.DR.AC,R.AC.REC,F.AC,Y.ERR)
    Y.DR.CCY = R.AC.REC<AC.AccountOpening.Account.Currency>
*
    Y.CR.AC = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrPaymentAccount)
    EB.DataAccess.FRead(FN.AC,Y.CR.AC,R.AC.REC1,F.AC,Y.ERRR)
    Y.CR.CCY=R.AC.REC1<AC.AccountOpening.Account.Currency>
*
    Y.DR.TYPE = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawingType)
    
*--------------BC RATE -----------------
    Y.BILL.CCY = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawCurrency)
*********Edited By Shafiul***************************
*Y.BILL.CCY = 'EUR'
*********End*****************************************
    EB.DataAccess.FRead(FN.CURR, Y.BILL.CCY, R.CURR.REC,F.CURR,Y.ERR.CURR)
    IF Y.BILL.CCY EQ 'BDT' THEN
        Y.BC.RATE = 1
    END ELSE
        IF Y.BILL.CCY EQ 'USD' OR Y.BILL.CCY EQ 'GBP' OR Y.BILL.CCY EQ 'EUR' OR Y.BILL.CCY EQ 'SAR' THEN
            Y.BC.RATE = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,5,1>
        END ELSE
            IF Y.BILL.CCY EQ 'JPY' OR Y.BILL.CCY EQ 'CHF' OR Y.BILL.CCY EQ 'CAD' OR Y.BILL.CCY EQ 'AUD' OR Y.BILL.CCY EQ 'HKD' THEN
                Y.BC.RATE1 = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,4,1>
            END
        END
    END
    
*---------------TT CLEAN RATE----------
    IF Y.BILL.CCY EQ 'BDT' THEN
        Y.TT.CLEAN.RATE = 1
    END ELSE
        IF Y.BILL.CCY EQ 'USD' OR Y.BILL.CCY EQ 'GBP' OR Y.BILL.CCY EQ 'EUR' OR Y.BILL.CCY EQ 'SAR' THEN
            Y.TT.CLEAN.RATE = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,3,1>
        END ELSE
            IF Y.BILL.CCY EQ 'JPY' OR Y.BILL.CCY EQ 'CHF' OR Y.BILL.CCY EQ 'CAD' OR Y.BILL.CCY EQ 'AUD' OR Y.BILL.CCY EQ 'HKD' THEN
                Y.TT.CLEAN.RATE1 = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,2,1>
            END
        END
    END
    
*--------OD SIGHT EXPORT RATE---------
    IF Y.BILL.CCY EQ 'BDT' THEN
        Y.OD.SIGHT.RATE=1
    END ELSE
        IF Y.BILL.CCY EQ 'USD' OR Y.BILL.CCY EQ 'GBP' OR Y.BILL.CCY EQ 'EUR' THEN
            Y.OD.SIGHT.RATE = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,7,1>
        END ELSE
            IF Y.BILL.CCY EQ 'JPY' OR Y.BILL.CCY EQ 'CHF' OR Y.BILL.CCY EQ 'CAD' OR Y.BILL.CCY EQ 'HKD' THEN
                Y.OD.SIGHT.RATE1 = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,6,1>
            END
        END
    END
    
*---------TT OD RATE-----------------
    IF Y.BILL.CCY EQ 'BDT' THEN
        Y.TT.OD=1
    END ELSE
        IF Y.BILL.CCY EQ 'USD' OR Y.BILL.CCY EQ 'GBP' OR Y.BILL.CCY EQ 'EUR' OR Y.BILL.CCY EQ 'SAR' THEN
            Y.TT.OD = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,4,1>
        END ELSE
            IF Y.BILL.CCY EQ 'JPY' OR Y.BILL.CCY EQ 'CHF' OR Y.BILL.CCY EQ 'CAD' OR Y.BILL.CCY EQ 'HKD' THEN
                Y.TT.OD1 = R.CURR.REC<ST.CurrencyConfig.Currency.EbCurMidRevalRate,3,1>
            END
        END
    END
    
*-------------SPREAD CLACULATION------------
    SPREAD = (Y.BC.RATE - Y.TT.OD)
    SPREAD1 = (Y.TT.CLEAN.RATE - Y.OD.SIGHT.RATE)
    SPREAD2 = (Y.BC.RATE - Y.OD.SIGHT.RATE)
    SPREAD.1 = (Y.BC.RATE1 - Y.TT.OD1)
    SPREAD1.1 = (Y.TT.CLEAN.RATE1 - Y.OD.SIGHT.RATE1)
    SPREAD2.1 = (Y.BC.RATE1 - Y.OD.SIGHT.RATE1)
*----------USD CURRENCY----------------------
*
*----CASE-1------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'USD' AND Y.DR.CCY EQ 'USD' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.TT.CLEAN.RATE)
            Y.CONV.RATE = Y.TT.CLEAN.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD1)
            Y.SPREAD = SPREAD1
        END
    END
*
*----CASE-2------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'USD' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'USD' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.TT.OD)
            Y.CONV.RATE = Y.TT.OD
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD)
            Y.SPREAD = SPREAD
        END
    END
*
*-----CASE-3-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'USD' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.BC.RATE)
            Y.CONV.RATE = Y.BC.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2)
            Y.SPREAD2 = SPREAD2
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.OD.SIGHT.RATE)
            Y.CONV.RATE = Y.OD.SIGHT.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD2)
            Y.SPREAD = SPREAD2
        END
    END
*
*----CASE-4-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'USD' AND Y.DR.CCY EQ 'USD' AND Y.CR.CCY EQ 'USD' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, '')
            Y.SPREAD = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, '')
            Y.SPREAD = ''
        END
    END
*----------EUR CURRENCY----------------------
*
*----CASE-5-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
*IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'EUR' AND Y.CR.CCY EQ 'BDT' THEN
        IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'EUR' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.TT.CLEAN.RATE)
            Y.CONV.RATE = Y.TT.CLEAN.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD1)
            Y.SPREAD = SPREAD1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2)
            Y.SPREAD = SPREAD2
        END
    END
*
*----CASE-6-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'EUR' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.TT.OD)
            Y.CONV.RATE = Y.TT.OD
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD)
            Y.SPREAD = SPREAD
        END
    END
*
*-----CASE-7-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.BC.RATE)
            Y.CONV.RATE = Y.BC.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD2)
            Y.SPREAD2 = SPREAD2
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.OD.SIGHT.RATE)
            Y.CONV.RATE = Y.OD.SIGHT.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2)
            Y.SPREAD = SPREAD2
        END
    END
*
*----CASE-8-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
*IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'EUR' AND Y.CR.CCY EQ 'EUR' THEN
        IF Y.BILL.CCY EQ 'EUR' AND Y.DR.CCY EQ 'EUR' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, '')
            Y.SPREAD = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, '')
            Y.SPREAD = ''
        END
    END
*
*----------GBP CURRENCY----------------------
*
*----CASE-9------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'GBP' AND Y.DR.CCY EQ 'GBP' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.TT.CLEAN.RATE)
            Y.CONV.RATE = Y.TT.CLEAN.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD1)
            Y.SPREAD = SPREAD1
        END
    END
*
*----CASE-10------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'GBP' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'GBP' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.TT.OD)
            Y.CONV.RATE = Y.TT.OD
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD)
            Y.SPREAD = SPREAD
        END
    END
*
*-----CASE-11-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'GBP' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.BC.RATE)
            Y.CONV.RATE = Y.BC.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD2)
            Y.SPREAD2 = SPREAD2
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.OD.SIGHT.RATE)
            Y.CONV.RATE = Y.OD.SIGHT.RATE
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2)
            Y.SPREAD = SPREAD2
        END
    END
*
*----CASE-12-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'GBP' AND Y.DR.CCY EQ 'GBP' AND Y.CR.CCY EQ 'GBP' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, '')
            Y.SPREAD = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, '')
            Y.SPREAD = ''
        END
    END
*----------JPY CURRENCY----------------------
*
*----CASE-13------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'JPY' AND Y.DR.CCY EQ 'JPY' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.TT.CLEAN.RATE1)
            Y.CONV.RATE = Y.TT.CLEAN.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD1.1)
            Y.SPREAD = SPREAD1.1
        END
    END
*
*----CASE-14------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'JPY' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'JPY' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.TT.OD1)
            Y.CONV.RATE = Y.TT.OD1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD.1)
            Y.SPREAD = SPREAD.1
        END
    END
*
*-----CASE-15-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'JPY' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.BC.RATE1)
            Y.CONV.RATE = Y.BC.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2.1)
            Y.SPREAD2.1 = SPREAD2.1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.OD.SIGHT.RATE1)
            Y.CONV.RATE = Y.OD.SIGHT.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD2.1)
            Y.SPREAD = SPREAD2.1
        END
    END
*
*----CASE-16-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'JPY' AND Y.DR.CCY EQ 'JPY' AND Y.CR.CCY EQ 'JPY' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, '')
            Y.SPREAD = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, '')
            Y.SPREAD = ''
        END
    END
*
*----------CHF CURRENCY----------------------
*
*----CASE-17------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'CHF' AND Y.DR.CCY EQ 'CHF' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.TT.CLEAN.RATE1)
            Y.CONV.RATE = Y.TT.CLEAN.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD1.1)
            Y.SPREAD = SPREAD1.1
        END
    END
*
*----CASE-18------
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'CHF' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'CHF' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.TT.OD1)
            Y.CONV.RATE = Y.TT.OD1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD.1)
            Y.SPREAD = SPREAD.1
        END
    END
*
*-----CASE-19-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'CHF' AND Y.DR.CCY EQ 'BDT' AND Y.CR.CCY EQ 'BDT' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, Y.BC.RATE1)
            Y.CONV.RATE = Y.BC.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, SPREAD2.1)
            Y.SPREAD2.1 = SPREAD2.1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, Y.OD.SIGHT.RATE1)
            Y.CONV.RATE = Y.OD.SIGHT.RATE1
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, SPREAD2.1)
            Y.SPREAD = SPREAD2.1
        END
    END
*
*----CASE-20-----
    IF Y.DR.TYPE EQ 'MA' OR Y.DR.TYPE EQ 'MD' OR Y.DR.TYPE EQ 'SP' THEN
        IF Y.BILL.CCY EQ 'CHF' AND Y.DR.CCY EQ 'CHF' AND Y.CR.CCY EQ 'CHF' THEN
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrTreasuryRate, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrCustomerSpread, '')
            Y.SPREAD = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateBooked, '')
            Y.CONV.RATE = ''
            EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrRateSpread, '')
            Y.SPREAD = ''
        END
    END
*-----------------------------------------------------------------------------
RETURN
END
