# BizAssist Domain Model Bible

**Status:** Canonical (must be followed)  
**Scope:** BizAssist_mobile + BizAssist_api + database + reporting + analytics + AI readers

This document defines the canonical business entities and invariants for BizAssist. If implementation conflicts with this model, implementation is wrong and must be corrected.

---

## Purpose

The Domain Model Bible exists to:
- define canonical business entities
- establish domain invariants
- prevent inconsistent feature implementations
- maintain product correctness
- ensure financial and inventory accuracy

---

## Non-Negotiable Domain Principles

### Inventory-First Architecture
- Inventory is the system of record for product quantities.
- POS transactions must integrate with inventory movements.

### Append-Only Inventory Ledger
- Inventory history is immutable.
- Stock changes occur only through inventory movement records.
- Movement types:
  - `STOCK_IN`
  - `STOCK_OUT`
  - `ADJUSTMENT`
  - `SALE`
  - `RETURN`
- Direct stock editing is prohibited.

### UDQI Quantity System
- Quantity behavior is governed by `Unit.precisionScale`.
- Quantities are stored as fixed-point integers.
- Floating-point quantity storage is prohibited.

### Archive-Only Lifecycle
- Persisted business entities follow lifecycle states rather than destructive delete.
- Canonical states:
  - `ACTIVE`
  - `ARCHIVED`

---

## Canonical Core Entities

### User
- Represents a human operator.
- Canonical attributes:
  - `id`
  - `firstName`
  - `lastName`
  - `email`
  - `passwordHash`

### Business
- Represents a merchant account.
- Canonical attributes:
  - `id`
  - `name`
  - `ownerId`
  - `createdAt`
- v1 constraint: each user may create one business.

### StaffMembership
- Defines relationship between users and businesses.
- Canonical attributes:
  - `userId`
  - `businessId`
  - `role`
- Canonical roles:
  - `OWNER`
  - `STAFF`

### Product
- Represents a sellable catalog item.
- Canonical attributes:
  - `id`
  - `name`
  - `type`
  - `price`
  - `unitId`
  - `categoryId`
- Canonical product types:
  - `PHYSICAL`
  - `SERVICE`

### Unit
- Defines quantity behavior.
- Canonical attributes:
  - `id`
  - `name`
  - `abbreviation`
  - `precisionScale`

### Category
- Represents product grouping.
- Canonical attributes:
  - `id`
  - `name`
  - `businessId`
- Category lifecycle is owned by Settings.

### ModifierSet
- Represents configurable option groups attached to products/services.
- Canonical attributes:
  - `id`
  - `name`
  - `selectionType`
  - `minSelected`
  - `maxSelected`

### ModifierOption
- Represents selectable modifier entries.
- Canonical attributes:
  - `id`
  - `modifierSetId`
  - `name`
  - `priceDelta`
- Modifier options affect price only.

### Sale
- Represents a completed POS transaction.
- Canonical attributes:
  - `id`
  - `businessId`
  - `totalAmount`
  - `createdAt`
- Completed sales must generate inventory movements where inventory tracking applies.

### SaleLineItem
- Represents items sold within a sale.
- Canonical attributes:
  - `saleId`
  - `productId`
  - `quantity`
  - `unitPrice`

### Payment
- Represents payment applied to a sale.
- Canonical attributes:
  - `saleId`
  - `amount`
  - `method`

### InventoryMovement
- Represents immutable stock changes.
- Canonical attributes:
  - `productId`
  - `movementType`
  - `quantity`
  - `createdAt`
- Canonical movement types:
  - `STOCK_IN`
  - `STOCK_OUT`
  - `ADJUSTMENT`
  - `SALE`
  - `RETURN`

---

## Domain Invariants

### Inventory Integrity
- Stock totals are derived from `InventoryMovement` records.
- Mutable persisted stock totals are prohibited as source-of-truth.

### Pricing Integrity
- `SaleLineItem.unitPrice` is snapshotted at sale finalization.
- Later product price changes must not rewrite historical sales.

### Unit Integrity
- Quantities must conform to `Unit.precisionScale`.
- Example:
  - `precisionScale = 0` means whole units only.
  - `precisionScale = 2` means 0.01 precision.

### Modifier Integrity
- Modifiers influence price only.
- Modifiers must not change inventory quantity calculations.

### Sales Finality
- Once finalized:
  - sale line items are immutable
  - financial totals are immutable
  - linked inventory movements are preserved

---

## POS Domain Rules

- Cart is temporary state.
- Sale is permanent state.
- Only finalized sales affect inventory.
- Inventory movement creation must occur within checkout transaction guarantees.

---

## Service Domain Rules

- Services must have `trackInventory = false`.
- Services may use time-based units (for example `Hour`, `Session`).

---

## Domain Extensibility Rule

- Reporting, analytics, and AI features may read canonical domain entities.
- These features must not redefine core domain behavior or invariants.

---

## Enforcement Principle

The Domain Model Bible is the canonical truth of BizAssist domain behavior. API logic, mobile UI, database schema, and downstream analysis systems must conform to this model.
