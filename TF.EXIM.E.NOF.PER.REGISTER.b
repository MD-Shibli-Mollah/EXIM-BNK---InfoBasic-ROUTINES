* @ValidationCode : MjoxMDc4MTIxMzgxOkNwMTI1MjoxNTg5ODcxNjMxODQ2OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 May 2020 13:00:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.E.NOF.PER.REGISTER(Y.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.BTB.JOB.REGISTER
    $INSERT I_F.BD.SCT.CAPTURE
    $INSERT I_F.EXIM.EXPFORM
    
    
    $USING EB.Reports
    $USING EB.DataAccess
    $USING LC.Contract
    $USING EB.Updates
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----
INIT:
*----

    Y.DR.TYPE.LIST = 'SP':VM:'MA':VM:'CO':VM:'AC':VM:'DP'
    Y.R.DR.TYPE = 'SP':VM:'MA':VM:'MD'
    FN.JOB.REG = 'F.BD.BTB.JOB.REGISTER'
    F.JOB.REG = ''
    FN.SCT = 'F.BD.SCT.CAPTURE'
    F.SCT = ''
    FN.EXP = 'F.EXIM.EXPFORM'
    F.EXP = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.LC = 'F.LETTER.OF.CREDIT'
    F.LC = ''
    FN.DR = 'F.DRAWINGS'
    F.DR = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    Y.COLL.WITHOUT.LC.VALUE = 0
    
    LOCATE 'CUSTOMER.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING Y.CUS.NO.POS THEN
        Y.CUS.OPD = EB.Reports.getEnqSelection()<3,Y.CUS.NO.POS>
        Y.CUS = EB.Reports.getEnqSelection()<4,Y.CUS.NO.POS>
    END
    LOCATE 'JOB.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING Y.JOB.NO.POS THEN
        Y.JOB.OPD = EB.Reports.getEnqSelection()<3,Y.JOB.NO.POS>
        Y.JOB.NO = EB.Reports.getEnqSelection()<4,Y.JOB.NO.POS>
    END
    
    FLD.POS = ''
    APPLICATION.NAME = 'LETTER.OF.CREDIT':FM:'DRAWINGS'
    LOCAL.FIELDS = 'LT.TF.UNIT':VM:'LT.TF.COMD.QTY':VM:'LT.TF.UNIT.PRIC':VM:'LT.TF.COMD.ID':FM:'LT.TF.EXP.NO':VM:'LT.TF.PAY.DATE'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.UNIT.POS = FLD.POS<1,1>
    Y.QUANTITY.POS = FLD.POS<1,2>
    Y.UNIT.PRICE.POS = FLD.POS<1,3>
    Y.COMD.ID.POS = FLD.POS<1,4>
    Y.LT.TF.EXP.NO.POS = FLD.POS<2,1>
    Y.PAY.DATE.POS = FLD.POS<2,2>
    
    Y.BTB.TF.NO = ''
    Y.BTB.LC.NO = ''
    Y.VALUE.IN.FC = ''
    Y.ITEM = ''
    Y.BTB.DR.ID = ''
    Y.DRAWING.VALUE = ''
    Y.BTB.MAT.DATE = ''
    Y.PAYMENT.DATE = ''
    Y.AA.ID = ''
    Y.TYPE.OF.FINANCE = ''
    Y.AA.START.DATE = ''
    Y.AMOUNT = ''
    Y.EXP.DATE = ''
    Y.ADJUST.AMT = ''
    Y.DATE.OF.ADJ = ''
    Y.OUTSTAND.AMT = ''
    
    Y.FCB.DATE = ''
    Y.FCB.DR.ID = ''
    Y.BILL.NO = ''
    Y.FCB.DEBIT = ''
    Y.FCB.CREDIT = ''
    Y.FCB.BALANCE = ''

RETURN

*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.JOB.REG,F.JOB.REG)
    EB.DataAccess.Opf(FN.SCT,F.SCT)
    EB.DataAccess.Opf(FN.EXP,F.EXP)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.LC,F.LC)
    EB.DataAccess.Opf(FN.DR,F.DR)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.AC,F.AC)
RETURN

