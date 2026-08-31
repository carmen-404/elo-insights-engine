package com.eloinsights.domain;

import java.time.LocalDate;

public final class PlayerRecord {
	private final long playerId;
	private final String fullName;
	private final LocalDate dateOfBirth; // nullable
	
	// CONSTRUCTOR
	public PlayerRecord(long playerId, String fullName, LocalDate dateOfBirth) {
		this.playerId = playerId;
		this.fullName = fullName;
		this.dateOfBirth = dateOfBirth;
	}

	// GETTERS
	public long getPlayerId() {
		return playerId;
	}

	public String getFullName() {
		return fullName;
	}

	public LocalDate getDateOfBirth() {
		return dateOfBirth;
	}
	
}