# Document Set: ops-guide

## 1 When to Use

Use for projects that need to give operations or data platform users guidance on data collection, analysis methods, or operational actions

## 2 Composition

Create the operations guide directory and each of the three guides as needed
When no guide is needed, you can omit the `ops-guide/` directory
Place the docs in the operations guide directory specified by the repo type; see the table below for the required conditions and file names

```text
ops-guide/
├─ README.md
├─ data-collection.md
├─ data-analysis.md
└─ ops-actions.md
```

| File | Required when | Responsibility |
| --- | --- | --- |
| `README.md` | The operations guide directory is created | Explain the purpose of the selected guides, their relationships, and the entry points for execution |
| [data-collection.md](../documents/data-collection.md) | This project needs to explain how to acquire and define data | Explain raw data sources, acquisition methods, and data definitions |
| [data-analysis.md](../documents/data-analysis.md) | This project needs to give guidance on metric analysis | Summarize metrics and explain the analysis method and optional visualization methods for each metric |
| [ops-actions.md](../documents/ops-actions.md) | This project needs to give guidance on operational actions | Explain permitted actions, operating methods, and result verification methods, and explain the basis for operations as needed |

Organize entry points and navigation in README according to the [readme doc design](../documents/readme.md)
Each selected guide organizes content around its own responsibilities, with its specific chapter structure defined by its doc design
When data acquisition involves export, decryption, or parsing, put the operating instructions in the acquisition method of [data-collection](../documents/data-collection.md#2-structure)

### 2.1 Input–Output Relationships

1. The analysis guide references the sources and definitions of the required raw data
2. The actions guide explains the basis for operations as needed
   When actions depend on analysis metrics, reference one or more corresponding metric chapters
3. The actions guide explains result verification methods
   When data is needed to evaluate the effects of actions, reference the corresponding data sources and analysis metrics

### 2.2 Shared Content

1. Reference existing engineering definitions
   Use the data contracts, interfaces, and configuration constraints from the corresponding designs
   Reference [instrumentation](../documents/instrumentation.md) for engineering-generated events and parameters without redefining them
2. Define shared content in one place
   Prefer a unified explanation in the guide responsible for that content
3. Retain information for the current scenario
   When referencing shared methods, specify the selected method, applicable conditions, inputs or parameters, and expected results

## 3 Governance Order

1. Determine the guides this engineering system must provide, and select files according to [Composition](#2-composition)
   Check the required data, analysis methods, and permitted actions, and locate existing definitions
2. When data acquisition and definitions must be explained, write the data collection guide
   Define raw data sources, acquisition methods, and data definitions
3. When metric analysis guidance is needed, write the data analysis guide
   Summarize metrics and explain the analysis method and optional visualization methods for each metric
   If required raw data sources or definitions are missing, add the corresponding content or references
4. When operational action guidance is needed, write the operational actions guide
   Explain permitted actions, operating methods, and result verification methods by chapter
   When actions depend on analysis metrics, add the corresponding content or references
5. Complete README and cross-doc references
   Summarize the purpose and entry points for execution of the selected guides, and check the inputs and result verification methods each one needs

When engineering capabilities or business decisions are insufficient, record the specific gaps and continue writing after the input provider confirms them
The guides must not invent unconfirmed engineering capabilities
This chapter defines the doc governance order, while each guide defines its actual operational execution cycle

## 4 Checklist

- [ ] The directory and guides are selected according to the actual needs of this engineering system, and file names follow the composition
- [ ] When the directory is created, README explains the purpose of the selected guides, their relationships, and the entry points for execution
- [ ] When the data collection guide is selected, raw data sources, acquisition methods, and data definitions are complete
- [ ] When the data analysis guide is selected, the metric summary provides access to each metric chapter, and analysis methods are clear
- [ ] When the operational actions guide is selected, permitted actions, operating methods, and result verification methods are clear
- [ ] When data is used to evaluate the effects of actions, the required data and analysis metrics can be located
- [ ] The analysis guide references the required raw data, and actions that depend on analysis metrics reference the corresponding metric chapters
- [ ] Shared definitions and rules are defined in one place and can be located through references
- [ ] When shared methods are referenced, applicable conditions, inputs or parameters, and expected results are clear
- [ ] The guides match the engineering system's actual data, interfaces, and operational capabilities