*-------
PROCESS:
*-------
    IF Y.CUS NE '' AND Y.JOB.NO EQ '' THEN
        SEL.CMD = 'SELECT ':FN.JOB.REG:' WITH @ID LIKE ...':Y.CUS:'...'
    END ELSE
        SEL.CMD = 'SELECT ':FN.JOB.REG:' WITH @ID ':Y.JOB.OPD:' ':Y.JOB.NO
    END
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, RET.CODE)
    LOOP
        REMOVE Y.JOB.ID FROM SEL.LIST SETTING Y.JOB.ID.POS
    WHILE Y.JOB.ID : Y.JOB.ID.POS
        EB.DataAccess.FRead(FN.JOB.REG,Y.JOB.ID,R.JOB.REG,F.JOB.REG,ERR.JOB.REG)
        Y.TOT.CON.RENO.ID = R.JOB.REG<BTB.JOB.CONT.REFNO>
        
        Y.TOT.COLL.DR.REFNO = R.JOB.REG<BTB.JOB.COLL.DR.REFNO>
        Y.TOT.COLL.AA.REFNO = R.JOB.REG<BTB.JOB.COLL.PUR.REFNO>
        
        Y.TOT.ELC.TF.REFNO = R.JOB.REG<BTB.JOB.ELC.TF.REFNO>
        Y.TOT.ELC.DR.REFNO = R.JOB.REG<BTB.JOB.ELC.DR.REFNO>
        Y.TOT.ELC.AA.REFNO = R.JOB.REG<BTB.JOB.ELC.PUR.REFNO>
        
        Y.TOT.BTB.TF.REFNO = R.JOB.REG<BTB.JOB.BTB.TF.REFNO>
        Y.TOT.BTB.DR.REFNO = R.JOB.REG<BTB.JOB.BTB.DR.REFNO>
        Y.TOT.BTB.MIB.REFNO = R.JOB.REG<BTB.JOB.BTB.MIB.REFNO>
        Y.TOT.BTB.MPI.REFNO = R.JOB.REG<BTB.JOB.BTB.MPI.REFNO>
        
        Y.DCOUNT = DCOUNT(Y.TOT.CON.RENO.ID,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.CON.RENO.ID = Y.TOT.CON.RENO.ID<1,I>
            EB.DataAccess.FRead(FN.SCT,Y.CON.RENO.ID,R.SCT,F.SCT,ERR.SCT)
            Y.ID = Y.CON.RENO.ID
            Y.DATE.OF.LIEN = R.SCT<SCT.CONTRACT.DATE>
            Y.CONTRACT.NO = R.SCT<SCT.CONTRACT.NUMBER>
            Y.CONTRACT.VALUE = R.SCT<SCT.CONTRACT.AMT>
            Y.REPLACEMENT = 0
            Y.COLL.WITHOUT.LC.VALUE = R.SCT<SCT.COLL.AWAIT.AMT>
            Y.BALANCE.VALUE = ABS(Y.CONTRACT.VALUE - (Y.REPLACEMENT + Y.COLL.WITHOUT.LC.VALUE))
            Y.TENOR = R.SCT<SCT.TENOR.DAYS>
            Y.DATE.OF.SHIPMENT = R.SCT<SCT.SHIPMENT.DATE>
            Y.EXPIRY.DATE = R.SCT<SCT.EXPIRY.DATE>
            Y.BUYER.COUNTRY = R.SCT<SCT.BUYER.NAME>
            Y.ITEM.NO = R.SCT<SCT.COMD.UNIT>
            Y.QUANTITY = R.SCT<SCT.COMD.QTY>
            Y.UNIT.PRICE = R.SCT<SCT.COMD.UNIT.PRICE>
            Y.DR.COUNT = DCOUNT(Y.TOT.COLL.DR.REFNO,SM)
            FOR J = 1 TO Y.DR.COUNT
                Y.DR.ID = Y.TOT.COLL.DR.REFNO<1,1,J>
                Y.AA.ID = Y.TOT.COLL.AA.REFNO<1,1,J>
                IF J GT 1 THEN
                    GOSUB SCT.REFRESH
                END
                EB.DataAccess.FRead(FN.DR,Y.DR.ID,R.DR,F.DR,ERR.DR)
                Y.DR.TYPE = R.DR<LC.Contract.Drawings.TfDrDrawingType>
                Y.EXP.ID = R.DR<LC.Contract.Drawings.TfDrLocalRef><1,Y.LT.TF.EXP.NO.POS>
                LOCATE Y.DR.TYPE IN Y.DR.TYPE.LIST<1,1> SETTING Y.DR.TYPE.POS THEN
                    EB.DataAccess.FRead(FN.EXP,Y.EXP.ID,R.EXP,F.EXP,ERR.EXP)
                    Y.EXP.BILL.NO = R.EXP<EXP.BILL.OF.EXP.NO>
                    Y.BOOKING.DATE = R.DR<LC.Contract.Drawings.TfDrBookingDate>
                    Y.VALUE = R.DR<LC.Contract.Drawings.TfDrDocumentAmount>
                    Y.MAT.DATE = R.DR<LC.Contract.Drawings.TfDrMaturityReview>
                    LOCATE Y.DR.TYPE IN Y.R.DR.TYPE<1,1> SETTING Y.R.DR.TYPE.POS THEN
                        Y.REALIZED.VALUE = R.EXP<EXP.EXP.REALIZED.AMT>
                        Y.REALIZED.DATE = R.EXP<EXP.EXP.REALIZED.DATE>
                    END ELSE
                        Y.REALIZED.VALUE = ''
                        Y.REALIZED.DATE = ''
                    END
                END
                EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,ERR.AA)
                Y.PRODUCT = R.AA<AA.Framework.Arrangement.ArrProduct>
                Y.TYPE.OF.FINANCE = Y.PRODUCT
                Y.AA.START.DATE = R.AA<AA.Framework.Arrangement.ArrStartDate>
                EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,ERR.AA.AC)
                PROP.CLASS = 'TERM.AMOUNT'
                AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
                R.REC = RAISE(RETURN.VALUES)
                Y.AMOUNT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
                Y.EXP.DATE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
                Y.ADJUST.AMT = 0
                Y.DATE.OF.ADJ = ''
                BaseBalance = 'CURACCOUNT'
                RequestType<2> = 'ALL'
                RequestType<3> = 'ALL'
                RequestType<4> = 'ECB'
                RequestType<4,2> = 'END'
                AA.Framework.GetArrangementAccountId(Y.AA.ID, accountId, Currency, ReturnError)   ;*To get Arrangement Account
                Y.SYSTEMDATE = EB.SystemTables.getToday()
                AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                Y.OUTSTAND.AMT = ABS(BalDetails<4>)
                GOSUB FCB.DATA
                Y.DATA<-1> = Y.ID:'*':Y.DATE.OF.LIEN:'*':Y.CONTRACT.NO:'*':Y.CONTRACT.VALUE:'*':Y.REPLACEMENT:'*':Y.COLL.WITHOUT.LC.VALUE:'*':Y.BALANCE.VALUE:'*':Y.TENOR:'*':Y.DATE.OF.SHIPMENT:'*':Y.EXPIRY.DATE:'*':Y.BUYER.COUNTRY:'*':Y.ITEM.NO:'*':Y.QUANTITY:'*':Y.UNIT.PRICE:'*':Y.DR.ID:'*':Y.EXP.BILL.NO:'*':Y.BOOKING.DATE:'*':Y.VALUE:'*':Y.MAT.DATE:'*':Y.REALIZED.VALUE:'*':Y.REALIZED.DATE:'*':Y.BTB.TF.NO:'*':Y.BTB.LC.NO:'*':Y.VALUE.IN.FC:'*':Y.ITEM:'*':Y.BTB.DR.ID:'*':Y.DRAWING.VALUE:'*':Y.BTB.MAT.DATE:'*':Y.PAYMENT.DATE:'*':Y.AA.ID:'*':Y.TYPE.OF.FINANCE:'*':Y.BTB.DR.ID:'*':Y.AA.START.DATE:'*':Y.AMOUNT:'*':Y.EXP.DATE:'*':Y.ADJUST.AMT:'*':Y.DATE.OF.ADJ:'*':Y.OUTSTAND.AMT:'*':Y.FCB.DATE:'*':Y.FCB.DR.ID:'*':Y.BILL.NO:'*':Y.FCB.DEBIT:'*':Y.FCB.CREDIT:'*':Y.FCB.BALANCE
