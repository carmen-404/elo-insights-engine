CREATE OR REPLACE TRIGGER tp_tournament_player_source_trg
-- AFTER, not BEFORE: BEFORE can hide an actual FK error
-- behind a wrong or misleading message. AFTER lets FK checks happen first.
AFTER INSERT OR UPDATE OF tournament_id, player_id
ON TOURNAMENT_PARTICIPANTS
FOR EACH ROW
DECLARE
    v_source_system_id  NUMBER;
    v_player_id         NUMBER;
BEGIN
    -- First, find which source reported this tournament.
    -- The tournament_id PK guarantees exactly one row.
    SELECT source_system_id
    INTO v_source_system_id
    FROM TOURNAMENTS
    WHERE tournament_id = :NEW.tournament_id;

    -- TOO_MANY_ROWS isn't possible due to
    -- player_source_uk (player_id, source_system_id)
    SELECT player_id
    INTO v_player_id
    FROM PLAYER_EXTERNAL_REFS
    WHERE player_id = :NEW.player_id
      AND source_system_id = v_source_system_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Player is not registered with the tournament''s source system'
        );
END;
/