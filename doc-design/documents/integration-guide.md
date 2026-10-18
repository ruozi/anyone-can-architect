# Doc Design: integration-guide

## 1 Purpose

Guide integrators through integrating and using the capabilities this product provides, and verifying the results
Integrators can complete the scenarios supported by the guide without reading internal design docs

Base interface contracts on [interface](interface.md)
Base artifact acquisition and installation on [distribution](distribution.md)

## 2 Structure

Start by stating the intended audience, platforms, and version scope

The first chapter describes the environment required for integration, and the installation, authentication, and configuration steps

From the second chapter onward, organize usage content by integration type
- For SDKs, follow the integration workflow, then describe usage scenarios after integration
- For APIs, organize chapters by user business scenario, combining the interfaces required to complete each scenario

Develop usage content using [drill-down](../../skills/references/drill-down.md)
For each scenario, describe the applicable conditions, operating steps, completion results, and failure handling
State the required and optional integration conditions for each scenario

After the usage content, add a “Debugging and Verification” chapter to explain how to check the overall integration and locate problems
Add an “FAQ” chapter as needed to explain the applicable conditions, solutions, and feedback channels for common problems

Structure outline:

```text
## 1 Environment and Configuration
## 2 <integration workflow or usage scenario>
### 2.1 <specific content>
### 2.2 <specific content>
## 3 <usage scenario>
…
## N Debugging and Verification
## N+1 FAQ              As needed
```

## 3 Writing Steps