*                              1             2                   3                   4                5                       6                   7                  8                9                   10              11                  12             13           14             15              16                  17              18           19              20                  21                 22           23               24                 25         26               27                  28                29                  30              31                  32               33              34             35               36              37              38                 39              40              41              42              43              44
                Y.FCB.CREDIT = ''
            NEXT J
        
            Y.TOT.ELC.REPLACE.NO = R.SCT<SCT.REP.ELC.NO>
            Y.D.RECORD = DCOUNT(Y.TOT.ELC.TF.REFNO,VM)
            FOR K = 1 TO Y.D.RECORD
                Y.ELC.RECORD.NO = Y.TOT.ELC.TF.REFNO<1,K>
                Y.VM.ELC.DR.REFNO = Y.TOT.ELC.DR.REFNO<1,K>
                Y.VM.ELC.AA.REFNO = Y.TOT.ELC.AA.REFNO<1,K>
                LOCATE Y.ELC.RECORD.NO IN Y.TOT.ELC.REPLACE.NO<1,1> SETTING Y.TF.POS THEN
                    GOSUB ELC.REPLACE
                END ELSE
                    GOSUB ELC.RECORDING
                END
            NEXT K
        NEXT I
        Y.BTB.COUNT = DCOUNT(Y.TOT.BTB.TF.REFNO,VM)
        FOR Q = 1 TO Y.BTB.COUNT
            GOSUB SCT.ELC.REC.OUT.REFRESH
            Y.BTB.TF.REFNO = Y.TOT.BTB.TF.REFNO<1,Q>
            Y.VM.BTB.DR.REFNO = Y.TOT.BTB.DR.REFNO<1,Q>
            Y.VM.BTB.MIB.REFNO = Y.TOT.BTB.MIB.REFNO<1,Q>
            Y.VM.BTB.MPI.REFNO = Y.TOT.BTB.MPI.REFNO<1,Q>
            EB.DataAccess.FRead(FN.LC,Y.BTB.TF.REFNO,R.LC,F.LC,ERR.LC)
            Y.BTB.TF.NO = Y.BTB.TF.REFNO
            Y.BTB.LC.NO = R.LC<LC.Contract.LetterOfCredit.TfLcOldLcNumber>
            Y.VALUE.IN.FC = R.LC<LC.Contract.LetterOfCredit.TfLcLcAmount>
            Y.ITEM = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.COMD.ID.POS>
            Y.BTB.DR.COUNT = DCOUNT(Y.VM.BTB.DR.REFNO,SM)
            IF Y.BTB.DR.COUNT LT 1 THEN
                GOSUB BTB.PROCESS.WO.DR
            END ELSE
                FOR S = 1 TO Y.BTB.DR.COUNT
                    Y.BTB.DR.ID = Y.VM.BTB.DR.REFNO<1,1,S>
                    Y.AA.ID = Y.VM.BTB.MIB.REFNO<1,1,S>
                    IF Y.AA.ID EQ '' THEN
                        Y.AA.ID = Y.VM.BTB.MPI.REFNO<1,1,S>
                    END
                    IF S GT 1 THEN
                        GOSUB BTB.LC.REFRESH
                    END
                    EB.DataAccess.FRead(FN.DR,Y.BTB.DR.ID,R.DR,F.DR,ERR.DR)
                    Y.DRAWING.VALUE = R.DR<LC.Contract.Drawings.TfDrDocumentAmount>
                    Y.BTB.MAT.DATE = R.DR<LC.Contract.Drawings.TfDrMaturityReview>
                    Y.PAYMENT.DATE = R.DR<LC.Contract.Drawings.TfDrLocalRef,Y.PAY.DATE.POS>
                    EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,ERR.AA)
                    Y.PRODUCT = R.AA<AA.Framework.Arrangement.ArrProduct>
                    Y.TYPE.OF.FINANCE = Y.PRODUCT
                    Y.AA.START.DATE = R.AA<AA.Framework.Arrangement.ArrStartDate>
                    EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,ERR.AA.AC)
                    PROP.CLASS = 'TERM.AMOUNT'
                    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
                    R.REC = RAISE(RETURN.VALUES)
                    Y.AMOUNT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
                    Y.EXP.DATE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
                    Y.ADJUST.AMT = 0
                    Y.DATE.OF.ADJ = ''
                    BaseBalance = 'CURACCOUNT'
                    RequestType<2> = 'ALL'
                    RequestType<3> = 'ALL'
                    RequestType<4> = 'ECB'
                    RequestType<4,2> = 'END'
                    AA.Framework.GetArrangementAccountId(Y.AA.ID, accountId, Currency, ReturnError)   ;*To get Arrangement Account
                    Y.SYSTEMDATE = EB.SystemTables.getToday()
                    AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
                    Y.OUTSTAND.AMT = ABS(BalDetails<4>)
                    
                    Y.TOT.ASSINGMNENT.REF = R.DR<LC.Contract.Drawings.TfDrAssignmentRef>
                    Y.TOT.ASSING.CR.ACC = R.DR<LC.Contract.Drawings.TfDrAssnCrAcct>
                    Y.TOT.ASSN.AMT = R.DR<LC.Contract.Drawings.TfDrAssnAmount>
                    Y.FCB.DATE = R.DR<LC.Contract.Drawings.TfDrValueDate>
                    Y.FCB.DR.ID = Y.BTB.DR.ID
                    Y.BILL.NO = Y.BTB.LC.NO
                    Y.FCB.CREDIT = 0
                    Y.FCB.COUNT = DCOUNT(Y.TOT.ASSINGMNENT.REF,VM)
                    FOR U = 1 TO Y.FCB.COUNT
                        Y.ASSINGMNENT.REF = Y.TOT.ASSINGMNENT.REF<1,U>
                        Y.AC.ID = Y.TOT.ASSING.CR.ACC<1,U>
                        EB.DataAccess.FRead(FN.AC,Y.AC.ID,R.AC,F.AC,ERR.AC)
                        Y.CATEGORY = R.AC<AC.AccountOpening.Account.Category>
                        IF Y.ASSINGMNENT.REF EQ 'TPRECV' AND Y.CATEGORY EQ '13080' THEN
                            Y.FCB.DEBIT = Y.FCB.DEBIT + Y.TOT.ASSN.AMT<1,U>
                        END
                    NEXT U
                    Y.FCB.BALANCE = Y.FCB.BALANCE - Y.FCB.DEBIT
                    Y.DATA<-1> = Y.ID:'*':Y.DATE.OF.LIEN:'*':Y.CONTRACT.NO:'*':Y.CONTRACT.VALUE:'*':Y.REPLACEMENT:'*':Y.COLL.WITHOUT.LC.VALUE:'*':Y.BALANCE.VALUE:'*':Y.TENOR:'*':Y.DATE.OF.SHIPMENT:'*':Y.EXPIRY.DATE:'*':Y.BUYER.COUNTRY:'*':Y.ITEM.NO:'*':Y.QUANTITY:'*':Y.UNIT.PRICE:'*':Y.DR.ID:'*':Y.EXP.BILL.NO:'*':Y.BOOKING.DATE:'*':Y.VALUE:'*':Y.MAT.DATE:'*':Y.REALIZED.VALUE:'*':Y.REALIZED.DATE:'*':Y.BTB.TF.NO:'*':Y.BTB.LC.NO:'*':Y.VALUE.IN.FC:'*':Y.ITEM:'*':Y.BTB.DR.ID:'*':Y.DRAWING.VALUE:'*':Y.BTB.MAT.DATE:'*':Y.PAYMENT.DATE:'*':Y.AA.ID:'*':Y.TYPE.OF.FINANCE:'*':Y.BTB.DR.ID:'*':Y.AA.START.DATE:'*':Y.AMOUNT:'*':Y.EXP.DATE:'*':Y.ADJUST.AMT:'*':Y.DATE.OF.ADJ:'*':Y.OUTSTAND.AMT:'*':Y.FCB.DATE:'*':Y.FCB.DR.ID:'*':Y.BILL.NO:'*':Y.FCB.DEBIT:'*':Y.FCB.CREDIT:'*':Y.FCB.BALANCE
