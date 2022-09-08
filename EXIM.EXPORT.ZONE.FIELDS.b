* @ValidationCode : MjoxNzgzNjQ5OTc6Q3AxMjUyOjE1NjcyODYyOTYwMjQ6REVMTDotMTotMTowOjA6dHJ1ZTpOL0E6UjE3X0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 01 Sep 2019 03:18:16
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
SUBROUTINE EXIM.EXPORT.ZONE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.EXPORT.ZONE.FIELDS
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
    ID.F = "REC.ID" ; ID.N = "2" ; ID.T = "" ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition('XX.NAME','65.1','A','')

    CALL Table.addReservedField('RESERVED.03')
    CALL Table.addReservedField('RESERVED.02')
    CALL Table.addReservedField('RESERVED.01')
    CALL Table.addOverrideField
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
