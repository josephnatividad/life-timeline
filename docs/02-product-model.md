# Product Model

## Core model

Do not model everything as a generic timeline entry.

### Entity

A persistent thing, place, organization or concept in the user's
history.

Examples:

-   MacBook Air
-   Honda Civic
-   Passport
-   Employer
-   University
-   Home
-   Trip destination

### Event

Something that happened at a point or period in time.

Examples:

-   Purchased
-   Sold
-   Renewed
-   Graduated
-   Joined company
-   Promoted
-   Moved
-   Traveled
-   Repaired

### Evidence

Information supporting an event or entity.

Examples:

-   Receipt
-   Photo
-   PDF
-   Certificate
-   Ticket
-   Screenshot
-   Imported metadata

### Relationship

A typed connection.

Examples:

-   event `purchased` entity
-   phone `replaced` previous phone
-   employment event `at` company
-   trip `visited` place
-   evidence `supports` event

## Provenance

Every extracted or inferred field should be able to retain:

``` text
value
source_id
source_type
extraction_method
confidence
user_confirmed
created_at
updated_at
```

AI output must never silently become authoritative history.

## Temporal precision

Historical memories are often imprecise. The data model must support:

``` text
EXACT       2026-08-08
MONTH       2026-08
YEAR        2016
APPROXIMATE around 2012
RANGE       2018–2020
BEFORE      before 2010
AFTER       after 2010
UNKNOWN
```

Never manufacture an exact date to satisfy a database schema.

## Record lifecycle

Recommended states:

``` text
candidate
confirmed
archived
deleted_soft
```

Candidates live in the Memory Inbox until confirmed.

## Memory Inbox

All automatically discovered or imported candidate memories should
appear here first.

Nothing should silently enter permanent personal history.

Possible actions:

-   Confirm
-   Edit then confirm
-   Link to existing entity
-   Ignore
-   Delete candidate

## Duplicate/entity resolution

Before creating a new entity, attempt local matching against existing
entities.

Example:

``` text
Possible match
MacBook Air M4
92% likely the same device

[Link] [Create New]
```

The user remains the final authority.
