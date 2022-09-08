* @ValidationCode : MjotNjM4MDgyNDk2OkNwMTI1MjoxNTY5MTI5NjU5OTI1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Sep 2019 11:20:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.E.CNV.CUS.NAU
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.Reports
    $USING ST.Customer
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    Y.CUS.TYPE = EB.Reports.getOData()
    
    IF Y.CUS.TYPE EQ 'RETAIL' THEN
        Y.VERSION.NAME = 'CUSTOMER,EXIM.INPUT'
    END ELSE
        IF Y.CUS.TYPE EQ 'CORPORATE' THEN
            Y.VERSION.NAME = 'CUSTOMER,EXIM.CORP'
        END ELSE
            Y.VERSION.NAME = 'CUSTOMER,EXIM.OTHERS'
        END
    END

    EB.Reports.setOData(Y.VERSION.NAME)
    
RETURN

END
