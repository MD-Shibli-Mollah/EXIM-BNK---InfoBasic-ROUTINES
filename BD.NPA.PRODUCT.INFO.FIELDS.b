* @ValidationCode : Mjo3OTU5NzUxMDM6Q3AxMjUyOjE1OTE2NzkzMTQyMTE6REVMTDotMTotMTowOjA6dHJ1ZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Jun 2020 11:08:34
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
SUBROUTINE BD.NPA.PRODUCT.INFO.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.NPA.PRODUCT.INFO.FIELDS
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
    $USING ST.Config
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId('PRODUCT.CODE', T24_String) ;* Define Table id
    CALL Field.setCheckFile('AA.PRODUCT')
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition('DESCRIPTION', '35', 'A', '')
    CALL Table.addFieldDefinition('PROD.PREFIX', '4', '', '')
    CALL Table.addFieldDefinition('CIB.LN.SUB.TYP.LE5', '1', 'A_B', '')
    CALL Table.addFieldDefinition('CIB.LN.SUB.TYP.GT5', '1', 'A_B', '')
    CALL Table.addFieldWithEbLookup('CIB.LOAN.TYPE','BD.CIB.LN.TYPE','') ;* Specify Lookup values
    CALL Table.addFieldWithEbLookup('CIB.CONTRACT.TYPE','BD.CIB.CONTR.TYPE','') ;* Specify Lookup values
    CALL Table.addFieldDefinition('PROV.EXP.CATEG','5..C','A','')
    CALL Field.setCheckFile('CATEGORY':FM:ST.Config.Category.EbCatShortName:FM:'L')
    CALL Table.addFieldDefinition('PROV.RESV.CATEG','5..C','A','')
    CALL Field.setCheckFile('CATEGORY':FM:ST.Config.Category.EbCatShortName:FM:'L')
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
