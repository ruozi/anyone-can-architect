# Document Set: command

## 1 When to Use

Users issue commands in instant messaging through natural language, menus, or card actions

For background triggers without real-time user participation, use the [event](event.md) document set

## 2 Composition

Place command docs in `docs/design/command/` and use a [hierarchy tree](../patterns/hierarchy-tree.md) to show the directory structure
Always use `00-routing.md`, `01-feedback.md`, and `02-help.md`
Number the remaining commands or command groups starting from `03`
Organize command groups into directories by business object, and number commands within each group starting from `01`

```text
command/
├─ README.md
├─ 00-routing.md
├─ 01-feedback.md
├─ 02-help.md
└─ 03-task/
   ├─ README.md
   ├─ 01-create.md
   └─ 02-query.md
```

| File | Responsibility | Doc design |
| --- | --- | --- |
| README.md | Command descriptions, registry, and shared rules | [readme](../documents/readme.md) |
| 00-routing.md | Command intake, recognition, parameter extraction, and dispatch | [command-router](../documents/command-router.md) |
| README.md for each group | Shared conventions within the group, create when shared conventions exist | [readme](../documents/readme.md) |
| Each leaf command file | Processing and replies for a single command | [command](../documents/command.md) |

## 3 Design Order

1. Determine command groups and the file list
2. Create the command registry according to the [readme](../documents/readme.md) doc design
3. Write the routing hub and leaf commands according to the doc designs referenced in [§2](#2-composition)
4. Complete each README

## 4 Checklist

- [ ] Leaf command files correspond one-to-one with registry entries
- [ ] Each file meets its corresponding doc design
- [ ] Routing, feedback, and help always use `00-routing.md`, `01-feedback.md`, and `02-help.md`, respectively