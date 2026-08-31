package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.eloinsights.domain.PlayerRecord;

@Repository
public class PlayerRecordRepository {
	private final JdbcTemplate jdbcTemplate;
	// ROWMAPPER: Converts one row of PLAYERS into one PlayerRecord.
	private static final RowMapper<PlayerRecord> PLAYER_RECORD_MAPPER = new RowMapper<PlayerRecord>() {
		
		@Override
		public PlayerRecord mapRow(ResultSet rs, int rowNum) throws SQLException {
			long playerId = rs.getLong("player_id");
			String fullName = rs.getString("full_name");
			// .toLocalDate() on a null crashes, so check before assignment
			LocalDate dateOfBirth;
			if (rs.getDate("date_of_birth") != null) {
				dateOfBirth = rs.getDate("date_of_birth").toLocalDate();
			} else {
				dateOfBirth = null;
			}
			
			return new PlayerRecord(playerId, fullName, dateOfBirth);
		}
	};
	
	// CONSTRUCTOR
	public PlayerRecordRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}
	
	// METHODS
	public PlayerRecord findByPlayerId(long playerId) {
		String sql = "SELECT player_id, full_name, date_of_birth "
					+ "FROM PLAYERS "
					+ "WHERE player_id = ?";
		
		return jdbcTemplate.queryForObject(sql, PLAYER_RECORD_MAPPER, playerId);
		
	}
		
}
