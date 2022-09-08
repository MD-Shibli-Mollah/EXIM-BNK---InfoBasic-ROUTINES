* @ValidationCode : MjotMTk4MjQ2MTA3NzpDcDEyNTI6MTU2MjQyMDE0NDQyMzpERUxMOi0xOi0xOjA6MDp0cnVlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Jul 2019 19:35:44
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
SUBROUTINE BDMB.NPA.PARAM.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BDMB.NPA.PARAM.FIELDS
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
    $USING ST.AssetProcessing
    $USING ST.Config
    
*$INSERT I_F.LN.ASSET.CLASS
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId('NPA.PARAM.ID', T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition('IS.AMT.CHK', '3', '': FM : 'YES_','')
    CALL Table.addFieldDefinition('CALC.TYPE', '20', '': FM : 'DAYS_DAY.AND.INSTALLMENT_INSTALLMENT','')
    
    CALL Table.addFieldDefinition('XX<OVERDUE.DAY.FR','7','R','')
    CALL Table.addFieldDefinition('XX-OVERDUE.DAY.TO','7','R','')
    CALL Table.addFieldDefinition('XX-OVERDUE.INS.FR','5','','')
    CALL Table.addFieldDefinition('XX-OVERDUE.INS.TO','5','','')
    CALL Table.addAmountField('XX-AMOUNT.FR', 'CURRENCY', '','')
    CALL Table.addAmountField('XX-AMOUNT.TO', 'CURRENCY', '','')
    CALL Table.addFieldDefinition('XX-ASSET.CLASS','3','A','')
    CALL Field.setCheckFile('LN.ASSET.CLASS':FM:ST.AssetProcessing.LnAssetClass.LnAssclsShortDesc:FM:'L')
    CALL Table.addFieldDefinition('XX-INT.RECOG', '8', '': FM : 'INCOME_SUSPENSE','')
    CALL Table.addFieldDefinition('XX-PROV.PER','11..C','R','')
    CALL Table.addFieldDefinition('XX-PROV.RESV.CATEG','5..C','A','')
    CALL Field.setCheckFile('CATEGORY':FM:ST.Config.Category.EbCatShortName:FM:'L')
    CALL Table.addFieldDefinition('XX-PROV.EXP.CATEG','5..C','A','')
    CALL Field.setCheckFile('CATEGORY':FM:ST.Config.Category.EbCatShortName:FM:'L')
    CALL Table.addFieldDefinition('XX<OVERDUE.LTY.DAY.FR','7','R','')
    CALL Table.addFieldDefinition('XX-OVERDUE.LTY.DAY.TO','7','R','')
    CALL Table.addFieldDefinition('XX-OVERDUE.LTY.INS.FR','5','','')
    CALL Table.addFieldDefinition('XX-OVERDUE.LTY.INS.TO','5','','')
    CALL Table.addReservedField('RESERVED.13')
    CALL Table.addReservedField('RESERVED.12')
    CALL Table.addFieldDefinition('XX>DECISION', '2', '': FM : 'EQ_GE_GT_LE_LT_NE_NR_RG','')
    
    CALL Table.addFieldDefinition('PROV.REVIEW.FREQ','19','FQU','')
    CALL Table.addFieldDefinition('BL.RATE','5','AMT','')
    CALL Table.addFieldDefinition('RATE.EFFECTED', '30', '': FM : 'PRESENT_MONTHLY_QUERTERLY_START.OF.THE.YEAR','')
    CALL Table.addFieldDefinition('IS.AFTER.MAT', '3', '': FM : 'YES_','')
    
    CALL Table.addFieldDefinition('LOAN.TERM.YEAR.GT', '2', '': FM : '_1_2_3_4_5_6_7_8_9_10_11_12','')
    CALL Table.addReservedField('RESERVED.11')
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
