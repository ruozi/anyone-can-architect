# Doc Design: roadmap

## 1 Purpose

Record the project's release goals and progress

## 2 Structure

Use level-two headings for each part, organized in the order below

| Part | Required When | Content and Writing Guidance |
| --- | --- | --- |
| Current State | Always required | [Current release and progress stage](#21-current-state) |
| Future Release Planning | Future release plans are confirmed | [Goals and scope of each planned release](#22-future-release-planning) |
| Release Evolution Path | Goals and status of multiple releases need a consolidated view | [Goals and status of each release](#23-release-evolution-path) |
| Direction Planning | Directions exist that are not yet assigned to specific releases | [Directions not yet refined into release scope](#24-direction-planning) |

### 2.1 Current State

If any versions have been released, specify the latest release
If a release is in progress, specify the target version and its current stage
Record milestones reached

### 2.2 Future Release Planning

Use one [section](../../CONTEXT.md#section) for each planned release, with the target version number as its heading
First state the results the release must achieve
Then list the features, fixes, or adjustments confirmed for inclusion in the release
Explicitly list items that could be mistaken for included scope as exclusions and explain why

### 2.3 Release Evolution Path

Use a table to summarize the version number, goals, and status of each release

### 2.4 Direction Planning

State the desired results for each direction separately

## 3 Writing Steps

1. Check released versions and actual progress, and record them according to the [Current State](#21-current-state) rules
2. Confirm the goals and scope of future releases with the developer
   Record them according to the [Future Release Planning](#22-future-release-planning) rules
3. Update the release evolution path and direction planning according to the requirements and corresponding writing guidance in [Structure](#2-structure)
4. When release goals, scope, or progress change, update all affected parts accordingly
5. After release, check what was actually delivered and update the release completion status
   Confirm with the developer whether undelivered items should remain in future release planning

## 4 Example

For a structure example, see the [ROADMAP template](../../templates/ROADMAP.md.example)

## 5 Checklist

- [ ] The current state matches actual releases and progress
- [ ] The goals of each planned release clearly state the results to achieve
- [ ] The included scope of each planned release is confirmed
- [ ] The goals, scope, and status of the same release are consistent across all parts
- [ ] Release completion status matches actual delivery
- [ ] Each part meets the requirements and corresponding writing guidance in [Structure](#2-structure)
