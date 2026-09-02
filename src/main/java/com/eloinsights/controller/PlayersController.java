package com.eloinsights.controller;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
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
	public ResponseEntity<PlayerRecord> getPlayerById(@PathVariable Long playerId) {
		// TODO: move error handling to a shared @ControllerAdvice class once
		// there are enough controllers to show real duplication - deferred
		// deliberately for now, since with one controller there's nothing to
		// compare the abstraction against yet (rule of three).
		try {
			// Call the repository method to fetch the PlayerRecord
			PlayerRecord player = playerRepo.findByPlayerId(playerId);

			// Returns a 200 OK response with the PlayerRecord serialized to JSON.
			return ResponseEntity.ok(player); // ResponseEntity.status(HttpStatus.OK).body(player);
		} catch (EmptyResultDataAccessException e) {
			// .status() starts a builder; .build() completes the creation of the 404 ResponseEntity.
			return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		}
	}

}
