* @ValidationCode : MjoxNTkyNjU1Mzk3OkNwMTI1MjoxNTg2ODMyODQzODYxOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Apr 2020 08:54:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
* @AUTHOR         : MD SHIBLI MOLLAH

SUBROUTINE GB.EXIM.DEP.LCY.RATES(Y.DATA)
*PROGRAM GB.EXIM.DEP.LCY.RATES
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING AA.PaymentSchedule
    $USING ST.CompanyCreation
    $USING AA.TermAmount

    GOSUB INIT

    GOSUB OPENFILES
 
    GOSUB PROCESS
RETURN

INIT:
    
    FN.AA.PRD = 'F.AA.PRODUCT'
    F.AA.PRD = ''
    
    FN.AA.PRD.LNE = 'F.AA.PRODUCT.GROUP'
    F.AA.PRD.LNE -= ''
   
    FN.AA.PRD.CAT = 'F.AA.PRD.CAT.INTEREST'
    F.AA.PRD.CAT = ''
    
    FN.AA.PRD.TERM = 'F.AA.PRD.CAT.TERM.AMOUNT'
    F.AA.PRD.TERM = ''
    
    Y.MIN.TERM = ''
    Y.MAX.TERM = ''
    Y.MIN.AMT= ''
    Y.MAX.AMT= ''
 
    ST.CompanyCreation.LoadCompany('BNK')
 
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AA.PRD, F.AA.PRD)
    EB.DataAccess.Opf(FN.AA.PRD.LNE, F.AA.PRD.LNE)
    EB.DataAccess.Opf(FN.AA.PRD.CAT, F.AA.PRD.CAT)
    EB.DataAccess.Opf(FN.AA.PRD.TERM, F.AA.PRD.TERM)
RETURN
 
PROCESS:
*
    SEL.CMD = 'SELECT ':FN.AA.PRD.LNE:' WITH PRODUCT.LINE EQ DEPOSITS'
*
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
    LOOP
        REMOVE Y.PRD.G.ID FROM SEL.LIST SETTING POS
    WHILE Y.PRD.G.ID:POS
        EB.DataAccess.FRead(FN.AA.PRD.LNE, Y.PRD.G.ID, REC.L.PRD, F.AA.PRD.LNE, Er)
*
*  Y.PRD.GRP = REC.L.PRD<AA.ProductFramework.ProductGroup.PgProductType>
        
****------SELECT PRODUCTS WITH GROUP ID----------------*********
        SEL.CMD.1 = 'SELECT ':FN.AA.PRD:' WITH PRODUCT.GROUP EQ ': Y.PRD.G.ID
        
****SHOULD READ PRODUCT WHERE PRODUCT GROUP
        EB.DataAccess.Readlist(SEL.CMD.1, SEL.LIST.1, '', NO.OF.REC.1, SystemReturnCode.1)
        LOOP
            REMOVE Y.PRD.ID FROM SEL.LIST.1 SETTING POS
        WHILE Y.PRD.ID:POS
            EB.DataAccess.FRead(FN.AA.PRD, Y.PRD.ID, REC.PRD, F.AA.PRD, Er)
            Y.DESCRIPTION = REC.PRD<AA.ProductManagement.Product.PdtDescription>
*
            SEL.CMD.2 = 'SELECT ':FN.AA.PRD.CAT:' WITH @ID LIKE ':Y.PRD.ID:'-DEPOSITPFT...'
            EB.DataAccess.Readlist(SEL.CMD.2, SEL.LIST.2, '', NO.OF.REC.2, SystemReturnCode.2)
            
            LOOP
                REMOVE Y.PRD.CAT.ID FROM SEL.LIST.2 SETTING POS
            WHILE Y.PRD.CAT.ID:POS
                EB.DataAccess.FRead(FN.AA.PRD.CAT, Y.PRD.CAT.ID, REC.PRD.CAT, F.AA.PRD.CAT, Er)
*
                Y.INT.DAY.BASIS = REC.PRD.CAT<AA.Interest.Interest.IntDayBasis>
                Y.INT.FIXED.RATE = REC.PRD.CAT<AA.Interest.Interest.IntFixedRate>
                
            REPEAT
        
            SEL.CMD.3 = 'SELECT ':FN.AA.PRD.TERM:' WITH @ID LIKE ':Y.PRD.ID:'-...'
            
            EB.DataAccess.Readlist(SEL.CMD.3, SEL.LIST.3, '', NO.OF.REC.3, SystemReturnCode.3)
            
            LOOP
                REMOVE Y.TERM.ID FROM SEL.LIST.3 SETTING POS
            WHILE Y.TERM.ID:POS
                EB.DataAccess.FRead(FN.AA.PRD.TERM, Y.TERM.ID, REC.AA.TERM, F.AA.PRD.TERM, Er)
                Y.MIN.TERM = REC.AA.TERM<AA.TermAmount.TermAmount.AmtTerm>
                Y.NR.ATTRIBUTE = REC.AA.TERM<AA.TermAmount.TermAmount.AmtNrAttribute>
                Y.MIN.AMT = REC.AA.TERM<AA.TermAmount.TermAmount.AmtNrValue>
*******----------LOCATE NR.ATTRIBUTE---------------------------------------------*************
                IF Y.MIN.TERM EQ '' THEN
                    
                    LOCATE "TERM" IN Y.NR.ATTRIBUTE SETTING NR.POS THEN
                        Y.MIN.TERM = Y.NR.ATTRIBUTE<4, NR.POS>
                    END
                END
                
                Y.DATA<-1> = Y.DESCRIPTION:'*':Y.MIN.TERM:'*':Y.MAX.TERM:'*':Y.MIN.AMT:'*':Y.MAX.AMT:'*':Y.INT.DAY.BASIS:'*':Y.INT.FIXED.RATE
*                                  1                 2            3              4              5               6                   7
            REPEAT
        REPEAT
*--------------------------------------------------------------------------------------------------
    REPEAT
    Y.DATA = Y.DATA
RETURN
END