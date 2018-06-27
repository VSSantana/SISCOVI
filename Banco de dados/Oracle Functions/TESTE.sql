SELECT  u.nome AS "Gestor",
        c.nome_empresa AS "Empresa",
        'Contrato Nº: ' || c.numero_contrato AS "Contrato",
        f.nome AS "Função",
        tmr.data_referencia AS "Data referência",
        ROUND(SUM(tmr.ferias), 2) AS "Férias retido",
        ROUND(SUM(tmr.terco_constitucional), 2) AS "Terço constitucional retido",
        ROUND(SUM(tmr.decimo_terceiro), 2) AS "Décimo terceiro retido",
        ROUND(SUM(tmr.incidencia_submodulo_4_1), 2) AS "Incidência retido",
        ROUND(SUM(tmr.multa_fgts), 2) AS "MULTA do FGTS retido",
        ROUND(SUM(tmr.ferias) + SUM(tmr.terco_constitucional) + SUM(tmr.decimo_terceiro) + SUM(tmr.incidencia_submodulo_4_1) + SUM(tmr.multa_fgts), 2) AS "Total retido"
  FROM tb_funcao_contrato fc
    JOIN tb_contrato c ON c.cod = fc.cod_contrato
    JOIN tb_funcao f ON f.cod = fc.cod_funcao
    JOIN tb_funcao_terceirizado ft ON ft.cod_funcao_contrato = fc.cod
    JOIN tb_terceirizado_contrato tc ON tc.cod = ft.cod_terceirizado_contrato
    JOIN tb_total_mensal_a_reter tmr ON tmr.cod_terceirizado_contrato = tc.cod
    JOIN tb_historico_gestao_contrato hgc ON hgc.cod_contrato = c.cod
    JOIN tb_usuario u ON u.cod = hgc.cod_usuario
  WHERE c.cod = :P18_COD_CONTRATO
    AND EXTRACT(month FROM tmr.data_referencia) = :P18_MES 
    AND EXTRACT(year FROM tmr.data_referencia) = :P18_ANO
    AND hgc.cod_usuario = F_RETORNA_COD_GESTOR_ATUAL(c.cod)
    AND tmr.cod_funcao_terceirizado = ft.cod
  GROUP BY u.nome, 
         c.nome_empresa, 
         'Contrato Nº: ' || c.numero_contrato || '/' || F_RETORNA_ANO_CONTRATO(c.cod), 
         f.nome,
         tmr.data_referencia
ORDER BY 1,2,3,4