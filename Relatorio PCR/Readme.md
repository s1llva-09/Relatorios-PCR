
# Relatório PCR - Conferência de Consumo x Estrutura

Relatório desenvolvido para identificar divergências entre o consumo previsto
na estrutura do produto e o consumo registrado na produção. O relatório foi
solicitado por Edson (Edinho).

## Objetivo

Para cada produção de produto pai, o relatório compara:

- **Consumo esperado:** quantidade produzida do pai multiplicada pela quantidade do componente na estrutura.
- **Consumo real:** soma dos movimentos do componente na `SD3`, agrupados por filial, sequência e produto.
- **Variação:** `Consumo Real - Consumo Esperado`.

Uma variação negativa indica consumo abaixo do esperado; uma variação positiva
indica consumo acima do esperado. Componentes sem movimento também aparecem,
com consumo real igual a zero.

## Arquivo

- **Fonte:** `zpce.tlpp`
- **Função de menu:** `U_PCEMenu()`
- **Função principal:** `U_RelatorioPCE()`
- **Função de teste:** `U_ZTSTPCE()`
- **Saída:** planilha Excel `.xlsx`, com aba `Consumo`

## Requisitos

- Ambiente Protheus/TLPP com acesso ao banco via TopConn.
- Execução na **empresa 02**.
- Tabelas padrão com dados válidos: `SD3`, `SG1` e `SB1`.
- Tabela customizada `ZPX020`, com o campo `ZPX_NUMSEQ` e, opcionalmente,
  `ZPX_CELULA`.
- Campo customizado `B1_ZZBLQPI` na `SB1`.
- Classe `FWMsExcelXlsx` disponível no ambiente.
- Permissão para criar arquivos no diretório `\cachenosso\` do AppServer e
  para copiar arquivos do servidor para o terminal.

> A tabela `ZPX020` é intencionalmente fixa. Ela não é obtida por
> `RetSqlName()`, pois não está cadastrada no dicionário SX2.

## Utilização pelo menu

Compile `zpce.tlpp` no ambiente Protheus e associe `U_PCEMenu()` a uma opção de
menu. Ao executar, informe:

| Parâmetro | Descrição | Padrão |
|---|---|---|
| Filial de | Filial inicial do intervalo | Filial logada |
| Filial até | Filial final do intervalo | Filial logada |
| Emissão de | Data inicial da produção | Primeiro dia do mês corrente |
| Emissão até | Data final da produção | Último dia do mês corrente |
| Tipo de | Tipo inicial do produto pai | `PA` |
| Tipo até | Tipo final do produto pai | `PE` |

Os tipos disponíveis são `PA` e `PE`. O filtro usa uma lista fechada, e não
`BETWEEN`, para não incluir tipos intermediários que não foram selecionados.

Depois da consulta, o sistema abre uma janela para escolher a pasta de destino,
copia o arquivo para o computador do usuário e remove a cópia temporária do
servidor. Cancelar a janela de download não gera erro, mas o arquivo temporário
continua sendo removido.

## Uso programático

```advpl
Local cArquivo := U_RelatorioPCE(;
    "0201", ;
    "0301", ;
    "20260701", ;
    "20260731", ;
    "PA", ;
    "PE" )

If Empty(cArquivo)
    ConOut("Nenhum registro encontrado ou empresa não suportada")
Else
    ConOut("Arquivo gerado: " + cArquivo)
