package com.eloinsights.domain;

import java.time.LocalDateTime;

public final class PlayerRatingProgressionEntry {

	private final LocalDateTime effectiveDate;
	private final int effectiveRating;
	private final Integer ratingDelta; // nullable, if first entry has no previous to compare
	private final Integer cumulativeChange; // nullable, same reason

	// CONSTRUCTOR
	public PlayerRatingProgressionEntry(LocalDateTime effectiveDate, int effectiveRating, Integer ratingDelta, Integer cumulativeChange) {
		this.effectiveDate = effectiveDate;
		this.effectiveRating = effectiveRating;
		this.ratingDelta = ratingDelta;
		this.cumulativeChange = cumulativeChange;
	}

	// GETTERS
	public LocalDateTime getEffectiveDate() {
		return effectiveDate;
	}

	public int getEffectiveRating() {
		return effectiveRating;
	}

	public Integer getRatingDelta() {
		return ratingDelta;
	}

	public Integer getCumulativeChange() {
		return cumulativeChange;
	}

}