*                                   1             2                   3                   4                   5                       6                   7                  8                9                   10              11                  12             13              14          15              16              17           18         19              20                     21                 22              23               24             25          26                27                  28                   29              30              31                  32               33                 34             35         36                  37                  38           39              40              41              42              43              44
                    Y.FCB.DEBIT = ''
                NEXT S
            END
        NEXT Q
    REPEAT
RETURN

*-----------
ELC.REPLACE:
*-----------
    EB.DataAccess.FRead(FN.LC,Y.ELC.RECORD.NO,R.LC,F.LC,ERR.LC)
    Y.ID = Y.ELC.RECORD.NO
    Y.DATE.OF.LIEN = R.LC<LC.Contract.LetterOfCredit.TfLcBookingDate>
    Y.CONTRACT.NO = R.LC<LC.Contract.LetterOfCredit.TfLcExternalReference>
    Y.CONTRACT.VALUE = 0
    Y.REPLACEMENT = R.LC<LC.Contract.LetterOfCredit.TfLcLcAmount>
    Y.COLL.WITHOUT.LC.VALUE = 0
    Y.BALANCE.VALUE = ABS(Y.BALANCE.VALUE - Y.REPLACEMENT)
    Y.TENOR = R.LC<LC.Contract.LetterOfCredit.TfLcTenor>
    Y.DATE.OF.SHIPMENT = ''
    Y.EXPIRY.DATE = R.LC<LC.Contract.LetterOfCredit.TfLcAdviceExpiryDate>
    Y.BUYER.COUNTRY = R.LC<LC.Contract.LetterOfCredit.TfLcBeneficiary>
    Y.ITEM.NO = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.UNIT.POS>
    Y.QUANTITY = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.QUANTITY.POS>
    Y.UNIT.PRICE = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.UNIT.PRICE.POS>
    Y.ELC.DR.COUNT = DCOUNT(Y.VM.ELC.DR.REFNO,SM)
    FOR M = 1 TO Y.ELC.DR.COUNT
        Y.DR.ID = Y.VM.ELC.DR.REFNO<1,1,M>
        Y.AA.ID = Y.VM.ELC.AA.REFNO<1,1,M>
        IF M GT 1 THEN
            GOSUB SCT.REFRESH
        END
        EB.DataAccess.FRead(FN.DR,Y.DR.ID,R.DR,F.DR,ERR.DR)
        Y.DR.TYPE = R.DR<LC.Contract.Drawings.TfDrDrawingType>
        Y.EXP.ID = R.DR<LC.Contract.Drawings.TfDrLocalRef><1,Y.LT.TF.EXP.NO.POS>
        LOCATE Y.DR.TYPE IN Y.DR.TYPE.LIST<1,1> SETTING Y.DR.TYPE.POS THEN
            EB.DataAccess.FRead(FN.EXP,Y.EXP.ID,R.EXP,F.EXP,ERR.EXP)
            Y.EXP.BILL.NO = R.EXP<EXP.BILL.OF.EXP.NO>
            Y.BOOKING.DATE = R.DR<LC.Contract.Drawings.TfDrBookingDate>
            Y.VALUE = R.DR<LC.Contract.Drawings.TfDrDocumentAmount>
            Y.MAT.DATE = R.DR<LC.Contract.Drawings.TfDrMaturityReview>
            LOCATE Y.DR.TYPE IN Y.R.DR.TYPE<1,1> SETTING Y.R.DR.TYPE.POS THEN
                Y.REALIZED.VALUE = R.EXP<EXP.EXP.REALIZED.AMT>
                Y.REALIZED.DATE = R.EXP<EXP.EXP.REALIZED.DATE>
            END ELSE
                Y.REALIZED.VALUE = ''
                Y.REALIZED.DATE = ''
            END
        END
        EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,ERR.AA)
        Y.PRODUCT = R.AA<AA.Framework.Arrangement.ArrProduct>
        Y.TYPE.OF.FINANCE = Y.PRODUCT
        Y.AA.START.DATE = R.AA<AA.Framework.Arrangement.ArrStartDate>
        EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,ERR.AA.AC)
        PROP.CLASS = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.AMOUNT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        Y.EXP.DATE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
        Y.ADJUST.AMT = 0
        Y.DATE.OF.ADJ = ''
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        AA.Framework.GetArrangementAccountId(Y.AA.ID, accountId, Currency, ReturnError)   ;*To get Arrangement Account
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.OUTSTAND.AMT = ABS(BalDetails<4>)
        GOSUB FCB.DATA
        Y.DATA<-1> = Y.ID:'*':Y.DATE.OF.LIEN:'*':Y.CONTRACT.NO:'*':Y.CONTRACT.VALUE:'*':Y.REPLACEMENT:'*':Y.COLL.WITHOUT.LC.VALUE:'*':Y.BALANCE.VALUE:'*':Y.TENOR:'*':Y.DATE.OF.SHIPMENT:'*':Y.EXPIRY.DATE:'*':Y.BUYER.COUNTRY:'*':Y.ITEM.NO:'*':Y.QUANTITY:'*':Y.UNIT.PRICE:'*':Y.DR.ID:'*':Y.EXP.BILL.NO:'*':Y.BOOKING.DATE:'*':Y.VALUE:'*':Y.MAT.DATE:'*':Y.REALIZED.VALUE:'*':Y.REALIZED.DATE:'*':Y.BTB.TF.NO:'*':Y.BTB.LC.NO:'*':Y.VALUE.IN.FC:'*':Y.ITEM:'*':Y.BTB.DR.ID:'*':Y.DRAWING.VALUE:'*':Y.BTB.MAT.DATE:'*':Y.PAYMENT.DATE:'*':Y.AA.ID:'*':Y.TYPE.OF.FINANCE:'*':Y.BTB.DR.ID:'*':Y.AA.START.DATE:'*':Y.AMOUNT:'*':Y.EXP.DATE:'*':Y.ADJUST.AMT:'*':Y.DATE.OF.ADJ:'*':Y.OUTSTAND.AMT:'*':Y.FCB.DATE:'*':Y.FCB.DR.ID:'*':Y.BILL.NO:'*':Y.FCB.DEBIT:'*':Y.FCB.CREDIT:'*':Y.FCB.BALANCE
