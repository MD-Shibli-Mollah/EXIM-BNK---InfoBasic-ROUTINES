* @ValidationCode : MjotNTYxNTAzNjI4OkNwMTI1MjoxNTg0NTI2MzQzNDgzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Mar 2020 16:12:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CR.EXIM.V.CONCATE.CUS.LIMIT
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
    $USING AA.Limit
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
    LocalFields = 'LT.LIMIT.REF':@VM:'LT.CUS.LI.REF'
    EB.Foundation.MapLocalFields(ApplicationName, LocalFields, FieldPos)
    LimitRefPos = FieldPos<1,1>
    CusLimitPos = FieldPos<1,2>
    
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.LIMIT,F.LIMIT)
    
RETURN
********
PROCESS:
********
    CustomerId = EB.SystemTables.getComi()
    LocalFieldData = EB.SystemTables.getRNew(IS.Purchase.Contract.IcLocalRef)
    LimitRef = LocalFieldData<1, LimitRefPos> 'R%7'

    CustomerLimit = CustomerId :'.': LimitRef : '...'
    SEL.CMD = 'SELECT ':FN.LIMIT: ' WITH @ID LIKE ':CustomerLimit
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',TOT.REC,RET.CODE)
    IF TOT.REC EQ 0 THEN
        LimitRef = INT(LocalFieldData<1, LimitRefPos>/10)*10 'R%7'
        CustomerLimit = CustomerId :'.': LimitRef : '...'
        SEL.CMD = 'SELECT ':FN.LIMIT: ' WITH @ID LIKE ':CustomerLimit
        EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',TOT.REC,RET.CODE)
        IF TOT.REC EQ 0 THEN
            LimitRef = INT(LocalFieldData<1, LimitRefPos>/100)*100 'R%7'
            CustomerLimit = CustomerId :'.': LimitRef : '...'
            SEL.CMD = 'SELECT ':FN.LIMIT: ' WITH @ID LIKE ':CustomerLimit
            EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',TOT.REC,RET.CODE)
        END
    END
    LocalFieldData<1, CusLimitPos> = CustomerLimit
    EB.SystemTables.setRNew(IS.Purchase.Contract.IcLocalRef, LocalFieldData)
RETURN

END
