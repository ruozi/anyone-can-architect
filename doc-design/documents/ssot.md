# Doc Design: ssot

## 1 Purpose

Register the external sources the project actually uses and where they come from

## 2 Structure

Use one [chapter](../../CONTEXT.md#chapter) per business topic
Use the business topic name as the chapter title
List source entries directly under the chapter

```text
# Project External Sources

## 1 <business topic>
- <source entry>
- <source entry>

## 2 <business topic>
- <source entry>
```

For each entry, record the source name, the actual link or path to the original file, and a one-sentence content summary
Specify the version or date when the content used depends on a specific version or date
Describe what the source provides in the content summary
Use relative paths to reference original external files stored in the repository

## 3 Writing Steps

1. Identify the external sources actually used in the design or specifications
2. Find the original source and verify that its content supports the rules the project uses
   Confirm the version or date used as needed
   Confirm the source to use with the developer when the source cannot be verified or source contents conflict
3. Group and register verified sources according to the [Structure](#2-structure)
4. Reference the corresponding SSOT entry in the body text that uses the source
   Explain which rules from the source are actually used
5. When the sources used by the project change, update the corresponding entries, affected body text, and references

## 4 Example

```markdown
# Project External Sources

## 1 Version Management
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): Record notable changes by version and distinguish unreleased content from released content
```

## 5 Checklist

- [ ] Each entry is an external source the project actually uses
- [ ] The location identifies the verified source
- [ ] Sources that require a specific version or date include that information
- [ ] Chapters and entries comply with the [Structure](#2-structure)
- [ ] No source is registered more than once
- [ ] Body text that uses a source references the corresponding SSOT entry
- [ ] The body text explains which rules from the source are actually used
- [ ] After the sources used by the project change, the corresponding entries, body text, and references are updated together
