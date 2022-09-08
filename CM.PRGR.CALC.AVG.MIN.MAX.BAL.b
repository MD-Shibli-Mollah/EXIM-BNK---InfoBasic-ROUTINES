* @ValidationCode : Mjo3MzkwNjY0ODM6Q3AxMjUyOjE1NzIyNDIyOTEwNDA6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 Oct 2019 11:58:11
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
* <Rating>255</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE CM.PRGR.CALC.AVG.MIN.MAX.BAL(IN.VAL,BAL.TYPE,CALC.TYPE,OUT.VAL)
*-----------------------------------------------------------------------------

* Subroutine to calculate average balances for accounts
* between two given dates.
* Incoming :
* 			IN.VAL variable = &#1;Account.no, Start date, End date
* 			BAL.TYPE        = AVERAGE or HIGHEST or LOWEST
* 			CALC.TYPE 		= DEBIT-ONLY or CREDIT-ONLY or ABSOLUTE
*
*Outgoing OUT.VAL variable = Days in Credit , Avrg Credit Balance
*                            Days in Debit , Avrg Debit Balance
*                            Number of days at Zreo balance, Minimum
*                            Balance, Maximum Balance
*************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.ACCOUNT
    
*-----------------------------------------------------------------------------
*    CALL LOAD.COMPANY('BD0010001')
*    IN.VAL ='20160301201604301001415000201'
*    BAL.TYPE = 'AVERAGE'
*    CALC.TYPE = 'CREDITONLY'
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
    
    CRT OUT.VAL
RETURN

*************************************************************************
*  Initialise Variables
***************************
*
INIT:
    ACCOUNT.DETAILS = IN.VAL
    OUT.VAL=''
    START.DATE = ACCOUNT.DETAILS[1,8]
    END.DATE = ACCOUNT.DETAILS[9,8]
    ACCOUNT.NO = ACCOUNT.DETAILS[17,13]
    ACCREC = ""
    NO.DAYS = "C"
    ZERO.DAYS = "0"
    DR.DAYS = "0"
    CR.DAYS = "0"
    DR.AV.BAL = "0"
    CR.AV.BAL = "0"
    CURR.DATE = START.DATE
    ACCOUNT.BAL = ""
    START.YRMN = START.DATE[1,6]
    START.DAY = START.DATE[7,2]
    END.YRMN = END.DATE[1,6]
    END.DAY = END.DATE[7,2]
    CURRENCY = ""
    END.FLAG = 0
    CNT = 1

    TOT.CR.BAL = '' ;* CI_10004707s
    TOT.DR.BAL = '' ;* CI_10004707e

    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    
*    FN.ACCT = 'F.ACCT.ACTIVITY'
*    F.ACCT  = ''
    FN.ACCT = 'F.ACCT.BALANCE.ACTIVITY'
    F.ACCT  = ''
    DR.BAL.LAST = ''
    CR.BAL.LAST = ''
    ABS.BAL.LAST= ''
    FIN.BAL = ''
    
RETURN

OPENFILES:
	
	CALL OPF(FN.AC,F.AC)
	CALL OPF(FN.ACCT,F.ACCT)
	
RETURN

PROCESS:

*
*  Check startdate not greater than enddate
*
    IF START.DATE > END.DATE THEN
        ETEXT ="AC.RTN.START.DATE.GT.THAN.END.DATE"
        GOTO PGM.EXIT
    END
*
*  Call routine to extract opening balance
*
    CALL GET.ENQ.BALANCE(ACCOUNT.NO,START.DATE,ACCOUNT.BAL)
*
*  Open and read account file to extract currency
*
    CALL F.READ(FN.AC,ACCOUNT.NO,REC,F.AC,READ.ERR)
    CURRENCY = REC<AC.CURRENCY>

*  Read Acct.Activity recs and locate correct dated entries
*  Open Acct.Activity file, locate correct mnth,year in Acct.Acct

    CALL GET.ACTIVITY.DATES(ACCOUNT.NO, YR.YEARM)

****************************************************
* Main process
****************************************************
    LOCATE START.YRMN IN YR.YEARM<1> BY "AR" SETTING YLOC ELSE
        NULL
    END
    LOOP
        IF YR.YEARM<YLOC> <> "" THEN
*
*  Read Acct.Activity records while valid dates exist
*
            ACCID = ACCOUNT.NO:"-":YR.YEARM<YLOC>
            CALL F.READ(FN.ACCT,ACCID,ACCREC,F.ACCT,READ.ERR)
            IF READ.ERR THEN
                ETEXT ="AC.RTN.NO.AC.ACTIVITY.ON.REC"
                GOTO PGM.EXIT
            END
