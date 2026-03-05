# BizAssist Product Capability Map

**Status:** Canonical (must be followed)  
**Scope:** Product capability ownership across BizAssist_mobile, BizAssist_api, and database domains

This map defines what BizAssist can do, where capability ownership lives, and which invariants apply.  
If a feature does not map cleanly to this document, it requires scope correction or architecture review.

---

## Level 1 Capability Domains

A) Identity & Access  
B) Business & Org  
C) Catalog (Items & Services)  
D) Units & Quantities (UDQI)  
E) Categories  
F) Inventory Ledger  
G) POS Checkout & Sales  
H) Discounts & Pricing Modifiers  
I) Modifiers (Add-ons / Option Sets)  
J) Media & Assets  
K) Reporting & Insights (v1)  
L) Settings Governance (Control Center)  
M) System Operations & Reliability  
N) AI Assistance (Non-Blocking)

---

## A) Identity & Access

### Level 2: Authentication & Session

#### Level 3: Sign In / Sign Out
Owner Surface: Workspace-owned (`Home` entry)  
Mobile: Login/logout UX, secure token storage, session handoff to app shell  
API: Credential validation, token issuance, session invalidation  
DB: `User`, session/token records (if persisted), audit fields  
Entities: `User`, `StaffMembership`  
Invariants: Authorization invariants, structured error invariants  
Exclusions/Notes: No staff self-registration in v1

#### Level 3: Password Recovery / Reset
Owner Surface: Workspace-owned (`Home` entry)  
Mobile: Request-reset + reset form flows  
API: Reset token generation/verification and password update  
DB: `User`, reset token artifacts  
Entities: `User`  
Invariants: Authorization invariants, observability for security events  
Exclusions/Notes: No social auth in v1

### Level 2: Authorization & Access Scope

#### Level 3: Business-Scoped Access Enforcement
Owner Surface: System-wide cross-cutting  
Mobile: Pass `activeBusinessId` context with protected requests  
API: Enforce auth + business scope + membership checks on protected routes  
DB: `StaffMembership` lookup constraints and indexes  
Entities: `User`, `Business`, `StaffMembership`  
Invariants: Authorization invariants (auth + activeBusiness + membership)  
Exclusions/Notes: No cross-business data visibility in v1

---

## B) Business & Org

### Level 2: Business Lifecycle

#### Level 3: Business Creation (v1 single-business)
Owner Surface: Settings-owned bootstrap flow  
Mobile: Create-business onboarding flow  
API: Business create endpoint and owner linkage  
DB: `Business` with `ownerId` relationship  
Entities: `Business`, `User`, `StaffMembership`  
Invariants: Archive-only lifecycle, authorization invariants  
Exclusions/Notes: No multi-store/multi-business switching in v1

### Level 2: Staff Membership

#### Level 3: Staff Invite/Assignment (Controlled)
Owner Surface: Settings-owned  
Mobile: Staff management screens  
API: Membership create/update/archive endpoints  
DB: `StaffMembership` table with role constraints  
Entities: `StaffMembership`, `User`, `Business`  
Invariants: Authorization invariants, archive-only lifecycle  
Exclusions/Notes: No open invite/public join in v1

---

## C) Catalog (Items & Services)

### Level 2: Product Lifecycle

#### Level 3: Create Item / Service
Owner Surface: Inventory workspace-owned process (with Settings pickers)  
Mobile: Sectioned form UI, validation, bottom CTA governance  
API: Product create with domain validation and ownership checks  
DB: `Product` with references to `Unit`, `Category`, optional media  
Entities: `Product`, `Unit`, `Category`  
Invariants: UDQI quantity compatibility, archive-only lifecycle, pricing integrity  
Exclusions/Notes: No hard delete; no modal-card full-form pattern

#### Level 3: Edit / Archive / Restore Product
Owner Surface: Inventory workspace-owned  
Mobile: Detail + process flows with Exit governance  
API: Update and lifecycle transition endpoints  
DB: `Product` lifecycle state updates  
Entities: `Product`  
Invariants: Archive-only lifecycle, pricing integrity for historical sales  
Exclusions/Notes: Archived products cannot be used for new sales

### Level 2: Catalog Browsing

#### Level 3: Inventory List and Item Detail
Owner Surface: Inventory workspace-owned  
Mobile: List/detail experience, search/filter UI  
API: Paginated product list/detail endpoints  
DB: Product search indexes, business-scoped queries  
Entities: `Product`, `Category`, `Unit`  
Invariants: Authorization invariants, archive visibility rules  
Exclusions/Notes: No list-level destructive hard delete actions

