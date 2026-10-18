# Context

## Language

### repo-type

Repo type
An engineering project belongs to exactly one repo type, determined by its engineering form; the type defines its standard documentation structure—which docs are required, which doc design each follows, and in what order they are written
Registered in `doc-design/repo-types/` and recorded in the project's aca-footer; the English key `repo-type` is a historical identifier and remains in use
_Avoid_: "repository type", "project type"

### repo-type-spec

Repo-type spec
The carrier of the standard documentation structure for a repo type, namely `doc-design/repo-types/{repo-type}.md`: it registers the doc list for this repo type and the doc design for each, the files allowed in the root directory, the design order, and the walkthrough order
_Avoid_: "type README", "repo-type README"

### document-set

A document set (Document Set) is a group of docs that jointly describe a design object
It specifies which files to include, their responsibilities and relationships, and the design order
Rules reside in `doc-design/document-sets/`, selected by repo types as needed
Each file follows its corresponding doc design
_Avoid_: Using "module" as a collective term for module, command, and event document sets

### doc-design

A doc design defines the organization rules for a single design doc
It specifies the chapters, the pattern used in each chapter, the writing steps, and the checklist
Rules reside in `doc-design/documents/`, selected by repo types and document sets
_Avoid_: "outline", "structure outline", "template"—the chapter and section skeleton provided by a doc design is a criterion, not a replaceable style

### pattern

The best writing unit for a class of problems or solutions
When a type of content recurs (a state machine, a sequence involving multiple parties, a set of APIs, a card), it has a best way to be written, and a pattern fixes that way: use the writing format that readers can understand most easily to express the unit's design clearly, without redundancy, omissions, or ambiguity, and explain when to select it
Reusable across repo types; its scope is a passage within a doc, referenced by doc designs, and one doc design can reference multiple patterns
_Avoid_: "diagram type", "style"—form is the result of a pattern, not the pattern itself

### card-mockup

Card mockup (card mockup)
A visual model in a design doc that uses HTML and concrete examples to simulate a card's intended appearance, showing layout, copy, data, and controls to help readers understand the design visually and guide implementation of the card JSON; the `lark-card-mockup` pattern defines the specific expression rules

### module

A module is a design unit divided by business capability in a project with multiple modules
Each module has its own directory `docs/design/module-{X}/`, with a complete external contract, internal design, and verification
architecture defines the module boundaries and topology, while each module's design docs detail its internals
The repo type determines when to use modules, and the module document set specifies the directory composition
_Avoid_: Treating a module as a class, file, or independent service in code

### axiom

Injected axiom
A baseline that belongs to no single doc or workflow and applies to the entire methodology, enforced through mechanical injection rather than references
Writing axioms are injected into the bodies of design skills at build time and prepended to each doc design at deployment time; completeness axioms are injected only into design skills
Source files reside directly in `axioms/`, and [axioms/README.md](axioms/README.md) registers their injection destinations

### chapter

Chapter
`## N Title`, the first level of division below the doc title, corresponding to a division in ISO 2145 and a chapter in GB/T 1.1
_Avoid_: "part", "first-level heading"

### section

Section
`### N.N Title`, the second level of division below a chapter, corresponding to a subdivision in ISO 2145 and a clause in GB/T 1.1
_Avoid_: "subsection", "second-level heading", "clause"

### subsection

Subsection
`#### N.N.N Title`, the third level of division below a section and the deepest level, appearing only in blocks specified by a pattern
_Avoid_: "third-level heading"

### drill-down

Drill-down starts from the problem or requirement as a whole and progressively breaks down and refines the solution until it can be implemented directly
A doc design says "drill down into X" to specify the content that needs elaboration
_Avoid_: "drill into", "recursive expansion", "entry point"

### aca-footer

The last line of the project's root README
It indicates that the project was designed with Anyone Can Architect, records the Anyone Can Architect version and repo-type in use, and is the sole source of truth for repo-type; other files, directories, and code can only assist initial identification and cannot override it; the repository's own version line sits immediately above it
_Avoid_: "imprint", "marker", "version block"

## Relationships

- [repo-type](#repo-type) has one [repo-type-spec](#repo-type-spec) (the entry point for all rules of the type)
- [repo-type-spec](#repo-type-spec) selects [document-set](#document-set) and individual [doc-design](#doc-design), and specifies the files allowed in the root directory and the project's overall design and walkthrough order
- [document-set](#document-set) organizes multiple [doc-design](#doc-design), specifying file responsibilities and design order within the set
- [doc-design](#doc-design) references many [pattern](#pattern) (each passage in a doc uses its own pattern)
- [pattern](#pattern) may reference another [pattern](#pattern) (delegating a content unit and stating the trigger conditions)
- [doc-design](#doc-design) references the guiding principles for drill-down and specifies which parts to [drill-down](#drill-down) into
- [module](#module) uses the module [document-set](#document-set), with [repo-type-spec](#repo-type-spec) determining when to use it
- [aca-footer](#aca-footer) determines the project's [repo-type](#repo-type)
- [chapter](#chapter) contains many [section](#section), [section](#section) contains many [subsection](#subsection), and doc designs specify structure only down to section

## Flagged ambiguities

- Rules for the structure of an entire doc belong to [doc-design](#doc-design), not [pattern](#pattern); patterns govern only content-level expression—integration-guide and ssot were previously misplaced in patterns and have been moved to their correct locations
- "Governance" previously referred to the act of producing design docs, operations management, and manual maintenance — resolved: from the perspective of outputs, use "design" consistently, and rename the directory `doc-governance/` to `doc-design/`; use "constraints / management" for operations, "maintenance" for manual upkeep, and "support" for capability scope
- "SSOT" has been used for three different objects in repositories applying the methodology: the root external sources file `SSOT.md`, a project-defined directory of internal standards shared across modules (such as `docs/ssot/`), and "contract docs that serve as the source of design truth" — current rule: root `SSOT.md` contains only external sources; the latter two uses show that Anyone Can Architect has no designated location for internal standards shared across modules, pending a decision
- Follow the [context doc design](doc-design/documents/context.md) for the scope and wording of terms included in a project's CONTEXT
- "Doc design" and "design doc" — resolved: a doc design is a rule in Anyone Can Architect that specifies how to write a doc, while a design doc is the output a project produces under those rules (`docs/design/`); the feedback field `target_outline` and feedback type `outline-diff` are existing data contracts and remain in use
