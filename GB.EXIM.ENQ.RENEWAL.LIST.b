* @ValidationCode : Mjo3Mzk3NDcwNjpDcDEyNTI6MTU4NTQ3NjM0MTI1ODp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 29 Mar 2020 16:05:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ENQ.RENEWAL.LIST(Y.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING AA.PaymentSchedule
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Account
    $USING AA.Interest
    $USING EB.LocalReferences
    $USING AC.AccountOpening
    $USING AA.ChangeProduct

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    LOCATE 'BRANCH.ID' IN D.FIELDS<1> SETTING BR.ID.POS ELSE
    END
    LOCATE 'DATE.ID' IN D.FIELDS<1> SETTING DATE.ID.POS ELSE
    END
    Y.BR.ID = ENQ.SELECTION<4,BR.ID.POS>
    Y.DATE = ENQ.SELECTION<4,DATE.ID.POS>
    Y.DT.LEN = LEN(Y.DATE)
    IF Y.DT.LEN GT 8 THEN
        Y.DATE.1 = Y.DATE[1,8]
        Y.DATE.2 = Y.DATE[10,8]
    END ELSE
        Y.DATE.3 = Y.DATE
    END
    FN.AC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AC.DETAILS = ''
    
    FN.AA.BILL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DET = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AC.DETAILS, F.AC.DETAILS)
    EB.DataAccess.Opf(FN.AA.BILL.DET, F.AA.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR, F.AA.ARR)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
RETURN

PROCESS:
*  BEGIN CASE
*     CASE Y.BR.ID EQ '' AND Y.DATE EQ ''
    SEL.CMD = 'SELECT ':FN.AC.DETAILS
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
  
    GOSUB GET.VALUE
*        CASE Y.BR.ID EQ '' AND Y.DATE NE ''
*            SEL.CMD = 'SELECT ':FN.AC.DETAILS:' WITH LAST.RENEW.DATE EQ ':Y.DATE
*            EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
*            GOSUB GET.VALUE
*        CASE Y.DATE EQ '' AND Y.BR.ID NE ''
*            SEL.CMD = 'SELECT ':FN.AC.DETAILS
*            EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
*            Y.COMPANY = EB.SystemTables.getIdCompany()
*            GOSUB GET.VALUE
*    END CASE
RETURN
GET.VALUE:
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.FILED.NAME = 'LT.SPCL.INSTRC'
    Y.FIELD.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.FILED.NAME,Y.FIELD.POS)
    LOOP
        REMOVE Y.AA.DET.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.DET.ID:POS
        EB.DataAccess.FRead(FN.AC.DETAILS, Y.AA.DET.ID, REC.ACC.DET, F.AC.DETAILS, Er)
        Y.RENEWAL.DT.1 = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
        Y.TOT.RENW = DCOUNT(Y.RENEWAL.DT.1,VM)
        Y.RENEWAL.DT = Y.RENEWAL.DT.1<1,Y.TOT.RENW>
        IF Y.RENEWAL.DT NE '' THEN
            IF Y.DATE.3 NE '' THEN
                GOSUB DATE.SINGLE
            END
            ELSE
                GOSUB DATE.DOUBLE
            END
        END
    REPEAT
RETURN

DATE.SINGLE:
                
    Y.ARR.ID = Y.AA.DET.ID
*----------------------ACCOUNT PROPERTY READ-----------------------------------------------------------
    PROP.CLASS.1 = 'ACCOUNT'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES.1)
    Y.ACC.ID = R.ACC.REC<AA.Account.Account.AcAccountReference>
    EB.DataAccess.FRead(FN.ACC, Y.ACC.ID, REC.ACC, F.ACC, Er.RRR)
    Y.ACC.TITLE = REC.ACC<AC.AccountOpening.Account.AccountTitleOne>
    Y.SPECIAL.INS.VAL = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.FIELD.POS>
    Y.COM.ID = R.ACC.REC<AA.Account.Account.AcCoCode>
*----------------------------------END----------------------------------------------------
    PROP.CLASS.3 = 'CHANGE.PRODUCT'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.3,PROPERTY,'',RETURN.IDS,RETURN.VALUES.3,ERR.MSG)
    R.ACC.TERM = RAISE(RETURN.VALUES.3)
    Y.TERM = R.ACC.TERM<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
