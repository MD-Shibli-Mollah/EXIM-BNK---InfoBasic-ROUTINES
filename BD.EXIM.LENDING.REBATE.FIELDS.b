* @ValidationCode : MjoyNTIwMTUyMjA6Q3AxMjUyOjE1ODM4MjU3MzI2NTk6dG93aGlkdGlwdTotMTotMTowOjA6dHJ1ZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Mar 2020 13:35:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : towhidtipu
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
SUBROUTINE BD.EXIM.LENDING.REBATE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.EXIM.LENDING.REBATE.FIELDS
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
    CALL Table.defineId("RECID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("ARRANGEMENT.ID","25","","")
    CALL Table.addField("XX<PAYMENT.DATE", T24_Date, "", "")
    CALL Table.addAmountField('XX-PAYMENT.AMT', 'CURRENCY', Field_AllowNegative, '')
    CALL Table.addAmountField('XX-REBATE.AMT', 'CURRENCY', Field_AllowNegative, '')
    CALL Table.addFieldDefinition("XX-ACTIVITY.ID","35","","")
    CALL Table.addFieldDefinition("XX-REV.MARKER","3","","")
    CALL Table.addFieldDefinition("XX>TRANSACTION.REF","35","","")
    CALL Table.addAmountField('CLOSING.BAL', 'CURRENCY', Field_AllowNegative, '')
    CALL Table.addFieldDefinition("DUE.MARKER","3","","")
    CALL Table.addReservedField('RESERVED.05')
    CALL Table.addReservedField('RESERVED.04')
    CALL Table.addReservedField('RESERVED.03')
    CALL Table.addReservedField('RESERVED.02')
    CALL Table.addReservedField('RESERVED.01')
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
