create or replace function "F_RETORNA_TIPO_RESTITUICAO" (pCodTipoResgate NUMBER) RETURN VARCHAR2
IS

  --Função que recebe o cod do tipo de restituição e 
  --retorna seu nome.

  vTipoResgate VARCHAR2(50);

BEGIN

  SELECT nome
    INTO vTipoResgate
    FROM tb_tipo_resgate
    WHERE cod = pCodTipoResgate;

  RETURN vTipoResgate;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END;
