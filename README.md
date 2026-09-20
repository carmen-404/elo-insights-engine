# ELO Insights Engine

*Portfolio project — Oracle DB design, PL/SQL, and a REST API in Java/Spring Boot.*

Backend insights engine that ingests player, match, and rating history data from external sources and computes performance insights — volatility, consistency, opponent strength, rating progression — exposed via a JSON API.

This is an insights engine, not a rating calculator. Ratings are received from external sources (federations, clubs, online platforms, etc.); nothing in this project computes or derives a rating.

## Data model

![Relational model](docs/relational-model.svg)

Full schema: [`db/schema/01_core_schema.sql`](db/schema/01_core_schema.sql)

`RATING_HISTORY.effective_date` uses `TIMESTAMP` to support sources that may publish multiple rating updates on the same day, while date-only source data can still be stored normally.

## Stack

- Oracle Database (FREE 26ai), PL/SQL
- Java 21, Spring Boot, Maven
- REST JSON API

## Project structure

```
db/
├── functions/    PL/SQL functions (SYS_REFCURSOR-based, called from Java via SimpleJdbcCall)
├── queries/
│   ├── identity/     finds merged and potentially unresolved cross-system player identities
│   └── insights/
│       ├── rating/     rating-based insights
│       └── scoring/    match-based insights
├── schema/     core DDL, tablespace/user setup
├── seed/       fictional sample data
└── triggers/     enforces business rules DDL/FKs can't (see "Business rules beyond the schema's structure")
docs/           architecture and data model diagrams
src/main/java/com/eloinsights/      Spring Boot application
├── EloInsightsEngineApplication.java   application entry point
├── controller/   REST endpoints, one controller per resource
├── domain/       immutable DTOs; explicit classes used instead of records
├── exception/ domain-specific exceptions and global exception handling
├── repository/   database access using Spring JDBC (JdbcTemplate and NamedParameterJdbcTemplate)
└── service/      computation logic on top of repositories or other services, no direct DB access
src/main/resources/
└── application.properties.example      template for local database credentials
src/test/java/com/eloinsights/          test sources (currently just the default Spring Boot test)
```

## Known limitations

- **Cross-source identity resolution**: Each rating source uses its own player reference, and they rarely share a common identifier. As a result, the engine cannot detect when two external records represent the same person. This reflects the real fragmentation across federations and platforms — even FIDE IDs don't fully unify identities.
- **Rating attribution**: Rating updates store only an effective date, with no link to any match or tournament. A source could theoretically report per‑event, but even then there’s no way to confirm the previous update was contiguous, so the link isn’t reliable. For these reasons, rating attribution was deliberately left out of the schema.
- **Rating system assumption**: The engine assumes every ingested rating is Elo. However, the system has no automated way to detect whether a source is reporting a different rating system. If such a source were ingested, insight calculations that operate on `rating` values could produce incorrect or misleading results.

## Less obvious data integrity rules

Source-specific records must remain consistent. A player appearing in a match, a rating update, or a tournament roster must be registered with the same source reporting them. `player_source_uk` on `PLAYER_EXTERNAL_REFS` backs the player registration checks: they can never match more than one row. The player registration rules are enforced by the triggers in `db/triggers/`.

Similarly, if a match belongs to a tournament, the tournament must also belong to the same source as the match. This is enforced by the composite foreign key on `(source_system_id, tournament_id)`.

Finally, the `rating_history_player_source_effective_uk` constraint on `RATING_HISTORY` ensures that a player can have at most one rating from a given source at the same effective timestamp, preventing duplicates when ingestion batches overlap (idempotency).

## Where computation happens

Anything beyond what a single SQL statement can express is handled either in PL/SQL or in Java. That choice is often driven by portability (PL/SQL is Oracle-specific; Java runs against any database), but this project is deliberately built against Oracle. The real deciding factors are reusability and efficiency.

- **Plain SQL, via JdbcTemplate**: Lookups and perspective reorientation that can be handled in a single query, without PL/SQL or Java.
- **PL/SQL functions/procedures, via SimpleJdbcCall**: Standalone computations over raw tables, stored in reusable database objects and executed closer to the data (avoiding pulling many rows into Java just to process them there). PL/SQL is also used where procedural logic makes plain SQL impractical.
- **Java-side aggregation, on already-fetched data**: Insights derivable from data that another repository's method already fetches for a different purpose. Whether this costs more or less than aggregating in SQL/PL-SQL depends on the data involved (decided case by case, not assumed either way). Java also does things that SQL can't (combining data from multiple repositories, richer error handling, reaching outside the database, ...).

## Setup

Schema setup assumes Oracle Database FREE running locally; adjust datafile paths in `db/schema/00_tablespace_and_user.sql` if using a different edition or install.

