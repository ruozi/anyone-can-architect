# Backend Service

## 1 Scope

Applies to projects whose primary purpose is to provide remote invocation capabilities to other programs
Common project forms include Web API services and RPC services

## 2 Project Structure

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<id>/          Contracts, implementation, and tests for each business module
│  │  ├─ architecture.md       Module responsibilities and collaboration relationships
│  │  ├─ class-design.md       Internal implementation and white-box tests for a single-module service
│  │  ├─ deployment.md         Deployment, upgrade, and recovery procedures
│  │  ├─ infrastructure.md     Infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interface.md          Remote interface contracts exposed by the project
│  │  ├─ release.md            Validation, merge, and version lock-in procedures
│  │  ├─ security.md           Security design
│  │  └─ testcase.md           Black-box tests for the project's external behavior
│  ├─ ops-guide/            Operations guide, included as needed
│  │  ├─ README.md          Operations guide entry
│  │  ├─ data-collection.md Raw data sources and definitions
│  │  ├─ data-analysis.md   Metrics and analysis methods
│  │  └─ ops-actions.md     Permitted operational actions
│  ├─ user-guide/
│  │  └─ integration-guide.md  Integration guide for callers
│  └─ README.md                Project documentation entry
├─ reference/                  External originals that must be stored in the repository
├─ CHANGELOG.md                Change records for released versions
├─ CONTEXT.md                  Project glossary
├─ README.md                   Project entry and repo type identifier
├─ ROADMAP.md                  Current version status and future version goals
├─ SSOT.md                     External sources and their original sources
└─ …                           Source code, test code, and build configuration organized according to the actual technology stack
```

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `CHANGELOG.md` | Always required | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| `README.md` (at each level) | Always required | [readme](../documents/readme.md) |
| `ROADMAP.md` | Always required | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | The design depends on external sources | [ssot](../documents/ssot.md) |
| `architecture.md` | The service contains multiple business modules | [architecture](../documents/architecture.md) |
| `class-design.md` | The service is not split into multiple business modules | [class-design](../documents/class-design.md) |
| `deployment.md` | Deployment is required to run the service | [deployment](../documents/deployment.md) |
| `infrastructure.md` | Always required | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `interface.md` | Always required | [interface](../documents/interface.md) |
| `module-<id>/` document set | The service contains multiple business modules | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and assessment, or operational actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Version releases are required | [release](../documents/release.md) |
| `security.md` | Always required | [security](../documents/security.md) |
| `testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `integration-guide.md` | Interfaces are delivered to integrators outside the repository | [integration-guide](../documents/integration-guide.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

## 3 Governance Order

1. Govern external contracts
   - First govern the project-level [interface](../documents/interface.md)
2. Govern responsibility allocation and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on the external contracts, then govern each module once the architecture is established
   - Before governing internal implementation, first govern the [infrastructure](../documents/infrastructure.md) content it depends on
   - First govern the constraints in [security](../documents/security.md) and the selected [deployment](../documents/deployment.md) that affect internal implementation
   - Govern [instrumentation](../documents/instrumentation.md) to clarify the data recording conventions required by internal implementation
3. Govern internal design
   - For a single-module service, govern the project-level [class-design](../documents/class-design.md)
   - For a multi-module service, follow the module dependencies defined in [architecture](../documents/architecture.md) and govern dependency modules first
   - Govern the internals of each module in a multi-module service in the order specified by the [module](../document-sets/module.md) document set
4. Govern overall validation
   - Once the internal design is clear, govern the project-level [testcase](../documents/testcase.md)
5. Complete delivery design
   - Complete the remaining design in [infrastructure](../documents/infrastructure.md), [security](../documents/security.md), and the selected [deployment](../documents/deployment.md)
   - Once the preceding designs are clear, govern the selected [release](../documents/release.md)
   - Once the external contracts and runtime conventions required for integration are clear, govern the selected [integration-guide](../documents/integration-guide.md)
   - Once the data, interfaces, and operational constraints required for operations are clear, govern the selected [ops-guide](../document-sets/ops-guide.md)
6. Complete the documentation entry
   - Once the project design is clear, complete the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operational analysis is designed, with clear recording timing, data content, data destinations, and responsible parties
- [ ] All docs and document sets whose conditions in Chapter 2 are met have been established
- [ ] Doc locations follow the hierarchy in Chapter 2, and the files within each document set comply with the corresponding set rules
- [ ] All contracts and constraints that subsequent designs depend on can be traced to upstream docs where they are already defined