# Doc Design: readme

## 1 Purpose

The documentation entry for the current level introduces its responsibilities and mainly provides navigation to docs at the next level
Include shared mechanisms and registries as needed for the corresponding design docs to reference

## 2 Structure

| Content | Requirement |
| --- | --- |
| Purpose | Introduce the responsibilities of the current level |
| Documentation navigation | Link to docs at the next level and indicate their purposes, with grouping or a reading order as needed |
| Shared content | Add chapters for shared mechanisms, registries, and other shared content as needed for related docs to reference |

Structure outline:

```text
<purpose>
<documentation navigation>
## <shared content>             Add as needed, with chapters determined by the content
```

## 3 Writing Steps

1. Determine content and responsibilities
   - List all design docs at the current level and determine whether shared mechanisms, registries, or other shared content are needed
   - If a corresponding repo type or document set exists, determine the doc composition according to its requirements
   - The root README can link only to the documentation entry, which provides navigation to the remaining docs
   - When CONTEXT and SSOT are reachable from the documentation entry, do not list them separately in the root README
2. Organize the doc structure
   - Write the purpose to introduce the responsibilities of the current level
   - Group navigation by doc responsibility and divide shared content into chapters by mechanism or registered object, with no extra grouping needed for a single topic
   - The root README can include a slogan, badges, and a quick start, and can use a linked badge for the documentation entry
   - The root README can include one line of version status and link to the corresponding details when ROADMAP is used
3. Write navigation
   - Use a table to link to docs or directory README files directly at the next level, with one entry per row and one sentence describing its purpose
   - Do not list the same navigation item more than once
   - Provide a reading order as needed, connecting related docs according to reader tasks
4. Expand shared content
   - Divide shared mechanisms into chapters by responsibility, apply [drill-down](../../skills/references/drill-down.md) to each mechanism, and have related docs reference the corresponding rules
   - Put the processing mechanism for a single object in its corresponding design doc
   - Define field meanings and value rules according to the registry's purpose
   - Use one row per registered object, including its identifier and corresponding design entry
   - Connect shared policies through references instead of redefining them in each row
5. Check consistency
   - Check navigation coverage and link validity, and update links when docs are added, deleted, or renamed
   - Check that objects, identifiers, and entries in registries match those in design docs
   - Check for duplicate definitions of shared content

## 4 Example

```markdown
# Business Events

Organize background triggers and processing for overdue reminders and weekly reports

| Doc | Purpose |
| --- | --- |
| [Event dispatch](00-mediator.md) | Accept triggers and forward events |
| [Overdue reminders](01-overdue.md) | Remind owners to handle overdue items |
| [Weekly reports](02-weekly-report.md) | Generate and send this week's business report |

## 1 Shared Trigger Mechanisms

### 1.1 Weekly Trigger

Trigger every Friday at 18:00 (Beijing time), with a reporting period from Monday of the current week to the trigger time
If the trigger time is missed, send the current week's report later, but do not send the previous week's report after the next week starts

### 1.2 Daily Trigger

Trigger every day at 09:00 (Beijing time)
If the trigger time is missed, recalculate based on the current state, but do not send the previous day's reminders after the next day starts

## 2 Event Registry

The event key uniquely identifies an event, and the trigger policy references the shared trigger mechanisms above

| Event key | Name | Responsibility | Trigger policy | Design entry |
| --- | --- | --- | --- | --- |
| event.overdue | Overdue reminders | Remind owners to handle overdue items | [Daily trigger](#12-daily-trigger) | [Overdue reminders](01-overdue.md) |
| event.weekly_report | Weekly reports | Summarize this week's business progress and send a report | [Weekly trigger](#11-weekly-trigger) | [Weekly reports](02-weekly-report.md) |
```

## 5 Checklist

- [ ] The purpose introduces the responsibilities of the current level
- [ ] Documentation navigation covers the level directly below, each entry includes a link and one sentence describing its purpose, and no navigation item is listed more than once
- [ ] If the root README links only to the documentation entry, all remaining docs are reachable from that entry
- [ ] If a reading order exists, it is organized by reader task
- [ ] If shared mechanisms exist, drill-down has been applied, related docs reference the corresponding rules, and no definitions are duplicated
- [ ] If a registry exists, each object has one row with its identifier and design entry, and field meanings and value rules are defined
- [ ] If a registry exists, it matches the corresponding design docs, and shared policies are connected through references
- [ ] Links point to actual files and sections, with no placeholder links
- [ ] If version status is included, its details link points to the corresponding version record