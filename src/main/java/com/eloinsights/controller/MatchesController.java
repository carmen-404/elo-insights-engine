package com.eloinsights.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerScoringSnapshot;
import com.eloinsights.repository.PlayerScoringSnapshotRepository;

@RestController
public class MatchesController {
	private final PlayerScoringSnapshotRepository scoringRepo;

	// CONSTRUCTOR
	public MatchesController(PlayerScoringSnapshotRepository scoringRepo) {
		super();
		this.scoringRepo = scoringRepo;
	}

	// METHODS
	@GetMapping("/players/{playerId}/matches")
	public ResponseEntity<List<PlayerScoringSnapshot>> getMatchesByPlayerId(@PathVariable Long playerId) {
		List<PlayerScoringSnapshot> matches = scoringRepo.findByPlayerId(playerId);
		return ResponseEntity.ok(matches);
	}

}