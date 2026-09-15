package com.eloinsights.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.SourceSystemRecord;
import com.eloinsights.repository.SourceSystemRecordRepository;

@RestController
public class SourceSystemsController {
	
	private final SourceSystemRecordRepository sourceRepo;
	
	// CONSTRUCTOR
	public SourceSystemsController(SourceSystemRecordRepository sourceRepo) {
		this.sourceRepo = sourceRepo;
	}
	
	// METHODS
	@GetMapping("source-systems/{sourceSystemId}")
	public ResponseEntity<SourceSystemRecord> getSourceSystemById(@PathVariable long sourceSystemId) {
		SourceSystemRecord source = sourceRepo.findBySourceSystemId(sourceSystemId);
		return ResponseEntity.ok(source);
	}

	
}