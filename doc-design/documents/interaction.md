# Doc Design: interaction

## 1 Purpose

Define product interaction behavior from the user's perspective so that user actions, interface states, and feedback can be understood, implemented, and verified consistently

Internal implementation belongs in the corresponding module design
Usage guidance belongs in [user-manual](user-manual.md)
Black-box tests for interaction behavior belong in [testcase](testcase.md)

## 2 Structure

Chapter 1, “Usage Scenarios”, summarizes what users need to do, the corresponding entry points, and the subsequent chapters

From Chapter 2 onward, each chapter expands on one usage scenario, using [drill-down](../../skills/references/drill-down.md) along the sequence of actions
Interface mockups accompany specific actions and show the states and feedback before and after each action
Define interaction rules shared by multiple scenarios in one place, and reference that content from other scenarios

Use HTML interaction mockups as the main pattern to show interface layouts, content, controls, and state changes triggered by actions
Show information directly in mockups where possible, and use text to supplement business conditions and behavior rules that affect interaction
Use [card mockups](../patterns/lark-card-mockup.md) for Lark (Feishu) cards

Structure outline:

```text
## 1 Usage Scenarios
## 2 <usage scenario>
### 2.1 <specific content>
### 2.2 <specific content>
#### 2.2.1 <specific content>
#### 2.2.2 <specific content>
## 3 <usage scenario>
…
```

## 3 Writing Steps

1. Identify users, goals, and usage scenarios
   - Divide scenarios by user goal, and identify entry points and applicable conditions
   - Where roles differ, describe the corresponding entry points, actions, and permissions
   - Summarize scenarios and link to the corresponding subsequent chapters
2. Map out the sequence of actions and branches in each scenario
   - Start at the entry point and identify the interface state, feedback, and subsequent actions triggered by each action
   - Map out failure, interruption, and recovery branches
3. Create HTML interaction mockups
   - Show user-visible interface states for specific actions, using example data and copy that fit the scenario
   - Keep controls, feedback placement, and layouts close to the actual usage environment
   - Provide direct links to each state
   - Provide an interactive prototype when static mockups cannot clearly express action sequences, immediate feedback, or dynamic changes
4. Add business conditions and behavior rules that affect interaction
   - Add permission restrictions, validation rules, and control enablement conditions that the mockups do not express
   - When actions involve saving data, canceling, leaving, or retrying, define the outcome and what is retained
   - Place rules next to the corresponding action or state, and reference a single definition for shared rules
5. Check complete scenarios
   - Follow the normal flow and each branch to check entry points, state changes, feedback, and subsequent actions
   - Check that mockups and rules are consistent, and that trigger conditions and outcomes are defined for every action

## 4 Example

### 4.1 Interaction Design Doc

````markdown
# Department Report Tool Interaction Design

## 1 Usage Scenarios

