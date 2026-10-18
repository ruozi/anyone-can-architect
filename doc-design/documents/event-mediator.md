# Doc Design: event-mediator

## 1 Purpose

The processing design for the event dispatch center defines trigger acceptance, target event selection, and forwarding

The event registry and shared trigger policies belong in the event directory's README
For specific writing guidance, see the [readme](readme.md) doc design
Business processing, output, and failure handling for specific events belong in [event](event.md)

## 2 Structure

The first chapter describes the overall dispatch flow and references specific mechanisms in later chapters

The second chapter defines the overall trigger mechanism, target event selection rules, and forwarding paths, and references specific mechanisms in later chapters

From the third chapter onward, [drill down](../../skills/references/drill-down.md) into internal mechanisms, with the number and titles of chapters determined by the solution

The last two chapters cover black-box tests and white-box tests, both organized as [test cases](../patterns/testcase.md)

Structure outline:

```text
## 1 Overall Dispatch Flow
## 2 Triggers and Forwarding
## 3 <part of the internal mechanisms>
…                          Number of chapters depends on the solution
## N Black-Box Tests
## N+1 White-Box Tests
```

## 3 Writing Steps

1. Reference the event registry and shared trigger policies, and define trigger entry points, target events, and dispatch responsibility boundaries
2. Organize the overall dispatch flow and list the internal mechanisms to detail
3. Define the overall trigger mechanism, target event selection rules, context passing, and forwarding paths
4. [Drill down](../../skills/references/drill-down.md) into each internal mechanism and define processing steps, state changes, failure branches, and dependency calls
   - When acceptance identifiers, deduplication, retries, or recovery are involved, define their respective rules and boundaries
   - For dependency modules, describe only calls, results, and subsequent processing, and reference the corresponding docs for internal design
   - Reference the corresponding event files for business processing, output, and failure handling for specific events
5. If cards are present, detail card states under the corresponding processing steps instead of collecting them in one place
   - Give each state at least its own [subsection](../../CONTEXT.md#subsection), define its trigger conditions and processing logic, and present it as a [Lark (Feishu) card mockup](../patterns/lark-card-mockup.md)
6. Write black-box tests and white-box tests based on the dispatch contract and internal design, respectively
   - Organize both chapters as [test cases](../patterns/testcase.md), specify driver entry points and observation points, and reference the design basis

## 4 Example

```text
## 1 Overall Dispatch Flow
## 2 Triggers and Forwarding
### 2.1 Scheduled Triggers
### 2.2 Message Subscriptions
### 2.3 Target Event Selection and Forwarding
## 3 Acceptance Records and Deduplication
### 3.1 Acceptance Identifiers
### 3.2 Duplicate Trigger Handling
## 4 Event Dispatch
### 4.1 Event Invocation
### 4.2 Result Handling
## 5 Retries and Recovery
### 5.1 Retries After Failure
### 5.2 Recovery After Restart
## 6 Black-Box Tests
## 7 White-Box Tests
```

## 5 Checklist

- [ ] Trigger entry points, target events, and dispatch responsibility boundaries are defined and consistent with the event registry and shared trigger policies
- [ ] The second chapter covers triggers and forwarding, including the overall trigger mechanism, target event selection rules, and forwarding paths
- [ ] The overall dispatch flow corresponds to each internal mechanism, and the internal mechanisms have been detailed through drill-down
- [ ] Rules and boundaries are defined for mechanisms involving acceptance identifiers, deduplication, retries, or recovery
- [ ] Internal designs of dependency modules and specific events are connected through references without repeating their details
- [ ] If cards are present, their states are described alongside processing steps, with at least a separate subsection and a Lark card mockup for each state
- [ ] The last two chapters cover black-box tests and white-box tests, and both meet the [test case checklist](../patterns/testcase.md#5-checklist)
