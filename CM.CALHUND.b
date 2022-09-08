* @ValidationCode : Mjo4NDU3NDA5NTU6Q3AxMjUyOjE1NTk2MjM3OTM1Njg6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Jun 2019 10:49:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.CALHUND(INTVAR,OUTVAR)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
* This Routine is created for CONV.NUM.TEXT routine.
* Return value "One to Nine" and "Ten to Ninety" against different number.
* Developed By : Md Rayhan Uddin
    $INSERT I_ENQUIRY.COMMON

    DIM TXTWORD(100)

    TXTVAR = ''

    TXTWORD(0) = ""
    TXTWORD(1) = "One"
    TXTWORD(2) = "Two"
    TXTWORD(3) = "Three"
    TXTWORD(4) = "Four"
    TXTWORD(5) = "Five"
    TXTWORD(6) = "Six"
    TXTWORD(7) = "Seven"
    TXTWORD(8) = "Eight"
    TXTWORD(9) = "Nine"
    TXTWORD(10) = "Ten"
    TXTWORD(11) = "Eleven"
    TXTWORD(12) = "Twelve"
    TXTWORD(13) = "Thirteen"
    TXTWORD(14) = "Fourteen"
    TXTWORD(15) = "Fifteen"
    TXTWORD(16) = "Sixteen"
    TXTWORD(17) = "Seventeen"
    TXTWORD(18) = "Eighteen"
    TXTWORD(19) = "Nineteen"
    TXTWORD(20) = "Twenty"
    TXTWORD(21) = "Thirty"
    TXTWORD(22) = "Forty"
    TXTWORD(23) = "Fifty"
    TXTWORD(24) = "Sixty"
    TXTWORD(25) = "Seventy"
    TXTWORD(26) = "Eighty"
    TXTWORD(27) = "Ninety"
    
    IF INTVAR GE 0 AND INTVAR LE 20 THEN
        OUTVAR = TXTWORD(INTVAR)
    END
    IF INTVAR GT 20 AND INTVAR LE 99 THEN
        OUTVAR = TXTWORD(INT(INTVAR / 10) + 18):" ":TXTWORD(INTVAR - INT(INTVAR / 10) * 10)
    END

    IF INTVAR GT 99 AND INTVAR LE 999 THEN
        INTVAR1=TXTWORD(INTVAR[1,1]) :" ":"Hundred"
        IF INTVAR[2,2] GT 20 THEN
            INTVAR2=TXTWORD(INT(INTVAR[2,2] / 10) + 18):" ":TXTWORD(INTVAR[2,2] - INT(INTVAR[2,2] / 10) * 10)
        END ELSE
            INTVAR2=TXTWORD(INTVAR[2,2])
        END
        OUTVAR = INTVAR1 :" ": INTVAR2
    END
    IF INTVAR GT 9999 AND INTVAR LE 99999 THEN
        IF INTVAR[1,2] GT 20 THEN
            INTVAR1=TXTWORD(INT(INTVAR[1,2] / 10) + 18):" ":TXTWORD(INTVAR[1,2] - INT(INTVAR[1,2] / 10) * 10) :" ":"Thousand"
        END ELSE
            INTVAR1=TXTWORD(INTVAR[1,2]) :" ":"Thousand"
        END
        INTVAR2=TXTWORD(INTVAR[3,1]) :" ":"Hundred"
        IF INTVAR[4,2] GT 20 THEN
            INTVAR3=TXTWORD(INT(INTVAR[4,2] / 10) + 18):" ":TXTWORD(INTVAR[4,2] - INT(INTVAR[4,2] / 10) * 10)
        END ELSE
            INTVAR3=TXTWORD(INTVAR[4,2])
        END
        OUTVAR = INTVAR1 :" ": INTVAR2:" ": INTVAR3
    END

RETURN
END
