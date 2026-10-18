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

Apply [drill-down](../../skills/references/drill-down.md) to "internal mechanisms", with no limit on the number of [chapters](../../CONTEXT.md#chapter), followed by [sections](../../CONTEXT.md#section), then [subsections](../../CONTEXT.md#subsection)
The [chapters](../../CONTEXT.md#chapter) and [sections](../../CONTEXT.md#section) for "external capabilities" correspond one-to-one with interface and follow "internal mechanisms", with [drill-down](../../CONTEXT.md#drill-down) applied to each [section](../../CONTEXT.md#section)
When submodules exist, the first [chapter](../../CONTEXT.md#chapter) of "internal mechanisms" is "internal composition", with a module table listing submodules, capabilities, and responsibility boundaries, and a relationship table listing collaboration between submodules, with each submodule name linking to its README
The last chapter is "internal tests", with white-box tests designed from the internal structure and processing mechanisms defined in this doc
Follow the [test cases](../patterns/testcase.md) pattern throughout the chapter, writing fixtures, test scenarios, and test cases in that order

Structure outline:

```text
"Internal mechanisms"               Apply drill-down to produce the following chapters
## 1 <part of the internal mechanisms>
## 2 <part of the internal mechanisms>
…                          The number of chapters depends on the solution
## N-1 <business category>          Corresponds to a chapter in interface
### N-1.1 <interface>           Corresponds to a section in interface · Apply drill-down
#### N-1.1.1 <subdivision>        As needed
## N <interface>                Also applies when a chapter in interface is itself an interface · Apply drill-down
## N+1 Internal Tests            Follow the test cases pattern, with content headings one level lower
```

## 3 Writing Steps

1. Understand all external capabilities defined in interface, what their implementation requires, and which downstream modules or external systems they depend on
2. Set the broad writing structure, without fixing the exact chapter and section structure
   - Define the structure: divide the implementation design into "internal mechanisms" and "external capabilities", then append an "internal tests" chapter
   - Arrange the [chapters](../../CONTEXT.md#chapter) and [sections](../../CONTEXT.md#section) for "external capabilities" to correspond one-to-one with interface, but leave their exact numbers undecided until the final arrangement of "internal mechanisms"
3. Apply [drill-down](../../CONTEXT.md#drill-down) to "internal mechanisms": determine the resulting [chapters](../../CONTEXT.md#chapter), [sections](../../CONTEXT.md#section), and [subsections](../../CONTEXT.md#subsection) in this step
   - Specify normal processing mechanisms, their inherent failure branches, guarantees, boundary conditions, and thresholds, with verification scenarios in the testing part
   - When submodules exist, write "internal composition" first, linking submodule capabilities to the child interface without restating signatures or implementation
   - Define only data structures owned by this module
   - For interactions with dependency modules or external systems, describe only calls sent and results received by this module, without describing the other party's internals
4. Apply [drill-down](../../CONTEXT.md#drill-down) to each "external capability" in order: for each [chapter](../../CONTEXT.md#chapter) or [section](../../CONTEXT.md#section) corresponding to interface, describe how to implement that interface
   - Use only results already declared in interface as external results, and clearly describe how internal errors map to them
   - Link to types and signatures in interface without restating them
   - Reference content already explained in "internal mechanisms" without repeating it
5. Write "internal tests"
   - List branches, state transitions, error mappings, and invariants to verify based on the internal structure and processing mechanisms
   - Define fixtures, list scenarios, and expand test cases following the [test cases](../patterns/testcase.md) pattern, linking the design basis to the corresponding design location in this doc
   - Specify test entry points and observation points, using internal entry points, state, and dependency test doubles as needed
   - Reference testcase for black-box scenarios already defined for the external contract without expanding them again
   - When submodules exist, verify their composition and collaboration, with each submodule's own contract and implementation verified by its child docs
6. Check [chapter](../../CONTEXT.md#chapter) numbering throughout: "internal mechanisms" is followed by "external capabilities" and then "internal tests", with consecutive numbering and the [sections](../../CONTEXT.md#section) for "external capabilities" in the same order as interface

## 4 Example

Paired with the order module in the interface example, the three "external capabilities" chapters have the same structure as that interface:

| Chapter or section | pattern |
| --- | --- |
| `## 1 Module Structure` | Layered module dependency view from [layered view](../patterns/layered-view.md) |
| `## 2 Order State Machine` | [State machine](../patterns/state-machine.md) |
| `## 3 Inventory Reservation Records` | Data structure description from [module interface](../patterns/interface.md) |
| `## 4 Order Intake` | Heading only |
| `### 4.1 Create Order` | [Sequence diagram](../patterns/sequence-diagram.md) |
| `### 4.2 Cancel Order` | Numbered list |
| `## 5 Inventory Collaboration` | Heading only |
| `### 5.1 Reserve Inventory` | [Sequence diagram](../patterns/sequence-diagram.md) |
| `### 5.2 Reservation Result Callback` | [Flowchart](../patterns/flowchart.md) |
| `## 6 Query Order Status` | Code |
| `## 7 Internal Tests` | [Test cases](../patterns/testcase.md) |

## 5 Checklist

- [ ] The [chapters](../../CONTEXT.md#chapter) and [sections](../../CONTEXT.md#section) for "external capabilities" correspond one-to-one with interface, follow "internal mechanisms", and have consecutive numbering
- [ ] "Internal mechanisms" and each "external capability" use drill-down to reach the leaves, leaving only one possible implementation of the module
- [ ] Types and signatures from interface are not restated
- [ ] Guarantees, boundary conditions, and thresholds of internal mechanisms are clear, with verification scenarios concentrated in the testing part
- [ ] The last chapter is "internal tests", verifying branches, state transitions, error mappings, and invariants based on the internal design and satisfying the test cases pattern
- [ ] All external results are already declared in interface, and mappings from internal errors to these results are clear
- [ ] When submodules exist, the first chapter is "internal composition", matches the submodule directories, and only links submodule capabilities to the child interface
- [ ] Only data structures owned by this module are defined
- [ ] Interactions with dependency modules or external systems contain only calls sent and results received by this module
- [ ] "External capabilities" does not restate content already explained in "internal mechanisms"
