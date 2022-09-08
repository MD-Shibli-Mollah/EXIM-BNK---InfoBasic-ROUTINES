* @ValidationCode : MjoxNjk3Mzc3MDgxOkNwMTI1MjoxNTY4MzAyOTM1NjUyOkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOlIxN19BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Sep 2019 21:42:15
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
SUBROUTINE EXIM.ECO.PUR.CODE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.ECO.PUR.CODE.FIELDS
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
*   CALL Table.defineId("EP.CODE", T24_String) ;* Define Table id
    ID.F = "EP.CODE" ; ID.N = "6" ; ID.T = ""
*-----------------------------------------------------------------------------
*   CALL Table.addField(fieldName, fieldType, args, neighbour) ;* Add a new fields
*   CALL Field.setCheckFile(fileName)        ;* Use DEFAULT.ENRICH from SS or just field 1
*   CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour) ;* Specify Lookup values
*   CALL Field.setDefault(defaultValue) ;* Assign default value
*   CALL Table.addFieldDefinition("XX.NAME", "35.1", "A", "") ;* Add a new field
*   CALL Table.addFieldDefinition("XX.DESC", "35.1", "A", "") ;* Add a new field
    CALL Table.addField("XX.EPC.NAME", T24_String,Field_Mandatory, "") ;* Add a new field
    CALL Table.addField("XX.EPC.DESC", T24_String,Field_Mandatory, "") ;* Add a new field
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
RETURN
*-----------------------------------------------------------------------------
END
