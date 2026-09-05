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

@RestController
public class RatingsController {
	
	private final PlayerRatingSnapshotRepository ratingsRepo;
	private final PlayerRatingProgressionEntryRepository progressionRepo;

	// CONSTRUCTOR
	public RatingsController(PlayerRatingSnapshotRepository ratingsRepo,
			PlayerRatingProgressionEntryRepository progressionRepo) {
		this.ratingsRepo = ratingsRepo;
		this.progressionRepo = progressionRepo;
	}

	// METHODS
	@GetMapping("/players/{playerId}/ratings")
	public ResponseEntity<List<PlayerRatingSnapshot>> getRatingsByPlayerId(@PathVariable Long playerId) {
		List<PlayerRatingSnapshot> ratings = ratingsRepo.findByPlayerId(playerId);
		return ResponseEntity.ok(ratings);
	}
	
	@GetMapping("/players/{playerId}/ratings/progression")
	public ResponseEntity<List<PlayerRatingProgressionEntry>> getProgression(
			@PathVariable Long playerId, // from the URL path, identifies the resource
			@RequestParam Long sourceSystemId) { // from the query string, filters the request
		List<PlayerRatingProgressionEntry> progression = progressionRepo.findByPlayerId(playerId, sourceSystemId);
		return ResponseEntity.ok(progression);
	}

}