*---------------------------INTEREST PROPERTY READ-----------------------------------------------
    PROP.CLASS.2 = 'INTEREST'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.2,PROPERTY,'',RETURN.IDS,RETURN.VALUES.2,ERR.MSG)
    R.ACC.INT = RAISE(RETURN.VALUES.2)
    Y.INT.RATE = R.ACC.INT<AA.Interest.Interest.IntEffectiveRate>
*--------------------------------------------------------------------------------------------------
    toDate = EB.SystemTables.getToday()
    AA.Framework.GetEcbBalanceAmount(Y.ACC.ID, 'CURACCOUNT', toDate, CUR.BAL, RetError)

    IF Y.BR.ID EQ '' AND Y.RENEWAL.DT EQ Y.DATE.3 THEN
        Y.DATA<-1> = Y.COM.ID:'*':Y.ACC.ID:'*':Y.ACC.TITLE:'*':Y.RENEWAL.DT:'*':CUR.BAL:'*':Y.INT.RATE:'*':Y.TERM:'*':Y.SPECIAL.INS.VAL
*                        1           2             3              4                 5           6              7            8
    END
    ELSE
        IF Y.BR.ID EQ Y.COM.ID AND Y.RENEWAL.DT EQ Y.DATE.3 THEN
            Y.DATA<-1> = Y.COM.ID:'*':Y.ACC.ID:'*':Y.ACC.TITLE:'*':Y.RENEWAL.DT:'*':CUR.BAL:'*':Y.INT.RATE:'*':Y.TERM:'*':Y.SPECIAL.INS.VAL
*                            1           2             3              4                 5           6              7           8
        END
    END
RETURN
    
DATE.DOUBLE:
    Y.ARR.ID = Y.AA.DET.ID
*----------------------ACCOUNT PROPERTY READ-----------------------------------------------------------
    PROP.CLASS.1 = 'ACCOUNT'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES.1)
    Y.ACC.ID = R.ACC.REC<AA.Account.Account.AcAccountReference>
    EB.DataAccess.FRead(FN.ACC, Y.ACC.ID, REC.ACC, F.ACC, Er.RRR)
    Y.ACC.TITLE = REC.ACC<AC.AccountOpening.Account.AccountTitleOne>
    Y.SPECIAL.INS.VAL = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.FIELD.POS>
    Y.COM.ID = R.ACC.REC<AA.Account.Account.AcCoCode>
*----------------------------------END----------------------------------------------------
    PROP.CLASS.3 = 'CHANGE.PRODUCT'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.3,PROPERTY,'',RETURN.IDS,RETURN.VALUES.3,ERR.MSG)
    R.ACC.TERM = RAISE(RETURN.VALUES.3)
    Y.TERM = R.ACC.TERM<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
*---------------------------INTEREST PROPERTY READ-----------------------------------------------
    PROP.CLASS.2 = 'INTEREST'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS.2,PROPERTY,'',RETURN.IDS,RETURN.VALUES.2,ERR.MSG)
    R.ACC.INT = RAISE(RETURN.VALUES.2)
    Y.INT.RATE = R.ACC.INT<AA.Interest.Interest.IntEffectiveRate>
*--------------------------------------------------------------------------------------------------
    toDate = EB.SystemTables.getToday()
    AA.Framework.GetEcbBalanceAmount(Y.ACC.ID, 'CURACCOUNT', toDate, CUR.BAL, RetError)
    
    IF Y.BR.ID EQ '' THEN
        IF Y.RENEWAL.DT GE Y.DATE.1 AND Y.RENEWAL.DT LE Y.DATE.2 THEN
            Y.DATA<-1> = Y.COM.ID:'*':Y.ACC.ID:'*':Y.ACC.TITLE:'*':Y.RENEWAL.DT:'*':CUR.BAL:'*':Y.INT.RATE:'*':Y.TERM:'*':Y.SPECIAL.INS.VAL
*                           1           2             3              4                 5           6              7             8
        END
    END
    ELSE
        IF Y.BR.ID EQ Y.COM.ID THEN
            IF Y.RENEWAL.DT GE Y.DATE.1 AND Y.RENEWAL.DT LE Y.DATE.2 THEN
                Y.DATA<-1> = Y.COM.ID:'*':Y.ACC.ID:'*':Y.ACC.TITLE:'*':Y.RENEWAL.DT:'*':CUR.BAL:'*':Y.INT.RATE:'*':Y.TERM:'*':Y.SPECIAL.INS.VAL
*                               1           2             3              4                 5           6              7                8
            END
        END
    END
RETURN
END