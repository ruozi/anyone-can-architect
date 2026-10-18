# Client SDK

## 1 Scope

Applies to projects whose main purpose is to provide installable, callable software packages to other client projects
Common project forms include SDKs and reusable client libraries

Supports two forms: client-only SDKs, and joint design of SDKs and their supporting backend services

## 2 Project Structure

### 2.1 Client-Only SDK

Govern only the SDK itself, and integrate required backend capabilities as external dependencies

```text
<project>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<id>/          Contracts, implementation, and tests for each business module
│  │  ├─ architecture.md       Module responsibilities and collaboration
│  │  ├─ class-design.md       Internal implementation and white-box tests for a single-module SDK
│  │  ├─ distribution.md       Artifact build, distribution, and failure handling workflow
│  │  ├─ infrastructure.md     Infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interface.md          External calling contract of the SDK
│  │  ├─ release.md            Validation, merge, and version lock-in workflow
│  │  ├─ security.md           Security design
│  │  └─ testcase.md           Black-box tests for the SDK's external behavior
│  ├─ ops-guide/               Operations and data platform guides, included as needed
│  │  ├─ README.md             Operations guide entry
│  │  ├─ data-collection.md    Raw data sources and definitions
│  │  ├─ data-analysis.md      Data analysis methods
│  │  └─ ops-actions.md        Executable operational actions
│  ├─ user-guide/
│  │  ├─ integration-guide.md  Integration guide for callers
│  │  └─ user-manual.md        Product user manual, included as needed
│  └─ README.md                Project documentation entry
├─ reference/                  External originals that must be stored in the repository
├─ CHANGELOG.md                Change records for released versions
├─ CONTEXT.md                  Project glossary
├─ README.md                   Project entry and repo type identifier
├─ ROADMAP.md                  Current version status and future version goals
├─ SSOT.md                     External sources and their original sources
└─ …                           Source code, test code, and build configuration organized by the actual technology stack
```

