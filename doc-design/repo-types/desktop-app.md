# Desktop App

## 1 Scope

Applies to application projects that run on desktop operating systems and provide functionality to users through interactive interfaces
Common project forms include Windows, macOS, and Linux applications

## 2 Project Structure

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<identifier>/     Interfaces, internal implementation, and tests for each business module
│  │  ├─ architecture.md    Module responsibilities, process boundaries, and collaboration
│  │  ├─ class-design.md    Internal implementation and white-box tests for a single-module application
│  │  ├─ distribution.md    Application artifact building, delivery, verification, and failure handling
│  │  ├─ infrastructure.md  Infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interaction.md     User scenarios, interfaces, and interaction behavior
│  │  ├─ release.md         Verification, merge, and version lock-in workflow
│  │  ├─ security.md        Attack surface analysis and reasoning for protective measures
│  │  └─ testcase.md        Black-box tests for user interaction behavior across the application
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
├─ ROADMAP.md               Current version status and goals for subsequent versions
├─ SSOT.md                  External sources and their original sources
└─ …                        Source code, test code, and build configuration organized by the actual technology stack
```

| File or document set | Required When | Writing Reference |
| --- | --- | --- |
| `CHANGELOG.md` | Always required | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| `README.md` (at each level) | Always required | [readme](../documents/readme.md) |
| `ROADMAP.md` | Always required | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | The design depends on external sources | [ssot](../documents/ssot.md) |
| `architecture.md` | The application contains multiple business modules or processes | [architecture](../documents/architecture.md) |
| `class-design.md` | The application has only one business module | [class-design](../documents/class-design.md) |
| `distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `infrastructure.md` | Infrastructure requires defined resource structures or integration conventions | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `interaction.md` | Always required | [interaction](../documents/interaction.md) |
| `module-<identifier>/` document set | The application contains multiple business modules | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and judgment, or operations actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Versions need to be released | [release](../documents/release.md) |
| `security.md` | Credentials, permissions, sensitive data, or untrusted input are involved | [security](../documents/security.md) |
| `testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `user-manual.md` | Users need separate instructions for use or troubleshooting | [user-manual](../documents/user-manual.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

## 3 Governance Order

When subsequent governance reveals missing or conflicting upstream designs, correct the corresponding docs and synchronize the affected downstream designs

1. Govern user interaction
   - Govern [interaction](../documents/interaction.md) first
2. Govern responsibility allocation and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on [interaction](../documents/interaction.md)
   - First govern the resource structures and integration conventions in the selected [infrastructure](../documents/infrastructure.md) that affect internal implementation
   - First govern the constraints in [distribution](../documents/distribution.md) and the selected [security](../documents/security.md) that affect internal implementation
   - Govern [instrumentation](../documents/instrumentation.md) to define the data recording conventions required for internal implementation
3. Govern internal design
   - For a single-module application, govern the project-level [class-design](../documents/class-design.md)
   - For a multi-module application, govern dependency modules first, following the module dependencies defined in [architecture](../documents/architecture.md)
   - Govern the internals of each module in a multi-module application in the order specified by the [module](../document-sets/module.md) document set
4. Govern overall verification
   - Govern the project-level [testcase](../documents/testcase.md) based on [interaction](../documents/interaction.md)
5. Complete delivery and usage instructions
   - Based on the internal design, fill in the selected [infrastructure](../documents/infrastructure.md) and complete the reasoning for protective measures in the selected [security](../documents/security.md)
   - Complete [distribution](../documents/distribution.md) based on the internal design and delivery constraints
   - Govern the selected [release](../documents/release.md) after the preceding designs are defined
   - Govern the selected [user-manual](../documents/user-manual.md) after the interaction behavior and delivery methods are defined
   - Govern the selected [ops-guide](../document-sets/ops-guide.md) after the data, interfaces, and operational constraints required for operations are defined
6. Complete the documentation entry
   - After the project design is defined, complete the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operations analysis is designed, with recording timing, data content, data destinations, and responsible parties defined
- [ ] All docs and document sets whose conditions in Chapter 2 are met have been created
- [ ] Doc locations follow the hierarchy tree in Chapter 2, and the files within each document set follow the corresponding set rules
- [ ] All contracts and constraints on which subsequent designs depend can be traced to upstream docs where they are already defined