| Usage scenario | Entry point | Interaction design |
| --- | --- | --- |
| Generate a department report | “Department reports” on the main screen | [Generate a Department Report](#2-generate-a-department-report) |

## 2 Generate a Department Report

### 2.1 Select the Report Scope

[Scope selection mockup](report-interaction.html#range)
[Date error mockup](report-interaction.html#invalid-range)

The department list shows only departments the current account can access, and selects the account's department by default
The date range defaults to the current month, and report generation is enabled when both the department and dates are valid
The start date must not be later than the end date, and correcting the dates clears the error and enables “Generate report”

### 2.2 Generate the Report

#### 2.2.1 Processing

[Processing mockup](report-interaction.html#processing)

Clicking “Generate report” starts processing
This scenario does not support cancellation, and closing the window does not stop generation
Reopening the window restores the latest state of the report

#### 2.2.2 Generated

[Generated mockup](report-interaction.html#success)

The generated report is saved to “Report history”
Clicking “View report” opens the report details

#### 2.2.3 Generation Failed

[Generation failure mockup](report-interaction.html#failure)

When the service is busy, users can retry, which continues processing the current generation request without creating a duplicate report
````

### 4.2 HTML Interaction Mockup

report-interaction.html shows five states, accessible through links at the top of the page

```html
<!doctype html>
<html lang="zh-CN">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Department Report Generation Interaction Mockup</title>
<style>
  body { margin: 0; padding: 24px; background: #f5f6f7; color: #1f2329;
    font: 14px/1.6 sans-serif; }
  nav, main { max-width: 640px; margin: auto; }
  nav { display: flex; gap: 16px; flex-wrap: wrap; }
  section { margin-top: 24px; padding: 24px; background: white;
    border: 1px solid #dee0e3; border-radius: 8px; }
  h1 { margin: 0 0 12px; font-size: 20px; }
  h2 { margin: 0 0 12px; font-size: 16px; }
  p { margin: 8px 0; }
  label { display: block; margin-top: 12px; }
  input, select, button { font: inherit; padding: 8px; }
  input, select { border: 1px solid #8f959e; border-radius: 4px; }
  button { margin-top: 16px; padding: 8px 16px; background: #1456f0;
    color: white; border: 0; border-radius: 4px; }
  button:disabled { background: #eff0f1; color: #646a73; }
  .error { color: #c02a38; }
</style>
<nav aria-label="Interaction states">
  <a href="#range">Select scope</a><a href="#invalid-range">Date error</a>
  <a href="#processing">Processing</a>
  <a href="#success">Generated</a><a href="#failure">Generation failed</a>
</nav>
<main>
  <section id="range">
    <h1>Generate a Department Report</h1>
    <label>Department <select aria-label="Department"><option>Sales</option></select></label>
    <label>Start date <input aria-label="Start date" type="date" value="2026-09-01"></label>
    <label>End date <input aria-label="End date" type="date" value="2026-09-30"></label>
    <button>Generate report</button>
  </section>
  <section id="invalid-range">
    <h2>Generate a Department Report</h2>
    <label>Department <select aria-label="Department"><option>Sales</option></select></label>
    <label>Start date <input aria-label="Start date" type="date" value="2026-09-30"></label>
    <label>End date <input aria-label="End date" type="date" value="2026-09-01"></label>
    <p class="error">The start date cannot be later than the end date</p>
    <button disabled>Generate report</button>
  </section>
  <section id="processing">
    <h2>Generate a Department Report</h2>
    <label>Department <select aria-label="Department" disabled><option>Sales</option></select></label>
    <label>Start date <input aria-label="Start date" type="date" value="2026-09-01" disabled></label>
    <label>End date <input aria-label="End date" type="date" value="2026-09-30" disabled></label>
    <p role="status">Generating the report, please wait</p>
    <button disabled>Generating</button>
  </section>
  <section id="success">
    <h2>Report Generated</h2>
    <p>Sales · 2026-09-01 to 2026-09-30</p>
    <p>128 records in total</p>
    <button>View report</button>
  </section>
  <section id="failure">
    <h2>Generate a Department Report</h2>
    <label>Department <select aria-label="Department"><option>Sales</option></select></label>
    <label>Start date <input aria-label="Start date" type="date" value="2026-09-01"></label>
    <label>End date <input aria-label="End date" type="date" value="2026-09-30"></label>
    <p class="error" role="alert">The report service is busy, please try again later</p>
    <button>Retry</button>
  </section>
</main>
</html>
```

## 5 Checklist

- [ ] Usage scenarios, entry points, and corresponding chapters can be located
- [ ] Action sequences and branches cover the actual interactions in each scenario
- [ ] User-visible states, content, and feedback have corresponding mockups
- [ ] Changes after actions and subsequent actions are defined
- [ ] Permissions, validation, and enablement conditions that affect interaction are defined
- [ ] Outcomes and retained content are defined for saving, canceling, leaving, and retrying
- [ ] Mockups and rules are consistent, and shared rules are referenced
- [ ] Trigger conditions and outcomes are defined for the normal flow and failure, interruption, and recovery branches
- [ ] Text supplements business conditions and behavior rules that mockups do not express, without repeating content already shown