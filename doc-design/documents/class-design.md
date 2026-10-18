# Doc Design: class-design

## 1 Purpose

Solution design within a module
Guides the unambiguous implementation of all details within the module
Must include how to implement every external capability defined in interface

The module's external capability definitions belong in [interface](interface.md)
Black-box tests of the external contract belong in [testcase](testcase.md)
White-box tests of internal mechanisms go in the last chapter of this doc, following [test cases](../patterns/testcase.md)
How top-level modules collaborate belongs in [architecture](architecture.md)
When submodules exist, this doc defines internal composition and submodule collaboration, while each submodule's implementation belongs in its own class-design, with responsibilities defined in the [module document set](../document-sets/module.md#23-parent-and-child-responsibilities)

## 2 Structure

The body consists of "internal mechanisms", "external capabilities", and "internal tests", in that order
"Internal mechanisms" consist of "internal composition" and shared mechanisms

The first [chapter](../../CONTEXT.md#chapter) of "internal mechanisms" is "internal composition"
- Without submodules, it lists the module's classes or components, the data this module owns, and the downstream modules or external systems it depends on
- With submodules, it uses a module table listing submodules, capabilities, and responsibility boundaries, and a relationship table listing collaboration between submodules, with each submodule name linking to its README

Shared mechanisms follow "internal composition", one [chapter](../../CONTEXT.md#chapter) per shared mechanism, and are omitted when there are none
A shared mechanism must meet both of the following criteria
- At least two "external capabilities" use it
- It defines a rule, state, or guarantee shared by those capabilities

A single field, a set of fields, or a notification helper is not a shared mechanism, and is written next to the implementation that uses it

The [chapters](../../CONTEXT.md#chapter) and [sections](../../CONTEXT.md#section) for "external capabilities" correspond one-to-one with interface and follow "internal mechanisms", with [drill-down](../../CONTEXT.md#drill-down) applied to each [section](../../CONTEXT.md#section)
The last chapter is "internal tests", with white-box tests designed from the internal structure and processing mechanisms defined in this doc
Follow the [test cases](../patterns/testcase.md) pattern throughout the chapter, writing fixtures, test scenarios, and test cases in that order

Structure outline:

```text
"Internal mechanisms"
## 1 Internal Composition         Classes or components, owned data, and dependencies · module and relationship tables when submodules exist
## 2 <shared mechanism>           As needed, only when it meets the shared mechanism criteria
…
"External capabilities"
## N-1 <business category>        Corresponds to a chapter in interface
### N-1.1 <interface>             Corresponds to a section in interface · Apply drill-down
#### N-1.1.1 <subdivision>        As needed
## N <interface>                  Also applies when a chapter in interface is itself an interface · Apply drill-down
## N+1 Internal Tests             Follow the test cases pattern, with content headings one level lower
```

## 3 Writing Steps

The writing order differs from the reading order: finish the implementation of each external capability first, then extract shared mechanisms from it

1. Understand all external capabilities defined in interface, what their implementation requires, and which downstream modules or external systems they depend on
2. Draft "internal composition"
   - List the classes or components needed to implement the external capabilities, the data this module owns, and its dependencies
   - When submodules exist, link submodule capabilities to the child interface without restating signatures or implementation
   - Define only data structures owned by this module
3. Apply [drill-down](../../CONTEXT.md#drill-down) to each "external capability" in order: for each [chapter](../../CONTEXT.md#chapter) or [section](../../CONTEXT.md#section) corresponding to interface, describe how to implement that interface
   - Write the complete execution in one place: inputs, conversions, calls, branches, and outputs
   - Write fields, conversions, and branches that serve only this interface next to its implementation
   - Use only results already declared in interface as external results, and clearly describe how internal errors map to them
   - Link to types, results, and error semantics already defined in interface without restating them
   - Implementation code may include method signatures to show how input parameters flow downstream
   - For interactions with dependency modules or external systems, describe only calls sent and results received by this module, without describing the other party's internals
   - Implementation details of a vendor or platform belong in its own Adapter
   - Choose the expression by [expression](#31-expression), and determine branches by [completeness basis](#32-completeness-basis)
4. Extract shared mechanisms
   - Find rules, state, or guarantees shared by several external capabilities in the finished implementations
   - Move those that meet the [shared mechanism criteria](#2-structure) into their own [chapter](../../CONTEXT.md#chapter)
   - Each usage site keeps its execution order: where it calls the mechanism, the inputs it passes, the result it gets, and the branches that follow
   - Explain the mechanism's internal rules and implementation details only in the mechanism chapter, and reference them from usage sites
   - Specify the mechanism's normal flow, inherent failure branches, guarantees, boundary conditions, and thresholds, with verification scenarios in the testing part
   - Keep anything that does not meet the criteria next to the implementation that uses it
5. Arrange the reading order
   - "Internal composition" comes first, followed by shared mechanisms, then "external capabilities", and finally "internal tests"
   - The [sections](../../CONTEXT.md#section) for "external capabilities" follow the same order as interface
   - Check that [chapter](../../CONTEXT.md#chapter) numbering is consecutive throughout
6. Write "internal tests"
   - List branches, state transitions, error mappings, and invariants to verify based on the internal structure and processing mechanisms
   - Define fixtures, list scenarios, and expand test cases following the [test cases](../patterns/testcase.md) pattern, linking the design basis to the corresponding design location in this doc
   - Specify test entry points and observation points, using internal entry points, state, and dependency test doubles as needed
   - Reference testcase for black-box scenarios already defined for the external contract without expanding them again
   - When submodules exist, verify their composition and collaboration, with each submodule's own contract and implementation verified by its child docs

### 3.1 Expression

| Content | Expression |
| --- | --- |
| Simple calls and field conversions | Code |
| Multi-step processing without loops | Numbered list<br>Each step starts with a bold phrase stating its purpose<br>Specific operations and conditional branches indented under the step |
| Flows with loops, or whose branch paths need to be shown as a whole | [Flowchart](../patterns/flowchart.md) |
| Interaction timing across objects | [Sequence diagram](../patterns/sequence-diagram.md) |
| Allowed state changes | [State machine](../patterns/state-machine.md), which does not replace the execution order of a handler |

Do not restate in prose what a diagram or code already expresses
Do not add an explanatory paragraph to a call that one line of code fully expresses

Show code at the following granularity
- Short handlers show the necessary processing, field conversions, and notifications directly
- Wiring repeated in several places is written as one piece of representative code
- Representative code states which locations it represents
- Constraints shared by those locations are written once
- Representative code does not omit key decisions
- Representative code does not pose as the complete implementation

### 3.2 Completeness Basis

Branches are based on real contracts and confirmed requirements
- Distinguish parameter validation, call exceptions, vendor business results, and unknown states
- Do not design retries, state machines, or notifications for results the contract does not provide
- Mark behavior that has not been verified as to be verified, without assuming whether it holds

Example: a vendor setter returns `void`
- When the contract provides no business result, do not design a set-success or set-failure flow
- When call exceptions have not been verified, mark them as to be verified

## 4 Example

Paired with the order module in the interface example, the three "external capabilities" chapters have the same structure as that interface:

| Chapter or section | pattern |
| --- | --- |
| `## 1 Internal Composition` | Layered module dependency view from [layered view](../patterns/layered-view.md)<br>Inventory reservation records described as a data structure from [module interface](../patterns/interface.md) |
| `## 2 Order State Machine` | [State machine](../patterns/state-machine.md)<br>Shared by create, cancel, and reservation result callback |
| `## 3 Order Intake` | Heading only |
| `### 3.1 Create Order` | [Sequence diagram](../patterns/sequence-diagram.md) |
| `### 3.2 Cancel Order` | Numbered list |
| `## 4 Inventory Collaboration` | Heading only |
| `### 4.1 Reserve Inventory` | [Sequence diagram](../patterns/sequence-diagram.md) |
| `### 4.2 Reservation Result Callback` | [Flowchart](../patterns/flowchart.md) |
| `## 5 Query Order Status` | Code |
| `## 6 Internal Tests` | [Test cases](../patterns/testcase.md) |

## 5 Checklist

- [ ] The first chapter is "internal composition"; when submodules exist, it matches the submodule directories and only links submodule capabilities to the child interface
- [ ] Every shared mechanism chapter meets the shared mechanism criteria and can name at least two external capabilities that use it
- [ ] The [chapters](../../CONTEXT.md#chapter) and [sections](../../CONTEXT.md#section) for "external capabilities" correspond one-to-one with interface, follow "internal mechanisms", and have consecutive numbering
- [ ] "Internal mechanisms" and each "external capability" use drill-down to reach the leaves, leaving only one possible implementation of the module
- [ ] The execution order of each interface can be read in one place, without piecing chapters together
- [ ] Inputs, key conversions, and outputs in examples are coherent
- [ ] Types, results, and error semantics defined in interface are not restated
- [ ] Prose, diagrams, and code do not repeat each other
- [ ] Guarantees, boundary conditions, and thresholds of shared mechanisms are clear, with verification scenarios concentrated in the testing part
- [ ] The last chapter is "internal tests", verifying branches, state transitions, error mappings, and invariants based on the internal design and satisfying the test cases pattern
- [ ] All external results are already declared in interface, and mappings from internal errors to these results are clear
- [ ] Every branch is based on a contract or a confirmed requirement, and unverified behavior is marked as to be verified
- [ ] Only data structures owned by this module are defined
- [ ] Interactions with dependency modules or external systems contain only calls sent and results received by this module
- [ ] Implementation details of vendors or platforms are not lifted into this module
- [ ] "External capabilities" does not restate content already explained in shared mechanisms
