* @ValidationCode : MjotNDc5NDY2OTAxOkNwMTI1MjoxNTY3Mjc5NjE5MjQ1OkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOlIxN19BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Sep 2019 01:26:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R17_AMR.0
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE EXIM.HS.CODE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.HS.CODE.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("HCODE", T24_String) ;* Define Table id
    ID.F = "HCODE" ; ID.N = "10" ; ID.T = "A"
*-----------------------------------------------------------------------------
*CALL Table.addField(fieldName, fieldType, args, neighbour) ;* Add a new fields
*CALL Field.setCheckFile(fileName)        ;* Use DEFAULT.ENRICH from SS or just field 1
*CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
*CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour) ;* Specify Lookup values
*CALL Field.setDefault(defaultValue) ;* Assign default value
    CALL Table.addFieldDefinition("XX.HDESC", "65.1", "A", "")
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')
    CALL Table.addField("XX.LOCAL.REF", T24_String, Field_NoInput,"")
    CALL Table.addOverrideField
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
END
