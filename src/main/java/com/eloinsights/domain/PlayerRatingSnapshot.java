package com.eloinsights.domain;

import java.time.LocalDate;

public class PlayerRatingSnapshot {
	private final long playerId;
	private final long sourceSystemId;
	private final int rating;
	private final LocalDate effectiveDate;
	
	// CONSTRUCTOR
	public PlayerRatingSnapshot(long playerId, long sourceSystemId, int rating, LocalDate effectiveDate) {
		super();
		this.playerId = playerId;
		this.sourceSystemId = sourceSystemId;
		this.rating = rating;
		this.effectiveDate = effectiveDate;
	}

	// GETTERS AND SETTERS
	public long getPlayerId() {
		return playerId;
	}

	public long getSourceSystemId() {
		return sourceSystemId;
	}

	public int getRating() {
		return rating;
	}

	public LocalDate getEffectiveDate() {
		return effectiveDate;
	}

}