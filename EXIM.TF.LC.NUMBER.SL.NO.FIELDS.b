* @ValidationCode : MjozMjMxMTc4NzQ6Q3AxMjUyOjE1NzEwNTAyMzAyNzE6TUVIRURJOi0xOi0xOjA6MDp0cnVlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Oct 2019 16:50:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
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
SUBROUTINE EXIM.TF.LC.NUMBER.SL.NO.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.TF.LC.NUMBER.SL.NO.FIELDS
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
    ID.F = "REC.ID" ; ID.N = "10" ; ID.T = "A" ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("XX<LC.TYPE","2","A","")
    CALL Table.addFieldDefinition("XX>SERIAL.NO","5","A","")

    CALL Table.addReservedField('RESERVED.03')
    CALL Table.addReservedField('RESERVED.02')
    CALL Table.addReservedField('RESERVED.01')
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
