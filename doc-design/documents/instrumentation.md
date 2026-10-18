# Doc Design: instrumentation

## 1 Purpose

Define how business data is recorded, including events and parameters, for engineering implementation and subsequent data collection and analysis
Define business records from instrumentation, structured logs, and third-party collection uniformly as events, using event name as the unique identifier

## 2 Structure

The body contains the following three chapters

| Chapter | Content requirements |
| --- | --- |
| 1 Data Destinations and Responsibilities | Describe the recording methods, data destinations, and responsibilities of each party, with references to infrastructure, third-party SDKs, or other existing designs as needed |
| 2 Event Summary | List event name, meaning, and recording trigger in a table, and link to the corresponding event details |
| 3 Event Details | Create a section for each event name to describe its parameters and data structures |

### 2.1 Data Destinations and Responsibilities

Specify whether data is recorded through an instrumentation SDK, logs, or other methods, who produces the records, and how and where they are delivered
When implementation depends on the integrating party, state its responsibilities and reference them in the integration guide
When multiple platforms share a design, describe each platform's recording responsibilities separately and connect them through references

### 2.2 Event Summary

The table must include at least three columns: event name, specific meaning, and recording trigger
Each event name must be unique within the project and lead to the corresponding event details
When existing designs define events and triggers, reuse them through references

### 2.3 Event Details

Start each event with a parameter table, with the number of parameters determined by the event's needs
Use key-value parameters, where key is the parameter name and value must have an explicit type and any necessary value constraints
The parameter table describes the key, the value type and constraints, and the parameter's meaning
For nested structures, specify each parameter's parent and the data structure at each level
Determine parent from the parameter's full parent path, and treat the top-level parameters of all events as belonging to the same parent
The parent path does not include event name

All recording methods must specify parameter types to support subsequent columnar data storage and analysis
Within the project, keys with the same name under the same parent must have consistent value types and data format constraints
Check consistency across events, with no exceptions for different event names
Use different key names when consistency cannot be maintained

## 3 Writing Steps

1. Specify recording methods, data destinations, and each party's responsibilities, and reference existing designs for infrastructure or third-party capabilities
2. Summarize events, and assign each event a unique event name, meaning, and recording trigger
3. Write details for each event, starting with the parameter table and then expanding the required data structures
4. Check keys with the same name under the same parent across events, align their types and data format constraints, and rename keys when conflicts occur
5. Complete the links from the event summary to the details, and check the doc against the [Checklist](#5-checklist)

## 4 Example

The first chapter states that task events are recorded using JSON streaming logs and references the log collection capabilities and data destinations in infrastructure
The second chapter uses an event summary table

| event name | Meaning | Recording trigger |
| --- | --- | --- |
| `task_started` | Task starts | When the task enters the running state |
| `task_finished` | Task ends | When task execution ends |

The third chapter contains separate sections for `task_started` and `task_finished`, with event names in the summary table linking to the corresponding sections
Each section starts with a parameter table, such as the parameters for `task_finished`

| key | value type and constraints | Meaning |
| --- | --- | --- |
| `task_id` | string, non-empty | Task identifier |
| `duration_ms` | integer, greater than or equal to 0 | Execution duration in milliseconds |

If `task_started` also uses `task_id` under the same parent, it uses the same string type and non-empty constraint

## 5 Checklist

- [ ] Recording methods, data destinations, and each party's responsibilities are clear, and references to existing designs are valid
- [ ] The event summary includes unique event names, meanings, and recording triggers, with a one-to-one correspondence to event details
- [ ] All events and parameters required for analysis are defined
- [ ] Each event's details start with a parameter table, with a clear key, value type, and necessary constraints for each parameter
- [ ] The parent and data structures of nested parameters are clear
- [ ] Cross-event checks confirm consistent value types and data format constraints for keys with the same name under the same parent
- [ ] When implementation depends on the integrating party, the integration guide states the corresponding requirements
