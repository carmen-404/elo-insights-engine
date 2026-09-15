package com.eloinsights.domain;

public final class SourceSystemRecord {

    private final long sourceSystemId;
    private final String code;
    private final String displayName;

    // CONSTRUCTOR
    public SourceSystemRecord(long sourceSystemId, String code, String displayName) {
        this.sourceSystemId = sourceSystemId;
        this.code = code;
        this.displayName = displayName;
    }

    // GETTERS
    public long getSourceSystemId() {
        return sourceSystemId;
    }

    public String getCode() {
        return code;
    }

    public String getDisplayName() {
        return displayName;
    }
}