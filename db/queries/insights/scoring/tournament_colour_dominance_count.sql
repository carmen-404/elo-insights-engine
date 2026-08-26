-- This insight compares colour dominance per tournament.
-- Draws are ignored because they don't tilt the balance.
-- A tournament is counted for White only if white_wins > black_wins,
-- and for Black only if black_wins > white_wins.
WITH per_tournament AS (
    SELECT
        t.tournament_id, 
        SUM(CASE WHEN m.result = 'WHITE_WIN' THEN 1 ELSE 0 END) AS white_wins,
        SUM(CASE WHEN m.result = 'BLACK_WIN' THEN 1 ELSE 0 END) AS black_wins
    FROM TOURNAMENTS t
    LEFT OUTER JOIN MATCHES m -- Matches without a tournament_id do not join
        ON m.tournament_id = t.tournament_id
    GROUP BY
        t.tournament_id
)
SELECT
    SUM(CASE WHEN white_wins > black_wins THEN 1 ELSE 0 END) AS tournaments_white_dominated,
    SUM(CASE WHEN white_wins < black_wins THEN 1 ELSE 0 END) AS tournaments_black_dominated,
    SUM(CASE WHEN white_wins = black_wins THEN 1 ELSE 0 END) AS tournaments_even
FROM per_tournament;