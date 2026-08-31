package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.eloinsights.domain.PlayerScoringSnapshot;

@Repository // marks this as a Spring-managed bean
public class PlayerScoringSnapshotRepository {
	private final JdbcTemplate jdbcTemplate;
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

			return new PlayerScoringSnapshot(matchId, playerId, opponentId, colour, result, playedOn, sourceSystemId,
					tournamentId);
		}
	};

	// CONSTRUCTOR (Spring supplies the JdbcTemplate automatically)
	public PlayerScoringSnapshotRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	// METHODS
	public List<PlayerScoringSnapshot> findByPlayerId(long playerId) {
		String sql = "SELECT " + "match_id, "
				+ "? AS player_id, "
				+ "CASE WHEN white_id = ? THEN black_id ELSE white_id END AS opponent_id, "
				+ "CASE WHEN white_id = ? THEN 'WHITE' ELSE 'BLACK' END AS colour, "
				+ "CASE WHEN white_id = ? "
				+ "    THEN CASE result WHEN 'WHITE_WIN' THEN 'WIN' WHEN 'BLACK_WIN' THEN 'LOSE' ELSE 'DRAW' END "
				+ "    ELSE CASE result WHEN 'WHITE_WIN' THEN 'LOSE' WHEN 'BLACK_WIN' THEN 'WIN' ELSE 'DRAW' END "
				+ "END AS result, "
				+ "played_on, source_system_id, tournament_id "
				+ "FROM MATCHES "
				+ "WHERE white_id = ? OR black_id = ? "
				+ "ORDER BY played_on";

		// sql = the query; SCORING_SNAPSHOT_MAPPER = builds one PlayerScoringSnapshot per row;
		// the rest = one value per ? in sql, in order.
		return jdbcTemplate.query(sql, SCORING_SNAPSHOT_MAPPER, playerId, playerId, playerId, playerId, playerId,
				playerId);
	}

}
