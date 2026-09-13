package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.eloinsights.domain.PlayerRatingSnapshot;

@Repository // marks this as a Spring-managed bean so it can be created and injected
			// automatically at startup.
public class PlayerRatingSnapshotRepository {
	private final JdbcTemplate jdbcTemplate;
	// ROWMAPPER: Converts one row of RATING_HISTORY into one PlayerRatingSnapshot.
	private static final RowMapper<PlayerRatingSnapshot> RATING_SNAPSHOT_MAPPER = new RowMapper<PlayerRatingSnapshot>() {

		@Override
		public PlayerRatingSnapshot mapRow(ResultSet rs, int rowNum) throws SQLException {
			long playerId = rs.getLong("player_id");
			long sourceSystemId = rs.getLong("source_system_id");
			int rating = rs.getInt("rating");
			LocalDate effectiveDate = rs.getDate("effective_date").toLocalDate();

			return new PlayerRatingSnapshot(playerId, sourceSystemId, rating, effectiveDate);
		}
	};

	// CONSTRUCTOR (Spring supplies the JdbcTemplate automatically)
	public PlayerRatingSnapshotRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	// METHODS
	public List<PlayerRatingSnapshot> findByPlayerId(long playerId) {
		String sql = "SELECT player_id, source_system_id, rating, effective_date "
				+ "FROM RATING_HISTORY "
				+ "WHERE player_id = ? "
				+ "ORDER BY source_system_id, effective_date";

		return jdbcTemplate.query(sql, RATING_SNAPSHOT_MAPPER, playerId);
	}

}
