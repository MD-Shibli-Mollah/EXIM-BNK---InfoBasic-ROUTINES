* @ValidationCode : MjotNTM2MDAyNzE6Q3AxMjUyOjE1ODk3ODE2Mzc0OTc6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 May 2020 12:00:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.EXIM.ED.RETURN.ZERO(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_GTS.COMMON

*-----------------------------------------------------------------------------


    balanceAmount = 199
    writeData = balanceAmount
    FileName = 'EDRETURNZERO.txt'
    FilePath = 'EXIM.DATA'
    OPENSEQ FilePath,FileName TO FileOutput THEN NULL
    ELSE
        CREATE FileOutput ELSE
        END
    END
    WRITESEQ writeData APPEND TO FileOutput ELSE
        CLOSESEQ FileOutput
    END

RETURN
END
