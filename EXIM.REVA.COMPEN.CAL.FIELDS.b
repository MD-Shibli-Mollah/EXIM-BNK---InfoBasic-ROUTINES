* @ValidationCode : MjoxMjgyOTQ1ODQwOkNwMTI1MjoxNTc5MTY5NzExNDgxOkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Jan 2020 16:15:11
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
SUBROUTINE EXIM.REVA.COMPEN.CAL.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.REVA.COMPEN.CALC.FIELDS
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
    CALL Table.defineId("AC.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addField('XX<TXN.DATE', T24_Date, Field_NoInput, '')
    CALL Table.addField('XX-FCY.AC.NO', 'A', Field_NoInput, '')
    CALL Table.addAmountField('XX-FCY.EXC.RATE', 'CURRENCY',Field_NoInput, '')
    CALL Table.addAmountField('XX-FCY.AMOUNT', 'CURRENCY',Field_NoInput, '')
    CALL Table.addAmountField('XX-LCY.AMOUNT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('XX>TRNS.REF', 'A', Field_NoInput, '')
    CALL Table.addAmountField('XX<REVA.TRN.BR', 'A', Field_NoInput, '')
    CALL Table.addField('XX-REVA.TRNS.REF', 'A', Field_NoInput, '')
    CALL Table.addField('XX>REVA.TRNS.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('XX<COMPEN.TRN.BR', 'A', Field_NoInput, '')
    CALL Table.addField('XX-COMPEN.TRNS.REF', 'A', Field_NoInput, '')
    CALL Table.addField('XX>COMPEN.TRNS.AMT', 'CURRENCY', Field_NoInput, '')
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
