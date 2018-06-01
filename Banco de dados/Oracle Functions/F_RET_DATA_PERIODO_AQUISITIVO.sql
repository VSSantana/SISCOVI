create or replace function "F_RET_DATA_PERIODO_AQUISITIVO" (pCodTerceirizadoContrato NUMBER, pOperacao NUMBER) RETURN DATE
IS

  --Função que retorna o início ou fim do período aquisitivo.

  --pOperação: 
  --1 - Início do período aquisitivo.
  --2 - Fim do período aquisitivo.

  vMaxDataCalculo DATE;
  vDataRetorno DATE;

BEGIN

  --Seleciona a máxima data fim dos períodos aquisitivos e adiciona 1 dia.

  BEGIN

    SELECT MAX(data_fim_periodo_aquisitivo)
      INTO vMaxDataCalculo
      FROM tb_restituicao_ferias
      WHERE cod_terceirizado_contrato = pCodTerceirizadoContrato;

    vDataRetorno := vMaxDataCalculo + 1;

    EXCEPTION WHEN OTHERS THEN

      vMaxDataCalculo := NULL;    

  END;

  --Atribui a data de disponibilização a data fim do período aquisitivo caso não exista nenhum.

  IF (vMaxDataCalculo IS NULL) THEN

    SELECT data_disponibilizacao
      INTO vDataRetorno
      FROM tb_terceirizado_contrato
      WHERE cod = pCodTerceirizadoContrato;

  END IF;

  --Determina o fim do período aquisitivo.

  IF (pOperacao = 2) THEN

    vDataRetorno := vDataRetorno + 364;

  END IF; 

  RETURN vDataRetorno;

END;