EndIf
```

Os parâmetros de data devem estar no formato `AAAAMMDD`. Parâmetros vazios
assumem os mesmos padrões da execução pelo menu. A função retorna o caminho do
arquivo no servidor ou uma string vazia quando não há dados ou a gravação falha.

## Colunas da planilha

`Filial`, `NumSeq Pai`, `Celula Costura`, `Armazem`, `OP Pai`, `Emissao`,
`Tipo Pai`, `Codigo Pai`, `Lote Pai`, `Qtd Produzida Pai`, `Codigo Componente`,
`Qtd Estrutura`, `Consumo Esperado`, `Consumo Real` e `Variacao`.

As colunas quantitativas são gravadas como números para permitir filtros,
ordenação e fórmulas no Excel.

## Regras da consulta

1. Produções são filtradas por `D3_CF = 'PR0'`, sem estorno e com tipo pai `PA` ou `PE`.
2. A estrutura é lida da `SG1`; componentes bloqueados com `B1_ZZBLQPI = 'S'` são ignorados.
3. São considerados componentes dos tipos `PI` e `PE` na `SB1`.
4. O consumo real é agrupado antes do `JOIN`, evitando duplicidade quando há várias requisições para a mesma sequência e componente.
5. A consulta usa `NOLOCK` e não chama `ChangeQuery`, pois o SQL contém CTEs (`WITH`) incompatíveis com esse tratamento no fluxo atual.

## SQL de referência

O SQL abaixo reproduz a regra principal para análise direta no banco. Ele é
uma versão manual da consulta montada dinamicamente por `MontaQuery()` em
`zpce.tlpp`. Substitua os valores indicados antes de executar e ajuste os
nomes físicos das tabelas caso o ambiente possua outro sufixo de empresa.

> Esta consulta é somente para análise. A execução oficial deve ser feita por
> `U_PCEMenu()`, que valida a empresa, aplica os parâmetros da tela e gera o
> arquivo Excel.

```sql
WITH OpPai AS (
    -- 1. Busca as produções dos produtos pais
    SELECT
        D3_FILIAL,
        D3_NUMSEQ,
        D3_EMISSAO,
        D3_DOC,
        D3_OP,
        D3_TIPO,
        D3_COD,
        D3_QUANT AS QTD_PAI,
        D3_USUARIO,
        D3_LOCAL,
        D3_LOTECTL
    FROM SD3020 D3 (NOLOCK)
    WHERE D3.D_E_L_E_T_ = ''
      AND D3_ESTORNO <> 'S'
      AND D3_FILIAL IN ('0201', '0301')
      AND D3_CF = 'PR0'
      -- AND D3_OP = '00177401002'
      AND D3_EMISSAO >= '20260801'
      AND D3_EMISSAO <= '20260831'
      AND D3_TIPO IN ('PE', 'PA')
),
Estrutura AS (
    -- 2. Busca a estrutura filtrada dos componentes
    SELECT
        G1_COD,
        G1_COMP,
        G1_QUANT
    FROM SG1020 G1 (NOLOCK)
    INNER JOIN SB1020 B1 (NOLOCK)
        ON B1_COD = G1_COMP
       AND B1.D_E_L_E_T_ = ''
       AND B1_ZZBLQPI <> 'S'
    WHERE G1.D_E_L_E_T_ = ''
      AND B1_TIPO IN ('PI', 'PE')
      -- AND LEFT(G1_COMP, 4) NOT IN ('CADA', 'CAPA', 'PRES')
),
ConsumoReal AS (
    -- 3. Agrupa o consumo real por NUMSEQ e componente
    SELECT
        D3_FILIAL,
        D3_NUMSEQ,
        D3_COD,
        SUM(D3_QUANT) AS QTD_REAL
    FROM SD3020 D3 (NOLOCK)
    WHERE D3.D_E_L_E_T_ = ''
      AND D3_ESTORNO <> 'S'
      -- AND D3_TIPO = 'RE'
    GROUP BY D3_FILIAL, D3_NUMSEQ, D3_COD
)

-- 4. Junta tudo trazendo o esperado versus o real
SELECT
    P.D3_FILIAL AS [Filial],
    P.D3_NUMSEQ AS [NumSeq Pai],
    ISNULL(Z.ZPX_CELULA, '') AS [Celula Costura],
    P.D3_LOCAL AS [Armazem],
    P.D3_OP AS [OP Pai],
    P.D3_EMISSAO AS [Emissão],
    P.D3_TIPO AS [TIPO PAI],
    P.D3_COD AS [Codigo Pai],
    P.D3_LOTECTL AS [Lote Pai],
    P.QTD_PAI AS [Qtd Produzida Pai],
    E.G1_COMP AS [Codigo Componente],
    E.G1_QUANT AS [Qtd Estrutura],
    -- Consumo esperado: quantidade produzida do pai x quantidade do componente
    P.QTD_PAI * E.G1_QUANT AS [Consumo Esperado],
    -- Consumo real: se for nulo, traz zero
    ISNULL(R.QTD_REAL, 0) AS [Consumo Real],
    -- Variação: diferença entre o esperado e o real
    ISNULL(R.QTD_REAL, 0) - (P.QTD_PAI * E.G1_QUANT) AS [Variacao]
FROM OpPai P
INNER JOIN Estrutura E ON E.G1_COD = P.D3_COD
LEFT JOIN ConsumoReal R
    ON R.D3_FILIAL = P.D3_FILIAL
   AND R.D3_NUMSEQ = P.D3_NUMSEQ
   AND R.D3_COD = E.G1_COMP
LEFT JOIN ZPX020 Z ON Z.ZPX_NUMSEQ = P.D3_NUMSEQ
ORDER BY P.D3_NUMSEQ, E.G1_COMP;
```

No código TLPP, `SD3020`, `SG1020` e `SB1020` são obtidas com
`RetSqlName()`. O `ZPX020` permanece fixo porque não está cadastrado no SX2.

## Teste e diagnóstico

`U_ZTSTPCE()` executa o relatório sem `ParamBox` ou mensagens de interface,
configura o ambiente com `RpcSetEnv("02", "0201")` e informa o resultado no
console via `ConOut()`. Use essa função apenas para depuração.

Mensagens comuns:

- **Empresa não suportada:** o usuário não está logado na empresa `02`.
- **Nenhum registro encontrado:** revise filial, período, tipos, estrutura e movimentos da `SD3`.
- **Arquivo não localizado:** verifique permissões do `rootpath`, do diretório `\cachenosso\` e do `CpyS2T`.
- **Erro na consulta:** confirme a existência de `ZPX020` e dos campos customizados citados nos requisitos.

## Histórico da regra

O SQL inicial foi mantido como referência durante a conversão para TLPP. A
implementação atual separa consulta, leitura dos dados, geração da planilha e
download para o terminal, facilitando manutenção e reutilização.
