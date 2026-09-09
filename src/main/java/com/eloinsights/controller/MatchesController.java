package com.eloinsights.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerScoringSnapshot;
import com.eloinsights.repository.PlayerScoringSnapshotRepository;

@RestController
public class MatchesController {
	
	private final PlayerScoringSnapshotRepository scoringRepo;

	// CONSTRUCTOR
	public MatchesController(PlayerScoringSnapshotRepository scoringRepo) {
		this.scoringRepo = scoringRepo;
	}

	// METHODS
	@GetMapping("/players/{playerId}/matches")
	public ResponseEntity<List<PlayerScoringSnapshot>> getMatchesByPlayerId(
			@PathVariable Long playerId,
			@RequestParam(required = false) Long sourceSystemId,
			@RequestParam(required = false) Long opponentId,
			@RequestParam(required = false) Long tournamentId,
			@RequestParam(required = false) LocalDate from,
			@RequestParam(required = false) LocalDate to) {
		
		List<PlayerScoringSnapshot> matches = scoringRepo.findByPlayerIdWithFilters(
				playerId,
				sourceSystemId,
				opponentId,
				tournamentId,
				from,
				to);
	
		return ResponseEntity.ok(matches);
	}

	
}