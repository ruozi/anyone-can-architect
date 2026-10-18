# Document Set: ops-guide

## 1 When to Use

Use for projects that use engineering-generated data to support analysis, judgment, and operational actions, and continuously check the effects of those actions

## 2 Composition

Data collection, data analysis, and operational actions have separate responsibilities, each described in its own guide
Place the docs in the operations guide directory specified by the repo type, with four fixed files

```text
ops-guide/
├─ README.md
├─ data-collection.md
├─ data-analysis.md
└─ ops-actions.md
```

| File | Responsibility |
| --- | --- |
| `README.md` | Explain operational objectives, the relationships among the three guides, and the entry points for execution |
| [data-collection.md](../documents/data-collection.md) | Explain raw data sources, acquisition methods, and data definitions |
| [data-analysis.md](../documents/data-analysis.md) | Summarize analysis metrics and explain the analysis method and optional visualization methods for each metric |
| [ops-actions.md](../documents/ops-actions.md) | Explain permitted actions, operating methods, and result verification methods by chapter, and explain the basis for operations as needed |

Organize entry points and navigation in README according to the [readme doc design](../documents/readme.md)
Each of the three guides organizes content around its own responsibilities, with its specific chapter structure defined by its doc design
Connect operational objectives through cross-doc references

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
   Create a separate doc only when the content requires independent maintenance and reuse across multiple scenarios
3. Retain information for the current scenario
   When referencing shared methods, specify the selected method, applicable conditions, inputs or parameters, and expected results

## 3 Governance Order

1. Determine operational objectives and the input–output relationships among the three guides
   Define the questions that analysis must answer and the data required
   Check the data the engineering system can provide and the actions that can actually be taken
2. Write the data collection guide
   Define raw data sources, acquisition methods, and data definitions
3. Write the data analysis guide
   Summarize metrics and explain the analysis method and optional visualization methods for each metric
   If required raw data sources or definitions are missing, return to step 2 to complete them
4. Write the operational actions guide
   Explain permitted actions, operating methods, and result verification methods by chapter
   Add references when actions depend on analysis metrics, and return to step 3 to add missing metrics
5. Complete README and cross-doc references
   When changes affect other guides, update inputs, outputs, and references together
   Starting from operational objectives, check the connections between collection, analysis, actions, and the next round of data

When engineering capabilities or business decisions are insufficient, record the specific gaps and continue writing after the input provider confirms them
The guides must not invent unconfirmed engineering capabilities
This chapter defines the doc governance order, while each guide defines its actual operational execution cycle

## 4 Checklist

- [ ] After selecting the document set, all four fixed files exist and each has clear responsibilities
- [ ] README explains operational objectives and the relationships among the three guides, and provides valid entry points
- [ ] Raw data sources, acquisition methods, and data definitions are complete and can be consulted directly or located through references
- [ ] The metric summary provides access to each metric chapter, analysis methods are clear, and visualizations are explained as needed
- [ ] Permitted actions, operating methods, and result verification methods are clear
- [ ] When data is used to evaluate the effects of actions, the required data and analysis metrics can be located
- [ ] The analysis guide references the required raw data, and actions that depend on analysis metrics reference the corresponding metric chapters
- [ ] Shared definitions and rules are defined in one place and can be located through references
- [ ] When shared methods are referenced, applicable conditions, inputs or parameters, and expected results are clear
- [ ] The guides match the engineering system's actual data, interfaces, and operational capabilities