*                     1             2                   3                   4                   5                       6                   7                  8                9                   10              11                  12             13           14             15              16              17              18              19              20                  21                 22           23                  24              25         26               27                  28              29              30              31                  32               33              34             35               36              37                     38                39             40              41              42           43                 44
        Y.FCB.CREDIT = ''
    NEXT M
RETURN

*-------------
ELC.RECORDING:
*-------------
    EB.DataAccess.FRead(FN.LC,Y.ELC.RECORD.NO,R.LC,F.LC,ERR.LC)
    Y.ID = Y.ELC.RECORD.NO
    Y.DATE.OF.LIEN = R.LC<LC.Contract.LetterOfCredit.TfLcBookingDate>
    Y.CONTRACT.NO = R.LC<LC.Contract.LetterOfCredit.TfLcExternalReference>
    Y.CONTRACT.VALUE = R.LC<LC.Contract.LetterOfCredit.TfLcLcAmount>
    Y.REPLACEMENT = 0
    Y.COLL.WITHOUT.LC.VALUE = 0
    Y.BALANCE.VALUE = 0
    Y.TENOR = R.LC<LC.Contract.LetterOfCredit.TfLcTenor>
    Y.DATE.OF.SHIPMENT = ''
    Y.EXPIRY.DATE = R.LC<LC.Contract.LetterOfCredit.TfLcAdviceExpiryDate>
    Y.BUYER.COUNTRY = R.LC<LC.Contract.LetterOfCredit.TfLcBeneficiary>
    Y.ITEM.NO = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.UNIT.POS>
    Y.QUANTITY = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.QUANTITY.POS>
    Y.UNIT.PRICE = R.LC<LC.Contract.LetterOfCredit.TfLcLocalRef,Y.UNIT.PRICE.POS>
    Y.ELC.DR.COUNT = DCOUNT(Y.VM.ELC.DR.REFNO,SM)
    FOR M = 1 TO Y.ELC.DR.COUNT
        Y.DR.ID = Y.VM.ELC.DR.REFNO<1,1,M>
        Y.AA.ID = Y.VM.ELC.AA.REFNO<1,1,M>
        IF M GT 1 THEN
            GOSUB SCT.REFRESH
        END
        EB.DataAccess.FRead(FN.DR,Y.DR.ID,R.DR,F.DR,ERR.DR)
        Y.DR.TYPE = R.DR<LC.Contract.Drawings.TfDrDrawingType>
        Y.EXP.ID = R.DR<LC.Contract.Drawings.TfDrLocalRef><1,Y.LT.TF.EXP.NO.POS>
        LOCATE Y.DR.TYPE IN Y.DR.TYPE.LIST<1,1> SETTING Y.DR.TYPE.POS THEN
            EB.DataAccess.FRead(FN.EXP,Y.EXP.ID,R.EXP,F.EXP,ERR.EXP)
            Y.EXP.BILL.NO = R.EXP<EXP.BILL.OF.EXP.NO>
            Y.BOOKING.DATE = R.DR<LC.Contract.Drawings.TfDrBookingDate>
            Y.VALUE = R.DR<LC.Contract.Drawings.TfDrDocumentAmount>
            Y.MAT.DATE = R.DR<LC.Contract.Drawings.TfDrMaturityReview>
            LOCATE Y.DR.TYPE IN Y.R.DR.TYPE<1,1> SETTING Y.R.DR.TYPE.POS THEN
                Y.REALIZED.VALUE = R.EXP<EXP.EXP.REALIZED.AMT>
                Y.REALIZED.DATE = R.EXP<EXP.EXP.REALIZED.DATE>
            END ELSE
                Y.REALIZED.VALUE = ''
                Y.REALIZED.DATE = ''
            END
        END
        EB.DataAccess.FRead(FN.AA,Y.AA.ID,R.AA,F.AA,ERR.AA)
        Y.PRODUCT = R.AA<AA.Framework.Arrangement.ArrProduct>
        Y.TYPE.OF.FINANCE = Y.PRODUCT
        Y.AA.START.DATE = R.AA<AA.Framework.Arrangement.ArrStartDate>
        EB.DataAccess.FRead(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,ERR.AA.AC)
        PROP.CLASS = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.AMOUNT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        Y.EXP.DATE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
        Y.ADJUST.AMT = 0
        Y.DATE.OF.ADJ = ''
        BaseBalance = 'CURACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        AA.Framework.GetArrangementAccountId(Y.AA.ID, accountId, Currency, ReturnError)   ;*To get Arrangement Account
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.OUTSTAND.AMT = ABS(BalDetails<4>)
        GOSUB FCB.DATA
        Y.DATA<-1> = Y.ID:'*':Y.DATE.OF.LIEN:'*':Y.CONTRACT.NO:'*':Y.CONTRACT.VALUE:'*':Y.REPLACEMENT:'*':Y.COLL.WITHOUT.LC.VALUE:'*':Y.BALANCE.VALUE:'*':Y.TENOR:'*':Y.DATE.OF.SHIPMENT:'*':Y.EXPIRY.DATE:'*':Y.BUYER.COUNTRY:'*':Y.ITEM.NO:'*':Y.QUANTITY:'*':Y.UNIT.PRICE:'*':Y.DR.ID:'*':Y.EXP.BILL.NO:'*':Y.BOOKING.DATE:'*':Y.VALUE:'*':Y.MAT.DATE:'*':Y.REALIZED.VALUE:'*':Y.REALIZED.DATE:'*':Y.BTB.TF.NO:'*':Y.BTB.LC.NO:'*':Y.VALUE.IN.FC:'*':Y.ITEM:'*':Y.BTB.DR.ID:'*':Y.DRAWING.VALUE:'*':Y.BTB.MAT.DATE:'*':Y.PAYMENT.DATE:'*':Y.AA.ID:'*':Y.TYPE.OF.FINANCE:'*':Y.BTB.DR.ID:'*':Y.AA.START.DATE:'*':Y.AMOUNT:'*':Y.EXP.DATE:'*':Y.ADJUST.AMT:'*':Y.DATE.OF.ADJ:'*':Y.OUTSTAND.AMT:'*':Y.FCB.DATE:'*':Y.FCB.DR.ID:'*':Y.BILL.NO:'*':Y.FCB.DEBIT:'*':Y.FCB.CREDIT:'*':Y.FCB.BALANCE
