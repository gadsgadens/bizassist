# BizAssist Feature Lifecycle Governance

**Status:** Canonical (must be followed)  
**Scope:** BizAssist_mobile + BizAssist_api + database + release process

This document governs how features move from idea to implementation and release. No feature may skip lifecycle stages.

---

## Purpose

Feature Lifecycle Governance exists to:
- prevent chaotic feature development
- ensure architectural compliance
- ensure domain model alignment
- reduce rework
- protect system integrity

---

## Mandatory Lifecycle Stages

All features must follow:

`Idea -> Discovery -> Decision -> Feature Ticket -> Implementation -> Release -> Iteration`

No stage skipping is permitted.

---

## Stage Definitions

### 1) Idea
- Capture potential improvements from:
  - product roadmap
  - customer feedback
  - internal improvement proposals
  - architectural evolution
- Ideas must be documented before implementation work begins.

### 2) Discovery
- Evaluate:
  - problem being solved
  - product impact
  - architecture impact
  - domain impact
- Discovery must explicitly answer:
  - what problem is solved
  - how it supports BizAssist strategy
  - whether it impacts Inventory, POS, domain model, or architecture

### 3) Decision
- Allowed outcomes:
  - `Approved`
  - `Rejected`
  - `Deferred`
- If architecture is materially affected, create/update ADR records before implementation.

### 4) Feature Ticket
- Approved work must be converted to a structured feature ticket with:
  - context anchor
  - feature idea
  - mode selection (`Discovery Mode` or `Implementation Mode`)
  - ownership boundaries (mobile, api, database, domain model)
  - technical constraints
  - acceptance criteria
  - regression targets

### 5) Implementation
- Required compliance checks:
  - Architecture Lawbook
  - ADR alignment
  - Domain Model Bible
  - System Invariants & Guardrails
  - Technical Standards Manual

### 6) Release
- Release requirements:
  - regression testing complete
  - domain invariants verified
  - feature integration validated against existing modules

### 7) Iteration
- Allowed post-release evolution:
  - UX improvements
  - performance improvements
  - bug fixes
- Iterations must not violate prior architectural decisions or invariants.

---

## Governance Rules

- Inventory-first architecture must remain intact.
- POS must remain tablet-first.
- AI features must remain assistive-only.
- Transactional logic must remain deterministic.

---

## Complexity Escalation Rule

Features that significantly alter system behavior require architecture review, including:
- new domain entities
- new pricing models
- inventory logic changes
- POS workflow changes

---

## Rollback Principle

Features must be reversible. If instability occurs in release, the feature must be disable-able or rollback-capable.

---

## Documentation Rule

Major features must include documentation covering:
- feature flow
- domain impact
- architectural considerations

---

## Final Principle

Feature delivery must be disciplined. Speed without governance creates chaos; lifecycle governance preserves architectural integrity while enabling controlled product evolution.
