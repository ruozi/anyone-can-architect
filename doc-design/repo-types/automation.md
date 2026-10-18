# Automation Service

## 1 Scope

Applies to projects whose main purpose is to receive commands or respond to triggers and automatically complete business tasks
Common in automation workflows based on IM interactions

## 2 Project Structure

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ command/              User command interaction and processing design
│  │  ├─ event/                Background trigger and event processing design
│  │  ├─ module-<identifier>/  Contracts, implementation, and tests for each business module
│  │  ├─ architecture.md       Module responsibilities and collaboration
│  │  ├─ deployment.md         Deployment, upgrade, and recovery workflows
│  │  ├─ infrastructure.md     Defines infrastructure to build or depend on
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ release.md            Validation, merge, and version lock-in workflows
│  │  ├─ security.md           Security design
│  │  └─ testcase.md           Black-box tests for overall project behavior
│  ├─ ops-guide/            Operations guide, included as needed
│  │  ├─ README.md          Operations guide entry
│  │  ├─ data-collection.md Raw data sources and definitions
│  │  ├─ data-analysis.md   Metrics and analysis methods
│  │  └─ ops-actions.md     Permitted operations actions
│  └─ README.md                Project documentation entry
├─ reference/                  External originals that must be stored in the repository
├─ CHANGELOG.md                Record of changes in released versions
├─ CONTEXT.md                  Project glossary
├─ README.md                   Project entry and repo type identifier
├─ ROADMAP.md                  Current version status and goals for future versions
├─ SSOT.md                     External sources and their original sources
└─ …                           Source code, test code, and build configuration organized by the actual technology stack
```

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `CHANGELOG.md` | Always required | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| `README.md` (at each level) | Always required | [readme](../documents/readme.md) |
| `ROADMAP.md` | Always required | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | The design depends on external sources | [ssot](../documents/ssot.md) |
| `architecture.md` | Business modules are split | [architecture](../documents/architecture.md) |
| `command/` document set | Command interactions involve users in real time | [command](../document-sets/command.md) |
| `deployment.md` | Deployment is required to run the project | [deployment](../documents/deployment.md) |
| `event/` document set | Background events, message subscriptions, webhooks, or scheduled triggers exist | [event](../document-sets/event.md) |
| `infrastructure.md` | Always required | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `module-<identifier>/` document set | Business modules are split | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and assessment, or operations actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Version releases are required | [release](../documents/release.md) |
| `security.md` | Credentials, permissions, sensitive data, or untrusted input exist | [security](../documents/security.md) |
| `testcase.md` | Overall behavior across commands, events, or modules needs validation | [testcase](../documents/testcase.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

## 3 Governance Order

1. Define entry points and external behavior
   - First govern the registries and external contracts of the selected [command](../document-sets/command.md) and [event](../document-sets/event.md) document sets
   - Govern processing workflows and tests after the contracts and constraints they depend on are clear, as described in step 4
2. Define responsibilities and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on entry point contracts, then govern each module once the architecture is established
   - Before governing module and entry point processing designs, govern the [infrastructure](../documents/infrastructure.md) content they depend on
   - First govern the constraints in the selected [security](../documents/security.md) and [deployment](../documents/deployment.md) that affect module and entry point processing designs
   - Govern [instrumentation](../documents/instrumentation.md) to define the data recording conventions required by the internal implementation
3. Govern module design
   - Skip this step if the [module](../document-sets/module.md) document set is not selected
   - Follow the module dependencies defined in [architecture](../documents/architecture.md) and govern dependency modules first
   - Within each module, follow the governance order specified by the [module](../document-sets/module.md) document set
4. Complete entry point processing design
   - After the contracts and constraints that entry point processing depends on are clear, complete the remaining designs in the selected [command](../document-sets/command.md) and [event](../document-sets/event.md) document sets
5. Complete overall validation and delivery design
   - After entry point processing design is complete, govern the selected [testcase](../documents/testcase.md)
   - Complete the remaining design in [infrastructure](../documents/infrastructure.md)
   - Complete the remaining designs in the selected [security](../documents/security.md) and [deployment](../documents/deployment.md)
   - After the selected designs above are clear, govern the selected [release](../documents/release.md)
   - After the data, interfaces, and action constraints required for operations are clear, govern the selected [ops-guide](../document-sets/ops-guide.md)
6. Refine the documentation entry
   - After the project design is clear, refine the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operations analysis is designed, with clear recording timing, data content, data destinations, and responsible parties
- [ ] All docs and document sets whose conditions in chapter 2 are met have been created
- [ ] Doc locations follow the hierarchy tree in chapter 2, and the files within each document set follow the corresponding set rules
- [ ] All contracts and constraints required by subsequent designs can be traced to upstream docs where they are already defined