1. Identify the integrators, scope, and usage scenarios supported by the guide
   - Select the interfaces and calling constraints required for each usage scenario based on the interface contracts, without requiring coverage of all interfaces
   - Determine how to organize usage content according to [§2](#2-structure)
2. Write the environment and configuration instructions
   - Describe the integration environment, dependencies, and compatibility requirements
   - Describe artifact acquisition, installation, authentication, and configuration in operating order, and provide a way to confirm completion
   - Explain how to obtain credentials and user-specific values and where to configure them, and read them from configuration in examples
3. Develop the integration workflow and usage scenarios
   - Describe when to make calls, the operating order, input sources, results, and failure handling
   - When callbacks, retries, or repeated operations are involved, explain the handling that integrators must provide
   - Provide executable minimal examples as needed for the operations, and indicate where partial examples belong in the complete workflow
4. Add debugging and verification instructions, and any required FAQ
   - Define the check steps and pass criteria for the overall integration
   - Provide ways to locate problems and recover based on errors, statuses, and logs available to users, and reference the corresponding content from usage scenarios
   - State the contact channels and information required for feedback, without requiring actual credential values
5. Check against the actual deliverables
   - Check installation methods, version requirements, and interfaces, and verify that examples are executable
   - Ensure that information required for use is available in the guide or public materials for integrators, without relying on internal design docs

## 4 Example

### 4.1 SDK Integration

````markdown
# Report SDK Integration Guide

For business projects that use Python 3.11 on Linux, supporting the generation and download of department reports
Use aca_report_sdk-2.0.0-py3-none-any.whl delivered by the distributor

## 1 Environment and Configuration

1. Install Python 3.11 and run `python3.11 --version` to confirm the version
2. Run `python3.11 -m venv .venv` in the business project, then run `source .venv/bin/activate`
3. Place the delivered wheel in the project directory and run `python -m pip install ./aca_report_sdk-2.0.0-py3-none-any.whl`
4. Run `python -c "from aca_report_sdk import ReportClient"`; no errors indicate that installation is complete
5. Request a test endpoint and test token from the report service administrator, and set `REPORT_ENDPOINT` and `REPORT_TOKEN` in the runtime environment
   - The endpoint connects to the test report service, and the token must have permission to generate and download sales department reports
   - Stop if you have not obtained the configuration, and do not use a production token to try the example

Configure these values in the same Bash session used to run the example, replacing placeholder values with the test configuration you obtained

```bash
export REPORT_ENDPOINT='<test endpoint>'
export REPORT_TOKEN='<test token>'
```

## 2 Integrate and Use Report Capabilities

### 2.1 Generate and Download a Report

Create `report_example.py` in the business project and add the following complete example
In this example, the service generates reports synchronously, so a report is available for download as soon as creation succeeds

```python
import os
from pathlib import Path
from aca_report_sdk import ReportClient

client = ReportClient(
    endpoint=os.environ["REPORT_ENDPOINT"],
    token=os.environ["REPORT_TOKEN"],
)
report = client.create_report(
    start_date="2026-09-01",
    end_date="2026-09-30",
    department="sales",
)
print(f"Created report {report.report_id}", flush=True)
content = client.download_report(report.report_id)
Path("sales-report.csv").write_bytes(content)
print(f"Downloaded report {report.report_id}, {len(content)} bytes")
```

Run `python report_example.py`
On success, sales-report.csv appears in the project directory, and the console displays the report identifier and file size in bytes

If creation fails, do not proceed to download; check the environment and permissions according to [§3](#3-debugging-and-verification)
If creation succeeds but download fails, retain the returned report_id and retry only the download, without creating the report again

### 2.2 Call from Business Logic

Call create_report after the business logic confirms the department and date range, and save the returned report_id
When a user downloads a generated report, call download_report with the saved report_id
The token's permissions must cover the selected department

## 3 Debugging and Verification

| Check action | Expected result | Problem handling |
| --- | --- | --- |
| Import ReportClient | No import errors | Confirm that .venv is in use and check whether the wheel was installed successfully |
| Run the example | Returns a report identifier and generates a CSV | Check the endpoint, token, and department permissions |
| Open the CSV | Data belongs to sales, and all dates are within the selected range | Retain report_id and contact the report service administrator to investigate |

## 4 FAQ

**What should I do if REPORT_TOKEN is missing?**

Obtain a test token from the administrator, set it in the runtime environment, and run again
Do not write the token directly into the example source code

**If creation succeeds but download fails, do I need to create the report again?**

No, save report_id, confirm network access and download permissions, and download again

If the problem persists, provide the administrator with the SDK version, report_id, error message, and time of occurrence
Do not provide the token value
````

### 4.2 API Usage Scenarios

````markdown
# Report API Usage Guide

For business projects that use the report service over HTTP, supporting two scenarios: generating reports and downloading existing reports
If you only need to download an existing report, obtain its identifier and access permissions, then go directly to [§3](#3-download-an-existing-report)

## 1 Environment and Configuration

Prepare Bash, curl, and Python 3
Obtain a test endpoint and token from the report service administrator, and configure them as REPORT_ENDPOINT and REPORT_TOKEN, respectively
Set the endpoint to the service root URL without a trailing slash
To download an existing report, obtain report_id from the report holder and configure it as REPORT_ID

Configure these values in the same Bash session used to run the subsequent commands, replacing placeholder values with the test configuration you obtained

```bash
export REPORT_ENDPOINT='<test endpoint>'
export REPORT_TOKEN='<test token>'
```

To download an existing report directly, also configure its identifier

```bash
export REPORT_ID='<existing report identifier>'
```

## 2 Generate a Report

The test token must have permission to generate reports for the sales department
Run the following commands in the same Bash session

```bash
REQUEST_ID=$(python3 -c 'import uuid; print(uuid.uuid4())')
RESPONSE_FILE=$(mktemp)
curl --fail-with-body "$REPORT_ENDPOINT/reports" \
  -H "Authorization: Bearer $REPORT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $REQUEST_ID" \
  --data '{"department":"sales","start_date":"2026-09-01","end_date":"2026-09-30"}' \
  --output "$RESPONSE_FILE"
```

A successful response is 201, and the JSON contains report_id and status, with status set to ready
Only after curl exits successfully, run the following commands to read the identifier and delete the temporary response file

```bash
REPORT_ID=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["report_id"])' "$RESPONSE_FILE")
rm "$RESPONSE_FILE"
```

If the network connection is interrupted and the result is unknown, retain REQUEST_ID and retry with the same request parameters and idempotency key, without generating a new idempotency key
If the response explicitly indicates failure, troubleshoot according to [§4](#4-debugging-and-verification) and do not proceed to download

## 3 Download an Existing Report

REPORT_ID must identify a generated report, and the token must have download permission for the department to which it belongs

```bash
curl --fail-with-body "$REPORT_ENDPOINT/reports/$REPORT_ID/file" \
  -H "Authorization: Bearer $REPORT_TOKEN" \
  --output sales-report.csv
```

A successful response is 200, and the file is a CSV
A failure response may be written to a file with the same name, so use it as a report only if curl exits successfully
If download fails, retain REPORT_ID, resolve network or permission issues, and retry

## 4 Debugging and Verification

| Check action | Expected result | Problem handling |
| --- | --- | --- |
| Generate a report | 201, status is ready, and report_id is returned | For 401, check the token; for 403, check department permissions |
| Download a report | 200, and the CSV data belongs to the selected department and date range | Check REPORT_ID, download permissions, and the error response |

## 5 FAQ

**If a report already exists, do I still need to call the generation interface first?**

No, obtain the report identifier and download permissions, then download according to [§3](#3-download-an-existing-report)

**How do I report a failed request?**

Provide the report service administrator with the request path, response status code, error message, time of occurrence, and request identifier
Do not provide the Authorization header or token value
````

## 5 Checklist

- [ ] The intended audience, platforms, version scope, and supported scenarios are stated
- [ ] The structure matches the integration type, and usage content is organized by workflow or business scenario
- [ ] The environment, dependencies, installation, authentication, and configuration are explained in the actual order, with ways to obtain the required information
- [ ] All capabilities required for each scenario are covered, and applicable conditions, operating steps, completion results, and failure handling are defined
- [ ] Calling methods match the interface contracts, and responsibilities for callbacks, retries, and repeated operations are stated
- [ ] Minimal examples can be executed by following the stated steps, and partial examples indicate where they belong in the complete workflow
- [ ] Overall verification has executable actions and observable results, and problems have methods for diagnosis or feedback
- [ ] The guide matches the actual artifacts, interfaces, and bundled materials, without relying on internal design docs
- [ ] No actual credential values are present, and user-specific configuration has stated sources and usage locations