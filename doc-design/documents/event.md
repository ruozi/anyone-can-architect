# Doc Design: event

## 1 Purpose

The processing design for a single background event or scheduled task defines parameter parsing and validation, business processing, and output results

The event directory README owns the event registry and shared trigger policies
See the [readme](readme.md) doc design for specific writing guidance
[event-mediator](event-mediator.md) owns trigger acceptance, target event determination, and forwarding
The corresponding module doc owns the internal implementation and tests of the module that handles the business logic

## 2 Structure

The first chapter describes the overall processing flow and references specific mechanisms in later chapters

The second chapter defines parameter sources, parsing rules, validation conditions, and failure handling, and states that there are no parameters for events without parameters

From the third chapter onward, [drill down](../../skills/references/drill-down.md) into business processing and internal mechanisms, with the number and titles of chapters determined by the solution

The last two chapters cover black-box tests and white-box tests, both organized as [test cases](../patterns/testcase.md)

Structure outline:

```text
## 1 Overall Processing Flow
## 2 Parameter Parsing and Validation
## 3 <part of business processing or internal mechanisms>
…                          Number of chapters depends on the solution
## N Black-Box Tests
## N+1 White-Box Tests
```

## 3 Writing Steps

1. Reference the event registry and shared trigger policies, specify the event key, and define the input context, business dependencies, and output results
2. Arrange the overall processing flow and list the business processing and internal mechanisms to detail
3. Define parameter sources, parsing rules, validation conditions, and failure handling, and connect existing contracts through references
   - State that there are no parameters for events without parameters
4. [Drill down](../../skills/references/drill-down.md) into business processing and internal mechanisms, and define steps, result branches, and dependency calls
   - For dependency modules, describe only calls, results, and subsequent handling, and reference the corresponding docs for internal design
   - When repeated execution, retries, abandonment, or notifications are involved, define the corresponding rules and boundaries
   - For external output, define conditions, content, and destinations, and state the completion conditions when there is no output
5. If cards exist, detail their states under the corresponding steps instead of collecting them in one place
   - Give each state at least its own [subsection](../../CONTEXT.md#subsection), define trigger conditions and processing logic, and use the [Lark (Feishu) card mockup](../patterns/lark-card-mockup.md) pattern
   - If actions exist, define trigger conditions, permissions, parameters, and targets
6. Write black-box tests and white-box tests based on the event contract and internal design, respectively
   - Organize both chapters as [test cases](../patterns/testcase.md), specify driver entry points and observation points, and reference the design basis
   - Reference the corresponding module test docs for business modules' internal tests instead of repeating the details

## 4 Example

```text
## 1 Overall Processing Flow
## 2 Parameter Parsing and Validation
### 2.1 Reporting Period and Recipients
### 2.2 Parameter Parsing
### 2.3 Parameter Validation
## 3 Weekly Report Generation
### 3.1 Query Business Data
### 3.2 Generate Report Content
## 4 Weekly Report Delivery
### 4.1 Delivery Conditions and Destinations
### 4.2 Delivery Result Handling
#### 4.2.1 Delivery Success
#### 4.2.2 Delivery Failure
### 4.3 Retry and Abandonment
## 5 Black-Box Tests
## 6 White-Box Tests
```

## 5 Checklist

- [ ] The event key matches the registry, and the input context, business dependencies, and output results are defined
- [ ] The second chapter covers parameter parsing and validation, including sources, parsing rules, validation conditions, and failure handling, and states that there are no parameters for events without parameters
- [ ] The overall flow corresponds to business processing and internal mechanisms, and specific mechanisms have been detailed through drill-down
- [ ] Dependency modules' internal implementation and tests are connected through references without repeating the details
- [ ] When repeated execution, retries, abandonment, or notifications are involved, the corresponding rules and boundaries are defined
- [ ] External output includes conditions, content, and destinations, and completion conditions are stated when there is no output
- [ ] If cards exist, their states are described alongside the steps, each state has at least its own subsection, and a Lark card mockup is included
- [ ] If actions exist, they include trigger conditions, permissions, parameters, and targets
- [ ] The last two chapters cover black-box tests and white-box tests, and both meet the [test case checklist](../patterns/testcase.md#5-checklist)