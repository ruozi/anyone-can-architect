# Web App

## 1 Scope

Applies to application projects that use a browser as the user interaction entry point
Common project forms include admin consoles, online editors, and collaboration platforms

Prefer governing the frontend and backend as separate repositories; use the full-stack structure when they must be delivered in the same repository

## 2 Project Structure

### 2.1 Frontend-Only Web App

The repository delivers only the frontend; integrate backend capabilities as external dependencies when needed

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<identifier>/     Interfaces, internal implementation, and tests for each business module
│  │  ├─ architecture.md    Module responsibilities, process boundaries, and collaboration
│  │  ├─ class-design.md    Internal implementation and white-box tests for a single-module application
│  │  ├─ distribution.md    Frontend artifact build, delivery, verification, and failure handling
│  │  ├─ infrastructure.md  Infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interaction.md     User scenarios, interfaces, and interaction behavior
│  │  ├─ release.md         Verification, merge, and version lock-in workflow
│  │  ├─ security.md        Attack surface analysis and protection rationale
│  │  └─ testcase.md        Black-box tests for user interaction behavior across the application
│  ├─ ops-guide/            Operations guide, included as needed
│  │  ├─ README.md          Operations guide entry
│  │  ├─ data-collection.md Raw data sources and definitions
│  │  ├─ data-analysis.md   Metrics and analysis methods
│  │  └─ ops-actions.md     Permitted operational actions
│  ├─ user-guide/
│  │  └─ user-manual.md     User operation and troubleshooting guide
│  └─ README.md             Project documentation entry
├─ reference/               External originals that must be stored in the repository
├─ CHANGELOG.md             Change records for released versions
├─ CONTEXT.md               Project glossary
├─ README.md                Project entry and repo type identifier
├─ ROADMAP.md               Current version status and goals for future versions
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
| `architecture.md` | The frontend contains multiple business modules or processes | [architecture](../documents/architecture.md) |
| `class-design.md` | The frontend has only one business module | [class-design](../documents/class-design.md) |
| `distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `infrastructure.md` | Infrastructure requires defined resource structures or integration conventions | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `interaction.md` | Always required | [interaction](../documents/interaction.md) |
| `module-<identifier>/` document set | The frontend contains multiple business modules | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and judgment, or operational actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Versions need to be released | [release](../documents/release.md) |
| `security.md` | Credentials, permissions, sensitive data, or untrusted input are involved | [security](../documents/security.md) |
| `testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `user-manual.md` | Users need separate usage or troubleshooting instructions | [user-manual](../documents/user-manual.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

### 2.2 Full-Stack Web App

The repository delivers both the frontend and backend
Project records, user guides, and operations guides use the locations and requirement conditions in §2.1

```text
design/
├─ backend/             Backend internal design and deployment
├─ frontend/            Frontend internal design and distribution
│  ├─ module-<identifier>/    Module design for a frontend with multiple modules
│  ├─ architecture.md   Internal frontend module responsibilities and collaboration
│  ├─ class-design.md   Internal implementation and white-box tests for a single-module frontend
│  ├─ distribution.md   Frontend artifact build, delivery, verification, and failure handling
│  ├─ infrastructure.md Frontend infrastructure, resources, and integration conventions
│  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  ├─ interaction.md    User scenarios, interfaces, and interaction behavior
│  ├─ security.md       Frontend security design
│  └─ testcase.md       Black-box tests for overall frontend behavior
├─ architecture.md      Frontend and backend responsibilities, boundaries, and collaboration
└─ release.md           Release verification, merge, and version lock-in for the entire application
```

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `backend/` | Always required | [backend-service](backend-service.md) |
| `frontend/` | Always required | Each file uses its corresponding writing reference in §2.1 |
| `architecture.md` | Always required | [architecture](../documents/architecture.md) |
| `frontend/architecture.md` | The frontend contains multiple business modules or processes | [architecture](../documents/architecture.md) |
| `frontend/distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `frontend/interaction.md` | Always required | [interaction](../documents/interaction.md) |
| `release.md` | Versions need to be released | [release](../documents/release.md) |
| `frontend/testcase.md` | Always required | [testcase](../documents/testcase.md) |

Determine which files are required within `frontend/` based on the frontend itself, using the corresponding rules in §2.1
Apply the internal design, interface, testing, infrastructure, data observability, security, and deployment rules in [backend-service](backend-service.md) to `backend/`; map the corresponding files from `docs/design/` to `backend/`
Govern project records, the documentation entry, user guides, and [release](../documents/release.md) together; place the user manual and backend integration guide in `docs/user-guide/`, and use release to define release verification, merge, and Tag lock-in for the entire repository
Place operations guides together in the outer `docs/ops-guide/`, referencing the event and data definitions of the frontend and backend
Define frontend distribution and backend deployment in `frontend/distribution.md` and `backend/deployment.md`, respectively
Define user interaction in `frontend/interaction.md`; maintain separate `testcase.md` files for the frontend and backend, without creating a project-level testcase

## 3 Governance Order

When subsequent governance identifies missing or conflicting upstream designs, correct the corresponding docs and update the affected downstream designs

### 3.1 Frontend-Only Web App

1. Govern user interaction
   - Govern [interaction](../documents/interaction.md) first
2. Govern responsibility allocation and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on [interaction](../documents/interaction.md)
   - First govern the resource structures and integration conventions in the selected [infrastructure](../documents/infrastructure.md) that affect internal implementation
   - First govern the constraints in [distribution](../documents/distribution.md) and the selected [security](../documents/security.md) that affect internal implementation
   - Govern [instrumentation](../documents/instrumentation.md) to define the data recording conventions needed for internal implementation
3. Govern internal design
   - For a single-module frontend, govern the project-level [class-design](../documents/class-design.md)
   - For a frontend with multiple modules, govern dependency modules first according to the module dependencies defined in [architecture](../documents/architecture.md)
   - Within each module of a frontend with multiple modules, follow the governance order specified by the [module](../document-sets/module.md) document set
4. Govern overall verification
   - Govern the project-level [testcase](../documents/testcase.md) based on [interaction](../documents/interaction.md)
5. Complete delivery and usage instructions
   - Based on the internal design, complete the selected [infrastructure](../documents/infrastructure.md) and the protection rationale in the selected [security](../documents/security.md)
   - Complete [distribution](../documents/distribution.md) based on the internal design and delivery constraints
   - Govern the selected [release](../documents/release.md) after the preceding designs are defined
   - Govern the selected [user-manual](../documents/user-manual.md) after interaction behavior and delivery methods are defined
   - Govern the selected [ops-guide](../document-sets/ops-guide.md) after the data, interfaces, and operational constraints needed for operations are defined
6. Complete the documentation entry
   - After the project design is defined, complete the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

### 3.2 Full-Stack Web App

1. Govern frontend [interaction](../documents/interaction.md) to define user interaction behavior
2. Govern the overall [architecture](../documents/architecture.md) based on frontend [interaction](../documents/interaction.md)
3. Govern frontend and backend designs based on overall responsibilities and dependencies
   - For frontend–backend collaboration, define the backend [interface](../documents/interface.md) contract first, then govern the frontend implementation that depends on it
   - Govern subsequent designs in `frontend/` according to §3.1; govern release, user guides, operations guides, and the project documentation entry together at the project level
   - Govern `backend/` according to the governance order in [backend-service](backend-service.md); govern release, integration guides, operations guides, and the project documentation entry together at the project level
4. Complete unified release and usage instructions
   - Govern the selected project-level [release](../documents/release.md) after the frontend and backend designs and delivery solutions are defined
   - Govern the selected [user-manual](../documents/user-manual.md) and [integration-guide](../documents/integration-guide.md) based on frontend interaction and backend integration conventions
   - Govern the selected [ops-guide](../document-sets/ops-guide.md) after the data, interfaces, and operational constraints needed for operations are defined
5. Complete the project documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operational analysis is designed, with clear recording timing, data content, data destinations, and responsible parties
- [ ] All docs and document sets whose prerequisites are met for the selected project form are established
- [ ] Doc locations follow the hierarchy tree for the selected project form, and internal file composition follows the corresponding document set or reference rules
- [ ] All contracts and constraints required by subsequent design can be traced to clearly defined upstream docs
- [ ] The frontend call design of the full-stack application references the backend [interface](../documents/interface.md) and conforms to its contract
