package com.eloinsights.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;

import com.eloinsights.domain.PlayerColourPerformance;
import com.eloinsights.domain.PlayerScoringSnapshot;
import com.eloinsights.repository.PlayerScoringSnapshotRepository;

@Service
public class PlayerColourPerformanceService {

	private final PlayerScoringSnapshotRepository scoringRepo;

	// CONSTRUCTOR
	public PlayerColourPerformanceService(PlayerScoringSnapshotRepository scoringRepo) {
		this.scoringRepo = scoringRepo;
	}

	// METHODS
	public PlayerColourPerformance getColourPerformance(
			long playerId,
			Long sourceSystemId, // null = ignore
			Long opponentId, // null = ignore
			Long tournamentId, // null = ignore
			LocalDate from, // null = ignore
			LocalDate to // null = ignore
	) {

		List<PlayerScoringSnapshot> matches = scoringRepo.findByPlayerIdWithFilters(playerId, sourceSystemId,
				opponentId, tournamentId, from, to);

		return buildColourPerformance(playerId, matches);
	}

	// helper
	private PlayerColourPerformance buildColourPerformance(long playerId, List<PlayerScoringSnapshot> matches) {
		// = 0 required (e.g. a player with no matches)
		int whiteWinsCount = 0;
		int blackWinsCount = 0;
		int whiteLossesCount = 0;
		int blackLossesCount = 0;
		int whiteDrawsCount = 0;
		int blackDrawsCount = 0;

		for (PlayerScoringSnapshot match : matches) {
			if (match.getColour().equals("WHITE")) {
				if (match.getResult().equals("WIN")) {
					whiteWinsCount++;
				} else if (match.getResult().equals("LOSE")) {
					whiteLossesCount++;
				} else {
					whiteDrawsCount++;
				}
			} else {
				if (match.getResult().equals("WIN")) {
					blackWinsCount++;
				} else if (match.getResult().equals("LOSE")) {
					blackLossesCount++;
				} else {
					blackDrawsCount++;
				}
			}
		}
		
		return new PlayerColourPerformance(playerId, whiteWinsCount, blackWinsCount, whiteLossesCount, blackLossesCount, whiteDrawsCount, blackDrawsCount);
	}

	
}