---

## D) Units & Quantities (UDQI)

### Level 2: Unit Definitions

#### Level 3: Unit Lifecycle Management
Owner Surface: Settings-owned  
Mobile: Unit create/edit/archive forms  
API: Unit lifecycle endpoints with compatibility checks  
DB: `Unit` with `precisionScale` and archive state  
Entities: `Unit`  
Invariants: UDQI precision invariants, archive-only lifecycle  
Exclusions/Notes: No unit deletion when referenced

### Level 2: Quantity Enforcement

#### Level 3: Quantity Parsing/Normalization
Owner Surface: Cross-cutting (Inventory + POS + Settings)  
Mobile: Quantity input behavior and sanitization  
API: Server-side precision validation and normalization  
DB: Fixed-point integer quantity storage  
Entities: `Unit`, `InventoryMovement`, `SaleLineItem`  
Invariants: UDQI precision, no floating-point quantities  
Exclusions/Notes: No float persistence for domain quantities

---

## E) Categories

### Level 2: Category Lifecycle

#### Level 3: Category Create/Edit/Archive/Restore
Owner Surface: Settings-owned  
Mobile: Category management screens in Settings  
API: Category lifecycle endpoints  
DB: `Category` records scoped to business  
Entities: `Category`  
Invariants: Archive-only lifecycle, authorization invariants  
Exclusions/Notes: Inventory and POS consume categories but do not own lifecycle

### Level 2: Category Consumption

#### Level 3: Category Assignment to Products
Owner Surface: Inventory workspace integration  
Mobile: Picker integration in product forms  
API: Product-category association validation  
DB: Foreign key from `Product` to `Category`  
Entities: `Product`, `Category`  
Invariants: Authorization invariants, archive rules for assignment eligibility  
Exclusions/Notes: No category lifecycle mutation from Inventory module

---

## F) Inventory Ledger

### Level 2: Movement Recording

#### Level 3: Stock In / Stock Out / Adjustment
Owner Surface: Inventory workspace-owned  
Mobile: Adjust/receive stock process screens  
API: Movement create endpoints with validation guards  
DB: Immutable `InventoryMovement` records  
Entities: `InventoryMovement`, `Product`, `Unit`  
Invariants: Append-only ledger, UDQI precision, authorization invariants  
Exclusions/Notes: No direct mutable stock edits

#### Level 3: Movement from POS Sale/Return
Owner Surface: POS-owned transaction integration (writes Inventory movements)  
Mobile: Checkout/return operational flows  
API: Transactional sale completion producing movement rows  
DB: Atomic write of `Sale`, `SaleLineItem`, `Payment`, `InventoryMovement`  
Entities: `Sale`, `SaleLineItem`, `Payment`, `InventoryMovement`, `Product`  
Invariants: Ledger invariants, sale finality, pricing integrity  
Exclusions/Notes: No partial sale finalization without corresponding movement write

### Level 2: Inventory Read Models

#### Level 3: On-Hand Quantity and Movement History
Owner Surface: Inventory workspace-owned  
Mobile: Product activity history and quantity display  
API: Derived stock read endpoints and movement history endpoints  
DB: Ledger aggregation queries + movement indexes  
Entities: `InventoryMovement`, `Product`  
Invariants: Inventory totals derived from movements only  
Exclusions/Notes: No persisted mutable "source-of-truth stock" column

---

## G) POS Checkout & Sales

### Level 2: Cart and Checkout

#### Level 3: Cart Management (Ephemeral)
Owner Surface: POS workspace-owned  
Mobile: Cart add/remove/update and local computation  
API: Optional server-assisted validations  
DB: No persistent cart requirement in v1  
Entities: `Product` (read), transient cart model  
Invariants: Deterministic pricing inputs, UDQI quantity validation  
Exclusions/Notes: Cart is temporary and non-ledger

#### Level 3: Checkout Finalization
Owner Surface: POS workspace-owned  
Mobile: Payment entry and confirm flow  
API: Atomic transaction for sale finalization  
DB: Persist `Sale`, `SaleLineItem`, `Payment`, and `InventoryMovement` together  
Entities: `Sale`, `SaleLineItem`, `Payment`, `InventoryMovement`, `Product`  
Invariants: Financial totals, payment reconciliation, sale finality, ledger invariants  
Exclusions/Notes: No AI-assisted transactional decisioning

### Level 2: Sales History

