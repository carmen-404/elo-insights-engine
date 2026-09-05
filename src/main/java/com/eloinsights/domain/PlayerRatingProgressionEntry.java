package com.eloinsights.domain;

import java.time.LocalDate;

public final class PlayerRatingProgressionEntry {

	private final LocalDate effectiveDate;
	private final int effectiveRating;
	private final Integer ratingDelta; // nullable, first entry has no previous to compare
	private final Integer daysElapsed; // nullable, same reason

	// CONSTRUCTOR
	public PlayerRatingProgressionEntry(LocalDate effectiveDate, int effectiveRating, Integer ratingDelta, Integer daysElapsed) {
		this.effectiveDate = effectiveDate;
		this.effectiveRating = effectiveRating;
		this.ratingDelta = ratingDelta;
		this.daysElapsed = daysElapsed;
	}

	// GETTERS
	public LocalDate getEffectiveDate() {
		return effectiveDate;
	}

	public int getEffectiveRating() {
		return effectiveRating;
	}

	public Integer getRatingDelta() {
		return ratingDelta;
	}

	public Integer getDaysElapsed() {
		return daysElapsed;
	}

}
