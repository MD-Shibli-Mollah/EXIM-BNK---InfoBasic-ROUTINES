* @ValidationCode : MjoyNjQzMjYyMDM6Q3AxMjUyOjE1ODU4MjUwNDUwMzg6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Apr 2020 16:57:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.LI.VALUE.ASSIGN
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING IS.Purchase
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING LI.Config
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
   
******
INIT:
******
    FN.LIMIT = 'F.LIMIT'
    F.LIMIT = ''
   
    FieldPos = ''
    ApplicationName = 'IS.CONTRACT'
    LocalFields = 'LT.LIMIT.AMT':VM:'LT.LI.AVAIL.AMT':VM:'LT.LI.UTIL.AMT':VM:'LT.LIMIT.REF':VM:'LT.AA.PROD.ID'
    EB.Foundation.MapLocalFields(ApplicationName, LocalFields, FieldPos)
    Y.LIMIT.AMT.POS = FieldPos<1,1>
    Y.AVAIL.AMT.POS = FieldPos<1,2>
    Y.UTIL.AMT.POS = FieldPos<1,3>
    Y.LIMIT.POS = FieldPos<1,4>
    Y.AA.PROD.ID.POS = FieldPos<1,5>
    
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.LIMIT,F.LIMIT)
    
RETURN
********
PROCESS:
********
    Y.LIMIT.ID = EB.SystemTables.getComi()
    Y.LIMIT.REF.ID = EB.SystemTables.getRNew(IS.Purchase.Contract.IcLocalRef)<1,Y.LIMIT.POS>
    Y.AA.PROD.ID = EB.SystemTables.getRNew(IS.Purchase.Contract.IcLocalRef)<1,Y.AA.PROD.ID.POS>
    EB.DataAccess.FRead(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,Er.LI)
    Y.LIMIT.AMT = R.LIMIT<LI.Config.Limit.InternalAmount>
    Y.LIMIT.AVAIL.AMT = R.LIMIT<LI.Config.Limit.AvailAmt>
    Y.LIMIT.UTIL.AMT = Y.LIMIT.AMT - Y.LIMIT.AVAIL.AMT
    Y.LOCAL.FIELD = EB.SystemTables.getRNew(LI.Config.Limit.LocalRef)
    Y.LOCAL.FIELD<1, Y.LIMIT.AMT.POS> = Y.LIMIT.AMT
    Y.LOCAL.FIELD<1, Y.AVAIL.AMT.POS> = Y.LIMIT.AVAIL.AMT
    Y.LOCAL.FIELD<1, Y.UTIL.AMT.POS> = Y.LIMIT.UTIL.AMT
    Y.LOCAL.FIELD<1, Y.LIMIT.POS> = Y.LIMIT.REF.ID
    Y.LOCAL.FIELD<1, Y.AA.PROD.ID.POS> = Y.AA.PROD.ID
    EB.SystemTables.setRNew(IS.Purchase.Contract.IcLocalRef,Y.LOCAL.FIELD)
    
RETURN

END