#### Level 3: Sale Detail and Receipt Access (v1 minimal)
Owner Surface: POS workspace-owned  
Mobile: Sale history list/detail minimal views  
API: Sale list/detail endpoints  
DB: Sales indexes by business/date  
Entities: `Sale`, `SaleLineItem`, `Payment`  
Invariants: Sale finality and pricing integrity  
Exclusions/Notes: No full accounting subsystem in v1

---

## H) Discounts & Pricing Modifiers

### Level 2: Discount Definitions

#### Level 3: Discount Lifecycle Management
Owner Surface: Settings-owned  
Mobile: Discount create/edit/archive forms  
API: Discount lifecycle endpoints and validation  
DB: `Discount` definitions scoped to business  
Entities: `Discount` (domain config)  
Invariants: Archive-only lifecycle, authorization invariants  
Exclusions/Notes: No ad hoc discount schema outside Settings ownership

### Level 2: Discount Application

#### Level 3: Apply Discounts in POS
Owner Surface: POS workspace integration  
Mobile: Discount selection and preview in checkout flow  
API: Discount resolution and total computation  
DB: Discount definition reads + sale discount snapshot fields  
Entities: `Discount`, `Sale`, `SaleLineItem`  
Invariants: Financial invariants, pricing integrity, sale finality  
Exclusions/Notes: No AI-generated discount application in transaction path

---

## I) Modifiers (Add-ons / Option Sets)

### Level 2: Modifier Definition

#### Level 3: Modifier Set and Option Lifecycle
Owner Surface: Settings-owned  
Mobile: Modifier set/option management screens  
API: Modifier lifecycle endpoints and constraint validation  
DB: `ModifierSet`, `ModifierOption` with archive state  
Entities: `ModifierSet`, `ModifierOption`  
Invariants: Archive-only lifecycle, modifier constraint integrity  
Exclusions/Notes: No direct POS ownership of modifier definitions

### Level 2: Modifier Usage

#### Level 3: Modifier Selection in POS/Item Flows
Owner Surface: POS workspace integration (Inventory for product attachment flows)  
Mobile: Selection UX enforcing min/max constraints  
API: Price impact validation and sale snapshot writes  
DB: Sale line snapshots for selected modifiers (if modeled), definition lookups  
Entities: `ModifierSet`, `ModifierOption`, `SaleLineItem`  
Invariants: Modifier price-only rule, financial invariants, sale finality  
Exclusions/Notes: Modifiers must never drive inventory quantity mutation

---

## J) Media & Assets

### Level 2: Media Intake Pipeline

#### Level 3: Product Image Upload and Normalization
Owner Surface: Inventory workspace (consumes Media module)  
Mobile: Crop/preview/upload UX using signed URL flow  
API: Signed upload URL issuance + metadata association  
DB: Media metadata and product-media references  
Entities: `Product`, media metadata entity  
Invariants: Media invariants (signed URLs, deterministic paths), authorization invariants  
Exclusions/Notes: Clients cannot select arbitrary bucket paths

### Level 2: Media Rendering

#### Level 3: Product Image Display
Owner Surface: Inventory and POS workspaces  
Mobile: Render normalized product images across list/detail/POS surfaces  
API: Serve metadata + access URLs  
DB: Media linkage retrieval  
Entities: `Product`, media metadata entity  
Invariants: Authorization for protected asset access  
Exclusions/Notes: No bypass of media pipeline

---

## K) Reporting & Insights (v1)

### Level 2: Operational Summaries

#### Level 3: Sales and Inventory Snapshot Metrics
Owner Surface: Home workspace-owned (summary only)  
Mobile: Dashboard cards and trend summaries  
API: Aggregated read endpoints  
DB: Aggregation queries over `Sale` and `InventoryMovement`  
Entities: `Sale`, `SaleLineItem`, `InventoryMovement`, `Product`  
Invariants: Ledger-derived inventory, sale finality  
Exclusions/Notes: No advanced BI modeling in v1

### Level 2: Export/Analysis Readiness

#### Level 3: Structured Reporting Feeds (v1 basic)
Owner Surface: Settings/Home integration  
Mobile: Basic export trigger surfaces (if enabled)  
API: Structured export endpoints with scoped filtering  
DB: Indexed query paths for export windows  
Entities: `Sale`, `Product`, `InventoryMovement`, `Category`, `Unit`  
Invariants: Authorization invariants, historical immutability  
Exclusions/Notes: No real-time warehouse integrations in v1

---

## L) Settings Governance (Control Center)

### Level 2: Configuration Ownership