`user-guide/` guides product users in integrating or using the product
`ops-guide/` guides operations or data platform users in data collection, analysis and assessment, operational actions, and verification of action results
Guides in `user-guide/` follow the writing guidance in [integration-guide](../documents/integration-guide.md) or [user-manual](../documents/user-manual.md), depending on how the product is used
Organize `ops-guide/` according to the [ops-guide](../document-sets/ops-guide.md) document set

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `CHANGELOG.md` | Always required | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| `README.md` (at each level) | Always required | [readme](../documents/readme.md) |
| `ROADMAP.md` | Always required | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | The design relies on external sources | [ssot](../documents/ssot.md) |
| `architecture.md` | The SDK contains multiple business modules | [architecture](../documents/architecture.md) |
| `class-design.md` | The SDK is not split into multiple business modules | [class-design](../documents/class-design.md) |
| `distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `infrastructure.md` | Infrastructure must be built or relied on | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | Always required | [instrumentation](../documents/instrumentation.md) |
| `interface.md` | Always required | [interface](../documents/interface.md) |
| `module-<id>/` document set | The SDK contains multiple business modules | [module](../document-sets/module.md) |
| `ops-guide/` document set | Operations or data platform users need guidance on data collection, analysis and assessment, or operational actions | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | Versions need to be released | [release](../documents/release.md) |
| `security.md` | Credentials, user data, network transmission, or permissions are involved | [security](../documents/security.md) |
| `testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `integration-guide.md` | Always required | [integration-guide](../documents/integration-guide.md) |
| `user-manual.md` | Product users need separate usage instructions | [user-manual](../documents/user-manual.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

### 2.2 Joint SDK and Backend Design

Place design docs for the SDK and its supporting backend services under the same design entry

```text
docs/
├─ backend/                 Backend service documentation
│  ├─ design/               Contracts, internal design, tests, and deployment
│  └─ user-guide/           Guides for backend users, included as needed
│     └─ integration-guide.md  Integration guide for backend interface callers
├─ design/
│  ├─ architecture.md       Responsibilities, boundaries, and collaboration of both sides
│  └─ release.md            Repository release workflow when both sides share a code repository
├─ ops-guide/               Operational data and action guides, included as needed
│  ├─ README.md             Operations guide entry
│  ├─ data-collection.md    Raw data sources and definitions
│  ├─ data-analysis.md      Data analysis methods
│  └─ ops-actions.md        Executable operational actions
├─ sdk/                     SDK documentation
│  ├─ design/
│  │  ├─ module-<id>/       Module design for a multi-module SDK
│  │  ├─ architecture.md    Internal module responsibilities and collaboration in the SDK
│  │  ├─ class-design.md    Internal implementation and white-box tests for a single-module SDK
│  │  ├─ distribution.md    SDK artifact build, distribution, and failure handling
│  │  ├─ infrastructure.md  SDK infrastructure, resources, and integration conventions
│  │  ├─ instrumentation.md   Business data recording, collection destinations, and responsibilities
│  │  ├─ interface.md       SDK contract for callers
│  │  ├─ release.md         SDK repository release workflow
│  │  ├─ security.md        SDK security design
│  │  └─ testcase.md        Black-box tests for the SDK's external behavior
│  └─ user-guide/
│     ├─ integration-guide.md  Integration guide for SDK callers
│     └─ user-manual.md        SDK product user manual, included as needed
└─ README.md                Shared documentation entry
```

Paths in the following table are relative to `docs/`

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `backend/` | Always required | [backend-service](backend-service.md) |
| `sdk/` | Always required | Each file follows the corresponding writing reference in [§2.1](#21-client-only-sdk) |
| `design/architecture.md` | Always required | [architecture](../documents/architecture.md) |
| `sdk/design/architecture.md` | The SDK contains multiple business modules | [architecture](../documents/architecture.md) |
| `sdk/design/distribution.md` | Always required | [distribution](../documents/distribution.md) |
| `sdk/design/interface.md` | Always required | [interface](../documents/interface.md) |
| `sdk/design/testcase.md` | Always required | [testcase](../documents/testcase.md) |
| `sdk/design/release.md` | SDK code has its own repository and versions need to be released | [release](../documents/release.md) |
| `backend/design/release.md` | Backend code has its own repository and versions need to be released | [release](../documents/release.md) |
| `design/release.md` | Both sides share a code repository and versions need to be released | [release](../documents/release.md) |
| `ops-guide/` document set | Follows the required conditions in [§2.1](#21-client-only-sdk) | [ops-guide](../document-sets/ops-guide.md) |
| `sdk/user-guide/integration-guide.md` | Always required | [integration-guide](../documents/integration-guide.md) |
| `backend/user-guide/integration-guide.md` | Backend interfaces are delivered to integrators outside the repository | [integration-guide](../documents/integration-guide.md) |
| `sdk/user-guide/user-manual.md` | Follows the required conditions in [§2.1](#21-client-only-sdk) | [user-manual](../documents/user-manual.md) |
| `README.md` (at each level) | Follows the required conditions in [§2.1](#21-client-only-sdk) | [readme](../documents/readme.md) |

Files within `sdk/` follow the required conditions in [§2.1](#21-client-only-sdk), assessed based on the SDK itself
`backend/` follows the documentation rules in [backend-service](backend-service.md)
The `docs/` content in each side's repo-type spec maps to `docs/sdk/` and `docs/backend/`, respectively
Place all operations guides in the outer `docs/ops-guide/`
Select the release docs for both sides according to the table above

When the SDK calls backend interfaces, reference the contracts in `backend/design/interface.md`
`sdk/design/interface.md` defines the contracts that the SDK provides to callers
Each side maintains its own `testcase.md`, without creating a project-level testcase
Develop white-box tests alongside each side's internal implementation design
`sdk/design/distribution.md` and `backend/design/deployment.md` define SDK distribution and backend deployment, respectively
Organize separate integration guides for SDK callers and backend interface callers
Follow the required conditions in each side's repo-type spec
Split operations guides into separate docs by collection, analysis, and action responsibilities
Organize each doc according to the [ops-guide](../document-sets/ops-guide.md) document set and the corresponding doc design
When an operational goal involves both sides, the three guides reference the contracts, data, and security designs of the corresponding side
Use cross-document references to connect data collection, analysis and assessment, operational actions, and verification of results
Define shared methods and procedures in one place, and reference them from other guides

Co-located design docs do not require both sides to share a code repository, versions, or Tags
When each side has its own code repository, each maintains its own version records and release workflow
When both sides share a code repository
- Maintain project-level records together
- `docs/design/release.md` defines repository-level releases and Tag lock-in

## 3 Governance Order

### 3.1 Client-Only SDK

1. Govern the external contract
   - First govern the project-level [interface](../documents/interface.md)
2. Govern responsibility allocation and runtime constraints
   - Govern the selected [architecture](../documents/architecture.md) based on the external contract, then govern each module once the architecture is established
   - If [infrastructure](../documents/infrastructure.md) is selected, govern the infrastructure dependencies before governing the internal implementation
   - First govern the platform and artifact constraints in [distribution](../documents/distribution.md) that affect the internal implementation
   - First govern the constraints in the selected [security](../documents/security.md) that affect the internal implementation
   - Govern [instrumentation](../documents/instrumentation.md) to define the data recording conventions required by the internal implementation
3. Govern the internal design
   - For a single-module SDK, govern the project-level [class-design](../documents/class-design.md)
   - For a multi-module SDK, follow the module dependencies defined in [architecture](../documents/architecture.md) and govern dependency modules first
   - Within each module of a multi-module SDK, follow the governance order specified by the [module](../document-sets/module.md) document set
4. Govern overall verification
   - Once the internal design is clear, govern the project-level [testcase](../documents/testcase.md)
5. Complete distribution, release, and guides
   - Complete the remaining design in the selected [infrastructure](../documents/infrastructure.md) and [security](../documents/security.md)
   - Complete the remaining design in [distribution](../documents/distribution.md)
   - Once the preceding designs are clear, govern the selected [release](../documents/release.md)
   - Once the external contract and artifact integration conventions are clear, govern [integration-guide](../documents/integration-guide.md)
   - Once the usage workflow is clear, govern the selected [user-manual](../documents/user-manual.md)
   - Once the data, interfaces, and operational constraints required for operations are clear, govern the selected [ops-guide](../document-sets/ops-guide.md)
6. Refine the documentation entry
   - Once the project design is clear, refine the project-level documentation entry `docs/README.md` according to [readme](../documents/readme.md)

### 3.2 Joint SDK and Backend Design

1. Govern the SDK [interface](../documents/interface.md) to define the capabilities provided to callers
2. Govern the overall [architecture](../documents/architecture.md) based on the SDK external contract
   - Define the responsibilities, boundaries, and collaboration between both sides
3. Govern the designs of both sides based on the overall responsibilities and dependencies
   - When the SDK calls backend capabilities, first define the backend [interface](../documents/interface.md), then govern the SDK implementation that depends on that contract
   - Govern subsequent design in `sdk/` according to [§3.1](#31-client-only-sdk)
   - Govern `backend/` according to the governance order in [backend-service](backend-service.md)
   - Govern release, all guides, and the shared documentation entry for both sides in steps 4 and 5
4. Complete release and guides
   - Once the designs, distribution, and deployment solutions for both sides are clear, govern the selected [release](../documents/release.md) according to the repository boundaries in [§2.2](#22-joint-sdk-and-backend-design)
   - Govern the required [integration-guide](../documents/integration-guide.md) for each side based on their contracts and integration conventions
   - Once the usage workflow is clear, govern the selected [user-manual](../documents/user-manual.md)
   - Once the data, interfaces, and operational constraints required for operations are clear, govern the selected [ops-guide](../document-sets/ops-guide.md)
5. Refine the shared documentation entry `docs/README.md` according to [readme](../documents/readme.md)

## 4 Checklist

- [ ] The business data recording mechanism that supports operational analysis is designed, with clear recording timing, data content, data destinations, and responsible parties
- [ ] All docs and document sets whose required conditions are met for the selected project form are established
- [ ] Doc locations match the hierarchy tree of the selected project form, and internal file composition follows the corresponding document set or reference rules
- [ ] All contracts and constraints required by subsequent design can be traced to upstream docs where they are already defined
- [ ] The intended users and purposes of guides are clear, their content follows the selected doc design, and the design references they cite are consistent
- [ ] In joint design, the design for SDK calls to the backend references the backend [interface](../documents/interface.md) and complies with its contract
- [ ] In joint design, the location and version boundaries of release match the repository organization of the code for both sides
