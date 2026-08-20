-- Same name and date of birth, different player_id: likely
-- duplicate identities.
SELECT p.player_id, p.full_name, p.date_of_birth,
       r.source_system_id, s.display_name AS source_system_name,
       r.external_ref
FROM PLAYERS p
JOIN PLAYER_EXTERNAL_REFS r
    ON r.player_id = p.player_id
JOIN SOURCE_SYSTEMS s
    ON s.source_system_id = r.source_system_id
WHERE EXISTS (
        SELECT 1
        FROM PLAYERS p2
        JOIN PLAYER_EXTERNAL_REFS r2
            ON r2.player_id = p2.player_id
        WHERE p2.full_name = p.full_name
            AND p2.date_of_birth = p.date_of_birth
            AND p2.player_id <> p.player_id)
ORDER BY full_name;