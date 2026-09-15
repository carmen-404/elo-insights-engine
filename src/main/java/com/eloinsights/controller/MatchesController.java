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
import com.eloinsights.repository.PlayerRecordRepository;
import com.eloinsights.repository.PlayerScoringSnapshotRepository;
import com.eloinsights.service.PlayerColourPerformanceService;

@RestController
public class MatchesController {
	
	private final PlayerScoringSnapshotRepository scoringRepo;
	private final PlayerColourPerformanceService colourPerformanceService;
	private final PlayerRecordRepository playerRepo;

	// CONSTRUCTOR
	public MatchesController(PlayerScoringSnapshotRepository scoringRepo, PlayerColourPerformanceService colourPerformanceService,
			PlayerRecordRepository playerRepo) {
		this.scoringRepo = scoringRepo;
		this.colourPerformanceService = colourPerformanceService;
		this.playerRepo = playerRepo;
	}

	// METHODS
	
	// Matches' History
	@GetMapping("/players/{playerId}/matches")
	public ResponseEntity<List<PlayerScoringSnapshot>> getMatchesByPlayerId(
			@PathVariable long playerId,
			@RequestParam(name = "source-system-id", required = false) Long sourceSystemId,
			@RequestParam(name = "opponent-id", required = false) Long opponentId,
	        @RequestParam(name = "tournament-id", required = false) Long tournamentId,
			@RequestParam(required = false) LocalDate from,
			@RequestParam(required = false) LocalDate to) {
		
		// Checks if playerId exists
		playerRepo.findByPlayerId(playerId);
		
		
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
			@PathVariable long playerId,
			@RequestParam(name = "source-system-id", required = false) Long sourceSystemId,
			@RequestParam(name = "opponent-id", required = false) Long opponentId,
	        @RequestParam(name = "tournament-id", required = false) Long tournamentId,
			@RequestParam(required = false) LocalDate from,
			@RequestParam(required = false) LocalDate to) {
		
		// Checks if playerId exists
		playerRepo.findByPlayerId(playerId);

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