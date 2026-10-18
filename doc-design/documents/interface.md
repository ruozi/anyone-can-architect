# Doc Design: interface

## 1 Purpose

The external interface contract of a unit, sufficient for callers to use the unit correctly by reading this doc alone
A unit can be as large as the entire project or as small as any module within it

The unit's purpose and value belong in [readme](readme.md)
Internal implementation and white-box tests of internal mechanisms belong in [class-design](class-design.md)
Black-box tests of external contracts belong in [testcase](testcase.md)
Topology between modules belongs in [architecture](architecture.md)

## 2 Structure

Use only two levels: [chapter](../../CONTEXT.md#chapter) and [section](../../CONTEXT.md#section)
A [chapter](../../CONTEXT.md#chapter) has either no [section](../../CONTEXT.md#section) or two or more [section](../../CONTEXT.md#section) entries

Structure outline:

```text
## 1 Public Contracts           As needed · Data contract
## 2 <business activity type>
### 2.1 Shared Contracts        As needed · Data contract
### 2.2 <interface>          Module interface
### 2.3 <interface>          Module interface
## 3 <interface>             When the business has only one interface, the chapter itself is the interface · Module interface
```

- Public contracts [chapter](../../CONTEXT.md#chapter): contracts shared by interfaces for different business activities
- A [chapter](../../CONTEXT.md#chapter) for one type of business activity: one [section](../../CONTEXT.md#section) per interface
  - Shared contracts [section](../../CONTEXT.md#section): contracts shared within this type of business activity

## 3 Writing Steps

1. Understand and list all content before writing
   - Understand the business: which business activity each interface serves
   - Understand the data structures: which data structures each interface uses
2. Determine the public contracts
   - If data structures or validation contracts are shared by interfaces for different business activities: place them in the first [chapter](../../CONTEXT.md#chapter) and use the data contract pattern
   - Otherwise: skip
3. Divide the content into [chapter](../../CONTEXT.md#chapter) and [section](../../CONTEXT.md#section) entries
   - Group interfaces into several [chapter](../../CONTEXT.md#chapter) entries by business activity, using business language for names, not protocol verbs, paths, or method names
   - A [chapter](../../CONTEXT.md#chapter) containing only one interface is that interface, with no [section](../../CONTEXT.md#section)
   - If a [chapter](../../CONTEXT.md#chapter) containing multiple interfaces has data structures or validation contracts shared by multiple interfaces: place them in its first [section](../../CONTEXT.md#section) and use the data contract pattern
   - In a [chapter](../../CONTEXT.md#chapter) containing multiple interfaces, use one [section](../../CONTEXT.md#section) per interface, with names in business language
4. Write each interface: use the module interface pattern, add no explanatory notes, and do not list callers

## 4 Example

A project-level interface with a public contracts [chapter](../../CONTEXT.md#chapter) and a shared contracts [section](../../CONTEXT.md#section) for order acceptance:

| Chapter or section | pattern |
| --- | --- |
| `## 1 Public Contracts` | Heading only |
| `### 1.1 Error Bodies and Error Codes` | [Data contract](../patterns/schema.md) |
| `### 1.2 Common Types` | [Data contract](../patterns/schema.md) |
| `## 2 Order Acceptance` | Heading only |
| `### 2.1 Shared Order Types` | [Data contract](../patterns/schema.md) |
| `### 2.2 Create Order` | [Module interface](../patterns/interface.md) |
| `### 2.3 Cancel Order` | [Module interface](../patterns/interface.md) |
| `### 2.4 Order Status Change Notification` | [Module interface](../patterns/interface.md) |
| `## 3 Order Queries` | Heading only |
| `### 3.1 Query Order` | [Module interface](../patterns/interface.md) |
| `### 3.2 Query Order List` | [Module interface](../patterns/interface.md) |

A module-level interface with no public contracts, where the query order status [chapter](../../CONTEXT.md#chapter) itself is an interface:

| Chapter or section | pattern |
| --- | --- |
| `## 1 Order Acceptance` | Heading only |
| `### 1.1 Create Order` | [Module interface](../patterns/interface.md) |
| `### 1.2 Cancel Order` | [Module interface](../patterns/interface.md) |
| `## 2 Inventory Coordination` | Heading only |
| `### 2.1 Reserve Inventory` | [Module interface](../patterns/interface.md) |
| `### 2.2 Reservation Result Callback` | [Module interface](../patterns/interface.md) |
| `## 3 Query Order Status` | [Module interface](../patterns/interface.md) |

## 5 Checklist

- [ ] There are only two levels, [chapter](../../CONTEXT.md#chapter) and [section](../../CONTEXT.md#section), and no [chapter](../../CONTEXT.md#chapter) has exactly one [section](../../CONTEXT.md#section)
- [ ] [chapter](../../CONTEXT.md#chapter) names and [section](../../CONTEXT.md#section) names use business language, with no protocol verbs, paths, or method names
- [ ] Contract types are placed according to their scope of use, the public contracts [chapter](../../CONTEXT.md#chapter) contains no types used by only one [chapter](../../CONTEXT.md#chapter), and shared contracts [section](../../CONTEXT.md#section) entries contain no types used by only one interface
- [ ] No callers are listed
- [ ] All interfaces called in architecture business scenarios are in this doc, and every interface listed in this doc is triggered by a business scenario