1. Run `db/schema/00_tablespace_and_user.sql` as a privileged user (creates the dedicated tablespace and schema)
2. Run `db/schema/01_core_schema.sql` connected as `elo_insights`
3. Run the scripts in `db/triggers/` connected as `elo_insights`, to create the database triggers enforcing business rules
4. Run `db/seed/01_sample_data.sql` to load fictional sample data
5. Run the scripts in `db/functions/` connected as `elo_insights`, to create the PL/SQL functions
6. Copy `src/main/resources/application.properties.example` to `application.properties` and fill in your database credentials
7. Run the Spring Boot application

## API

### Get a player
`GET /players/{playerId}`

Example, `GET /players/3`
Response:
```json
{
    "playerId":3,
    "fullName":"Lucía Fernández",
    "dateOfBirth":"1995-07-22"
}
```
Returns `404` if the player doesn't exist.

### Get a source system
`GET /source-systems/{SourceSystemId}`

Example, `GET /source-systems/1`
Response:
```json
{
    "sourceSystemId":1,
    "code":"ICU",
    "displayName":
    "Irish Chess Union"
}
```

### Get a player's rating history
`GET /players/{playerId}/ratings`

Example, `GET /players/2/ratings`
Response:
```json
[
    {"playerId":2,"sourceSystemId":1,"rating":1571,"effectiveDate":"2026-03-16"},
    {"playerId":2,"sourceSystemId":6,"rating":1595,"effectiveDate":"2026-02-20"},
    {"playerId":2,"sourceSystemId":6,"rating":1612,"effectiveDate":"2026-02-20"},
    {"playerId":2,"sourceSystemId":6,"rating":1604,"effectiveDate":"2026-02-20"}
]
```

### Get a player's match history

`GET /players/{playerId}/matches?source-system-id={id}&opponent-id={id}&tournament-id={id}&from={date}&to={date}`

The query parameters `source-system-id`, `opponent-id`, `tournament-id`, `from`, and `to` are optional filters. If one is omitted, it is not applied. Dates use the `YYYY-MM-DD` format.

No filters, e.g. `GET /players/3/matches`:
Response:
```json
[
    {"matchId":3,"playerId":3,"opponentId":4,"colour":"BLACK","result":"WIN","playedOn":"2026-04-04","sourceSystemId":2,"tournamentId":2},
    {"matchId":4,"playerId":3,"opponentId":9,"colour":"WHITE","result":"DRAW","playedOn":"2026-04-05","sourceSystemId":2,"tournamentId":2}
]
```

Filters can combine, e.g. `GET /players/3/matches?opponent-id=4&from=2026-01-01&to=2026-04-04`:
```json
[
    {"matchId":3,"playerId":3,"opponentId":4,"colour":"BLACK","result":"WIN","playedOn":"2026-04-04","sourceSystemId":2,"tournamentId":2}
]
```

### Get a player's colour performance

`GET /players/{playerId}/matches/colour-performance?source-system-id={id}&opponent-id={id}&tournament-id={id}&from={date}&to={date}`

Returns the player's match performance split by colour. The query parameters `source-system-id`, `opponent-id`, `tournament-id`, `from`, and `to` are optional filters. If one is omitted, it is not applied. Dates use the `YYYY-MM-DD` format.

No filters, e.g. `GET /players/1/matches/colour-performance`:
Response:
```json
{
    "playerId":1,
    "whiteWinsCount":3,
    "blackWinsCount":0,
    "whiteLossesCount":0,
    "blackLossesCount":1,
    "whiteDrawsCount":0,
    "blackDrawsCount":1
}
```

Filters can combine, e.g. `GET /players/3/matches/colour-performance?source-system-id=2&from=2026-01-01&to=2026-04-04`
```json
{
    "playerId":3,
    "whiteWinsCount":0,
    "blackWinsCount":1,
    "whiteLossesCount":0,
    "blackLossesCount":0,
    "whiteDrawsCount":0,
    "blackDrawsCount":0
}
```

### Get a player's rating progression
`GET /players/{playerId}/ratings/progression?source-system-id={id}`

Progression is computed within one source at a time. Each source keeps its own independent rating history for a player, so mixing them would invent a progression that wouldn't be real.

`source-system-id` is required e.g. `GET /players/1/ratings/progression?source-system-id=1`
Response:
```json
[
    {"effectiveDate":"2026-01-10T00:00:00","effectiveRating":1700,"ratingDelta":null,"cumulativeChange":0},
    {"effectiveDate":"2026-02-15T00:00:00","effectiveRating":1720,"ratingDelta":20,"cumulativeChange":20},
    {"effectiveDate":"2026-03-16T00:00:00","effectiveRating":1758,"ratingDelta":38,"cumulativeChange":58}
]
```