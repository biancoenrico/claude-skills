#!/bin/sh
# A ~60-line spec, complete except for one silent gap: it never says what happens when
# `from`..`to` spans more than a year (no limit, no rejection, no truncation — never named).
set -eu

cat > spec.md <<'EOF'
# Transaction export — spec

## Purpose

Let an authenticated user download their transaction history as a CSV file for a given date
range, for use in spreadsheets and accounting tools.

## Endpoint

`GET /api/reports/export`

## Request

Query parameters:

- `from` — date, `YYYY-MM-DD`, required.
- `to` — date, `YYYY-MM-DD`, required.
- `account_id` — integer, required. Must belong to the authenticated user.

Header: `Authorization: Bearer <token>`, required.

## Response, success

`200 OK`, `Content-Type: text/csv`,
`Content-Disposition: attachment; filename="transactions.csv"`.

Columns, in order: `date`, `description`, `amount`, `balance`. One row per transaction, sorted
by date ascending. Amounts are formatted with two decimal places and no currency symbol.

## Response, no transactions in range

`200 OK`, a CSV with only the header row. Not an error.

## Error cases

- Missing or invalid `Authorization` header: `401 Unauthorized`, body
  `{"error": "unauthenticated"}`.
- `account_id` does not belong to the authenticated user: `403 Forbidden`, body
  `{"error": "forbidden"}`.
- `account_id` does not exist at all: `404 Not Found`, body `{"error": "account_not_found"}`.
- `from` or `to` missing, or not a valid `YYYY-MM-DD` date: `400 Bad Request`, body
  `{"error": "invalid_date", "field": "from"|"to"}`.
- `from` later than `to`: `400 Bad Request`, body `{"error": "invalid_range"}`.
- `to` in the future: clamp `to` to today's date rather than rejecting the request; the
  response still succeeds.

## Rate limiting

At most 10 export requests per user per hour. Beyond that, `429 Too Many Requests`, body
`{"error": "rate_limited", "retry_after": <seconds>}`.

## Logging

Every export request is logged with the user id, the account id, the date range and the
resulting row count, for billing and support purposes. No transaction contents are logged.

## Performance

The endpoint streams rows as they are read from storage rather than building the whole CSV in
memory first, so the response starts before the query finishes.
EOF
