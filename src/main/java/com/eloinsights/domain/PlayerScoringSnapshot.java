package com.eloinsights.domain;

import java.time.LocalDate;

public final class PlayerScoringSnapshot {

	private final long matchId; // scoring event
	private final long playerId; // primary player
	private final long opponentId;
	private final String result; // WIN / LOSE / DRAW (player-centered)
	private final LocalDate playedOn;
	private final long sourceSystemId;
	private final Long tournamentId; // optional (wrapper type so it can be null)

	// CONSTRUCTOR
	public PlayerScoringSnapshot(long matchId, long playerId, long opponentId, String result, LocalDate playedOn,
			long sourceSystemId, Long tournamentId) {
		super();
		this.matchId = matchId;
		this.playerId = playerId;
		this.opponentId = opponentId;
		this.result = result;
		this.playedOn = playedOn;
		this.sourceSystemId = sourceSystemId;
		this.tournamentId = tournamentId;
	}

	// GETTERS
	public long getMatchId() {
		return matchId;
	}

	public long getPlayerId() {
		return playerId;
	}

	public long getOpponentId() {
		return opponentId;
	}

	public String getResult() {
		return result;
	}

	public LocalDate getPlayedOn() {
		return playedOn;
	}

	public long getSourceSystemId() {
		return sourceSystemId;
	}

	public Long getTournamentId() {
		return tournamentId;
	}
}
