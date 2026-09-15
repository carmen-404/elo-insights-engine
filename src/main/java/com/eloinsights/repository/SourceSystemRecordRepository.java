package com.eloinsights.repository;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.eloinsights.domain.SourceSystemRecord;
import com.eloinsights.exception.SourceSystemNotFoundException;

@Repository
public class SourceSystemRecordRepository {
	private final JdbcTemplate jdbcTemplate;
	
	private static final RowMapper<SourceSystemRecord> SOURCE_SYSTEM_RECORD_MAPPER = new RowMapper<SourceSystemRecord>() {
		
		@Override
		public SourceSystemRecord mapRow(ResultSet rs, int rowNum) throws SQLException {
			long sourceSystemId = rs.getLong("source_system_id");
	        String code = rs.getString("code");
	        String displayName = rs.getString("display_name");
			
			return new SourceSystemRecord(sourceSystemId, code, displayName);
		}
	};
	
	// CONSTRUCTOR
	public SourceSystemRecordRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}
	
	// METHODS
	public SourceSystemRecord findBySourceSystemId(long sourceSystemId) {
		String sql = """
				SELECT source_system_id, code, display_name
				FROM SOURCE_SYSTEMS
				WHERE source_system_id = ?
				""";
		
		// Empty as "Source not found"; propagate other result-size errors.
		try {
			return jdbcTemplate.queryForObject(sql, SOURCE_SYSTEM_RECORD_MAPPER, sourceSystemId);
		} catch (EmptyResultDataAccessException e) {
			throw new SourceSystemNotFoundException();
		}
		
	}
		
}
