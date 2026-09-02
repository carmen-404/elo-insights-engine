package com.eloinsights.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerRatingSnapshot;
import com.eloinsights.repository.PlayerRatingSnapshotRepository;

@RestController
public class RatingsController {
	private final PlayerRatingSnapshotRepository ratingsRepo;

	// CONSTRUCTOR
	public RatingsController(PlayerRatingSnapshotRepository ratingsRepo) {
		super();
		this. ratingsRepo =  ratingsRepo;
	}

	// METHODS
	@GetMapping("/players/{playerId}/ratings")
	public ResponseEntity<List<PlayerRatingSnapshot>> getRatingsByPlayerId(@PathVariable Long playerId) {
		List<PlayerRatingSnapshot> ratings = ratingsRepo.findByPlayerId(playerId);
		return ResponseEntity.ok(ratings);
	}

}