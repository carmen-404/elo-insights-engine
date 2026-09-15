package com.eloinsights.exception;

public class SourceSystemNotFoundException extends RuntimeException {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public SourceSystemNotFoundException() {
		super("Source system not found");
	}
}
