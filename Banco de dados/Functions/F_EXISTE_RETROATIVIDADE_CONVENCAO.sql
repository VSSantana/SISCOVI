create or replace function "F_EXISTE_RETROATIVIDADE_CONVENCAO"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER) RETURN NUMBER
IS

--Função que retorna se em um determinado mês, para um determindado cargo, existe caso de retroatividade.

  vCodConvencao NUMBER := 0;
  vDataReferencia DATE;
  vDataConvencao DATE;
  vDataAditamento DATE;

BEGIN

  vDataReferencia := TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno), 'dd/mm/yyyy');
  
    
  --Determina o código da convenção subsequente ao período informado.
  
  SELECT cod, data_convencao, data_aditamento 
    INTO vCodConvencao, vDataConvencao, vDataAditamento
    FROM tb_convencao_coletiva
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND EXTRACT(month FROM data_convencao) = pMes
      AND EXTRACT(year FROM data_convencao) = pAno
      AND data_aditamento IS NOT NULL
      AND F_CONVENCAO_ANTERIOR(cod) IS NOT NULL;

  IF(vCodConvencao IS NOT NULL) THEN

    IF(vDataConvencao >  vDataReferencia AND EXTRACT(month FROM vDataAditamento) > pMes) THEN
    
      RETURN vCodConvencao;
      
    END IF;
    
    IF(vDataConvencao =  vDataReferencia AND EXTRACT(month FROM vDataAditamento) > pMes) THEN
    
      RETURN vCodConvencao;
      
    END IF;

  END IF;

  RETURN NULL;
  
END;
