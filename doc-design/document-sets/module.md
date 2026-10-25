# Document Set: module

## 1 When to Use

Use for projects divided into multiple modules by business capability
Split capabilities within a module into submodules when they meet the [split criteria](#22-submodules)

[architecture](../documents/architecture.md) defines the division, responsibility boundaries, and dependencies of top-level modules
The direct parent's [class-design](../documents/class-design.md) defines the division, responsibility boundaries, and collaboration of submodules

## 2 Composition

### 2.1 Module Directory

Each module has one directory `module-{X}/` containing four fixed files
The top-level module directory is `docs/design/module-{X}/`
`{X}` is the module's English identifier, using lowercase letters and hyphens between words
For example, `order-management` corresponds to the directory `module-order-management`

| File | Responsibility | Doc design |
| --- | --- | --- |
| interface.md | The module's external contract | [interface](../documents/interface.md) |
| class-design.md | Internal implementation and internal tests, defining internal composition and submodule collaboration when submodules exist | [class-design](../documents/class-design.md) |
| testcase.md | Black-box tests of the external contract | [testcase](../documents/testcase.md) |
| README.md | Module purpose and doc navigation, linking to each submodule's README when submodules exist | [readme](../documents/readme.md) |

### 2.2 Submodules

Place submodule directories inside their direct parent module's directory, following the four-file structure and naming rules in [§2.1](#21-module-directory), with no limit on nesting depth

```text
docs/design/module-order/
├─ README.md
├─ interface.md
├─ class-design.md
├─ testcase.md
└─ module-pricing/
   ├─ README.md
   ├─ interface.md
   ├─ class-design.md
   └─ testcase.md
```

Split a capability within a module into a submodule when it meets all the following criteria
Otherwise, keep it in the parent's class-design, which decides by its [shared mechanism criteria](../documents/class-design.md#2-structure) whether it gets its own chapter

- Has an independent external contract that callers can use correctly by reading only the child's interface
- Owns its state or algorithms
- Can be tested independently through its interface with black-box tests

Do not split data structures or helper classes into separate submodules

**Counterexamples**

- ❌ Place submodule directories directly under `docs/design/`, at the same level as their parent module → The parent–child relationship is lost, so place submodule directories inside their direct parent module's directory
- ❌ Split an internal class without an independent contract into a submodule → It does not meet the split criteria, so keep it in the parent's class-design
- ❌ Repeat signatures from the child's interface or the child's internal implementation in the parent's class-design → The parent only references the child's interface

### 2.3 Parent and Child Responsibilities

| Level | interface | class-design | testcase |
| --- | --- | --- | --- |
| Parent | The parent module's contract with its callers | Internal composition, data ownership, and submodule collaboration, referencing child interfaces for submodule capabilities | Verify overall behavior within the boundary of the parent's interface |
| Child | The submodule's contract with its parent and sibling submodules | The submodule's own implementation | Verify the submodule's contract and algorithms within the boundary of the child's interface |

A child's interface does not automatically become part of the parent's external contract, and capabilities the parent exposes are declared in the parent's interface
Verify composition and collaboration between submodules in the internal tests of the parent's class-design
Each test case belongs to only one level
Directory nesting does not require the implementation to use language-level nesting

## 3 Design Order

1. Create top-level module directories based on the module division in [architecture](../documents/architecture.md)
2. Write each module in the following order
   1. interface
   2. class-design, first defining internal composition and each submodule's responsibility boundaries when submodules exist
   3. Write each submodule according to dependencies between submodules, writing dependencies first and following this same sequence for each submodule
   4. Review the parent's class-design to verify the parent-child boundary
      - Submodule calls, input conversions, and result handling in the parent are consistent with each child's interface
      - The parent does not directly manipulate internal fields of a child or call methods not declared in a child's interface
      - Data structures, state machines, algorithms, and internal tests belonging to a child are fully taken over by the child and removed from the parent
   5. testcase
   6. README

## 4 Checklist

- [ ] Top-level module directories match the module list in architecture
- [ ] Submodule directories are inside their direct parent module's directory and match the internal composition in the parent's class-design
- [ ] Modules at every level contain the four fixed files, and each file meets its corresponding doc design
- [ ] README links to the three docs within the module and to each submodule's README when submodules exist
- [ ] Each submodule meets the split criteria, and capabilities that do not meet them remain in the parent's class-design
- [ ] The parent's class-design collaborates only through capabilities declared in child interfaces, without directly manipulating internal fields of a child or calling undeclared methods
- [ ] The parent's class-design does not retain data structures, state machines, algorithms, or child internal tests that belong to a child
- [ ] All capabilities the parent exposes are declared in the parent's interface
- [ ] Each level's testcase uses only that level's interface as its black-box boundary, and each test case belongs to only one level
