# BizAssist System Invariants & Guardrails

**Status:** Canonical (must be followed)  
**Scope:** BizAssist_mobile + BizAssist_api + PostgreSQL + infrastructure integrations

System invariants protect financial correctness, inventory integrity, and historical truth. If an invariant is violated, the operation must fail.

---

## Purpose

System invariants guarantee:
- money calculations remain correct
- inventory remains accurate
- domain entities remain valid
- historical records cannot be corrupted

Correctness overrides convenience.

---

## Inventory Invariants

- Inventory quantity is derived from immutable `InventoryMovement` records.
- Mutable stock totals must not be treated as source-of-truth.
- `InventoryMovement` records are immutable after write.
- Allowed movement types only:
  - `STOCK_IN`
  - `STOCK_OUT`
  - `ADJUSTMENT`
  - `SALE`
  - `RETURN`
- Direct stock mutation is forbidden.
- Every movement must include:
  - `productId`
  - `quantity`
  - `movementType`
  - `timestamp`

---

## Quantity Invariants (UDQI)

- Quantities must respect `Unit.precisionScale`.
- Quantities must be stored as fixed-point integers.
- Floating-point quantity storage is forbidden.
- Example constraints:
  - `precisionScale = 0` -> whole units only
  - `precisionScale = 2` -> increments of 0.01

---

## Financial Invariants

- Sale totals must equal sum of line items:
  - `Sale.totalAmount = sum(SaleLineItem.quantity * SaleLineItem.unitPrice)`
- Sum of payments must equal sale total:
  - `sum(Payment.amount) = Sale.totalAmount`
- Negative totals are forbidden.

---

## Pricing Invariants

- `SaleLineItem.unitPrice` is the historical price at moment of sale.
- Product price changes must not alter historical sales.
- Historical sales data is immutable after completion.

---

## Modifier Invariants

- Modifiers affect price only.
- Modifiers must never mutate inventory quantities.
- Modifier selection constraints must be enforced (`minSelected`, `maxSelected`).

---

## Sale Finality Invariants

Once completed:
- sale line items must not change
- sale totals must not change
- linked inventory movements must be preserved

Completed sales are immutable records.

---

## Lifecycle Invariants

- Persisted business entities follow archive-only lifecycle.
- Destructive deletion of business entities is prohibited.
- Canonical transitions:
  - `ACTIVE -> ARCHIVED`
- Archived entities must not be used in new transactions.
- Historical references to archived entities remain valid.

---

## Authorization Invariants

All protected operations must validate:
- authenticated user
- `activeBusinessId`
- staff membership

Unauthorized operations must fail immediately.

---

## Media Invariants

- Product media must follow approved media pipeline.
- Images must be cropped/normalized.
- Uploads must use signed URLs.
- Storage paths must be deterministic.
- Clients must never directly control storage bucket paths.

---

## Failure Principle

If an invariant is violated:
- reject operation immediately
- never silently correct invalid state
- never ignore violations

Examples:
- reject invalid inventory movement
- reject invalid quantity precision
- reject incorrect sale totals
- reject unauthorized mutation

---

## Observability Rule

Invariant violations must be logged with:
- violation type
- affected entity
- user context
- request `correlationId`

---

## Guardrail Enforcement Layers

Critical rules must be enforced in multiple layers:
- API validation
- service-layer checks
- database constraints

Client-side validation alone is never sufficient.

---

## Final Principle

BizAssist is a financial and inventory system. No feature implementation may violate system invariants.
