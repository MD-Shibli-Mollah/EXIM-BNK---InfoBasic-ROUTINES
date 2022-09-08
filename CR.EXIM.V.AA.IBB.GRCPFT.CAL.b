* @ValidationCode : MjoxMzQzMjg2MDkxOkNwMTI1MjoxNTkwNTExMTEwNTI3OnRvd2hpZHRpcHU6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 26 May 2020 22:38:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.AA.IBB.GRCPFT.CAL
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.Foundation
    $USING AA.Fees
    $USING EB.API
    $USING AC.Fees
    $USING AA.Interest
    $USING AA.TermAmount
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

INITIALISE:
    localFieldsFt = 'LT.CH.GRC.PRD': @VM :'LT.CH.GRC.RC.MN'
    EB.Foundation.MapLocalFields("AA.PRD.DES.CHARGE", localFieldsFt, localfieldPos)
    GracePrdEndDtPos = localfieldPos<1,1>
    GraceRecMnthPos = localfieldPos<1,2>
RETURN

OPENFILES:
RETURN

PROCESS:
    ChargeLclRef = EB.SystemTables.getRNew(AA.Fees.Charge.LocalRef)
    GracePrdEndDt = ChargeLclRef<1,GracePrdEndDtPos>
    GraceRecMnth = ChargeLclRef<1,GraceRecMnthPos>
    
    Idarrangementcomp = c_aalocArrId
    Idpropertyclass = ''
    Idproperty = 'GRACEPFT'
    Effectivedate = ''
    AA.Framework.GetArrangementConditions(Idarrangementcomp, Idpropertyclass, Idproperty, Effectivedate, Returnids, Returnconditions, Returnerror)
    GracePftCon = RAISE(Returnconditions)
    GracePftEfRate = GracePftCon<AA.Interest.Interest.IntEffectiveRate>
    
    Idpropertyclass2 = ''
    Idproperty2 = 'COMMITMENT'
    Effectivedate2 = ''
    AA.Framework.GetArrangementConditions(Idarrangementcomp, Idpropertyclass2, Idproperty2, Effectivedate2, Returnids2, Returnconditions2, Returnerror2)
    CommtmntCon = RAISE(Returnconditions2)
    TermAmt = CommtmntCon<AA.TermAmount.TermAmount.AmtAmount>
    
    Yregion = ''
    CALL CDD('',c_aalocActivityEffDate,GracePrdEndDt,Ydays)
*EB.API.Cdd(c_aalocActivityEffDate, GracePrdEndDt, Ydays, Yregion)
    TotGrcPrftCol = (((TermAmt * GracePftEfRate) / 100) / 360) * Ydays
    MnthGrcPrft = TotGrcPrftCol / GraceRecMnth
    
    FMT(EB.SystemTables.setRNew(AA.Fees.Charge.FixedAmount, MnthGrcPrft),'R2*10')
    
    GOSUB WRITE.FILE
RETURN

WRITE.FILE:
    WriteData = ''
    WriteData = c_aalocActivityEffDate:'-':Idarrangementcomp:'-':GracePrdEndDt:'-':GracePftEfRate:'-':TermAmt:'-':GraceRecMnth:'-':Ydays:'-':TotGrcPrftCol:'-':MnthGrcPrft
*    :'-':DateDiff:'-':RoundAmts
*   WriteData = Idarrangementcomp:'-':Returnerror:'-':Returnconditions:'-':ArrRecord:'-':PropertyList
    FileName = 'TEST.csv'
    FilePath = 'EXIM.DATA'
    OPENSEQ FilePath,FileName TO FileOutput THEN NULL
    ELSE
        CREATE FileOutput ELSE
        END
    END
    WRITESEQ WriteData APPEND TO FileOutput ELSE
        CLOSESEQ FileOutput
    END
    CLOSESEQ FileOutput
RETURN
END
