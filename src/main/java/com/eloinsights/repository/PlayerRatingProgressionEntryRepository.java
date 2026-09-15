package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Repository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import com.eloinsights.domain.PlayerRatingProgressionEntry;

@Repository
public class PlayerRatingProgressionEntryRepository {

	private final JdbcTemplate jdbcTemplate;
	
	// Maps each row returned by the SQL query
	private static final RowMapper<PlayerRatingProgressionEntry> PROGRESSION_MAPPER = new RowMapper<PlayerRatingProgressionEntry>() {

		@Override
		public PlayerRatingProgressionEntry mapRow(ResultSet rs, int rowNum) throws SQLException {		
			// Check for null because calling toLocalDateTime() on a null Timestamp causes a NullPointerException.
			Timestamp timestamp = rs.getTimestamp("effective_date");
			LocalDateTime effectiveDate = timestamp != null ? timestamp.toLocalDateTime() : null;
			
			int effectiveRating = rs.getInt("effective_rating");	
			
			// getObject(col, Integer.class) converts to Integer directly.
			// getObject(col) alone returns the JDBC driver's default type for NUMBER columns,
			// which may be BigDecimal, so a direct (Integer) cast can fail.
			Integer ratingDelta = rs.getObject("rating_delta", Integer.class);
			Integer cumulativeChange = rs.getObject("cumulative_change", Integer.class);

			return new PlayerRatingProgressionEntry(effectiveDate, effectiveRating, ratingDelta, cumulativeChange);
		}
	};

	// CONSTRUCTOR
	public PlayerRatingProgressionEntryRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	// METHODS
	public List<PlayerRatingProgressionEntry> findByPlayerId(long playerId, long sourceSystemId) {
		String sql = """
				SELECT
				    effective_date,
				    rating AS effective_rating,
				    
				    -- LAG iterates through the values in the order defined by OVER, getting the previous value.
				    rating - LAG(rating) OVER (ORDER BY effective_date) AS rating_delta,
				    
				    -- FIRST_VALUE gets the first value in the order defined by OVER, so current rating minus first rating gives the cumulative change.
					rating - FIRST_VALUE(rating) OVER (ORDER BY effective_date) AS cumulative_change
					
				FROM rating_history
				WHERE player_id = ?
					AND source_system_id = ?
				ORDER BY effective_date;    
				""";
		
		// PROGRESSION_MAPPER builds one PlayerRatingProgressionEntry per row
		return jdbcTemplate.query(sql, PROGRESSION_MAPPER, playerId, sourceSystemId);
	}

}
