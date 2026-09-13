CREATE OR REPLACE TRIGGER rating_history_player_source_trg
-- AFTER, not BEFORE: BEFORE can hide an actual FK error
-- behind a wrong or misleading message. AFTER lets FK checks happen first.
AFTER INSERT OR UPDATE OF player_id, source_system_id
ON RATING_HISTORY
FOR EACH ROW
DECLARE
    v_player_id NUMBER;
BEGIN
    -- TOO_MANY_ROWS isn't possible due to
    -- player_source_uk (player_id, source_system_id)
    SELECT player_id
    INTO v_player_id
    FROM PLAYER_EXTERNAL_REFS
    WHERE player_id = :NEW.player_id
      AND source_system_id = :NEW.source_system_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Player is not registered with the rating entry''s source system'
        );
END;
/