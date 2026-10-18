# Doc Design: context

## 1 Purpose

Define the terms shared across the project and their meanings
Include terms specific to this business that at least two modules share and whose meanings need explicit agreement
Define terms used only within a single module in that module's design doc
Exclude content outside this business, common industry terms, and general terms

Project positioning belongs in [readme](readme.md)

## 2 Structure

Use `# Context` as the doc title
Use level-two headings for each part, in the order shown below

| Part | Requirement | Content and writing rules |
| --- | --- | --- |
| `Language` | Always required | [Term names and definitions](#21-language) |
| `Relationships` | As needed | [Relationships between concepts](#22-relationships) |
| `Example dialogue` | As needed | [Dialogue showing term usage](#23-example-dialogue) |
| `Flagged ambiguities` | As needed | [Ambiguous expressions and their explicit meanings](#24-flagged-ambiguities) |

### 2.1 Language

Create an entry for each concept with a level-three heading
Use the concept's primary name as the heading, without numbering
Entry headings must be unique throughout the doc, ignoring case
Put translations and aliases for the same concept under the same entry
When different concepts share a name, add a business scope qualifier to the name

Prefer English for primary names
When a primary name uses an existing code name or proper name, preserve its original form
If no accurate English name exists, keep the primary name in its original language
Use only letters, digits, spaces, underscores, hyphens, and periods `.` in English entry headings

When a term is needed in another language, write a fixed translation below the heading, such as `中文：责任人` <!-- i18n-keep -->
Write translations and annotations as visible body text
Write definitions in the team's working language

Start each definition with one sentence stating what the concept is
Add scope and boundaries that are easy to confuse as needed
Explain the concept's meaning rather than only listing synonyms
When a definition uses other project terms, link to their entries

Add the following notes after the definition as needed
Use the markers in the table without adding separate headings

| Marker | Content |
| --- | --- |
| `Aliases:` | Abbreviations for the same concept or other names accepted in this business |
| `_Avoid_:` | Names to avoid in this business and the reasons |
| `_For users_:` | Natural wording for users |

Use primary names or fixed translations in design docs
Express the same concepts in code names according to the programming language's naming conventions
Keep user-facing wording consistent with the concepts' meanings

### 2.2 Relationships

Write this chapter when ownership, composition, or associations between concepts need a consolidated explanation
Link the concepts involved in each relationship to their entries
State the direction of directional relationships
State cardinality constraints when they are needed to distinguish concepts

### 2.3 Example dialogue

When terms are easy to misuse in business communication, use short dialogues to demonstrate correct usage
Link terms in the dialogue to their entries
Show how to distinguish concepts that are easy to confuse

### 2.4 Flagged ambiguities

When an expression can refer to different concepts, state which concept it refers to in this business
Link the concepts involved to their entries

## 3 Writing Steps

1. Extract candidate terms from business discussions, existing docs, and code
   Check which modules use them and for what business purposes, then filter them by the [inclusion scope](#1-purpose)
   Determine cross-module use by whether multiple modules depend on the concept's meaning, rather than only counting occurrences of its name
2. Compare candidates with existing entries to identify reusable concepts, new concepts, and changes in meaning
   Reuse the corresponding entries for existing concepts
3. Confirm the primary names, definitions, and scope of new or revised concepts with business stakeholders
4. Write or revise entries according to the [Language](#21-language) rules
5. Test whether terms have clear meanings using actual business statements
   Add [Relationships](#22-relationships), [Example dialogue](#23-example-dialogue), and [Flagged ambiguities](#24-flagged-ambiguities) as needed
6. When a term's name or meaning changes, update wording and entry references in affected docs
   - Name changes: update affected references to entry anchors
   - Meaning changes: check related contracts and implementation designs
7. Review the doc against the [Checklist](#5-checklist)
   Run `aca-context-check CONTEXT.md`

## 4 Example

The following example uses task owners and owners in a task collaboration business

```markdown
# Context

## Language

### task-owner

Chinese: task owner
The person accountable for delivery of the entire task
Distinct from the [owner](#owner), who performs specific work
_Avoid_: task owner, which can be confused with the [owner](#owner) who performs specific work
_For users_: Who is accountable for delivering this task

### owner

Chinese: owner
The person who performs specific work within a task
_For users_: Who will do this work
```

## 5 Checklist

- [ ] Include only terms specific to this business whose meanings need explicit agreement
- [ ] At least two modules share each concept, rather than its name merely appearing in multiple places
- [ ] Create only one entry for each concept
- [ ] Names and definitions distinguish concepts that are easy to confuse
- [ ] Additional notes follow the [Language](#21-language) rules
- [ ] Terms in docs and code have meanings consistent with their entry definitions
- [ ] [Relationships](#22-relationships), [dialogues](#23-example-dialogue), and [ambiguity clarifications](#24-flagged-ambiguities) meet their respective writing conditions and expression rules
- [ ] Changes to term names or meanings are reflected in affected docs
- [ ] Entry references are valid
- [ ] The `aca-context-check` check passes
