# Doc Design: data-analysis

## 1 Purpose

For analysts of operational data, explain the analysis methods and available visualization options for each metric
The same raw data can support analysis of multiple metrics

## 2 Structure

The first chapter is “Metric Summary”, with a table listing metrics, their meanings, and links to the corresponding analysis chapters
From the second chapter onward, each chapter explains one metric

Each metric includes the following content

| Content | Requirement |
| --- | --- |
| Analysis method | Reference the required raw data definitions and explain how to calculate and analyze the metric |
| Visualization | Describe presentation options as needed, optionally including an HTML mockup |

## 3 Writing Steps

1. Identify the metrics to analyze and write the metric summary table
2. Write a separate analysis chapter for each metric, explaining the required data and analysis process
3. Add visualization options or an HTML mockup as needed
4. Complete the links from the summary table to each metric chapter and check the doc against the [Checklist](#5-checklist)

## 4 Example

The first chapter summarizes “Order count” and “Transaction amount”, linking each to its analysis chapter
The “Order count” chapter references the order data definitions and explains the scope, filter criteria, and counting process
To observe trends, describe a line chart by date or provide the corresponding HTML mockup
Explain the analysis method for “Transaction amount” in a separate chapter

## 5 Checklist

- [ ] The first chapter summarizes the metrics in a table, including their meanings and valid links to analysis chapters
- [ ] Each metric has a separate chapter, and the required raw data definitions can be located
- [ ] The analysis method explains how to calculate and analyze the metric
- [ ] When visualizations are provided, their content matches the corresponding metrics and analysis methods