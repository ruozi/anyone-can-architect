# Specification Repository

## 1 Scope

Applies to department specifications, team guides, and rule collections

When the primary deliverable is a product or service, govern it according to the corresponding repo type

## 2 Project Structure

The following is an example structure, with specification files and directories arranged by actual topic and their locations identified in the project entry

```text
<project>/
├─ <deliverable>/    Independently delivered non-doc object, included as needed
│  └─ CHANGELOG.md   Object changes, compatibility impacts, and migration instructions
├─ <spec-topic>/     Specification content organized by topic
│  ├─ README.md      Topic entry, included as needed
│  └─ <spec>.md      Specific specification and usage requirements
├─ reference/        External originals that must be stored in the repository
├─ CONTEXT.md        Project glossary
├─ README.md         Project entry and repo type identifier
└─ SSOT.md           External sources and their original sources
```

| File or document set | Required when | Writing reference |
| --- | --- | --- |
| `CONTEXT.md` | Always required | [context](../documents/context.md) |
| Root `README.md` | Always required | [readme](../documents/readme.md) |
| Topic `README.md` | Topic responsibilities need explanation or navigation within the topic is needed | [readme](../documents/readme.md) |
| `SSOT.md` | Specifications rely on external sources | [ssot](../documents/ssot.md) |
| `<spec>.md` | Always required, organized by actual topic | [guideline](../documents/guideline.md) |
| `<deliverable>/CHANGELOG.md` | A non-doc object has independent providers and consumers | [changelog](../documents/changelog.md) |
| `reference/` | External originals must be stored in the repository | [ssot](../documents/ssot.md) |

guideline does not create, retain, or read `ROADMAP.md`
The guideline root directory does not create, retain, or read `CHANGELOG.md`
Object-level records describe the change summaries, compatibility impacts, and migration actions that consumers need to know