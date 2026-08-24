# ELO Insights Engine

Backend analytics engine that ingests player, match, and rating history data from external sources and computes performance insights — volatility, consistency, opponent strength, rating progression — exposed via a JSON API.

This is an analytics engine, not a rating calculator. Ratings are received from external sources (federations, clubs, online platforms, etc.); nothing in this project computes or derives a rating.

## Data model

![Relational model](docs/relational-model.svg)

Full schema: [`db/schema/01_core_schema.sql`](db/schema/01_core_schema.sql)

## Stack

- Oracle Database (FREE 26ai), PL/SQL
- Java 21, Spring Boot, Maven
- REST JSON API

## Project structure

```
db/
├── schema/     core DDL, tablespace/user setup
├── seed/       fictional sample data
└── queries/
    ├── identity/    queries finding merged and unresolved cross-system player identities
    └── insights/    standalone analytics queries (colour win rates, etc.)
docs/           architecture and data model diagrams
src/            Spring Boot application
```

## Known limitations

- **Cross-source identity resolution**: different rating sources each have their own player reference, but they don’t share one across systems, so the engine has no way to know when two players from different sources are actually the same person. This reflects how the surrounding chess infrastructure works — players move between federations, and even FIDE’s ID system doesn’t prevent identity fragmentation across federations or platforms.
- **Rating attribution granularity**: how often a source reports rating updates varies — per event, per game, or on a fixed period. A source that batches several events into one update can't be split back apart; figures like gain per tournament or per colour aren't answerable from a batched source.

## Setup

Schema setup assumes Oracle Database FREE running locally; adjust datafile paths in `db/schema/00_tablespace_and_user.sql` if using a different edition or install.

1. Run `db/schema/00_tablespace_and_user.sql` as a privileged user (creates the dedicated tablespace and schema)
2. Run `db/schema/01_core_schema.sql` connected as `elo_insights`
3. Run `db/seed/01_sample_data.sql` to load fictional sample data
4. Copy `src/main/resources/application.properties.example` to `application.properties` and fill in your database credentials
5. Run the Spring Boot application
