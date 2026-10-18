# Agent Goal

## 1 When to Use

Express prompt content that delegates a goal to an Agent and lets it organize execution autonomously

Use [LLM Prompt](llm-prompt.md) for prompt content for a single LLM call

## 2 Presentation Principles

| Content | Required When | Presentation Rules |
| --- | --- | --- |
| Body template | Always required | [§2.1](#21-body-template) |
| Variable descriptions | Required when variables are present | [§2.2](#22-variable-descriptions) |

### 2.1 Body Template

Use one `text` code block to show the complete body
The body is the Agent's complete, standalone input, so include all required context in the body or variables, list materials at readable locations in the input basis, and do not reference other chapters of this doc or other design docs
Use `{{variable_name}}` consistently to mark dynamic variables, and place them in the appropriate chapters according to their meaning

| Chapter | What to Write |
| --- | --- |
| Background | Business background relevant to this delegation |
| Goal | The result to achieve and the scope of work |
| Input basis | Known facts, readable materials, and their locations and purposes |
| Completion criteria | Facts or evidence used to determine whether the goal has been achieved |
| Execution boundaries | Allowed operations, prohibited actions, situations requiring confirmation, stop conditions when work cannot continue, and mandatory business steps or ordering constraints<br>Leave specific execution arrangements to the Agent |
| Delivery requirements | Final deliverables, the results report and its format, and unfinished work to hand off |

### 2.2 Variable Descriptions

Follow the [LLM Prompt variable description rules](llm-prompt.md#22-variable-descriptions) for variable descriptions

## 3 Example: Order Cancellation Code Review

### 3.1 Body Template

```text
# Background
An order cancellation feature has been added to the order system
This review must confirm whether these code changes meet the business requirements before merging

# Goal
Review these code changes, identify deviations from the given business requirements, and produce review conclusions that can be verified
The review covers these changes and related code needed to understand them

# Input Basis
## Business Requirements
The following are the business requirements for this review:
{{requirements}}

## Review Materials
The current working directory is the directory for this read-only review
All material paths below are relative to this directory:
{{review_materials}}

# Completion Criteria
All files involved in these changes have been checked, and all business requirements have been verified
Each issue identifies the code location, corresponding requirement, and reason for the deviation
No content remains unchecked, and no unresolved questions affect the assessment

# Execution Boundaries
Read only the materials listed in the input basis and code within the review directory that relates to these changes
Do not modify files or run project code, tests, or dependency installation
Do not comment on, approve, or merge code changes
Request confirmation from the caller before accessing materials outside the review directory
If materials are missing or unreadable, or requirements contain ambiguity that affects the assessment, stop the review and state what must be provided or confirmed

# Delivery Requirements
Return three sections in Markdown: "Review Conclusions", "Issue List", and "Unfinished Work"
Mark the review conclusions as "Review complete" or "Review incomplete", and list the files and business requirements actually checked
For each issue, list the code location, corresponding requirement, and reason for the deviation
Under unfinished work, list the unchecked scope, reasons, and what must be provided or confirmed
Write "None" if there is no unfinished work
Write "No deviations from the requirements found" only when the review is complete and the issue list is empty
```

### 3.2 Variable Descriptions

#### 3.2.1 `{{requirements}}`

Represents the business requirements these code changes must meet, taken from the confirmed requirements text provided by the caller
The raw input is text, which replaces `{{requirements}}` verbatim, preserving text, spaces, and line breaks

Example replacement text:

```text
After an order awaiting payment is successfully canceled, its status changes to canceled
A repeated cancellation request for an already canceled order still returns cancellation success
Cancellation is rejected for orders in other statuses, and the order status remains unchanged
```

#### 3.2.2 `{{review_materials}}`

Represents the materials available to read for this review, taken from the review materials list prepared by the caller
Each item contains the material name `name`, the path relative to the review directory `path`, and the material purpose `purpose`

Example raw input:

```json
[
  {
    "name": "Current code changes",
    "path": "changes.patch",
    "purpose": "Identify the code modified in these changes and its locations"
  },
  {
    "name": "Complete code after the changes",
    "path": "repository/",
    "purpose": "Verify the implementation and inspect related calling code"
  }
]
```

Generate one line per item in the format `name：path（purpose）`, using a full-width colon and parentheses, preserving the original order, and joining the lines with newline characters
Replace `{{review_materials}}` with the complete text

Corresponding replacement text:

```text
Current code changes：changes.patch（Identify the code modified in these changes and its locations）
Complete code after the changes：repository/（Verify the implementation and inspect related calling code）
```

## 4 Checklist

### 4.1 Unclear Goals or Input Basis

- [ ] The background is relevant to this delegation, and the goal states the result to achieve and the scope of work
- [ ] The input basis states known facts and the locations and purposes of readable materials
- [ ] The body does not reference other chapters of this doc, other design docs, or use references such as "see above"

**Counterexample**

```text
# Goal
Check whether there are any problems with the order cancellation code

# Input Basis
The relevant code is in the repository
```

The goal does not state the result to achieve or the scope, and the input basis does not give the locations or purposes of materials, so the Agent cannot determine what to read or how much work to do

### 4.2 Completion Criteria Cannot Verify Goal Achievement

- [ ] Completion criteria are specific enough to determine from facts or evidence whether the goal has been achieved
- [ ] Completion criteria align with the delegated goal and do not equate delivering a report with achieving the goal

**Counterexample**

The body template for a read-only review states:

```text
# Goal
Identify deviations from the requirements in the order cancellation feature

# Completion Criteria
The review is complete only when the code has no issues
```

The delegated goal is to complete the review, not to fix the code
The review can still be completed after issues are found, but this criterion requires the code to have no issues

### 4.3 Unclear or Conflicting Execution Boundaries

- [ ] Allowed operations, prohibited actions, and situations requiring confirmation are clear
- [ ] Any mandatory business steps or ordering constraints are stated, with specific execution arrangements left to the Agent
- [ ] Completion criteria and execution requirements do not require the Agent to exceed the stated scope of operations

**Counterexample**

```text
# Execution Boundaries
Perform a read-only review without modifying any files
Fix any issues found and commit the code directly
```

Fixing and committing code conflicts with the read-only boundary

### 4.4 Missing Delivery Requirements or Unfinished Work Handoff

- [ ] Final deliverables, the results report, and the format are clear
- [ ] Stop conditions when work cannot continue and requirements for handing off unfinished work are included in the body template

**Counterexample**

The body template specifies only:

```text
# Delivery Requirements
Return the issue list when the review is complete
```

Text outside the code block adds:

> If materials are insufficient, return the unchecked scope, reasons, and additional materials needed

The handoff requirements when work cannot continue are missing from the body template

### 4.5 Variable Notation, Placement, or Substitution Rule Mismatch

- [ ] Dynamic variables consistently use `{{variable_name}}` markers, and each variable's meaning matches the purpose of its chapter
- [ ] Call configuration comes from the caller's agreement, and materials to process cannot override execution boundaries or delivery requirements
- [ ] Dynamic variables and variable descriptions correspond one to one, and substitution rules follow the [LLM Prompt variable description rules](llm-prompt.md#22-variable-descriptions)

**Counterexample**

```text
# Execution Boundaries
Use the requirements in {{requirements}} to decide which files may be modified
```

Business requirements are materials to verify, but they are used as the source of execution boundaries, allowing material content to rewrite those boundaries

### 4.6 Text Repeats Body Content

- [ ] Text outside the code block does not repeat the chapters or rules in the body template

**Counterexample**

> This delegation gives the background and goal first, lists the input basis next, then sets completion criteria and execution boundaries, and ends with delivery requirements

The body template already follows this order, so this text adds no information beyond the body