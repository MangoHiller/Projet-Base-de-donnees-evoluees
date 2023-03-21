--------------------------------------------------
--- 1eme VPD -------------------------------------
--------------------------------------------------

CREATE OR REPLACE FUNCTION is_accessible_geographique (p_schema_name VARCHAR2, p_table_name VARCHAR2)
RETURN VARCHAR2
AS
  v_geographique_id NUMBER;
BEGIN
  SELECT geographique_id INTO v_geographique_id FROM dim_geographique
  WHERE country_code = SYS_CONTEXT('USERENV', 'COUNTRY_CODE');
  
  RETURN 'fait_leve_de_fond.geographique_id = ' || v_geographique_id;
END;
/

BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema => 'HUGO',
    object_name => 'fait_leve_de_fond',
    policy_name => 'restrict_geographique_access',
    function_schema => 'HUGO',
    policy_function => 'is_accessible_geographique',
    statement_types => 'select, insert, update, delete',
    enable => TRUE,
    update_check => true
  );
END;
/

--------------------------------------------------
--- 2eme VPD -------------------------------------
--------------------------------------------------

-- création de la fonction qui récupère le nom de l'utilisateur courant
CREATE OR REPLACE FUNCTION get_user_name RETURN VARCHAR2 AS
BEGIN
  RETURN USER;
END;
/

-- création de la VPD
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'HUGO',
    object_name     => 'fait_leve_de_fond',
    policy_name     => 'vpd_funding_policy',
    function_schema => 'HUGO',
    policy_function => 'vpd_funding_function',
    statement_types => 'SELECT');
END;
/

-- définition de la fonction de la VPD
CREATE OR REPLACE FUNCTION vpd_funding_function(
  schema_name  IN VARCHAR2,
  table_name   IN VARCHAR2)
  RETURN VARCHAR2
AS
  user_name VARCHAR2(30);
BEGIN
  user_name := get_user_name;
  IF user_name != 'HUGO' THEN
    RETURN 'funding_total_usd IS NULL';
  ELSE
    RETURN NULL;
  END IF;
END;
/

--------------------------------------------------
--- 3eme VPD -------------------------------------
--------------------------------------------------
CREATE OR REPLACE FUNCTION vpd_context
   RETURN VARCHAR2
IS
   role_name VARCHAR2(30);
BEGIN
   SELECT LOWER(USERENV('CURRENT_USER_ROLE'))
   INTO role_name
   FROM dual;

   IF role_name = 'Directeur' THEN
      RETURN 'funding_total_usd IS NOT NULL';
   ELSE
      RETURN '1=1';
   END IF;
END;


BEGIN
   DBMS_RLS.ADD_POLICY (
      object_schema   => 'HUGO',
      object_name     => 'fait_leve_de_fond',
      policy_name     => 'vpd_policy',
      function_schema => 'HUGO',
      policy_function => 'vpd_context',
      statement_types => 'SELECT',
      update_check    => FALSE,
      enable          => TRUE
   );
END;

---- Ci dessous le code a éxecuter si l'on veut supprimer les VPD----
/*
BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'HUGO',
    object_name => 'fait_leve_de_fond',
    policy_name => 'restrict_geographique_access'
  );
END;
/

BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'HUGO',
    object_name => 'fait_leve_de_fond',
    policy_name => 'vpd_funding_policy'
  );
END;
/

BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'HUGO',
    object_name => 'fait_leve_de_fond',
    policy_name => 'vpd_policy'
  );
END;
/
*/