SELECT
    SUM(CASE WHEN result =  'WHITE_WIN' THEN 1 ELSE 0 END) AS white_wins,
    SUM(CASE WHEN result =  'BLACK_WIN' THEN 1 ELSE 0 END) AS black_wins,
    SUM(CASE WHEN result =  'DRAW' THEN 1 ELSE 0 END) AS draws
FROM MATCHES;