* @ValidationCode : MjoxNDM0NTczODQ6Q3AxMjUyOjE1ODAwMzE2NTM2NDU6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Jan 2020 15:40:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
PROGRAM CM.FUNCTION.CHECK
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_GTS.COMMON
    $INSERT I_F.BD.CHG.CHECK

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.COM = 'F.COMPANY'
    F.COM = ''
    
    Y.FREAD.CNT = 0
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

********
PROCESS:
********
    
*-----------------------------------------------------------------------------------------
    COM.TYPE="EXECUTE"
    RESULT=''
    RET.CODE=''

    CALL SYSTEM.CALL(COM.TYPE,"UNIX",'pwd',RESULT,RET.CODE)
    PRINT RESULT

    Y.DIR ='EXIM.BP'
    OPEN Y.DIR TO JBASE.DIR ELSE STOP
    
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
    
    SEL.CMD = 'SELECT EXIM.BP'

    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECORD,RET.CODE)
    LOOP
     
        REMOVE Y.FILE.NAME FROM SEL.LIST SETTING Y.POS
    WHILE Y.FILE.NAME:Y.POS
        READ FILE.VALUES FROM JBASE.DIR,Y.FILE.NAME THEN
            PRINT "ROUTINE NAME : ": Y.FILE.NAME
            PRINT "NO of EB.DataAccess.FRead :" : COUNT(FILE.VALUES,'EB.DataAccess.FRead')
            PRINT "NO of F.READ :": COUNT(FILE.VALUES,'F.READ')
            PRINT "NO of EB.DataAccess.FWrite :": COUNT(FILE.VALUES,'EB.DataAccess.FWrite')
            PRINT "NO of F.Write :" : COUNT(FILE.VALUES,'F.WRITE')
            PRINT "NO of Write :" : COUNT(FILE.VALUES,'WRITE')
            PRINT "NO of EB.TransactionControl.JournalUpdate :" : COUNT(FILE.VALUES,'EB.TransactionControl.JournalUpdate')
            PRINT "NO of EB.DataAccess.Readlist :" : COUNT(FILE.VALUES,'EB.DataAccess.Readlist')
            PRINT "NO of EB.READLIST :" : COUNT(FILE.VALUES,'EB.READLIST')
            PRINT "NO of IF :" : COUNT(FILE.VALUES,'IF')
            PRINT "NO of FOR :" : COUNT(FILE.VALUES,'FOR')
            PRINT "NO of WHILE :" : COUNT(FILE.VALUES,'WHILE')
            PRINT "********************************************"
        END
    REPEAT
*-----------------------------------------------------------------------------------------

RETURN
END
