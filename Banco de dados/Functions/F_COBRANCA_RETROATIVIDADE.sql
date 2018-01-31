create or replace function "F_COBRANCA_RETROATIVIDADE" (pCodContrato NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN BOOLEAN
IS

  --Função que retorna se em um determinado mês
  --dever ser cobrada a retroatividade.
  
  --pOperacao = 1 - Retroatividade de convenção.
  --pOperacao = 2 - Retroatividade de percentual.

  vRetroatividadeConvencao NUMBER := 0;
  vRetroatividadePercentual NUMBER := 0;

BEGIN

  IF (pOperacao = 1) THEN

    SELECT COUNT(rc.cod)
      INTO vRetroatividadeConvencao
      FROM tb_retroatividade_convencao rc
        JOIN tb_convencao_coletiva cco ON cco.cod = rc.cod_convencao_coletiva
        JOIN tb_cargo_contrato cc ON cc.cod = cco.cod_cargo_contrato
      WHERE cc.cod_contrato = pCodContrato
        AND EXTRACT(month FROM data_cobranca) = pMes
        AND EXTRACT(year FROM data_cobranca) = pAno;

    IF (vRetroatividadeConvencao > 0) THEN

      RETURN TRUE;

    END IF;

  END IF;
  
  IF (pOperacao = 2) THEN
  
    SELECT COUNT(rp.cod)
      INTO vRetroatividadePercentual
      FROM tb_retroatividade_percentual rp
        JOIN tb_percentual_contrato pc ON pc.cod = rp.cod_percentual_contrato
      WHERE pc.cod_contrato = pCodContrato
        AND EXTRACT(month FROM rp.data_cobranca) = pMes
        AND EXTRACT(year FROM rp.data_cobranca) = pAno;

    IF (vRetroatividadePercentual > 0) THEN

      RETURN TRUE;

    END IF;
 
  END IF;
 
  RETURN FALSE;  

END;
