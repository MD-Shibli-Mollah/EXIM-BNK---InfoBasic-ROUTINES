* @ValidationCode : Mjo5NzMzOTczNDM6Q3AxMjUyOjE1NzIxNzQxMjc2MzY6TUVIRURJOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 27 Oct 2019 17:02:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MEHEDI
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE TF.EXIM.E.CNV.DRW.TXN.ENTRY.MB
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ENQUIRY.SELECT
    $INSERT I_GTS.COMMON
*
    $USING EB.Reports
    $USING EB.Foundation
    $USING LC.Contract
    $USING EB.DataAccess
    $USING FT.Contract
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
*-----
INIT:
*-----
    FN.DRAWINGS = 'FBNK.DRAWINGS'
    F.DRAWINGS  = ''
*
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT  = ''
*
    FN.FT.HIS = 'FBNK.FUNDS.TRANSFER$HIS'
    F.FT.HIS  = ''
*
    FN.STMT.ENT = 'FBNK.STMT.ENTRY'
    F.STMT.ENT  = ''
*
    FN.ACCT = 'FBNK.ACCOUNT'
    F.ACCT  = ''
*
    FN.COMP = 'F.COMPANY'
    F.COMP  = ''
RETURN
*----------
OPENFILES:
*----------
    EB.DataAccess.Opf(FN.DRAWINGS, F.DRAWINGS)
    EB.DataAccess.Opf(FN.FT, F.FT)
    EB.DataAccess.Opf(FN.FT.HIS, F.FT.HIS)
    EB.DataAccess.Opf(FN.STMT.ENT, F.STMT.ENT)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
    EB.DataAccess.Opf(FN.COMP, F.COMP)
RETURN
*----------
PROCESS:
*----------
    Y.DRAWING.ID = EB.Reports.getOData()
    APPLICATION.NAME ='DRAWINGS'
    LOCAL.FIELD = 'LT.FT.REF.NO'
    EB.Foundation.MapLocalFields(APPLICATION.NAME, LOCAL.FIELD, Y.LC.LT.FLD.POS)
    EB.DataAccess.FRead(FN.DRAWINGS, Y.DRAWING.ID, REC.DRW, F.DRAWINGS, ERR.DRW)
    Y.FT.ID = REC.DRW<LC.Contract.Drawings.TfDrLocalRef,Y.LC.LT.FLD.POS>
    EB.DataAccess.FRead(FN.FT, Y.FT.ID, REC.FT, F.FT, ERR.FT)
    IF REC.FT EQ '' THEN
        EB.DataAccess.FRead(FN.FT.HIS, Y.FT.ID:';1', REC.FT, F.FT.HIS, ERR.FT)
    END
    Y.FT.STMT.ID  = REC.FT<FT.Contract.FundsTransfer.StmtNos,1>
    Y.FT.STMT.ID.1 = FIELD(Y.FT.STMT.ID,'.',1)
    Y.FT.STMT.ID.2 = FIELD(Y.FT.STMT.ID,'.',2)
    FOR I=1 TO '4'
        Y.STMT.ENT.ID = Y.FT.STMT.ID.1:'.':FMT(Y.FT.STMT.ID.2, 'L%5'):I
        EB.DataAccess.FRead(FN.STMT.ENT, Y.STMT.ENT.ID, REC.STMT.ENT, F.STMT.ENT, ERR.STMT.ENT)
        Y.STMT.VAL.DT = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteValueDate>
        Y.STMT.ACCT.NO = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteAccountNumber>
        EB.DataAccess.FRead(FN.ACCT, Y.STMT.ACCT.NO, REC.ACCT, F.ACCT, ERR.ACCT)
        Y.CUS.ID = REC.ACCT<AC.AccountOpening.Account.Customer>
        Y.STMT.COMP.ID = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteCompanyCode>
        EB.DataAccess.FRead(FN.COMP, Y.STMT.COMP.ID, REC.COMP, F.COMP, ERR.COPM)
        Y.COMP.MNE = REC.COMP<ST.CompanyCreation.Company.EbComMnemonic>
        Y.STMT.CURR = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteCurrency>
        Y.STMT.FCY.AMT = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteAmountFcy>
        Y.STMT.LCY.AMT = REC.STMT.ENT<AC.EntryCreation.StmtEntry.SteAmountLcy>
        Y.RETURN<-1> = Y.STMT.VAL.DT:"*":Y.STMT.ACCT.NO:"*":Y.CUS.ID:"*":Y.COMP.MNE:"*":Y.STMT.CURR:"*":Y.STMT.FCY.AMT:"*":Y.STMT.LCY.AMT:"*":Y.STMT.ENT.ID
    NEXT I
    CONVERT FM TO '|' IN Y.RETURN
*    ENQ = 'TXN.ENTRY.MB'
**    ENQ<2> = R.SEL<ESAV.SELECTION.FIELD>
**    ENQ<3> = R.SEL<ESAV.OPERAND>
**    ENQ<4> = R.SEL<ESAV.LIST>
**    ENQ<9> = R.SEL<ESAV.SORT.FIELD>
*    ENQ<2> = 'TRANSACTION.REF'
*    ENQ<3> = 'EQ'
*    ENQ<4> = Y.DRAWING.ID
**ENQ<9> = R.SEL<ESAV.SORT.FIELD>
*    EB.Reports.EnquiryDisplay(ENQ)
*    DEBUG
    EB.Reports.setOData(Y.RETURN)
RETURN
END
