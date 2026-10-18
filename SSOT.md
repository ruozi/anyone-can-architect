# Project External Sources

## 1 Writing Rules

- [Copywriting Typography Guidelines](https://github.com/sparanoid/chinese-copywriting-guidelines): Specify consistent English punctuation, spacing, and typography, with sentence case for body text and Title Case only for headings
- [ISO 2145](https://www.iso.org/standard/26533.html): Specifies chapter and section numbering such as `1` and `1.1`, with no trailing dot, and how to reference these numbers
- [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/STE_faq.html): Reduces ambiguity in technical English through controlled vocabulary, one topic per sentence, direct instructions, and conditions placed before actions
- [Google Developer Documentation Style Guide](https://developers.google.com/style): Specifies language style, wording, formatting, and organization for developer documentation

## 2 Structure

- [The Pyramid Principle](https://www.barbaraminto.com/concept) (Barbara Minto): Organizes ideas as a pyramid, presenting the whole before details and conclusions before supporting evidence

## 3 Terminology Governance

- [Ubiquitous Language](https://martinfowler.com/bliki/UbiquitousLanguage.html) (Martin Fowler): Developers and business stakeholders jointly establish a clear domain language, test it for ambiguity in communication, and update it as their understanding of the domain evolves
- [W3C SKOS Primer](https://www.w3.org/TR/skos-primer/#secconcept): Distinguishes concepts from names and maintains preferred names, alternative names, descriptions, and semantic relationships for the same concept in different languages

## 4 Design and Maintainability

- [Simon, The Architecture of Complexity, 1962](https://www.jstor.org/stable/985254): Complex systems have hierarchical and nearly decomposable structures, hierarchies form stable intermediate structures, lower-level details affect higher levels in aggregate, and descriptions present outlines before details
- [Parnas, On the Criteria To Be Used in Decomposing Systems into Modules, 1972](https://dl.acm.org/doi/10.1145/361598.361623): Assigns modules by responsibility, decomposes systems around decisions that are difficult or likely to change, hides each decision separately, and minimizes what interfaces expose
- [Ousterhout, A Philosophy of Software Design, 2018](https://web.stanford.edu/~ouster/cgi-bin/book.php): Complexity makes systems difficult to understand and modify and manifests as change amplification, cognitive load, and unknown unknowns, while deep modules hide complexity behind small interfaces
- [Stevens, Myers, Constantine, Structured Design, 1974](https://doi.org/10.1147/sj.132.0115): Organizes design around high cohesion and low coupling, lets form follow function, and tests responsibility divisions by expressing them as sentences
- [Dijkstra, The Structure of the THE Multiprogramming System, 1968](https://dl.acm.org/doi/10.1145/363095.363143): Organizes systems by abstraction level and designs for failures alongside normal conditions

## 5 Philosophy

- [Garry Tan, Boil the Ocean](https://garryslist.org/posts/boil-the-ocean): AI reduces the cost of work, making complete goals that were previously too expensive worth pursuing

## 6 API Design

- [RFC 9110 (HTTP Semantics)](https://www.rfc-editor.org/rfc/rfc9110): Defines HTTP semantics, including methods, status codes, fields, safety, and idempotency
- [OWASP API Security Top 10](https://owasp.org/API-Security/): Summarizes common API security risks, including authorization, authentication, resource consumption, and configuration issues

## 7 Platforms and Tools

- [Official Mermaid Syntax](https://mermaid.ai/open-source/): Defines text syntax, configuration, and rendering for various diagram types
- [GitHub REST API: Issues](https://docs.github.com/en/rest/issues/issues): Defines how to create and list issues and authenticate requests
- [Lark (Feishu) Send Message](https://open.feishu.cn/document/server-docs/im-v1/message/create): Defines the message sending interface, message types, request parameters, and message body size limits
- [Lark Card 2.0 JSON Structure](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure): Defines card JSON structure, configuration, headers, body components, and element count limits

- [Antigravity Agent Skills](https://www.antigravity.google/docs/skills?tab=ide): Defines the SKILL.md format and skill discovery directories for the IDE, 2.0, and CLI

## 8 Versions

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): Organizes changes that matter to users by version, separates unreleased content from released records, and groups changes by type
- [Semantic Versioning](https://semver.org/lang/zh-CN/): Distinguishes major, minor, and patch versions by compatibility changes, added functionality, and bug fixes
