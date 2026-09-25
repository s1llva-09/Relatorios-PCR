#include "Totvs.ch"
#include "TopConn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010tok  ³ Autor ³ Pcguiselini-ARMRP    ³ Data ³ 26.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conteflex ³ Valida a inclusão de Produtos				              ³±±
±±           ³ Especificamente, controla quais os tipos de produtos cada  ³±±
±±             usuário pode cadastrar.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aceflex   ³ Ponto Entrada programa Manutenção de Produtos              ³±±
±±³          ³ - Bloqueia produto Tipo SV (SERVICO) se nao cadastrado     ³±±
±±³          ³ na b.ase ACEFLEX e ACETEX.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponto Entrada programa Manutenção de Produtos              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/       

User Function A010tok()
	Local lRet 	 := .F.   
	Local lVldUsr:= .F.
	Local strAM := upper(GETMV("ZZ_USR_AM")) // AMOSTRA
	Local strAI := upper(GETMV("ZZ_USR_AI")) //ATIVO IMOBILIZADO   
	Local strEP := upper(GETMV("ZZ_USR_EP")) //
	Local strBN := upper(GETMV("ZZ_USR_BN")) //BENEFICIAMENTO  
	Local strGG := upper(GETMV("ZZ_USR_GG")) //GASTOS GERAIS     
	Local strMC := upper(GETMV("ZZ_USR_MC")) //MATERIAL DE CONSUMO    
	Local strME := upper(GETMV("ZZ_USR_ME")) //MERCADORIA 
	Local strSV := upper(GETMV("ZZ_USR_SV")) //SERVIÇO   
	Local strMP := upper(GETMV("ZZ_USR_MP")) //MATERIA PRIMA      
	Local strMS := upper(GETMV("ZZ_USR_MS")) //MATERIAL SECUNDARIO 
	Local strMT := upper(GETMV("ZZ_USR_MT")) //MANUTENCAO   
	Local strPA := upper(GETMV("ZZ_USR_PA")) //PRODUTO ACABADO  
	Local strPI := upper(GETMV("ZZ_USR_PI")) //PRODUTO INTERMEDIARIO   
	Local strEM := upper(GETMV("ZZ_USR_EM")) //EMBALAGEM  
	Local strGE := upper(GETMV("ZZ_USR_GE")) //GARANTIA ESTENDIDA  
	Local strGN := upper(GETMV("ZZ_USR_GN")) //GENERICO  
	Local strIA := upper(GETMV("ZZ_USR_IA")) //INSUMO AGRICOLA   
	Local strII := upper(GETMV("ZZ_USR_II")) //INSUMO INDUSTRIAIS    
	Local strIN := upper(GETMV("ZZ_USR_IN")) //PRODUTOS INDUSTRIAIS      
	Local strKT := upper(GETMV("ZZ_USR_KT")) //KIT 
	Local strMM := upper(GETMV("ZZ_USR_MM")) //MATERIAIS MANFRO    
	Local strMO := upper(GETMV("ZZ_USR_MO")) //MAO DE OBRA       
	Local strOI := upper(GETMV("ZZ_USR_OI")) //OUTROS INSUMOS     
	Local strPP := upper(GETMV("ZZ_USR_PP")) //PRODUTO EM PROCESSO    
	Local strPV := upper(GETMV("ZZ_USR_PV")) //PRODUTO VEICULO     
	Local strSL := upper(GETMV("ZZ_USR_SL")) //SELO DE CONTROLE     
	Local strSM := upper(GETMV("ZZ_USR_SM")) //SEMENTES      
	Local strSP := upper(GETMV("ZZ_USR_SP")) //SUBPRODUTO     

	LocaL cColaborador := UPPER(cUserName) 
	//Local nPos :=0
	//Local cFil     := ""
	//Local cTab     := ""
	//Local cProd    := ""
	//Local nPrcBase := 0
	//Local nPerIcms := 0

	If FunName() <> "MATA010" .or. (CEMPANT $ "01#04") 
		lRet := .T.
	Else
		If INCLUI  
			lRet := u_ChrValid(M->B1_COD,"+/-.,")  // // param: codigo do produto + caracteres especiais que vamos permitir 
		Else
			lRet := .T.    // aceita como foi cadastrado antes
		Endif   
		
		If lRet
			If !(M->B1_TIPO $ "BN#GE#GG#SV") .and. Empty(M->B1_POSIPI) .and. Len(M->B1_POSIPI) <> 8
				FWAlertWarning("Esse tipo de produto é obrigatório o NCM!!!"+CHR(13)+;    
					"Sempre escolha códigos NCM análiticos." +CHR(13)+;                         
					"Campo PosIPI/NCM na segunda pasta.","A010tok-003")
				lRet:= .F.
			Endif
		Endif
				
		If M->B1_TIPO $ "EP#AM#AI#BN#GG#MC#ME#SV#MP#MS#MT#PA#PI#PE#EM#GE#GN#IA#II#IN#KT#MM#MO#OI#PP#PV#PO#SM#SP"
			Do Case 
				Case M->B1_TIPO == "EP"
					lVldUsr := cColaborador $ strEP
				Case M->B1_TIPO == "AM"
					lVldUsr := cColaborador $ strAM
				Case M->B1_TIPO == "AI"
					lVldUsr := cColaborador $ strAI
				Case M->B1_TIPO == "BN"
					lVldUsr := cColaborador $ strBN
				Case M->B1_TIPO == "GG"
					lVldUsr := cColaborador $ strGG
				Case M->B1_TIPO == "MC"
					lVldUsr := cColaborador $ strMC
				Case M->B1_TIPO == "ME"
					lVldUsr := cColaborador $ strME
				Case M->B1_TIPO == "SV"
					lVldUsr := cColaborador $ strSV
				Case M->B1_TIPO == "MP"
					lVldUsr := cColaborador $ strMP
				Case M->B1_TIPO == "MS"
					lVldUsr := cColaborador $ strMS
				Case M->B1_TIPO == "MT"
					lVldUsr := cColaborador $ strMT
				Case M->B1_TIPO $ ("PA#PE")
					lVldUsr := cColaborador $ strPA
				Case M->B1_TIPO == "PI"
					lVldUsr := cColaborador $ strPI
				Case M->B1_TIPO == "EM"
					lVldUsr := cColaborador $ strEM
				Case M->B1_TIPO == "GE"
					lVldUsr := cColaborador $ strGE
				Case M->B1_TIPO == "GN"
					lVldUsr := cColaborador $ strGN
				Case M->B1_TIPO == "IA"
					lVldUsr := cColaborador $ strIA
				Case M->B1_TIPO == "II"
					lVldUsr := cColaborador $ strII
				Case M->B1_TIPO == "IN"
					lVldUsr := cColaborador $ strIN
				Case M->B1_TIPO == "KT"
					lVldUsr := cColaborador $ strKT
				Case M->B1_TIPO == "MM"					 
					lVldUsr := cColaborador $ strMM
				Case M->B1_TIPO == "MO"
					lVldUsr := cColaborador $ strMO
				Case M->B1_TIPO == "OI"
					lVldUsr := cColaborador $ strOI
				Case M->B1_TIPO == "PP"
					lVldUsr := cColaborador $ strPP
				Case M->B1_TIPO == "PV"
					lVldUsr := cColaborador $ strPV
				Case M->B1_TIPO == "PO"
					lVldUsr := cColaborador $ strSL
				Case M->B1_TIPO == "SM"
					lVldUsr := cColaborador $ strSM
				Case M->B1_TIPO == "SP"
					lVldUsr := cColaborador $ strSP
			EndCase	
			If cColaborador $ UPPER("Administrador#lbellini#ebfranco#bgqueiroz#microsiga#emsantos#jtsantos")
				lVldUsr := .T.
			Endif										       
			If !lVldUsr
				FWAlertWarning("Usuário "+cColaborador+" sem permissão para cadastrar produto tipo "+M->B1_TIPO, "A010TOK-001", "STOP")
				lRet:= .F.
			Endif   
		Else					
			FWAlertWarning("Tipo "+M->B1_TIPO+" não previsto na política de acesso da Empresa."+CHR(13)+;
					"Favor entrar em contato com o Administrador do sistema.", "A010TOK-002", "INFO")    
			lRet:= .F.
		EndIf

		If lRet .and. cEmpAnt=="02"  // Acefles e Xpert
			If M->B1_TIPO ="PI" 
				//M->B1_APROPRI = "I"
				If Empty(M->B1_DIAMETR) .or.  Empty(M->B1_COMPRIM) .or. Empty(M->B1_LARGURA) .or. Empty(M->B1_GRAMATU)
					FWAlertWarning("Para produtos tipo PI é obrigatório o preenchimento dos campos (terceira Aba):"+CHR(13)+;
							"Diametro, Comprimento e Largura do Corte. Dúvidas, entrar em contato com Adequação.", "A010TOK-005", "INFO")
					lRet:= .F.
				Endif
			Endif

			If lRet .and. M->B1_TIPO ="PA" .and. Empty(Alltrim(M->B1_MERCADO))
					FWAlertWarning("Favor indicar o Segmento de Mercado para produtos tipo "+M->B1_TIPO+". "+CHR(13)+;
							"Campo Mercado na terceira aba."+CHR(13)+;
							"Dúvidas, entrar em contato com o comercial.", "A010TOK-004", "INFO")
					lRet:= .F.
			Endif                     
			
			// Ajuste em 01/01/2018 - by pcguiselini
			If lRet .and. M->B1_TIPO ="MS" .and. M->B1_ZZREQCC<>"S"
					FWAlertWarning("Todo MS deve ser, obrigatoriamente, requisitado por CENTRO DE CUSTO."+CHR(13)+;
							"Solução: Campo 'Req por CC' na aba MRP/Suprimentos igual a SIM."+CHR(13)+;
							"Dúvidas, entrar em contato com a Contabilidade.", "A010TOK-005", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. M->B1_TIPO ="MP" .and. M->B1_ZZREQCC<>"N"
					FWAlertWarning("Todo MP deve ser, obrigatoriamente, NÃO pode ser requisitado por CENTRO DE CUSTO."+CHR(13)+;
							"Solução: Campo 'Req por CC' na aba MRP/Suprimentos igual a NAO."+CHR(13)+;
							"Dúvidas, entrar em contato com a Contabilidade.", "A010TOK-006", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. M->B1_TIPO ="PI" .and. M->B1_RASTRO<>"L" .and. M->B1_ZZREQCC<>"S" 
					FWAlertWarning("TODO PI é  rastreado."+CHR(13)+;
							"Exceto aqueles 'Req por CC' [veja na aba MRP] = SIM."+CHR(13)+;
							"Solução: Campo 'Rastro' na primeira aba igual a <L>ote."+CHR(13)+;
							"Dúvidas, entrar em contato com a Controladoria.", "A010TOK-007", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. M->B1_TIPO ="PA" .and. M->B1_RASTRO<>"L"
					FWAlertWarning("Todo PA é rastreado."+CHR(13)+;
							"Solução: Campo 'Rastro' na primeira aba igual a LOTE."+CHR(13)+;
							"Dúvidas, entrar em contato com a Controladoria.", "A010TOK-008", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. cEmpAnt == '02' .and. M->B1_TIPO ="PI" .and. M->B1_LOCPAD<>"PI"
					FWAlertWarning("o LOTE PADRAO de PI é o 'PI'."+CHR(13)+;
							"Solução: Campo 'Local Padrao' na primeira aba igual a PI."+CHR(13)+;
							"Dúvidas, entrar em contato com o Almoxarifado.", "A010TOK-009", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. M->B1_TIPO ="PA#PE" .and. !(M->B1_LOCPAD$"01#PL")
					FWAlertWarning("o LOTE PADRAO de PA é o '01'."+CHR(13)+;
							"Solução: Campo 'Local Padrao' na primeira aba igual a 01."+CHR(13)+;
							"Dúvidas, entrar em contato com o Almoxarifado.", "A010TOK-013", "INFO")
					lRet:= .F.
			Endif                     
			If lRet .and. M->B1_TIPO ="PI" .and. M->B1_APROPRI<>"D"
					FWAlertWarning("Todo produto 'PI' só pode ter APROPRIACAO DIRETA."+CHR(13)+;
							"Solução: Campo 'Apropriação' na primeira aba igual <D>ireto."+CHR(13)+;
							"Dúvidas, entrar em contato com o Controladoria.", "A010TOK-010", "INFO")
					lRet:= .F.
			Endif                     

			// Preenche o intervalo de Inspeção (QIP) a ser realizado a cada producao - Novidade da release 12.25 - Aplicado em 13/04/2020
			If lRet .and. M->B1_TIPO ="PA" .and. M->B1_NUMCQPR==0
					FWAlertWarning("Todo produto 'PA' exige-se Inspeção na Produção."+CHR(13)+;
							"Solução: Campo 'Produções CQ' na aba CQ deve ser igual a 1."+CHR(13)+;
							"Dúvidas, entrar em contato com a Qualidade.", "A010TOK-011", "INFO")
					lRet:= .F.
			Endif                     

			If lRet .and. M->B1_TIPO $ "MP#MS" .and. Empty(M->B1_CODTAB) 
				FWAlertWarning("Todo produto 'MP' e 'MS' exige Tabela de Custo Padrão."+CHR(13)+CHR(13)+;
						"Solução: Escolher a Tabela no campo 'Tabela Preço', aba MRP/Suprimentos."+CHR(13)+CHR(13)+;
						"Dúvidas, entrar em contato com o Controladoria.", "A010TOK-015", "INFO")
				lRet:= .F.
			Endif        

			// a. Escolher a tabela 
			// b. DA1_CONVKG  , conforme SB1 (identificar onde tem KG); não seguir sem fator KG; Somente MP e MS 
			// c. DA1_PRDVEN  , multiplicao entre PRECO BASE (DA0_PRCBAS) * FATOR (DA1_CONVKG) 
			// d. DA1_PRCCUS =  PRA QUE ISSO !!!???

			If lRet

			//limpa as tabelas antes ANTES de incluir na nova
			//vale tanto para troca de tabela quanto para o campo apagado

				LimpaDA1(M->B1_COD)

				If !Empty(M->B1_CODTAB) 
					If ChkFile("TRB",.F.)
						DbSelectArea("TRB")
						DbCloseArea()
					Endif				
					cQuery := "SELECT DISTINCT DA0_FILIAL" + CRLF 
					cQuery += " FROM " + RetSqlName("DA0") + " DA0 (NOLOCK)" + CRLF 
					cQuery += " WHERE DA0_CODTAB = '" + M->B1_CODTAB + "'" + CRLF
					cQuery += " AND DA0.D_E_L_E_T_=''" + CRLF 
					cQuery += " ORDER BY DA0_FILIAL"+ CRLF 
					TCQuery cQuery NEW ALIAS "TRB"

					While !(TRB->(EoF())) .and. lRet
						DA0->(dbSeek( TRB->DA0_FILIAL + M->B1_CODTAB ))
						If DA0->(!Eof()) .and. TRB->DA0_FILIAL == DA0->DA0_FILIAL .and.  M->B1_CODTAB == DA0->DA0_CODTAB .and. DA0->DA0_PRCBAS<>0  
							//nPrcVenda := If( M->B1_SEGUM=="KG" .and. M->B1_TIPCONV=="D",  Round(DA0->DA0_PRCBAS*M->B1_CONV,2),  Round(DA0->DA0_PRCBAS/M->B1_CONV,2) )		
							cFil     := TRB->DA0_FILIAL
						    cTab     := M->B1_CODTAB
						    cProd    := M->B1_COD
						    nPrcBase := DA0->DA0_PRCBAS
						    nPerIcms := DA0->DA0_PICMS 

							If M->B1_COD<>''
								Do Case
									Case M->B1_UM == "KG"
										nFatorKg := 1
									Case M->B1_SEGUM == "KG"
										If M->B1_TIPCONV == "D"
											nFatorKg := M->B1_CONV
										Else
											nFatorKg := IIf(M->B1_CONV <> 0, 1 / M->B1_CONV, 0)
										EndIf
									Case M->B1_TERCUM == "KG"
										If M->B1_TPCONV3 == "D"
											nFatorKg := M->B1_CONV3
										Else
											nFatorKg := IIf(M->B1_CONV3 <> 0, 1 / M->B1_CONV3, 0)
										EndIf
									OtherWise
										nFatorKg := 0
								EndCase 
							Else
								nFatorKg   := U_DA1_CONVKG(cFil, cTab, cProd) 
							EndIf

							nPrcVenda  := U_DA1_PRCVEN(cFil, cTab, cProd, nPrcBase, nFatorKg)  
							nPrcCusto  := U_DA1_PRCCUS(cFil, cTab, cProd, nPrcBase, nPerIcms, nFatorKg) 

							// Inclui o novo item na Tabela de Precos
							DA1->(dbSetOrder(1))
        					DA1->(dbSeek(xFilial("DA1")+M->B1_CODTAB+M->B1_COD,.T. ))  

							//If !DA1->(Found()) .or. DA1->DA1_FILIAL <> xFilial("DA1") .or. DA1->DA1_CODTAB <> M->B1_CODTAB .or. DA1->DA1_CODPRO<>M->B1_COD
							If !DA1->(Found()) .or. DA1->DA1_FILIAL <> TRB->DA0_FILIAL .or. DA1->DA1_CODTAB <> M->B1_CODTAB .or. DA1->DA1_CODPRO<>M->B1_COD

								// identifica o próximo item da tabela
								cQuery := "SELECT isNull(MAX(DA1_ITEM),'0000') AS DA1_ITEM "+ CRLF
								cQuery += "	from " + RetSqlName("DA1") + " DA1 (NOLOCK)"+ CRLF
								cQuery += "	where DA1_FILIAL = '"+TRB->DA0_FILIAL+"'"+ CRLF 
								cQuery += "   AND DA1_CODTAB = '"+M->B1_CODTAB+"'"+ CRLF 
								cQuery += "AND DA1.D_E_L_E_T_=''"+ CRLF
								TCQuery cQuery NEW ALIAS "TRBitem"
								TRBitem->(Dbgotop())

								cItem:= SOMA1(TRBitem->DA1_ITEM)
								TRBitem->(DbCloseArea()) 
/*
faça uso dessas funcoes
            nFatorKg := U_DA1_CONVKG(cFil, cTab, cProd) 
            nPrcVenda  := U_DA1_PRCVEN(cFil, cTab, cProd, nPrcBase, nFatorKg)   
            nPrcCusto  := U_DA1_PRCCUS(cFil, cTab, cProd, nPrcBase, nPerIcms, nFatorKg) 

*/

								Reclock("DA1",.T.)
								//DA1->DA1_FILIAL    := xFilial("DA1") TESTE1
								DA1->DA1_FILIAL := TRB->DA0_FILIAL
								DA1->DA1_ITEM      := cItem
								DA1->DA1_CODTAB    := M->B1_CODTAB
								DA1->DA1_CODPRO    := M->B1_COD
								DA1->DA1_GRUPO     := M->B1_GRUPO
								DA1->DA1_PRCVEN    := nPrcVenda
								DA1->DA1_PRCCUS    := nPrcCusto			 
								DA1->DA1_CONVKG    := nFatorKg
								DA1->DA1_QTDLOT    := 999999.99
								DA1->DA1_INDLOT    := "000000000999999.99  "
								DA1->DA1_VLRDES    := 0
								DA1->DA1_PERDES    := 0
								DA1->DA1_FRETE     := 0
								DA1->DA1_ATIVO     := "1"
								DA1->DA1_TPOPER    := "4"
								DA1->DA1_MOEDA     := 1
								DA1->DA1_DATVIG    := DA0->DA0_DATATE
								DA1->DA1_TIPPRE    := "1"  //1=Preco Venda;2=Venda Consumidor;3=Atacado;4=Varejo;5=Promocao
								MsUnlock()
							else
								Reclock("DA1",.F.)
								DA1->DA1_PRCVEN    := nPrcVenda         
								MsUnlock()
							Endif
						Else	
							FWAlertWarning("Tabela "+ M->B1_CODTAB  + " não encontrada na Filial "+ xFilial("DA0") +"." +CHR(13)+;
									"Solução: Verifique se a tabela existe; se tem Preco Base preenchido."+CHR(13)+;
									"Entrar em contato com Administrador do sistema.", "A010TOK-016", "INFO")
							lRet:= .F.
						Endif
						TRB->(dbSkip())
					End
					DbSelectArea("TRB")
					DbCloseArea()					
				Endif
			Endif
		Endif

		If lRet .and. cEmpAnt == '03'  // Somente Prolinhas
			If M->B1_TIPO$"PA#PI" .and. M->B1_NUMCQPR==0
					FWAlertWarning("Todo produto 'PA'/'PI' exige-se Inspeção na Produção."+CHR(13)+;
							"Solução: Campo 'Produções CQ' na aba CQ deve ser igual a 1."+CHR(13)+;
							"Dúvidas, entrar em contato com a Qualidade.", "A010TOK-012", "INFO")
					lRet:= .F.
			Endif   

			If M->B1_TIPO=="MP" .and. Empty(M->B1_FPCOD)
					FWAlertWarning("Obritatório indicar o SubGrupo de toda MP."+CHR(13)+;
							"Solução: Preencher o campo 'SubGrupo' na primeira aba do Cadastro de Produtos."+CHR(13)+;
							"Dúvidas, entrar em contato com a PCP.", "A010TOK-013", "INFO")
					lRet:= .F.
			Endif

			If lRet .and. cEmpAnt=="03"
				U_B1CONTA()
			Endif
		Endif


		// Valida Grupos x Tipos - Contabilidade
		SBM->(dbSeek(xFIlial("SBM")+M->B1_GRUPO))
		If lRet .and. !(M->B1_TIPO $ SBM->BM_TIPOOK)
			FWAlertWarning("GRUPO desse Produto não pertence ao TIPO indicado!"+CHR(13)+;
					"Solução: Visualize no cadadastro de Grupos os TIPOS permitidos."+CHR(13)+;
					"Dúvidas, entrar em contato com o setor Contábil/Custo.", "A010TOK-013", "INFO")
			lRet:= .F.
		Endif

		If lRet .and. M->B1_TIPO ="SV" .and. Empty(M->B1_CODISS)
				FWAlertWarning("Todo produto 'SERVICO' é obrigado a indicação do CÓDIGO DE SERVIÇO, conforme Legislação ECD REINF"+CHR(13)+;
						"Solução: Preenche o campo 'Cod.Serv.ISS' na aba Impostos."+CHR(13)+;
						"Dúvidas, entrar em contato com o Fiscal.", "A010TOK-014", "INFO")
				lRet:= .F.
		Endif              
		

	EndIf

Return( lRet )

/* direcionar automaticamente o LOCAL PADRAO na prolinhas:
SELECT D5_FILIAL, D5_LOTECTL, D5_PRODUTO, D5_LOCAL, D5_ORIGLAN, D5_NUMSEQ, D5_DOC, D5_DATA,  D5_QUANT, D5_ESTORNO
	,B1_GRUPO, B1_UM, B1_LOCPAD
	FROM SD5030 SD5
	INNER JOIN SB1030 SB1 ON B1_COD=D5_PRODUTO AND SB1.D_E_L_E_T_=''
	WHERE D5_FILIAL='5202' AND SD5.D_E_L_E_T_='' AND D5_ORIGLAN='003' AND D5_ESTORNO<>'S' AND LEFT(D5_DATA,6)='201911' AND D5_LOCAL='98'

SELECT DISTINCT B1_GRUPO, BM_DESC, D5_LOCAL
	FROM SD5030 SD5
	INNER JOIN SB1030 SB1 ON B1_COD=D5_PRODUTO AND SB1.D_E_L_E_T_=''
	INNER JOIN SBM030 SBM ON BM_GRUPO=B1_GRUPO AND SBM.D_E_L_E_T_=''
	WHERE  SD5.D_E_L_E_T_='' AND D5_ORIGLAN='003' AND D5_ESTORNO<>'S' AND LEFT(D5_DATA,4)='2019'
	ORDER BY B1_GRUPO, BM_DESC,  D5_LOCAL


B1_GRUPO	BM_DESC	D5_LOCAL
1010	Multifilamentos PP            	MF
1030	Linha                         	RT
1040	Alca                          	TT
1050	Cadarco                       	TT
1060	Fita                          	TT
1070	Trava                         	TE
1080	Corda e Vedante               	TE
1090	Rafia                         	RF
1100	Tecido                        	TT
1130	Amostras                      	TT */


/*
			nPos := At(M->B1_TIPO, SBM->BM_TIPOOK)   // xProdcurado, xLista
			cEncontrado := If( nPos>0, SubStr(cLista,nPos,2), "")
*/


/*
Remove o produto da DA1 de todas as tabelas que Não sejam a atual
com cTabAtual vazio, remove de todas -- é o caso do B1_CODTAB apagado
*/
Static Function LimpaDA1(cProd) 

	Local cQuery := ""
	Local aRecnos := {}
	Local nI := 0

	If ChkFile("TRBDEL",.F.)
		DbSelectArea("TRBDEL")
		DbCloseArea()
	EndIf

	cQuery := "SELECT R_E_C_N_O_ AS DA1RECNO" + CRLF
    cQuery += " FROM " + RetSqlName("DA1") + " DA1 (NOLOCK)" + CRLF
    cQuery += " WHERE DA1_CODPRO = '" + cProd + "'" + CRLF
    cQuery += " AND DA1.D_E_L_E_T_=''" + CRLF
	TCQuery cQuery NEW ALIAS "TRBDEL"

	TRBDEL->( dbGotop()) 

	While !(TRBDEL->(EoF()))
		DA1->(DbGoTo( TRBDEL->DA1RECNO)) 

		If DA1->(!Eof()) .and. DA1->DA1_CODPRO == cProd
			Reclock("DA1",.F.)
			DA1->(DbDelete())
			MsUnlock()
		EndIf

		TRBDEL->(DbSkip())
	End

	DbSelectArea("TRBDEL")
	DbCloseArea()

	For nI := 1 To Len(aRecnos)

	Next nI

Return Nil
