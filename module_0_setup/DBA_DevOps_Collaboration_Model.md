# DBA & DevOps Collaboration Model
## AdventureWorks Inventory Accuracy & ICQA Analytics Program

## Purpose
Define database and delivery practices supporting secure, performant, maintainable analytics.

## DBA Collaboration
- Read-only access model for analytics users
- Indexing awareness for high-volume queries
- Avoid SELECT * in production queries
- Query performance reviewed prior to release
- Change control for views/stored procedures (if introduced)

## DevOps Collaboration
- Version-controlled artifacts
- Sprint release notes and test evidence
- Incremental automation (CI) as the program matures
