# Document Set: event

## 1 When to Use

Background events, message subscriptions, webhooks, and scheduled tasks without real-time user participation

Use the [command](command.md) document set for interactions with direct user participation

## 2 Composition

Place event docs in `docs/design/event/` and use a [hierarchy tree](../patterns/hierarchy-tree.md) to show the directory structure
The dispatch center must be `00-mediator.md`
Number event files with two digits starting from `01`

```text
event/
├─ README.md
├─ 00-mediator.md
├─ 01-overdue.md
└─ 02-weekly-report.md
```

| File | Responsibility | Doc design |
| --- | --- | --- |
| README.md | Trigger methods, event registry, and shared conventions | [readme](../documents/readme.md) |
| 00-mediator.md | Event intake, dispatch, and recovery | [event-mediator](../documents/event-mediator.md) |
| Each event file | Triggers, processing, outputs, and failure handling for a single event | [event](../documents/event.md) |

## 3 Design Order

1. Define the list of event files
2. Build the event registry according to the [readme](../documents/readme.md) doc design
3. Write the dispatch center and each event according to the doc designs referenced in [§2](#2-composition)
4. Complete README

## 4 Checklist

- [ ] Event files and registry entries have a one-to-one correspondence
- [ ] Each file meets its corresponding doc design
- [ ] The dispatch center must be `00-mediator.md`
