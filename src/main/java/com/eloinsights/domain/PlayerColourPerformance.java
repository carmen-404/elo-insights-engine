package com.eloinsights.domain;

public final class PlayerColourPerformance {
	
	private final long playerId;
	private final int whiteWinsCount;
	private final int blackWinsCount;
	private final int whiteLossesCount;
	private final int blackLossesCount;
	private final int whiteDrawsCount;
	private final int blackDrawsCount;
	
	//CONSTRUCTOR
	public PlayerColourPerformance(long playerId, int whiteWinsCount, int blackWinsCount, int whiteLossesCount,
			int blackLossesCount, int whiteDrawsCount, int blackDrawsCount) {
		this.playerId = playerId;
		this.whiteWinsCount = whiteWinsCount;
		this.blackWinsCount = blackWinsCount;
		this.whiteLossesCount = whiteLossesCount;
		this.blackLossesCount = blackLossesCount;
		this.whiteDrawsCount = whiteDrawsCount;
		this.blackDrawsCount = blackDrawsCount;
	}

	// GETTERS
	public long getPlayerId() {
		return playerId;
	}

	public int getWhiteWinsCount() {
		return whiteWinsCount;
	}

	public int getBlackWinsCount() {
		return blackWinsCount;
	}

	public int getWhiteLossesCount() {
		return whiteLossesCount;
	}

	public int getBlackLossesCount() {
		return blackLossesCount;
	}

	public int getWhiteDrawsCount() {
		return whiteDrawsCount;
	}

	public int getBlackDrawsCount() {
		return blackDrawsCount;
	}
	
	
}
