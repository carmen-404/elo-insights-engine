package com.eloinsights.exception;

public class PlayerNotFoundException extends RuntimeException {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public PlayerNotFoundException() {
		super("Player not found");
	}
}