package com.eloinsights.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.eloinsights.domain.PlayerRecord;
import com.eloinsights.repository.PlayerRecordRepository;

// Convenience annotation combining @Controller and @ResponseBody,
// making @ResponseBody active by default for all request mapping methods.
@RestController
public class PlayersController {
	private final PlayerRecordRepository playerRepo;

	// CONSTRUCTOR
	public PlayersController(PlayerRecordRepository playerRepo) {
		this.playerRepo = playerRepo;
	}

	// METHODS
	// Configures Spring MVC to route GET /players/{playerId} requests to the following method.
	@GetMapping("/players/{playerId}")
	public ResponseEntity<PlayerRecord> getPlayerById(@PathVariable long playerId) {
		// If playerId doesn't exist, this throws EmptyResultDataAccessException,
		// caught globally by GlobalExceptionHandler (returns 404).
		PlayerRecord player = playerRepo.findByPlayerId(playerId);
		return ResponseEntity.ok(player);
	}

}
