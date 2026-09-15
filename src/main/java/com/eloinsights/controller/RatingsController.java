package com.eloinsights.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerRatingProgressionEntry;
import com.eloinsights.domain.PlayerRatingSnapshot;
import com.eloinsights.repository.PlayerRatingProgressionEntryRepository;
import com.eloinsights.repository.PlayerRatingSnapshotRepository;
import com.eloinsights.repository.PlayerRecordRepository;
import com.eloinsights.repository.SourceSystemRecordRepository;

@RestController
public class RatingsController {
	
	private final PlayerRatingSnapshotRepository ratingsRepo;
	private final PlayerRatingProgressionEntryRepository progressionRepo;
	private final PlayerRecordRepository playerRepo;
	private final SourceSystemRecordRepository sourceRepo;

	// CONSTRUCTOR
	public RatingsController(PlayerRatingSnapshotRepository ratingsRepo,
			PlayerRatingProgressionEntryRepository progressionRepo,
			PlayerRecordRepository playerRepo,
			SourceSystemRecordRepository sourceRepo) {
		this.ratingsRepo = ratingsRepo;
		this.progressionRepo = progressionRepo;
		this.playerRepo = playerRepo;
		this.sourceRepo = sourceRepo;
	}

	// METHODS
	@GetMapping("/players/{playerId}/ratings")
	public ResponseEntity<List<PlayerRatingSnapshot>> getRatingsByPlayerId(@PathVariable long playerId) {
		// Throws 404 if playerId doesn't exist.
		playerRepo.findByPlayerId(playerId);
		
		List<PlayerRatingSnapshot> ratings = ratingsRepo.findByPlayerId(playerId);
		return ResponseEntity.ok(ratings);
	}
	
	@GetMapping("/players/{playerId}/ratings/progression")
	public ResponseEntity<List<PlayerRatingProgressionEntry>> getProgression(
			@PathVariable long playerId, // from the URL path, identifies the resource
			@RequestParam(name = "source-system-id") long sourceSystemId) { // from the query string, filters the request
		
		// Checks if playerId exists
		playerRepo.findByPlayerId(playerId);
		
		// Checks if sourceSystemId exists
		sourceRepo.findBySourceSystemId(sourceSystemId);
		
		List<PlayerRatingProgressionEntry> progression = progressionRepo.findByPlayerId(playerId, sourceSystemId);
		return ResponseEntity.ok(progression);
	}

}