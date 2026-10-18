# Doc Design: command

## 1 Purpose

The processing design for a single leaf command defines argument parsing and validation, business processing, and interaction results

Command registration and shared interaction conventions belong in the README of the command directory
See the [readme](readme.md) doc design for writing details
Routing input to the target command, preparing arguments, and dispatching belong in [command-router](command-router.md)
The internal implementation and tests of modules that handle business logic belong in the corresponding module docs

## 2 Structure

The first chapter describes the overall processing flow and references specific mechanisms in later chapters

The second chapter defines argument sources, parsing rules, validation conditions, and failure handling, and states that there are no arguments for commands that take none

From the third chapter onward, [drill down](../../skills/references/drill-down.md) into business processing and internal mechanisms, with the number and titles of chapters determined by the solution

The last two chapters cover black-box tests and white-box tests, both structured as [test cases](../patterns/testcase.md)

Structure outline:

```text
## 1 Overall Processing Flow
## 2 Argument Parsing and Validation
## 3 <part of business processing or internal mechanisms>
…                          Number of chapters depends on the solution
## N Black-Box Tests
## N+1 White-Box Tests
```

## 3 Writing Steps

1. Reference the command registry, identify the leaf key, and define arguments, business dependencies, and interaction results
2. Arrange the overall processing flow and list the business processing and internal mechanisms to detail
3. Define argument sources, parsing rules, validation conditions, and failure handling, and connect existing contracts through references
   - State that there are no arguments for commands that take none
4. [Drill down](../../skills/references/drill-down.md) into business processing and internal mechanisms, defining steps, result branches, and dependency calls
   - For dependency modules, describe only calls, results, and subsequent processing, and reference the corresponding docs for internal design
   - When repeated execution, asynchronous processing, or notifications are involved, define the corresponding rules and boundaries
5. Detail card states and actions under the corresponding steps instead of collecting them in one summary
   - Give each state at least its own [subsection](../../CONTEXT.md#subsection), define trigger conditions and processing logic, and present it as a [Lark (Feishu) card mockup](../patterns/lark-card-mockup.md)
   - Define trigger conditions, permissions, arguments, and targets for actions
6. Write black-box tests and white-box tests separately based on interaction contracts and internal design
   - Structure both chapters as [test cases](../patterns/testcase.md), specify driver entry points and observation points, and reference the design basis
   - Reference the corresponding module test docs for internal tests of business modules without repeating the details

## 4 Example

```text
## 1 Overall Processing Flow
## 2 Argument Parsing and Validation
### 2.1 Argument Schema
### 2.2 Argument Parsing
### 2.3 Argument Validation
#### 2.3.1 Missing Task Name
#### 2.3.2 Invalid Argument Format
## 3 Create Task
### 3.1 Call the Task Module
### 3.2 Result Handling
#### 3.2.1 Creation Succeeded
#### 3.2.2 Business Rejection
#### 3.2.3 System Failure
## 4 Black-Box Tests
## 5 White-Box Tests
```

## 5 Checklist

- [ ] The leaf key matches the command registry, and arguments, business dependencies, and interaction results are defined
- [ ] The second chapter covers argument parsing and validation, including sources, parsing rules, validation conditions, and failure handling, and states that there are no arguments for commands that take none
- [ ] The overall flow corresponds to business processing and internal mechanisms, and specific mechanisms are detailed through drill-down
- [ ] Internal implementation and tests of dependency modules are connected through references without repeating the details
- [ ] When repeated execution, asynchronous processing, or notifications are involved, the corresponding rules and boundaries are defined
- [ ] Card states are described alongside steps, each state has at least its own subsection, and each includes a Lark card mockup
- [ ] Actions include trigger conditions, permissions, arguments, and targets
- [ ] The last two chapters cover black-box tests and white-box tests, and both meet the [test case checklist](../patterns/testcase.md#5-checklist)