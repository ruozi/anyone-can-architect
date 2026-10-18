# Doc Design: command-router

## 1 Purpose

The processing design for the command routing hub defines routing rules from input to target commands, parameter preparation, and dispatch

Command descriptions, the registry, and shared rules belong in the command directory's README
See the [readme](readme.md) doc design for writing details
Parameter governance, business actions, and replies for leaf commands belong in [command](command.md)

## 2 Structure

The first chapter describes the overall processing flow and references specific mechanisms in later chapters

The second chapter defines rules for determining target commands and dispatch paths for each input type, and references specific mechanisms in later chapters

Starting with the third chapter, apply [drill-down](../../skills/references/drill-down.md) to internal mechanisms, with chapter count and titles determined by the solution

The final two chapters cover black-box tests and white-box tests, both structured as [test cases](../patterns/testcase.md)

Structure outline:

```text
## 1 Overall Processing Flow
## 2 Command Routing
## 3 <part of the internal mechanisms>
…                          Chapter count depends on the solution
## N Black-Box Tests
## N+1 White-Box Tests
```

## 3 Writing Steps

1. Reference the command registry and define inputs, dispatch targets, and routing responsibility boundaries
2. Arrange the overall processing flow and list the internal mechanisms to detail
3. Define rules for determining target commands, parameter passing, and dispatch paths for each input type
4. Apply [drill-down](../../skills/references/drill-down.md) to each internal mechanism and define processing steps, state changes, failure branches, and dependency calls
   - For dependency modules, describe only calls, results, and subsequent processing, and reference the corresponding docs for internal design
   - Reference the corresponding leaf command files for business processing and replies
5. Detail card states under the corresponding processing steps instead of collecting them in one place
   - Give each state at least its own [subsection](../../CONTEXT.md#subsection), define trigger conditions and processing logic, and present it using a [Lark (Feishu) card mockup](../patterns/lark-card-mockup.md)
6. Write black-box tests and white-box tests separately based on the routing contract and internal design
   - Structure both chapters as [test cases](../patterns/testcase.md), specify driver entry points and observation points, and reference the design basis

## 4 Example

```text
## 1 Overall Processing Flow
## 2 Command Routing
### 2.1 Direct Command Access
### 2.2 Natural Language Input
## 3 Input Acceptance and Preprocessing
### 3.1 Input Acceptance
#### 3.1.1 Accepted
#### 3.1.2 Rejected
### 3.2 Message Preprocessing
## 4 Classification and Parameter Extraction
### 4.1 Call the Classification Capability
### 4.2 Call the Parameter Extraction Capability
## 5 Dispatch and Redelivery
### 5.1 Initial Dispatch
### 5.2 Failure and Retry
#### 5.2.1 Waiting to Retry
#### 5.2.2 Retrying
## 6 Black-Box Tests
## 7 White-Box Tests
```

## 5 Checklist

- [ ] Inputs, dispatch targets, and routing responsibility boundaries are defined and consistent with the command registry
- [ ] The second chapter covers command routing, including rules for determining target commands and dispatch paths for each input type
- [ ] The overall processing flow corresponds to each internal mechanism, and drill-down has been applied to the internal mechanisms
- [ ] Internal designs of dependency modules and leaf commands are connected through references without repeating their details
- [ ] Card states are described alongside processing steps, each state has at least its own subsection, and each includes a Lark card mockup
- [ ] The final two chapters cover black-box tests and white-box tests, and both meet the [test case checklist](../patterns/testcase.md#5-checklist)