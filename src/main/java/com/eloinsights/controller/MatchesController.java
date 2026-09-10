package com.eloinsights.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerColourPerformance;
import com.eloinsights.domain.PlayerScoringSnapshot;
import com.eloinsights.repository.PlayerScoringSnapshotRepository;
import com.eloinsights.service.PlayerColourPerformanceService;

@RestController
public class MatchesController {
	
	private final PlayerScoringSnapshotRepository scoringRepo;
	private final PlayerColourPerformanceService colourPerformanceService;

	// CONSTRUCTOR
	public MatchesController(PlayerScoringSnapshotRepository scoringRepo, PlayerColourPerformanceService colourPerformanceService) {
		this.scoringRepo = scoringRepo;
		this.colourPerformanceService = colourPerformanceService;
	}

	// METHODS
	
	// Matches' History
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
	
	// Colour Performance
	@GetMapping("/players/{playerId}/matches/colour-performance")
	public ResponseEntity<PlayerColourPerformance> getColourPerformanceByPlayerId(
			@PathVariable Long playerId,
			@RequestParam(required = false) Long sourceSystemId,
			@RequestParam(required = false) Long opponentId,
			@RequestParam(required = false) Long tournamentId,
			@RequestParam(required = false) LocalDate from,
			@RequestParam(required = false) LocalDate to) {

		PlayerColourPerformance colourPerformance = colourPerformanceService.getColourPerformance(
						playerId,
						sourceSystemId,
						opponentId,
						tournamentId,
						from,
						to);

		return ResponseEntity.ok(colourPerformance);
	}

	
}