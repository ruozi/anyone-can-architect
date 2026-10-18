# Doc Design Rules

This directory stores repo-type specs, document sets, single-doc design rules, and patterns

This file provides unified navigation; the corresponding repo-type spec defines each repo type's project structure, documentation requirements, and governance conventions
When designing project docs, first read the repo-type spec, then the selected document sets and corresponding doc designs, and select patterns as needed for the content

## Repo Type and Doc Design

Repo types define project structure and documentation requirements

| Repo type | Applicable projects | Design rules |
| --- | --- | --- |
| `web-app` | Applications that use a browser as the user interaction entry point | [Web Application](repo-types/web-app.md) |
| `mobile-app` | Mobile applications for Android, iOS, and other platforms | [Mobile Application](repo-types/mobile-app.md) |
| `desktop-app` | Desktop applications for Windows, macOS, Linux, and other platforms | [Desktop Application](repo-types/desktop-app.md) |
| `client-sdk` | SDKs or libraries for integration into client projects | [Client SDK](repo-types/client-sdk.md) |
| `backend-service` | Services that provide remote invocation capabilities to other programs | [Backend Service](repo-types/backend-service.md) |
| `automation` | Automation workflows triggered by commands or events | [Automation Service](repo-types/automation.md) |
| `guideline` | Department standards, team guidelines, and rule collections | [Guideline Repository](repo-types/guideline.md) |

## Document Set

Document sets define the files, responsibility relationships, and design order that together describe a design subject, and are stored in `document-sets/`
Repo types select the required document sets; each file's structure and writing method reference the corresponding doc design

| Document set | Responsibilities |
| --- | --- |
| [module](document-sets/module.md) | Module README, external contract, internal implementation, and black-box tests |
| [command](document-sets/command.md) | Command descriptions, registry, routing hub, and leaf commands |
| [event](document-sets/event.md) | Trigger policies, registry, dispatch center, and specific events |
| [ops-guide](document-sets/ops-guide.md) | Operations data collection, analysis methods, and executable actions |

## Doc Design

