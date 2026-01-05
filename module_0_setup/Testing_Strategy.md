# Testing Strategy
## AdventureWorks Inventory Accuracy & ICQA Analytics Program

## Objective
Ensure analytical outputs are accurate, stable, and release-ready through structured
testing aligned with enterprise analytics delivery.

## Smoke Tests (Every Sprint)
Confirm system readiness:
- SQL Server connectivity verified
- Source tables exist and contain data
- Core KPI queries execute successfully
- Excel dashboards refresh without errors
- Power BI refresh succeeds (future sprints)

## Functional Tests (Every Sprint)
Validate business correctness:
- On-hand and variance calculations match expected logic at correct grain
- Accuracy% values are within valid ranges (0100)
- Joins do not multiply rows unexpectedly
- Invalid values are flagged explicitly

## Automation Roadmap
- Phase 1: SQL validation scripts returning PASS/FAIL results
- Phase 2: Python runner to execute validations
- Phase 3: CI execution via GitHub Actions
