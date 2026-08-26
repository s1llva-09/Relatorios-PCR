
Relatorio Protheus passado por Edson(edinho)

--- Producao com Consumo errado

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
      AND D3_ESTORNO <>'S'
      AND D3_FILIAL IN ('0201','0301')
      AND D3_CF = 'PR0'
    --    AND D3_OP ='00177401002'
       AND D3_EMISSAO >= '20260801'  AND D3_EMISSAO <= '20260831'
      AND D3_TIPO In ('PE','PA')
),
Estrutura AS (
    -- 2. Busca a estrutura filtrada dos componentes
    SELECT 
        G1_COD,
        G1_COMP,
        G1_QUANT
    FROM SG1020 G1 (NOLOCK)
    INNER JOIN SB1020 B1 (NOLOCK) ON B1_COD = G1_COMP AND B1.D_E_L_E_T_ = '' AND B1_ZZBLQPI<>'S'
    WHERE G1.D_E_L_E_T_ = ''
      AND B1_TIPO = 'PI'
    --   AND LEFT(G1_COMP, 4) NOT IN ('CADA', 'CAPA','PRES')
),
ConsumoReal AS (
    -- 3. Agrupa o consumo real por NUMSEQ e COMPONENTE (evita duplicar linhas caso haja mais de uma requisição)
    SELECT 
        D3_FILIAL,
        D3_NUMSEQ,
        D3_COD,
        SUM(D3_QUANT) AS QTD_REAL
    FROM SD3020 D3 (NOLOCK)
    WHERE D3.D_E_L_E_T_ = '' 
      AND D3_ESTORNO <> 'S'
      -- Geralmente consumo de componente é RE (Requisição) ou DE (Devolução), ajuste se necessário
      -- AND D3_TIPO = 'RE' 
    GROUP BY D3_FILIAL, D3_NUMSEQ, D3_COD
)

-- 4. Junta tudo trazendo o esperado vs real
SELECT 
    P.D3_FILIAL            AS [Filial],
    P.D3_NUMSEQ            AS [NumSeq Pai],
    ISNULL(Z.ZPX_CELULA, '')  AS [Celula Costura],
    P.D3_LOCAL      AS [Armazem],
    P.D3_OP               AS [OP Pai],
    P.D3_EMISSAO          AS [Emissão],
    P.D3_TIPO             AS [TIPO PAI],
    P.D3_COD              AS [Codigo Pai],
    P.D3_LOTECTL    AS [Lote Pai],
    P.QTD_PAI             AS [Qtd Produzida Pai],
    E.G1_COMP             AS [Codigo Componente],
    E.G1_QUANT            AS [Qtd Estrutura],
    -- Consumo Esperado: Qtd produzida do pai * Qtd do componente na estrutura
    (P.QTD_PAI * E.G1_QUANT) AS [Consumo Esperado],
    -- Consumo Real: Se for nulo, traz 0
    ISNULL(R.QTD_REAL, 0)    AS [Consumo Real],
    -- Variação (Diferença entre o esperado e o real)
    ISNULL(R.QTD_REAL, 0) - (P.QTD_PAI * E.G1_QUANT) AS [Variacao]    
FROM OpPai P
INNER JOIN Estrutura E ON E.G1_COD = P.D3_COD
LEFT JOIN ConsumoReal R ON R.D3_FILIAL = P.D3_FILIAL 
                       AND R.D3_NUMSEQ = P.D3_NUMSEQ 
                       AND R.D3_COD = E.G1_COMP
LEFT JOIN ZPX020 Z ON Z.ZPX_NUMSEQ = P.D3_NUMSEQ 
ORDER BY P.D3_NUMSEQ, E.G1_COMP;
 