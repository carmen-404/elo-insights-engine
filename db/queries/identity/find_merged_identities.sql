-- Same player_id linked to more than one source system:
-- merged identities.
SELECT p.player_id, p.full_name, p.date_of_birth,
       r.source_system_id, s.display_name AS source_system_name,
       r.external_ref
FROM PLAYERS p
JOIN PLAYER_EXTERNAL_REFS r
    ON r.player_id = p.player_id
JOIN SOURCE_SYSTEMS s
    ON s.source_system_id = r.source_system_id
WHERE p.player_id IN (
        SELECT r2.player_id
        FROM PLAYER_EXTERNAL_REFS r2
        GROUP BY r2.player_id
        HAVING COUNT(DISTINCT r2.source_system_id) > 1)
ORDER BY player_id;