*
*
*  Process all Acct.Activity record for valid date and call calc process
*
            D.FLAG = 0
            CNT = 1
            LOOP WHILE ACCREC<IC.ACT.DAY.NO,CNT> <> "" AND D.FLAG = 0
                REC.DATE = YR.YEARM<YLOC> : ACCREC<IC.ACT.DAY.NO,CNT>
                IF REC.DATE >= START.DATE AND REC.DATE <= END.DATE THEN
                    GOSUB CALC.FIELDS
                END ELSE
                    IF REC.DATE >= START.DATE THEN
                        REC.DATE = END.DATE
                        D.FLAG = 1
                    END
                END
                CNT += 1
            REPEAT
            YLOC +=1
        END ELSE
            REC.DATE = END.DATE
            END.FLAG = 1
        END
    WHILE END.YRMN GE YR.YEARM<YLOC> AND END.FLAG = 0
    REPEAT
    REC.DATE = END.DATE
    GOSUB CALC.FIELDS
    GOSUB FINAL.CALC
RETURN
*
*-----------------------------------------------------------------------------
*****************************
* Calculate account balances
*  cr bal, dr bal, no of days at dr, cr and zero bal
*****************************
CALC.FIELDS:

    NO.DAYS = "C"
    CALL CDD("",CURR.DATE,REC.DATE,NO.DAYS)
    CURR.DATE = REC.DATE
    NEW.BAL = ACCREC<IC.ACT.BALANCE,CNT>
*
    BEGIN CASE
        CASE ACCOUNT.BAL < 0
            DR.DAYS += NO.DAYS
            DR.BAL = NO.DAYS * ACCOUNT.BAL
            TOT.DR.BAL += DR.BAL
            DR.BAL.LAST<-1> = ACCOUNT.BAL
        CASE ACCOUNT.BAL = "0"
            ZERO.DAYS += NO.DAYS
    
        CASE ACCOUNT.BAL > 0
            CR.DAYS += NO.DAYS
            CR.BAL = NO.DAYS * ACCOUNT.BAL
            TOT.CR.BAL += CR.BAL
            CR.BAL.LAST<-1> = ACCOUNT.BAL
    END CASE
*
    ACCOUNT.BAL = NEW.BAL
RETURN
*
*--------------------------------------------------------------
FINAL.CALC:
 
    BEGIN CASE
  
        CASE BAL.TYPE EQ 'AVERAGE'
* Credit bal - ie av credit bal for tot time in credit
            IF CR.DAYS AND CR.DAYS <> 0 THEN
                CR.AV.BAL = TOT.CR.BAL/CR.DAYS
                CALL EB.ROUND.AMOUNT(CURRENCY,CR.AV.BAL,"","")
            END
* Debit bal - ie av debit bal for total time in debit
            IF DR.DAYS AND DR.DAYS <> 0 THEN
                DR.AV.BAL = TOT.DR.BAL/DR.DAYS
                CALL EB.ROUND.AMOUNT(CURRENCY,DR.AV.BAL,"","")
            END
*
* Convert to O.Data for return to enquiry
*
*    O.DATA = CR.DAYS:">":CR.AV.BAL:">":DR.DAYS:">":DR.AV.BAL:">":ZERO.DAYS
            OUT.VAL= CR.DAYS:">":CR.AV.BAL:">":DR.DAYS:">":DR.AV.BAL:">":ZERO.DAYS:">":"":">":""
    
        CASE BAL.TYPE EQ 'HIGHEST'
            GOSUB CALC.TYPE.FIND
            OUT.VAL= "":">":"":">":"":">":"":">":"":">":"":">":MAXIMUM(FIN.BAL)
      
        CASE BAL.TYPE EQ 'LOWEST'
            GOSUB CALC.TYPE.FIND
            OUT.VAL= "":">":"":">":"":">":"":">":"":">":MINIMUM(FIN.BAL):">":""
    
    END CASE
    
RETURN
*
CALC.TYPE.FIND:


    BEGIN CASE
        CASE CALC.TYPE EQ 'DEBIT-ONLY'
            FIN.BAL = DR.BAL.LAST
              
        CASE CALC.TYPE EQ 'CREDIT-ONLY'
            FIN.BAL = CR.BAL.LAST
    		  
        CASE CALC.TYPE EQ 'ABSOLUTE'
            DR.BAL.CNT = DCOUNT(DR.BAL.LAST,FM)
            FOR I = 1 TO DR.BAL.CNT
                FIN.BAL1<-1> = ABS(DR.BAL.LAST<I>)
            NEXT
            FIN.BAL<-1> = CR.BAL.LAST
            FIN.BAL<-1> = FIN.BAL1
    END CASE
              
RETURN


PGM.EXIT:
    COMI = ""
RETURN
*
*--------------------------------------------------------------
*
END

