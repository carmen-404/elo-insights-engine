-- ============================================================
-- ELO INSIGHTS ENGINE - SAMPLE SEED DATA
-- Fictional players and games. Federation names are real
-- organisations (public information); all players, ratings,
-- and results are entirely fictional.
--
-- Run after 01_core_schema.sql, connected as elo_insights.
-- Safe to re-run: the RESET block below clears existing seed
-- data first in FK-safe order.
--
-- Covers, deliberately:
--   - identity merging only ever reflects an external, manually
--     validated decision (Cian: ICU + ChessNet; Lucía: RFEA + FIDE)
--     - nothing in this schema merges identities automatically.
--   - Marco Rossi shows the unmerged default: same real person,
--     no such decision exists for him (the documented LIMITATION)
--   - isolated matches with no tournament (tournament_id NULL)
--   - a withdrawn participant (registered, zero matches played)
--   - an inactive source system
--   - a player with a multi-point rising rating history (Aoife,
--     ICU) and one with a declining history (Javier, RFEA), so
--     LAG()-based progression logic has real, varied data to
--     chain through
--   - repeated matchup, same two players, alternating colour,
--     across multiple games (Aoife vs Cian) - for colour-vs-
--     opponent analysis
--   - multiple same-day online games and rating observations
--     with different timestamps from the fictional ChessNet
--     platform
-- ============================================================


-- ============================================================
-- RESET: clears existing seed data, in FK-safe order (children
-- before parents), so this script can be re-run safely.
-- ============================================================

DELETE FROM RATING_HISTORY;
DELETE FROM MATCHES;
DELETE FROM TOURNAMENT_PARTICIPANTS;
DELETE FROM TOURNAMENTS;
DELETE FROM PLAYER_EXTERNAL_REFS;
DELETE FROM PLAYERS;
DELETE FROM SOURCE_SYSTEMS;
COMMIT;


