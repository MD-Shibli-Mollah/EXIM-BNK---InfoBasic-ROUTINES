* @ValidationCode : MjotMTU5NzQ5ODE0OTpDcDEyNTI6MTU3MTMyMzkxODIwMzpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjE3X0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Oct 2019 20:51:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
SUBROUTINE TF.EXIM.I.COLL.PURR
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING LC.Contract
    
    APPLICATION.NAMES = 'DRAWINGS'
    LOCAL.FIELDS = 'LT.LIMIT.PROD':VM:'LT.TFLD.PUR.ID'
    EB.Foundation.MapLocalFields(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
    Y.LT.LIMIT.PROD.POS = FLD.POS<1,1>
    Y.TFLD.PUR.ID.POS = FLD.POS<1,2>
   
    tmpDRAWING =  EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrLocalRef)
    tmpRECSTATUS = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrRecordStatus)
    tmpLIMIT.PROD = tmpDRAWING<1,Y.LT.LIMIT.PROD.POS>
    tmpTFLD.PUR.ID = tmpDRAWING<1,Y.TFLD.PUR.ID.POS>

    tmp.LC.CRDT.TYPE = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrLcCreditType)

*For document collection
    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.FDBC.EXREG' OR EB.SystemTables.getPgmVersion() EQ ',EXIM.LDBC.EXREG' THEN
        BEGIN CASE
            CASE tmpRECSTATUS EQ '' AND tmpLIMIT.PROD EQ ''
                tmpDRAWING<1,Y.LT.LIMIT.PROD.POS> = 'COLL'
                EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef,tmpDRAWING)

            CASE tmpRECSTATUS EQ '' AND tmpLIMIT.PROD NE ''
                IF tmpLIMIT.PROD EQ 'PURR' THEN
                    EB.SystemTables.setEtext("Document Already Purchased")
                    EB.SystemTables.setAf(tmpDRAWING)
                    EB.SystemTables.setAv(Y.LT.LIMIT.PROD.POS)
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END

            CASE tmpRECSTATUS NE '' AND tmpLIMIT.PROD EQ ''
                tmpDRAWING<1,Y.LT.LIMIT.PROD.POS> = 'COLL'
                EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef,tmpDRAWING)

            CASE tmpRECSTATUS NE '' AND tmpLIMIT.PROD NE ''
                IF tmpLIMIT.PROD EQ 'PURR' THEN
                    EB.SystemTables.setEtext("Document Purchase Not Authorised")
                    EB.SystemTables.setAf(tmpDRAWING)
                    EB.SystemTables.setAv(Y.LT.LIMIT.PROD.POS)
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
        END CASE
    END

*For document purchase
    IF EB.SystemTables.getPgmVersion() EQ ',EXIM.FDBP.EXREG' OR EB.SystemTables.getPgmVersion() EQ ',EXIM.LDBP.EXREG' THEN
        BEGIN CASE
            CASE tmpLIMIT.PROD EQ ''
                EB.SystemTables.setEtext("Document not collected")
                EB.SystemTables.setAf(tmpDRAWING)
                EB.SystemTables.setAv(Y.LT.LIMIT.PROD.POS)
                EB.ErrorProcessing.StoreEndError()
                RETURN
             
            CASE tmpTFLD.PUR.ID NE ''
                EB.SystemTables.setEtext("Document Already Purchased and Disbursed")
                EB.SystemTables.setAf(tmpDRAWING)
                EB.SystemTables.setAv(Y.LT.LIMIT.PROD.POS)
                EB.ErrorProcessing.StoreEndError()
                RETURN
                
            CASE tmpRECSTATUS EQ '' AND tmpLIMIT.PROD EQ 'COLL'
                tmpDRAWING<1,Y.LT.LIMIT.PROD.POS> = 'PURR'
                EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrLocalRef,tmpDRAWING)
                
            CASE tmpRECSTATUS EQ '' AND tmpLIMIT.PROD EQ 'PURR'

            CASE tmpRECSTATUS NE '' AND tmpLIMIT.PROD EQ 'COLL'
                EB.SystemTables.setEtext("Document Not Collected")
                EB.SystemTables.setAf(tmpDRAWING)
                EB.SystemTables.setAv(Y.LT.LIMIT.PROD.POS)
                EB.ErrorProcessing.StoreEndError()
                RETURN
                
            CASE tmpRECSTATUS NE '' AND tmpLIMIT.PROD EQ 'PURR'

        END CASE
    END
    
RETURN
END
