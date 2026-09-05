CREATE OR REPLACE FUNCTION get_rating_progression_func (
    p_player_id IN NUMBER,
    p_source_system_id IN NUMBER
)
RETURN SYS_REFCURSOR
IS
    -- SYS_REFCURSOR, not a static CURSOR - needs to be returned to Java
    c_progression_data SYS_REFCURSOR;
BEGIN
    OPEN c_progression_data FOR
        SELECT
            effective_date,
            rating AS effective_rating,
            -- LAG() loops internally to find each row's previous value - no PL/SQL loop written here
            -- NULL for the first entry - no previous reading to compare against
            (rating - LAG(rating) OVER (ORDER BY effective_date)) AS rating_delta,
            (effective_date - LAG(effective_date) OVER (ORDER BY effective_date)) AS days_elapsed
        FROM RATING_HISTORY
        WHERE player_id = p_player_id
            AND source_system_id = p_source_system_id
        ORDER BY effective_date;
    
    RETURN c_progression_data;
END;
/