*                     1             2                   3                   4                   5                       6                   7                  8                9                   10              11                  12             13           14             15              16              17              18              19              20                  21                 22                23              24             25         26               27                  28                   29             30              31                  32               33              34             35               36              37               38                    39           40                 41           42              43              44
        Y.FCB.CREDIT = ''
    NEXT M
RETURN
*--------
FCB.DATA:
*--------
    Y.TOT.ASSINGMNENT.REF = R.DR<LC.Contract.Drawings.TfDrAssignmentRef>
    Y.TOT.ASSING.CR.ACC = R.DR<LC.Contract.Drawings.TfDrAssnCrAcct>
    Y.TOT.ASSN.AMT = R.DR<LC.Contract.Drawings.TfDrAssnAmount>
    Y.FCB.DATE = R.DR<LC.Contract.Drawings.TfDrValueDate>
    Y.FCB.DR.ID = Y.DR.ID
    Y.BILL.NO = Y.EXP.BILL.NO
    Y.FCB.DEBIT = 0
    Y.FCB.COUNT = DCOUNT(Y.TOT.ASSINGMNENT.REF,VM)
    FOR U = 1 TO Y.FCB.COUNT
        Y.ASSINGMNENT.REF = Y.TOT.ASSINGMNENT.REF<1,U>
        Y.AC.ID = Y.TOT.ASSING.CR.ACC<1,U>
        EB.DataAccess.FRead(FN.AC,Y.AC.ID,R.AC,F.AC,ERR.AC)
        Y.CATEGORY = R.AC<AC.AccountOpening.Account.Category>
        IF Y.ASSINGMNENT.REF EQ 'TPPAY' AND Y.CATEGORY EQ '13080' THEN
            Y.FCB.CREDIT = Y.FCB.CREDIT + Y.TOT.ASSN.AMT<1,U>
        END
    NEXT U
    Y.FCB.BALANCE = Y.FCB.BALANCE + Y.FCB.CREDIT
