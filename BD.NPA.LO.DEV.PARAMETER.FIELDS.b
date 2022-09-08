* @ValidationCode : MjotMTI4NTA1Mjg2MjpDcDEyNTI6MTU5MTYwMzIyMTI2MzpERUxMOi0xOi0xOjA6MDp0cnVlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 08 Jun 2020 14:00:21
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
SUBROUTINE BD.NPA.LO.DEV.PARAMETER.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.NPA.LO.DEV.PARAMETER.FIELDS
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
    CALL Table.defineId('LO.ID', T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition('XX<PROD.PREFIX', '4', '', '')
    CALL Table.addFieldDefinition('XX-AA.PROD.ID', '4', '', '')
    CALL Field.setCheckFile('AA.PRODUCT')
    CALL Table.addFieldDefinition('XX>PROD.DESC', '15', '', '')
    CALL Table.addFieldWithEbLookup('XX<LOAN.REGISTER.NAME','BD.GL.BRKP.REG.NAME','')
    CALL Table.addFieldDefinition('XX-LOAN.REGISTER.DESC', '65', '', '')
    CALL Table.addFieldDefinition('XX-LOAN.REGISTER.TYPE', '9', 'ASSET_LIABILITY', '')
    CALL Table.addFieldDefinition('XX>LOAN.REG.INT.ACCT', '12', 'A', '')
    CALL Table.addFieldDefinition( 'LN.REG.BK.FT.TXN.TYPE', '4', '', '')
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')
    CALL Table.addFieldDefinition('LN.REG.AD.FT.TXN.TYPE', '4', '', '')
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')
    CALL Table.addField('XX.LOCAL.REF', T24_String, Field_NoInput,'')
*-----------------------------------------------------------------------------
    CALL Table.addReservedField('RESERVED.10')
    CALL Table.addReservedField('RESERVED.09')
    CALL Table.addReservedField('RESERVED.08')
    CALL Table.addReservedField('RESERVED.07')
    CALL Table.addReservedField('RESERVED.06')
    CALL Table.addReservedField('RESERVED.05')
    CALL Table.addReservedField('RESERVED.04')
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
