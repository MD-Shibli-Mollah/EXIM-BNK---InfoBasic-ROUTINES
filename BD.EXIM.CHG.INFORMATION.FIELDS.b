* @ValidationCode : MjoyNDM5NjI4NDI6Q3AxMjUyOjE1NzcxODUxMjE5Mjc6REVMTDotMTotMTowOjA6dHJ1ZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Dec 2019 16:58:41
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
SUBROUTINE BD.EXIM.CHG.INFORMATION.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.EXIM.CHG.INFORMATION.FIELDS
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
    CALL Table.defineId("CHG.EXIM.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    CALL Table.addField('XX<CHG.TXN.DATE', T24_Date, Field_NoInput, '')
    CALL Table.addAmountField('XX-AVG.BAL.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('XX-SLAB.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('XX>CHG.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('REALIZE.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('DUE.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addField('CHG.TXN.REF.ID', T24_String, Field_NoInput, '')
    CALL Table.addOptionsField('CHG.WAVE', 'YES_NO', '', '')
    CALL Table.addField('REMARKS', T24_String, '', '')
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