RETURN
*-----------------
BTB.PROCESS.WO.DR:
*-----------------
    Y.BTB.DR.ID = ''
    Y.DRAWING.VALUE = ''
    Y.BTB.MAT.DATE = ''
    Y.PAYMENT.DATE = ''
    Y.AA.ID = ''
    Y.TYPE.OF.FINANCE = ''
    Y.AA.START.DATE = ''
    Y.AMOUNT = ''
    Y.EXP.DATE = ''
    Y.ADJUST.AMT = ''
    Y.DATE.OF.ADJ = ''
    Y.OUTSTAND.AMT = ''
    Y.FCB.DATE = ''
    Y.FCB.DR.ID = ''
    Y.BILL.NO = ''
    Y.FCB.DEBIT = ''
    Y.FCB.CREDIT = ''
    Y.FCB.BALANCE = Y.FCB.BALANCE
    Y.DATA<-1> = Y.ID:'*':Y.DATE.OF.LIEN:'*':Y.CONTRACT.NO:'*':Y.CONTRACT.VALUE:'*':Y.REPLACEMENT:'*':Y.COLL.WITHOUT.LC.VALUE:'*':Y.BALANCE.VALUE:'*':Y.TENOR:'*':Y.DATE.OF.SHIPMENT:'*':Y.EXPIRY.DATE:'*':Y.BUYER.COUNTRY:'*':Y.ITEM.NO:'*':Y.QUANTITY:'*':Y.UNIT.PRICE:'*':Y.DR.ID:'*':Y.EXP.BILL.NO:'*':Y.BOOKING.DATE:'*':Y.VALUE:'*':Y.MAT.DATE:'*':Y.REALIZED.VALUE:'*':Y.REALIZED.DATE:'*':Y.BTB.TF.NO:'*':Y.BTB.LC.NO:'*':Y.VALUE.IN.FC:'*':Y.ITEM:'*':Y.BTB.DR.ID:'*':Y.DRAWING.VALUE:'*':Y.BTB.MAT.DATE:'*':Y.PAYMENT.DATE:'*':Y.AA.ID:'*':Y.TYPE.OF.FINANCE:'*':Y.BTB.DR.ID:'*':Y.AA.START.DATE:'*':Y.AMOUNT:'*':Y.EXP.DATE:'*':Y.ADJUST.AMT:'*':Y.DATE.OF.ADJ:'*':Y.OUTSTAND.AMT'*':Y.FCB.DATE:'*':Y.FCB.DR.ID:'*':Y.BILL.NO:'*':Y.FCB.DEBIT:'*':Y.FCB.CREDIT:'*':Y.FCB.BALANCE
