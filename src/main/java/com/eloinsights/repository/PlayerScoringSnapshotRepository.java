package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import com.eloinsights.domain.PlayerScoringSnapshot;

@Repository
public class PlayerScoringSnapshotRepository {
	
	// Improves readability and avoids errors with multiple and/or repeated parameters.
	private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
	
	// ROWMAPPER: Converts one row of MATCHES into one PlayerScoringSnapshot.
	private static final RowMapper<PlayerScoringSnapshot> SCORING_SNAPSHOT_MAPPER = new RowMapper<PlayerScoringSnapshot>() {

		@Override
		public PlayerScoringSnapshot mapRow(ResultSet rs, int rowNum) throws SQLException {
			long matchId = rs.getLong("match_id");
			long playerId = rs.getLong("player_id"); // bound parameter
			long opponentId = rs.getLong("opponent_id"); // derived
			String colour = rs.getString("colour"); // derived
			String result = rs.getString("result"); // derived, values differ from raw column
			LocalDate playedOn = rs.getDate("played_on").toLocalDate();
			long sourceSystemId = rs.getLong("source_system_id");
			// IMPORTANT: getObject(..., Long.class) reads the column AS a Long,
			// deciding the type at read time so it can return NULL.
			// getLong() would SILENTLY turn NULLs into 0.
			Long tournamentId = rs.getObject("tournament_id", Long.class);

			return new PlayerScoringSnapshot(
					matchId,
					playerId,
					opponentId,
					colour,
					result,
					playedOn,
					sourceSystemId,
					tournamentId);
		}
	};

	// CONSTRUCTOR (Spring supplies the JdbcTemplate automatically)
	public PlayerScoringSnapshotRepository(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
		this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
	}

	// METHODS
	public List<PlayerScoringSnapshot> findByPlayerIdWithFilters(
			long playerId,
			Long sourceSystemId, // null = ignore
			Long opponentId, // null = ignore
			Long tournamentId, // null = ignore
			LocalDate from, // null = ignore
			LocalDate to // null = ignore
	) {
		String sql = """
				SELECT
				    match_id,
				    :playerId AS player_id,
				    CASE WHEN white_id = :playerId THEN black_id ELSE white_id END AS opponent_id,
				    CASE WHEN white_id = :playerId THEN 'WHITE' ELSE 'BLACK' END AS colour,
				    CASE WHEN white_id = :playerId
				         THEN CASE result WHEN 'WHITE_WIN' THEN 'WIN' WHEN 'BLACK_WIN' THEN 'LOSE' ELSE 'DRAW' END
				         ELSE CASE result WHEN 'WHITE_WIN' THEN 'LOSE' WHEN 'BLACK_WIN' THEN 'WIN' ELSE 'DRAW' END
				    END AS result,
				    played_on,
				    source_system_id,
				    tournament_id
				FROM MATCHES
				WHERE (white_id = :playerId OR black_id = :playerId)
				  AND (:sourceSystemId IS NULL OR source_system_id = :sourceSystemId)
				  AND (:opponentId IS NULL OR
				       (white_id = :playerId AND black_id = :opponentId) OR
				       (black_id = :playerId AND white_id = :opponentId))
				  AND (:tournamentId IS NULL OR tournament_id = :tournamentId)
				  AND (:fromDate IS NULL OR played_on >= :fromDate)
				  AND (:toDate IS NULL OR played_on <= :toDate)
				ORDER BY played_on
				""";
		
		// Maps each parameter value to its corresponding :name in the SQL.
		SqlParameterSource params = new MapSqlParameterSource()
				.addValue("playerId", playerId)
				.addValue("sourceSystemId", sourceSystemId)
				.addValue("opponentId", opponentId)
				.addValue("tournamentId", tournamentId)
				.addValue("fromDate", from)
				.addValue("toDate", to);

		
		// SCORING_SNAPSHOT_MAPPER builds one PlayerScoringSnapshot per row
		return namedParameterJdbcTemplate.query(sql, params, SCORING_SNAPSHOT_MAPPER);
	}

}
