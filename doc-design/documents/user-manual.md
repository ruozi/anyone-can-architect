# Doc Design: user-manual

## 1 Purpose

Guide product configuration, scenario use, and troubleshooting from the user's perspective
Users can complete the scenarios supported by the manual without reading internal design docs

User operations and interfaces follow [interaction](interaction.md)
Access entry points, artifact acquisition, and update methods follow the project's selected [distribution](distribution.md) or [deployment](deployment.md)

## 2 Structure

Start by stating the intended users, platforms, and version scope

The first chapter explains the required environment and how to access or start the product, with installation, login, and configuration steps as needed
From the second chapter onward, organize chapters by user scenario
Develop each scenario using [drill-down](../../skills/references/drill-down.md)
Each scenario explains prerequisites, operating steps, completion results, and how to handle failures

After the usage content, add a "Debugging and Verification" chapter that explains how to check overall usage and locate problems
Add an "FAQ" chapter as needed to explain when common issues apply, how to resolve them, and how to report them

Structure outline:

```text
## 1 Environment and Configuration
## 2 <usage scenario>
### 2.1 <specific content>
#### 2.1.1 <specific content>
### 2.2 <specific content>
## 3 <usage scenario>
…
## N Debugging and Verification
## N+1 FAQ              As needed
```

## 3 Writing Steps

1. Identify the users, scope, and usage scenarios supported by the manual
   - Organize scenarios by user goal and confirm the required permissions, inputs, and operating conditions
2. Write the environment and configuration instructions
   - Explain the environment and how to access or start the product, describe the required artifact acquisition, installation, login, and configuration in actual operating order, and provide a way to confirm completion
   - Explain the purpose of each configuration item, where its value comes from, and how to confirm completion
3. Develop each usage scenario
   - Describe inputs, operating steps, completion results, and failure handling in actual operating order
   - Use the product's actual wording for menus, buttons, messages, and terminology
   - Provide screenshots when text alone cannot clearly identify where to perform an operation or find its result
4. Add debugging and verification instructions and any required FAQ
   - Define steps and pass criteria for checking overall usage
   - Provide diagnostic and recovery operations that users can perform, and reference the corresponding content from usage scenarios
   - Explain the contact channels and the version, errors, logs, or screenshots to include when reporting issues, without requesting actual credential values
5. Check against the actual product
   - Ensure that access or startup methods, required configuration, operations, and results match the product version covered by the manual
   - Ensure that information required for use is available in the manual or user-facing materials and does not depend on internal design docs

## 4 Example

````markdown
# Department Report Tool User Manual

For department heads using Windows desktop version 2.0, covering how to generate, export, and view department reports

## 1 Environment and Configuration

1. Obtain "Department Report Tool" from the company software center and complete the installation
2. Open the tool and log in with your company account
   - Seeing your department confirms successful login
   - If your department is not displayed, contact the administrator to register your department permissions and do not proceed with report generation
3. Select an export directory in "Settings", then click "Check Directory"
   - Save the settings after "Directory is writable" appears
   - If the directory is not writable, select a directory you have write permission for and check again

## 2 Generate and Export Department Reports

### 2.1 Define the Report Scope

#### 2.1.1 Select a Department

Select the department you want to view in "Department Reports"
The list shows only departments that the current account has permission to access
If the target department is not listed, contact the administrator to request access

#### 2.1.2 Select Dates

Select the start and end dates, then click "Preview Scope"
For example, select 2026-09-01 through 2026-09-30, and the preview shows "September 2026" and the corresponding department
If the scope is incorrect, change the dates and do not proceed with generation

### 2.2 Generate and Check

1. Click "Generate Report" and wait for the status to change to "Generated"
   - If a failure appears, read the error message and troubleshoot using [§4](#4-debugging-and-verification), without clicking repeatedly
2. Check the department, date range, and record count at the top of the report page
   - If the department or dates do not match, select the scope again
   - If the record count is 0, read "No Data Explanation" to confirm whether the department has business records within the selected scope

### 2.3 Export Reports

1. Click "Export CSV" and confirm the save directory and file name
2. After "Export complete" appears, click "Open Directory"
3. Open the exported CSV and check the department, dates, and record count
   - If another program is using the file, close that program and export again
   - If the file is missing or its content does not match, check and report the issue using [§4](#4-debugging-and-verification)

## 3 View Existing Reports

1. Open "Report History" and find reports by department and date
2. Click a report record to view its department, dates, and generation time
3. To export, click "Export CSV" and check the file using [§2.3](#23-export-reports)

Historical reports retain the data from the time of generation and do not update automatically when business data changes
For the latest results, generate the report again using [§2](#2-generate-and-export-department-reports)

## 4 Debugging and Verification

| Check | Expected result | Troubleshooting |
| --- | --- | --- |
| Check the account and department | The current account and target department are correct | Log in again, and contact the administrator if department permissions are missing |
| Check the export directory | "Directory is writable" appears | Select another directory and check again |
| Compare the report and CSV | The department, date range, and record count match | Keep the report ID and contact the administrator to investigate |

Save the diagnostic file for this issue using "Help → Export Diagnostic Records"
When reporting the issue to the administrator, include the tool version, report ID, time of occurrence, error message, and diagnostic file
Do not include passwords or login credentials

## 5 FAQ

**What should I do if "Directory is not writable" appears?**

In "Settings", select a directory you have write permission for, click "Check Directory", and save

**Why do historical reports remain unchanged after business records are updated?**

Historical reports retain the data from the time of generation, so generate a new report for the latest results

**Do I need to generate the report again if I accidentally close the window?**

First look for the generated record in "Report History", where you can continue viewing or exporting it
Reports that were not generated successfully must be generated again
````

## 5 Checklist

- [ ] The intended users, platforms, version scope, and supported scenarios are stated
- [ ] Scenarios are organized by user goal, and complex content is broken down sufficiently to support complete operations
- [ ] The environment and access or startup methods are explained, required installation, login, and configuration follow the actual sequence, and configuration sources and confirmation methods are defined
- [ ] Prerequisites, inputs, operating steps, completion results, and failure handling are stated
- [ ] Terminology, menus, buttons, and messages match the actual product wording
- [ ] Users can locate the described operations, with screenshots where needed, without understanding the internal implementation
- [ ] Overall verification provides executable actions and observable results, and issues have diagnostic, recovery, or reporting methods
- [ ] The manual matches the actual product version and does not depend on internal design docs
- [ ] Users can obtain the information required for reporting issues, and no actual credential values are requested