*                 1             2                   3                   4                   5                       6                   7                  8                9                   10              11                  12             13           14             15              16              17              18              19              20                  21                 22              23               24             25          26                27                  28              29              30              31                  32               33                 34             35                 36              37              38                39           40                 41           42              43              44
*-----------
SCT.REFRESH:
*-----------
    Y.ID = ''
    Y.DATE.OF.LIEN = ''
    Y.CONTRACT.NO = ''
    Y.CONTRACT.VALUE = ''
    Y.REPLACEMENT = ''
    Y.COLL.WITHOUT.LC.VALUE = ''
    Y.BALANCE.VALUE = ''
    Y.TENOR = ''
    Y.DATE.OF.SHIPMENT = ''
    Y.EXPIRY.DATE = ''
    Y.BUYER.COUNTRY = ''
    Y.ITEM.NO = ''
    Y.QUANTITY = ''
    Y.UNIT.PRICE = ''
RETURN

*--------------
BTB.LC.REFRESH:
*--------------
    Y.BTB.TF.NO = ''
    Y.BTB.LC.NO = ''
    Y.VALUE.IN.FC = ''
    Y.ITEM = ''
RETURN
*-----------------------
SCT.ELC.REC.OUT.REFRESH:
*-----------------------
    Y.ID = ''
    Y.DATE.OF.LIEN = ''
    Y.CONTRACT.NO = ''
    Y.CONTRACT.VALUE = ''
    Y.REPLACEMENT = ''
    Y.COLL.WITHOUT.LC.VALUE = ''
    Y.BALANCE.VALUE = ''
    Y.TENOR = ''
    Y.DATE.OF.SHIPMENT = ''
    Y.EXPIRY.DATE = ''
    Y.BUYER.COUNTRY = ''
    Y.ITEM.NO = ''
    Y.QUANTITY = ''
    Y.UNIT.PRICE = ''
    Y.DR.ID = ''
    Y.EXP.BILL.NO = ''
    Y.BOOKING.DATE = ''
    Y.VALUE = ''
    Y.MAT.DATE = ''
    Y.REALIZED.VALUE = ''
    Y.REALIZED.DATE = ''
RETURN
Y.DATA = Y.DATA
END
