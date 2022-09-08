* @ValidationCode : MjotMTIzODgzMTc2MTpDcDEyNTI6MTU4MDAyNDA2NDM0ODpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 26 Jan 2020 13:34:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE COM.FUNCTION
*PROGRAM COM.FUNCTION
*-----------------------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_GTS.COMMON
    $INSERT I_F.BD.CHG.CHECK
    
    
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Updates
    $USING EB.Foundation
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****

    FN.BD.CHECK = 'F.BD.CHG.CHECK'
    F.BD.CHECK = ''
    FN.COM = 'F.COMPANY'
    F.COM = ''
    Y.FREAD.CNT = 0
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHECK,F.BD.CHECK)
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

********
PROCESS:
********
    
*-----------------------------------------------------------------------------------------
    Y.AF = EB.SystemTables.getAf()
    Y.APP = EB.SystemTables.getApplication()
    Y.AS = EB.SystemTables.getAs()
    Y.AV = EB.SystemTables.getAv()
    Y.A = EB.SystemTables.getA()
    Y.CS = EB.SystemTables.getClearScreen()
    Y.COMI = EB.SystemTables.getComi()
    Y.COMIE = EB.SystemTables.getComiEnri()
    Y.E = EB.SystemTables.getE()
    Y.ECOMI = EB.SystemTables.getEcomi()
    Y.ET = EB.SystemTables.getEtext()
    Y.IDCOM = EB.SystemTables.getIdCompany()
    Y.IDNEW = EB.SystemTables.getIdNew()
    Y.IDNEWL = EB.SystemTables.getIdNewLast()
    Y.IDOLD = EB.SystemTables.getIdOld()
    Y.OPERATOR = EB.SystemTables.getOperator()
    Y.VERSION = EB.SystemTables.getPgmVersion()
    Y.RCOMPANY = EB.SystemTables.getRCompany(BD.CHECK.CHG.AMT)
    Y.RNEW = EB.SystemTables.getRNew(BD.CHECK.SLAB.AMT)
    Y.RNEWLAST = EB.SystemTables.getRNewLast(BD.CHECK.SLAB.AMT)
    Y.ROLD = EB.SystemTables.getROld(BD.CHECK.SLAB.AMT)
    Y.RUSER = EB.SystemTables.getRUser()
    Y.RVERSION = EB.SystemTables.getRVersion(BD.CHECK.CHG.AMT)
    Y.RETURNCOMI = EB.SystemTables.getReturnComi()
    Y.TEXT = EB.SystemTables.getText()
    Y.TODAY = EB.SystemTables.getToday()
    Y.V = EB.SystemTables.getV()
    Y.ACTION = EB.SystemTables.getVAction()
    Y.FUNCTION = EB.SystemTables.getVFunction()
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
    EB.DataAccess.FDelete(Fileid,VKey)
    EB.DataAccess.FRead(Fileid,VKey,Rec,FFileid,Er)
    EB.DataAccess.FReadHistory(HistFileName,HisId,HistRec,HistFile,Yerror)
    EB.DataAccess.FReadu(Fileid,VKey,Rec,FFileid,Er,Retry)
    EB.DataAccess.FRelease(Fileid,VKey,FFileid)
    EB.DataAccess.FWrite(Fileid,VKey,Rec)
    EB.DataAccess.ReadHistoryRec(HistFile,HisId,HistRec,Yerror)
    EB.DataAccess.Readlist(SelectStatement,KeyList,ListName,Selected,SystemReturnCode)
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
    EB.Updates.MultiGetLocRef(ApplArr,FieldnameArr,PosArr)
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
    EB.Foundation.MapLocalFields(Appl,FieldRef,RetArr)
    EB.Foundation.BrowserPositions.Exists()
*-----------------------------------------------------------------------------------------
    DEBUG
    Y.DIR ='EXIM.BP'
    OPEN Y.DIR TO JBASE.DIR ELSE STOP
    OPEN "EXIM.BP" TO F.DESTINATION ELSE
        CMD = "CREATE.FILE EXIM.BP TYPE=UD"
        EXECUTE CMD
        OPEN "EXIM.BP" TO F.DESTINATION ELSE
            CRT "OPENING OF EXIM.BP FAILED"
        END
    END
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
    DEBUG
    SEL.CMD = 'SELECT EXIM.BP'

    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECORD,RET.CODE)
    LOOP
        DEBUG
        REMOVE Y.FILE.NAME FROM SEL.LIST SETTING Y.POS
    WHILE Y.FILE.NAME:Y.POS
        READ FILE.VALUES FROM JBASE.DIR,Y.FILE.NAME THEN
            Y.FREAD.CNT = DCOUNT(FILE.VALUES,'EB.DataAccess.FRead')
        END
    REPEAT
    
*-----------------------------------------------------------------------------------------
RETURN
END
