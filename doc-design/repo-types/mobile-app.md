# Mobile App

## 1 Scope

Applies to projects installed on mobile operating systems that provide functionality to users through an app interface
Common project forms include Android and iOS apps

## 2 Project Structure

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<id>/     Interfaces, internal implementation, and tests for each business module
│  │  ├─ architecture.md    Module responsibilities, process boundaries, and collaboration
│  │  ├─ class-design.md    Internal implementation and white-box tests for a single-module app
│  │  ├─ distribution.md    App artifact build, delivery, verification, and failure handling
│  │  ├─ infrastructure.md  Infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interaction.md     User scenarios, interfaces, and interaction behavior
│  │  ├─ release.md         Verification, merge, and version lock-in workflow
│  │  ├─ security.md        Attack surface analysis and protection rationale
│  │  └─ testcase.md        Black-box tests for user interaction behavior across the app
│  ├─ ops-guide/            Operations guide, included as needed
│  │  ├─ README.md          Operations guide entry
│  │  ├─ data-collection.md Raw data sources and definitions
│  │  ├─ data-analysis.md   Metrics and analysis methods
│  │  └─ ops-actions.md     Permitted operations actions
│  ├─ user-guide/
│  │  └─ user-manual.md     User operation and troubleshooting guide
│  └─ README.md             Project documentation entry
├─ reference/               External originals that must be stored in the repository
├─ CHANGELOG.md             Change records for released versions
├─ CONTEXT.md               Project glossary
├─ README.md                Project entry and repo type identifier
├─ ROADMAP.md               Current version status and future version goals
├─ SSOT.md                  External sources and their original sources
└─ …                        Source code, test code, and build configuration organized by the actual technology stack
```

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `CHANGELOG.md` | Always required | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| `README.md` (at each level) | Always required | [readme](../documents/readme.md) |
| `ROADMAP.md` | Always required | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | The design depends on external sources | [ssot](../documents/ssot.md) |
| `architecture.md` | The app contains multiple business modules or processes | [architecture](../documents/architecture.md) |
| `class-design.md` | The app has only one business module | [class-design](../documents/class-design.md) |
| `distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `infrastructure.md` | Infrastructure requires defined resource structures or integration conventions | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `interaction.md` | Always required | [interaction](../documents/interaction.md) |
| `module-<id>/` document set | The app contains multiple business modules | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and judgment, or operations actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Versions need to be released | [release](../documents/release.md) |
| `security.md` | Credentials, permissions, sensitive data, or untrusted input are involved | [security](../documents/security.md) |
| `testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `user-manual.md` | Users need separate instructions for use or troubleshooting | [user-manual](../documents/user-manual.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

## 3 Governance Order

When later governance reveals missing or conflicting upstream designs, correct the corresponding docs and update the affected downstream designs

1. Govern user interactions
   - Govern [interaction](../documents/interaction.md) first
2. Govern responsibility allocation and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on [interaction](../documents/interaction.md)
   - First govern the resource structures and integration conventions in the selected [infrastructure](../documents/infrastructure.md) that affect internal implementation
   - First govern the constraints in [distribution](../documents/distribution.md) and the selected [security](../documents/security.md) that affect internal implementation
   - Govern [instrumentation](../documents/instrumentation.md) to clarify the data recording conventions required for internal implementation
3. Govern internal design
   - For a single-module app, govern the project-level [class-design](../documents/class-design.md)
   - For a multi-module app, govern dependency modules first according to the module dependencies defined in [architecture](../documents/architecture.md)
   - Within each module of a multi-module app, follow the governance order specified by the [module](../document-sets/module.md) document set
4. Govern overall verification
   - Govern the project-level [testcase](../documents/testcase.md) based on [interaction](../documents/interaction.md)
5. Complete delivery and usage instructions
   - Based on the internal design, complete the selected [infrastructure](../documents/infrastructure.md) and the protection rationale in the selected [security](../documents/security.md)
   - Complete [distribution](../documents/distribution.md) based on the internal design and delivery constraints
   - Govern the selected [release](../documents/release.md) after the preceding designs are clear
   - Govern the selected [user-manual](../documents/user-manual.md) after the interaction behavior and delivery methods are clear
   - Govern the selected [ops-guide](../document-sets/ops-guide.md) after the data, interfaces, and operational constraints required for operations are clear
6. Complete the documentation entry
   - After the project design is clear, complete the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operations analysis is designed, with clear recording times, data content, data destinations, and responsible parties
- [ ] All docs and document sets whose conditions in Chapter 2 are met have been created
- [ ] Doc locations match the hierarchy tree in Chapter 2, and the files within each document set comply with the corresponding set rules
- [ ] All contracts and constraints that downstream designs depend on can be traced to clearly defined upstream docs