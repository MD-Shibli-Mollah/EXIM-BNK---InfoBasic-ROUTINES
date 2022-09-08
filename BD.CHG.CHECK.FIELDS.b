* @ValidationCode : MjoyNjk0NDg2OTE6Q3AxMjUyOjE1NzQ2MDAxNjQ2OTI6REVMTDotMTotMTowOjA6dHJ1ZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Nov 2019 18:56:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201710.0
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE BD.CHG.CHECK.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.CHG.CHECK.FIELDS
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
    CALL Table.defineId("CHG.CHECK.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    CALL Table.addAmountField('AMC.CHG.CHECK', 'A', Field_NoInput, '')
    CALL Table.addAmountField('ED.CHG.CHECK', 'A', Field_NoInput, '')
    CALL Table.addAmountField('XX<SLAB.AMT', 'CURRENCY', 'Field_AllowNegative', '')
    CALL Table.addAmountField('XX>CHG.AMT', 'CURRENCY', 'Field_AllowNegative', '')
    CALL Table.addField('XX.LOCAL.REF', T24_String, Field_NoInput,'')
    
*-----------------------------------------------------------------------------
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
