# Hierarchy Tree

## 1 When to Use

Show hierarchical relationships: folders and files, layers and nodes in design mockups

## 2 Presentation Principles

| Content | Required When | Presentation Rules |
| --- | --- | --- |
| Tree | Always required | [§2.1](#21-tree) |
| Comments | When an item's meaning needs clarification | [§2.2](#22-comments) |

### 2.1 Tree

Use a `text` code block to show the tree
The top level contains one root or several peer items; use `<placeholder>` for names that are not actual names
End folder names with `/`
Connect child items below their parents with tree lines, and left-align peer items
At each level, list folders before files, sort each group by name, and sort items with numbered prefixes by number

Show only items relevant to the topic, use a single `…` line for the rest, and combine several small items of the same kind on one line if needed

### 2.2 Comments

Place each comment to the right of its corresponding line, with one sentence per line
Align comments in the same tree to the same column
Each comment explains only the content of its corresponding line

## 3 Example: File Structure

```text
<Web application repository>/
├─ docs/
│  ├─ design/
│  │  ├─ module-order/       Order module contract, implementation, and tests
│  │  ├─ architecture.md     Module responsibilities and collaboration
│  │  └─ interaction.md      User scenarios and interactions
│  └─ README.md              Documentation index
├─ src/
│  ├─ order/                 Order module source code
│  └─ …
└─ README.md                 Project front page
```

## 4 Example: Figma Hierarchy

```text
<page>                        Page
├─ <user-scenario>            Section
│  └─ <design-module>         Frame
│     └─ <region>             Frame
│        ├─ Default           Instance
│        └─ Bonus             Instance
└─ Implementation Note        Section
   └─ <design-module>         Frame
      ├─ Target Link          Text
      └─ Responsive Sizing    Text
```

## 5 Checklist

### 5.1 Incomplete or Inaccurate Tree

- [ ] Each node appears only once, its name matches the actual name, and names that are not actual names use `<placeholder>`
- [ ] Folder names end with `/`, folders precede files at each level, and each group is sorted by name or number
- [ ] Omitted parts are marked with `…`

**Counterexample**

```text
command/
├─ README.md
└─ Command files
```

“Command files” is not an actual file name, so readers cannot tell which files exist

### 5.2 Text Repeats Tree Content

- [ ] Comments explain only their own line and do not repeat the name on that line
- [ ] Text outside the code block does not repeat the tree's nodes item by item

**Counterexample**

```text
docs/
├─ README.md            README file
└─ design/              design folder
```

The docs folder contains README.md and the design folder

The comments repeat the names on their lines, and the sentence below the tree repeats the entire tree