Doc designs are stored by doc name in `documents/`, with one file per doc; repo types and document sets select them by responsibility and determine their order
See [guideline](documents/guideline.md) for requirements for writing guideline content
See [context](documents/context.md) for the structure and writing method for project glossary docs
See [ssot](documents/ssot.md), [roadmap](documents/roadmap.md), and [changelog](documents/changelog.md) for project external sources, version planning, and change records, respectively
See [instrumentation](documents/instrumentation.md) for the structure and writing method for business data observation design
See [data-collection](documents/data-collection.md) and [data-analysis](documents/data-analysis.md) for the structure and writing methods for data collection and analysis guides, respectively
See [ops-actions](documents/ops-actions.md) for the structure and writing method for operations action guides
Doc designs have no purpose, introduction, or index [chapter](../CONTEXT.md#chapter); the readme explains what the unit is, and the directory structure provides navigation
Doc designs cover two things: Structure is the destination and defines the expected final form; Writing Steps explain how to reach it, while patterns define how to write the content of each [chapter](../CONTEXT.md#chapter)

## Patterns

Patterns stores patterns shared across repo types

- Name each pattern by content type and explain how to write and diagram that content
- When expression principles cover only one content unit, state the rules directly; for multiple content units, use a composition table and reference the corresponding subsections
- The composition table lists content, required conditions, and expression rules; when all content is required, state this before the table and omit the required conditions column
- Define the presentation format and specific rules in the corresponding subsections; do not repeat them in the composition table
- Describe scenario differences for the same content type in the same pattern file; do not create separate files
- Follow the official syntax pages for Mermaid syntax and styling; patterns define only content rules and do not invent styles
- A pattern may delegate one of its content units to another pattern, with explicit conditions for delegation; when only guiding selection, link without nesting
- For content whose doc design does not specify a pattern, select a pattern based on its usage scenarios; use tables or text only when no pattern fits
- See [companion rules](../skills/references/README.md) for methodology and mapping rules shared by doc designs and patterns

### Diagrams

- [Flowchart](patterns/flowchart.md) (programmatic flows and flows that include LLMs / Agents)
- [Sequence Diagram](patterns/sequence-diagram.md)
- [State Machine](patterns/state-machine.md)
- [Layered View](patterns/layered-view.md) (choose either a hierarchical relationship view or a layered module dependency view)
- [Hierarchy Tree](patterns/hierarchy-tree.md)

### Text

- [Module Interface](patterns/interface.md)
- [Data Contract](patterns/schema.md)
- [LLM Prompt](patterns/llm-prompt.md)
- [Agent Goal](patterns/agent-goal.md)
- [Test Cases](patterns/testcase.md) (fixtures, long-chain scenarios, and assertion writing shared by black-box and white-box tests)

### Cards

- [Lark (Feishu) Card Mockup](patterns/lark-card-mockup.md)

## Mermaid Diagram Type Dictionary (All 28 Types)

> Mermaid diagram types in design docs are limited to those "In Use"
> Before first using a "Candidate", test it successfully on the target renderer, then create a pattern for the content type
> Follow each type's official syntax page

### In Use (3 Types Covering All Diagram Patterns)

| Official type name | Keyword | Syntax SSOT | Patterns supported |
|---|---|---|---|
| Flowchart | `flowchart` | <https://mermaid.ai/open-source/syntax/flowchart.html> | flowchart · layered-view |
| Sequence Diagram | `sequenceDiagram` | <https://mermaid.ai/open-source/syntax/sequenceDiagram.html> | sequence-diagram |
| State Diagram | `stateDiagram-v2` | <https://mermaid.ai/open-source/syntax/stateDiagram.html> | state-machine |

> C4 Diagram (<https://mermaid.ai/open-source/syntax/c4.html>) is unused: its official syntax is still experimental and its layout cannot be controlled; layered views use `flowchart` + `subgraph`

### Candidates (Activate When a Real Scenario Arises)

| Official type name | Keyword | Syntax SSOT | Real scenario awaited |
|---|---|---|---|
| GitGraph Diagram | `gitGraph` | <https://mermaid.ai/open-source/syntax/gitgraph.html> | Illustrating version branching models / merge strategies |
| Class Diagram | `classDiagram` | <https://mermaid.ai/open-source/syntax/classDiagram.html> | A need to illustrate class structure |
| Entity Relationship Diagram | `erDiagram` | <https://mermaid.ai/open-source/syntax/entityRelationshipDiagram.html> | A need to illustrate entity relationships |
| Architecture | `architecture-beta` | <https://mermaid.ai/open-source/syntax/architecture.html> | Deployment topology with cloud resource icons<br>Currently covered by layered-view |
| Event Modeling | See syntax page | <https://mermaid.ai/open-source/syntax/eventmodeling.html> | Workflow modeling for event-driven backends (event sourcing) |
| Packet | `packet-beta` | <https://mermaid.ai/open-source/syntax/packet.html> | Bit-level binary protocol / packet format definitions |
| Venn | `venn-beta` | <https://mermaid.ai/open-source/syntax/venn.html> | Expressing set overlaps, such as intersections of audience selections or platform capabilities |

### Unused (Content Belongs Elsewhere)

| Official type name | Where this content type belongs in this system |
|---|---|
| User Journey | Product flows belong in flowchart or sequence-diagram<br>journey can only express linear flows with scores |
| Gantt | Schedules change at any time and belong in project management tools, outside design docs |
| Timeline | Git and Tags record history and milestones, design docs do not repeat them |
| Kanban | Task flows belong in project management tools |
| Pie Chart | Data presentation belongs in data reporting tools, design docs do not contain live data |
| XY Chart | Same as above |
| Sankey | Same as above, advertising funnels and volume allocation are data analysis outputs |
| Radar | Same as above |
| Treemap | Same as above |
| Quadrant Chart | Use standard comparison tables to reason through selection / positioning |
| Requirement Diagram | The design doc tree and § cross-references handle requirements tracking |
| ZenUML | Duplicates the expressive capabilities of sequenceDiagram and has poor renderer compatibility |
| Block Diagram | Structural block diagrams belong in layered-view / flowchart |
| Ishikawa | No actual usage scenario yet, excluded for now |
| Mindmap | Divergent brainstorming does not belong in design docs, write the resulting conclusions according to the target doc's doc design |
| Wardley Map | An exploratory strategy tool, this system serves well-defined business needs |
| TreeView | Hierarchy trees use indentation in code blocks, compatible with all renderers |