#### Level 3: Centralized Lifecycle for Units/Categories/Discounts/Modifiers
Owner Surface: Settings-owned  
Mobile: Settings module lifecycle screens and pickers  
API: Settings namespace endpoints for config entities  
DB: Config entity tables with archive state  
Entities: `Unit`, `Category`, `Discount`, `ModifierSet`, `ModifierOption`  
Invariants: Archive-only lifecycle, authorization invariants  
Exclusions/Notes: Operational modules consume settings data, do not own lifecycle

### Level 2: Policy & Limits Configuration (v1 placeholders)

#### Level 3: Guardrail and Policy Stubs
Owner Surface: Settings-owned  
Mobile: Placeholder controls for future policy expansion  
API: Read/write placeholders where approved  
DB: Policy configuration records (if enabled)  
Entities: policy config entity (future), `Business`  
Invariants: Authorization invariants  
Exclusions/Notes: No dynamic policy engine in v1

---

## M) System Operations & Reliability

### Level 2: Runtime Integrity

#### Level 3: Global Busy Overlay + Duplicate Submission Prevention
Owner Surface: Cross-workspace UI governance  
Mobile: withBusy / disabled CTA behavior for async writes  
API: Idempotency-safe write handling where applicable  
DB: Transaction boundaries and uniqueness safeguards  
Entities: cross-domain write entities  
Invariants: System invariants fail-fast, sale/ledger integrity  
Exclusions/Notes: No per-button spinner as primary global pattern

#### Level 3: Structured Error + Correlation Logging
Owner Surface: API reliability ownership  
Mobile: User-readable error surfaces and retry affordances  
API: Structured error responses with codes; correlation IDs in logs  
DB: Optional error/event audit storage  
Entities: operational telemetry entities  
Invariants: Observability rule for invariant violations  
Exclusions/Notes: No sensitive data in logs

### Level 2: Release Safety

#### Level 3: Regression Gates and Rollback Readiness
Owner Surface: Engineering process governance  
Mobile: Feature flags/controlled rollouts where applicable  
API: Backward-compatible contract enforcement  
DB: Migration safety and non-destructive evolution  
Entities: release metadata (process-level)  
Invariants: Schema safety, backward compatibility, system invariants  
Exclusions/Notes: No uncontrolled big-bang release for critical domains

---

## N) AI Assistance (Non-Blocking)

### Level 2: Assistive Suggestions

#### Level 3: AI Catalog Assist (Copy/Tags/Enrichment Suggestions)
Owner Surface: Inventory/Settings assistive surfaces  
Mobile: Suggestion UI with explicit user confirmation  
API: Assistive suggestion endpoints only  
DB: Optional suggestion logs; no authoritative writes without user action  
Entities: `Product` (read context), suggestion artifact  
Invariants: AI assistive-only rule, no transactional override  
Exclusions/Notes: AI cannot auto-commit catalog changes without user approval

### Level 2: Operational Guidance

#### Level 3: AI Hints for Optimization (Non-Transactional)
Owner Surface: Home/Reporting assistive surfaces  
Mobile: Insight cards and recommendations  
API: Recommendation generation endpoints  
DB: Historical read-only analysis inputs  
Entities: `Sale`, `InventoryMovement`, `Product` (read context)  
Invariants: AI excluded from transaction logic and ledger mutation  
Exclusions/Notes: No AI-driven pricing/tax/payment execution in v1

---

## Mandatory Ownership Law (Applied)

- Settings-owned capabilities:
  - Categories lifecycle
  - Units lifecycle
  - Discounts lifecycle
  - Modifiers lifecycle
  - Policy/limits configuration placeholders
- Inventory workspace capabilities:
  - inventory browse/detail/activity
  - create/edit items/services
  - stock adjustments (movement creation)
- POS workspace capabilities:
  - product selection for checkout
  - cart management (ephemeral)
  - checkout finalization (`Sale` + `Payment` + `InventoryMovement`)
  - sale history/detail (minimal v1)
- Home workspace capabilities:
  - system entry and quick actions only
  - no deep management ownership

---

## Explicit v1 Exclusions

- no hard deletes for persisted business entities
- no AI-driven pricing, tax, or payment decision logic
- no multi-store/multi-business operations in v1
- no staff self-registration in v1
- no variable pricing engine for core catalog unless explicitly governed
- no CRM automation as core scope (deferred)
- no advanced accounting integrations as core scope (deferred)
- no offline-first implied correctness; correctness remains online-authoritative unless explicit offline design is approved

---

## Capability Change Governance

- Every feature proposal must map to an existing capability.
- If no fit exists, propose a new capability and trigger architecture review.
- Overlap handling must define:
  - primary owner capability
  - secondary integration points
- No feature enters implementation without capability assignment.
