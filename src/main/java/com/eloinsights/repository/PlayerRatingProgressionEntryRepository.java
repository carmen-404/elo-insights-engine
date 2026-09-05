package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;

import com.eloinsights.domain.PlayerRatingProgressionEntry;

@Repository
public class PlayerRatingProgressionEntryRepository {

	private final SimpleJdbcCall progressionCall;
	
	// Maps each row of the REF CURSOR returned by the PL/SQL function
	private static final RowMapper<PlayerRatingProgressionEntry> PROGRESSION_MAPPER = new RowMapper<PlayerRatingProgressionEntry>() {

		@Override
		public PlayerRatingProgressionEntry mapRow(ResultSet rs, int rowNum) throws SQLException {		
			LocalDate effectiveDate;
			// .toLocalDate() on a null crashes, so check before assignment
			if (rs.getDate("effective_date") != null) {
				effectiveDate = rs.getDate("effective_date").toLocalDate();
			} else {
				effectiveDate = null;
			}	
			int effectiveRating = rs.getInt("effective_rating");	
			// getObject(col, Integer.class) converts to Integer directly.
			// getObject(col) alone defaults to BigDecimal for NUMBER columns
			// (per JDBC spec), (Integer) cast on that fails.
			Integer ratingDelta = rs.getObject("rating_delta", Integer.class);
			Integer daysElapsed = rs.getObject("days_elapsed", Integer.class);

			return new PlayerRatingProgressionEntry(effectiveDate, effectiveRating, ratingDelta, daysElapsed);
		}
	};

	// CONSTRUCTOR
	public PlayerRatingProgressionEntryRepository(JdbcTemplate jdbcTemplate) {
		this.progressionCall = new SimpleJdbcCall(jdbcTemplate)
				.withFunctionName("GET_RATING_PROGRESSION_FUNC")
				// Skip Spring's metadata lookup for parameters
				.withoutProcedureColumnMetaDataAccess()
				// Explicit parameter declarations
				.declareParameters(
						// Map function's return (SYS_REFCURSOR type) to List via RowMapper
						new SqlOutParameter("return", Types.REF_CURSOR, PROGRESSION_MAPPER),
						// Input parameters (names must match the PL/SQL ones)
						new SqlParameter("p_player_id",        Types.NUMERIC),
						new SqlParameter("p_source_system_id", Types.NUMERIC)
				);
	}

	// METHODS
	public List<PlayerRatingProgressionEntry> findByPlayerId(long playerId, long sourceSystemId) {
		// Bind values by the exact parameter names declared above
		SqlParameterSource inputParameters = new MapSqlParameterSource()
				.addValue("p_player_id", playerId)
				.addValue("p_source_system_id", sourceSystemId);

		// execute() always returns Map<String, Object>
		// The key is the name gave to the SqlOutParameter ("return")
		// The value is the List produced by the RowMapper
		Map<String, Object> result = progressionCall.execute(inputParameters);
		
		// Map.get() returns Object, so cast is required
		// Generics are erased at runtime, cast goes unchecked (suppress warning)
		@SuppressWarnings("unchecked")
		List<PlayerRatingProgressionEntry> progression = (List<PlayerRatingProgressionEntry>) result.get("return");
		
		return progression;
	}

}
