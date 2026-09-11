CREATE OR REPLACE TRIGGER matches_player_source_trg
-- AFTER, not BEFORE: BEFORE can hide an actual FK error
-- behind a wrong or misleading message. AFTER lets FK checks happen first.
AFTER INSERT OR UPDATE OF white_id, black_id, source_system_id
ON MATCHES
FOR EACH ROW
DECLARE
    v_case  PLS_INTEGER := 0;
    v_count PLS_INTEGER := 0;
BEGIN
    -- Check white player's registration with the source system
    SELECT COUNT(*)
    INTO v_count
    FROM PLAYER_EXTERNAL_REFS
    WHERE player_id = :NEW.white_id
        AND source_system_id = :NEW.source_system_id;
  
    IF v_count = 0 THEN
        v_case := 1; -- white not registered
    END IF;

    -- Check black player's registration with the source system
    SELECT COUNT(*)
    INTO v_count
    FROM PLAYER_EXTERNAL_REFS
    WHERE player_id = :NEW.black_id
      AND source_system_id = :NEW.source_system_id;

    IF v_count = 0 THEN
        IF v_case = 0 THEN
            v_case := 2; -- black not registered
        ELSE
            v_case := 3; -- neither registered
        END IF;
    END IF;

    CASE v_case
        WHEN 1 THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'White player is not registered with the specified source system'
            );

        WHEN 2 THEN
            RAISE_APPLICATION_ERROR(
                -20003,
                'Black player is not registered with the specified source system'
            );

        WHEN 3 THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'Neither player is registered with the specified source system'
            );
    END CASE;
END;
/