-- Restart identity sequences so ids are stable and predictable
-- across re-runs (matches the README's example player ids).

ALTER TABLE SOURCE_SYSTEMS MODIFY source_system_id
    GENERATED ALWAYS AS IDENTITY (RESTART START WITH 1);

ALTER TABLE PLAYERS MODIFY player_id
    GENERATED ALWAYS AS IDENTITY (RESTART START WITH 1);

ALTER TABLE TOURNAMENTS MODIFY tournament_id
    GENERATED ALWAYS AS IDENTITY (RESTART START WITH 1);

ALTER TABLE MATCHES MODIFY match_id
    GENERATED ALWAYS AS IDENTITY (RESTART START WITH 1);

ALTER TABLE RATING_HISTORY MODIFY rating_history_id
    GENERATED ALWAYS AS IDENTITY (RESTART START WITH 1);


-- ============================================================
-- SEED DATA: source systems, players, tournaments, matches,
-- and rating history - see notes above for what each part
-- deliberately demonstrates.
-- ============================================================

SET SERVEROUTPUT ON;

DECLARE
    v_icu        NUMBER;  -- Irish Chess Union
    v_rfea       NUMBER;  -- Real Federación Española de Ajedrez
    v_dsb        NUMBER;  -- Deutscher Schachbund
    v_ffe        NUMBER;  -- Fédération Française des Échecs
    v_fide       NUMBER;  -- FIDE, used only as a shared cross-federation ref
    v_chessnet   NUMBER;  -- fictional online platform, per-game updates
    v_oldplat    NUMBER;  -- fictional retired platform, inactive

    v_aoife      NUMBER;  -- Irish player
    v_cian       NUMBER;  -- Irish player, merged ICU + ChessNet
    v_lucia      NUMBER;  -- Spanish player, manually merged across RFEA + FIDE
    v_javier     NUMBER;  -- Spanish player
    v_lukas      NUMBER;  -- German player
    v_hannah     NUMBER;  -- German player, withdraws from a tournament
    v_camille    NUMBER;  -- French player
    v_antoine    NUMBER;  -- French player
    v_marco_rfea NUMBER;  -- "Marco Rossi" as registered with RFEA
    v_marco_dsb  NUMBER;  -- "Marco Rossi" as registered with DSB -
                           -- same real person, but no merge decision
                           -- exists for him; two separate rows, unmerged

    v_dublin     NUMBER;  -- tournament
    v_madrid     NUMBER;  -- tournament
    v_berlin     NUMBER;  -- tournament
    v_paris      NUMBER;  -- tournament
BEGIN

    -- --------------------------------------------------------
    -- SOURCE_SYSTEMS
    -- --------------------------------------------------------

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('ICU', 'Irish Chess Union')
        RETURNING source_system_id INTO v_icu;

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('RFEA', 'Real Federación Española de Ajedrez')
        RETURNING source_system_id INTO v_rfea;

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('DSB', 'Deutscher Schachbund')
        RETURNING source_system_id INTO v_dsb;

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('FFE', 'Fédération Française des Échecs')
        RETURNING source_system_id INTO v_ffe;

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES (
            'FIDE',
            'FIDE (used here only as a shared cross-federation reference)'
        )
        RETURNING source_system_id INTO v_fide;

    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES (
            'CHESSNET',
            'ChessNet (fictional online platform)'
        )
        RETURNING source_system_id INTO v_chessnet;

    INSERT INTO SOURCE_SYSTEMS (code, display_name, is_active)
        VALUES (
            'OLDPLATFORM',
            'Retired Rating Platform (fictional)',
            'N'
        )
        RETURNING source_system_id INTO v_oldplat;


    -- --------------------------------------------------------
    -- PLAYERS
    -- --------------------------------------------------------

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Aoife Byrne', DATE '1998-04-12')
        RETURNING player_id INTO v_aoife;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Cian Murphy', DATE '2001-11-03')
        RETURNING player_id INTO v_cian;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Lucía Fernández', DATE '1995-07-22')
        RETURNING player_id INTO v_lucia;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Javier Torres', DATE '1999-02-17')
        RETURNING player_id INTO v_javier;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Lukas Weber', DATE '1997-09-30')
        RETURNING player_id INTO v_lukas;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Hannah Fischer', DATE '2000-05-14')
        RETURNING player_id INTO v_hannah;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Camille Dubois', DATE '1996-12-08')
        RETURNING player_id INTO v_camille;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Antoine Laurent', DATE '1994-03-25')
        RETURNING player_id INTO v_antoine;


    -- Marco Rossi: same real person, but the engine can't detect that
    -- across sources (see README's identity resolution limitation) -
    -- merging only ever comes from outside info plus human validation.

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Marco Rossi', DATE '1993-06-19')
        RETURNING player_id INTO v_marco_rfea;

    INSERT INTO PLAYERS (full_name, date_of_birth)
        VALUES ('Marco Rossi', DATE '1993-06-19')
        RETURNING player_id INTO v_marco_dsb;


    -- --------------------------------------------------------
    -- PLAYER_EXTERNAL_REFS
    -- --------------------------------------------------------

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_aoife, v_icu, 'ICU-1042');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_cian, v_icu, 'ICU-1107');

    -- Cian has been manually validated as the same player across
    -- ICU and the fictional ChessNet platform.
    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_cian, v_chessnet, 'cn_cianm88');

    -- Aoife is also registered with ChessNet, allowing the
    -- source-specific match and rating-history triggers to pass.
    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_aoife, v_chessnet, 'cn_aoifeb17');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_javier, v_rfea, 'RFEA-3391');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_lukas, v_dsb, 'DSB-5521');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_hannah, v_dsb, 'DSB-5588');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_camille, v_ffe, 'FFE-7710');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_antoine, v_ffe, 'FFE-7744');


    -- Lucía: manually merged into one player_id across RFEA and FIDE.
    -- Nothing in this schema detects or performs this - it's seed data
    -- representing a merge that would have happened externally, same
    -- as Cian's ICU+ChessNet merge above.

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_lucia, v_rfea, 'RFEA-2205');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_lucia, v_fide, 'FIDE-1234567');


    -- Marco Rossi: two unmerged identities, the default outcome
    -- (see PLAYERS above for why).

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_marco_rfea, v_rfea, 'RFEA-4410');

    INSERT INTO PLAYER_EXTERNAL_REFS
        (player_id, source_system_id, external_ref)
        VALUES (v_marco_dsb, v_dsb, 'DSB-6602');


    -- --------------------------------------------------------
    -- TOURNAMENTS
    -- --------------------------------------------------------

    INSERT INTO TOURNAMENTS
        (source_system_id, external_ref, name, start_date, end_date)
        VALUES (
            v_icu,
            'ICU-T-2026-01',
            'Dublin Spring Open 2026',
            DATE '2026-03-14',
            DATE '2026-03-16'
        )
        RETURNING tournament_id INTO v_dublin;

    INSERT INTO TOURNAMENTS
        (source_system_id, external_ref, name, start_date, end_date)
        VALUES (
            v_rfea,
            'RFEA-T-2026-02',
            'Copa de Madrid 2026',
            DATE '2026-04-04',
            DATE '2026-04-06'
        )
        RETURNING tournament_id INTO v_madrid;

    INSERT INTO TOURNAMENTS
        (source_system_id, external_ref, name, start_date, end_date)
        VALUES (
            v_dsb,
            'DSB-T-2025-11',
            'Berlin Winter Cup 2025',
            DATE '2025-12-06',
            DATE '2025-12-08'
        )
        RETURNING tournament_id INTO v_berlin;

    INSERT INTO TOURNAMENTS
        (source_system_id, external_ref, name, start_date, end_date)
        VALUES (
            v_ffe,
            'FFE-T-2026-03',
            'Paris Rapid Masters 2026',
            DATE '2026-05-09',
            DATE '2026-05-09'
        )
        RETURNING tournament_id INTO v_paris;


    -- --------------------------------------------------------
    -- TOURNAMENT_PARTICIPANTS
    -- --------------------------------------------------------

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_dublin, v_aoife, 1742);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_dublin, v_cian, 1588);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_madrid, v_javier, 1810);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_madrid, v_lucia, 2044);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_madrid, v_marco_rfea, 1655);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_berlin, v_lukas, 1922);

    -- Hannah registers for Berlin but withdraws:
    -- no MATCHES row for her.
    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_berlin, v_hannah, 1877);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_berlin, v_marco_dsb, 1660);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_paris, v_camille, 1699);

    INSERT INTO TOURNAMENT_PARTICIPANTS
        (tournament_id, player_id, seed_rating)
        VALUES (v_paris, v_antoine, 1733);


    -- --------------------------------------------------------
    -- MATCHES
    -- --------------------------------------------------------

    -- Dublin Spring Open, round 1:
    -- Aoife (white) beats Cian.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_dublin,
            v_aoife,
            v_cian,
            'WHITE_WIN',
            DATE '2026-03-14',
            v_icu,
            'ICU-T-2026-01-R1-B1'
        );


    -- Dublin Spring Open, round 2:
    -- Aoife (white) beats Cian again.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_dublin,
            v_aoife,
            v_cian,
            'WHITE_WIN',
            DATE '2026-03-15',
            v_icu,
            'ICU-T-2026-01-R2-B1'
        );


    -- Copa de Madrid:
    -- Lucía (black) beats Javier.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_madrid,
            v_javier,
            v_lucia,
            'BLACK_WIN',
            DATE '2026-04-04',
            v_rfea,
            'RFEA-T-2026-02-R1-B1'
        );


    -- Copa de Madrid:
    -- Lucía (white) draws Marco (RFEA identity).
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_madrid,
            v_lucia,
            v_marco_rfea,
            'DRAW',
            DATE '2026-04-05',
            v_rfea,
            'RFEA-T-2026-02-R2-B1'
        );


    -- Berlin Winter Cup:
    -- Lukas (white) beats Marco (DSB identity).
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_berlin,
            v_lukas,
            v_marco_dsb,
            'WHITE_WIN',
            DATE '2025-12-06',
            v_dsb,
            'DSB-T-2025-11-R1-B1'
        );

    -- Hannah withdrew - correctly has zero MATCHES rows.


    -- Paris Rapid Masters:
    -- Camille (black) beats Antoine.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            v_paris,
            v_antoine,
            v_camille,
            'BLACK_WIN',
            DATE '2026-05-09',
            v_ffe,
            'FFE-T-2026-03-R1-B1'
        );


    -- --------------------------------------------------------
    -- CHESSNET ONLINE MATCHES
    -- --------------------------------------------------------
    -- Three isolated online games between Cian and Aoife on the
    -- same day. MATCHES.played_on is DATE, so the match time is
    -- intentionally not stored.
    --
    -- Colours alternate to provide useful colour-vs-opponent data.
    -- These matches have no tournament.

    -- Game 1: Cian beats Aoife.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            NULL,
            v_cian,
            v_aoife,
            'WHITE_WIN',
            DATE '2026-02-20',
            v_chessnet,
            'cn_game_88213'
        );

    -- Game 2: Aoife beats Cian.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            NULL,
            v_aoife,
            v_cian,
            'WHITE_WIN',
            DATE '2026-02-20',
            v_chessnet,
            'cn_game_88214'
        );

    -- Game 3: Cian draws Aoife.
    INSERT INTO MATCHES
        (tournament_id, white_id, black_id, result,
         played_on, source_system_id, external_ref)
        VALUES (
            NULL,
            v_cian,
            v_aoife,
            'DRAW',
            DATE '2026-02-20',
            v_chessnet,
            'cn_game_88215'
        );


    -- --------------------------------------------------------
    -- RATING_HISTORY
    -- --------------------------------------------------------

    -- Aoife: three ICU entries, same source, rising - gives the
    -- progression function (LAG-based) a real, increasing sequence
    -- to chain through.

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_aoife,
            v_icu,
            1700,
            DATE '2026-01-10'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_aoife,
            v_icu,
            1720,
            DATE '2026-02-15'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_aoife,
            v_icu,
            1758,
            DATE '2026-03-16'
        );


    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_cian,
            v_icu,
            1571,
            DATE '2026-03-16'
        );


    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_lucia,
            v_rfea,
            2061,
            DATE '2026-04-06'
        );


    -- Javier: three RFEA entries, same source, declining - gives the
    -- progression function a real negative-delta sequence to chain
    -- through, alongside Aoife's rising one.

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_javier,
            v_rfea,
            1850,
            DATE '2026-02-01'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_javier,
            v_rfea,
            1820,
            DATE '2026-03-01'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_javier,
            v_rfea,
            1794,
            DATE '2026-04-06'
        );


    -- Lucía also has a FIDE-reported rating, same real person,
    -- different source, independent number - demonstrates one
    -- player legitimately having more than one rating history.

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_lucia,
            v_fide,
            2058,
            DATE '2026-04-30'
        );


    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_marco_rfea,
            v_rfea,
            1649,
            DATE '2026-04-30'
        );


    -- --------------------------------------------------------
    -- CHESSNET RATING HISTORY
    -- --------------------------------------------------------
    -- ChessNet is fictional and is modelled here as providing
    -- per-game rating updates. The exact match-to-rating
    -- attribution is intentionally not stored.
    --
    -- effective_date is TIMESTAMP so multiple updates from
    -- the same day can be represented without treating them as
    -- duplicates.

    -- Cian and Aoife: ChessNet rating after game 1
    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_cian, v_chessnet, 1595,
                TIMESTAMP '2026-02-20 18:42:00');

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_aoife, v_chessnet, 1748,
                TIMESTAMP '2026-02-20 18:42:00');


    -- Cian and Aoife: ChessNet rating after game 2
    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_cian, v_chessnet, 1612,
                TIMESTAMP '2026-02-20 19:17:00');

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_aoife, v_chessnet, 1731,
                TIMESTAMP '2026-02-20 19:17:00');


    -- Cian and Aoife: ChessNet rating after game 3
    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_cian, v_chessnet, 1604,
                TIMESTAMP '2026-02-20 20:03:00');

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (v_aoife, v_chessnet, 1739,
                TIMESTAMP '2026-02-20 20:03:00');


    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_lukas,
            v_dsb,
            1935,
            DATE '2025-12-08'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_marco_dsb,
            v_dsb,
            1650,
            DATE '2025-12-08'
        );

    -- Hannah withdrew, so no RATING_HISTORY row follows from Berlin.


    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_camille,
            v_ffe,
            1714,
            DATE '2026-05-09'
        );

    INSERT INTO RATING_HISTORY
        (player_id, source_system_id, rating, effective_date)
        VALUES (
            v_antoine,
            v_ffe,
            1719,
            DATE '2026-05-09'
        );


    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Seed data inserted successfully.');
END;
/