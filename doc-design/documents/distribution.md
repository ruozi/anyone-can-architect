# Doc Design: distribution

## 1 Purpose

Define artifact build, delivery, verification, and failure handling procedures for locked-in versions delivered to integrators or users, including updates, withdrawal, and version rollback

## 2 Structure

Chapter 1 defines distribution prerequisites, including versions and artifacts, recipients, target platforms, channels, and signing requirements

Chapter 2 presents the distribution workflow in the project's actual sequence
Each step defines the execution method, pass criteria, failure handling, and where to resume
Organize stages such as building, signing, uploading, review, and delivery as needed

Chapter 3 defines delivery verification and failure handling, including artifact retrieval, installation or integration verification, withdrawal, updates, and handling of delivered versions
Define overall verification criteria for the relevant distribution and handling steps to reference
Define rollback boundaries for channels and installed or integrated versions, and define alternative handling when rollback is not possible

Use [drill-down](../../skills/references/drill-down.md) in each chapter based on its actual content, without fixed platform, channel, or subsection templates

Structure outline:

```text
## 1 Distribution Prerequisites
## 2 Distribution Workflow
### 2.1 <execution stage>
### 2.2 <execution stage>
…
## 3 Delivery Verification and Failure Handling
### 3.1 <verification or handling details>
### 3.2 <verification or handling details>
…
```

## 3 Writing Steps

1. Determine distribution prerequisites
   - Define the source of the version locked in by release, recipients, target platforms, channels, and required permissions
   - Define the mapping between artifact names, versions, source commits, and digests, along with build and signing requirements
   - Define the delivery scope, including installation packages, SDKs, integration docs, or user manuals
2. Design the distribution workflow
   - Arrange operations such as building, signing, uploading, review, delivery, and activation according to their dependencies
   - Define the execution method, pass criteria, failure handling, and where to resume for each step
   - Define credential sources and usage, and how to handle missing or invalid credentials
   - When channel review, caching, or staged delivery is involved, define waiting, status queries, and activation conditions
3. Define delivery verification
   - Define checks and pass criteria for artifact identity, channel visibility, retrieval, installation, and integration
   - Check that bundled docs match the actual artifacts and that examples work on the target platforms
   - Define overall verification criteria for initial delivery and updates
4. Define failure handling and subsequent maintenance
   - Distinguish between states where delivery has not occurred, the release is available through the channel, and users have installed or integrated it, and define handling procedures for each
   - Define conditions, operations, and result verification for withdrawal, stopping updates, restoring old artifacts, or delivering a corrected version
   - Define version compatibility and update paths, and define alternative handling when rollback is not possible
   - Define the scope of retention and cleanup for old artifacts and verification records
5. Organize chapters according to [§2](#2-structure) and check the complete workflow
   - Artifact identities for all platforms and channels are registered and traceable to the corresponding locked-in versions
   - Each step's results meet the prerequisites for subsequent steps, and resuming execution does not publish duplicates or overwrite the wrong artifacts
   - Reference [deployment](deployment.md) for server operations and failure handling, and [release](release.md) for merging and version locking

## 4 Example

````markdown
# Report SDK Distribution

## 1 Distribution Prerequisites

| Item | Definition |
| --- | --- |
| Version source | v2.0.0 locked in by release |
| Recipients | Business projects that use Python |
| Artifact | aca_report_sdk-2.0.0-py3-none-any.whl |
| Target environments | Python 3.11 and 3.12 |
| Channel | Company private Python package index |
| Source and artifact identity | release-manifest.json records the Tag, source commit, file name, and SHA-256 |
| Release permissions | A dedicated account can upload only the aca-report-sdk package, with credentials supplied by the pipeline secret store |
| Bundled docs | Integration guide and version change notes |
| Compatibility requirements | v2.0.0 and v1.9.0 use the same report service API |

This SDK has no separate local database, so version rollback does not involve persistent data migration
Business projects select a version through a dependency lock file, and channel uploads do not automatically update integrated projects
Build results, manifests, and verification records are saved in the release pipeline's artifact storage

## 2 Distribution Workflow

### 2.1 Build and Register Artifacts

**Execution**: Check out v2.0.0 and run `bash scripts/build-sdk.sh v2.0.0`
The script builds the wheel and writes the artifact version, source commit, and digest to the release manifest

**Pass criteria**: The source commit matches the Tag target, the package version is 2.0.0, and the artifact digest matches the manifest

**Failure and recovery**: Do not upload, correct the build environment, and retry
If the source needs a fix, return to the version locking workflow and use a new version without modifying v2.0.0

### 2.2 Verify Artifacts and Docs

**Execution**: Run `bash scripts/verify-sdk.sh --local v2.0.0`, install this wheel in separate environments for the two target Python versions, and verify according to §3.1

**Pass criteria**: Both environments pass verification, the bundled guide matches 2.0.0, and examples use only public interfaces

**Failure and recovery**: Do not upload, and retain failure records
If the artifact or bundled docs need corrections, use a new locked-in version and restart from §2.1

### 2.3 Upload and Verify the Channel

**Execution**: Run `bash scripts/publish-sdk.sh v2.0.0`, upload the artifact and release manifest, and query the channel status

**Pass criteria**: A recipient identity can retrieve the artifact, the download digest matches the release manifest, and verification according to §3.1 passes

**Failure and recovery**: If the upload result is unknown, query the channel first
If a file with the same name and version exists and its digest matches, do not upload it again, and continue verification
If a file with the same name and version has a different digest, stop and report the issue without overwriting the channel artifact
If the artifact is available through the channel but verification fails, follow §3.2

## 3 Delivery Verification and Failure Handling

### 3.1 Delivery Verification

Verification tasks use a dedicated test account and test report service without operating on production business data

| Check | Pass criteria |
| --- | --- |
| Artifact identity | The downloaded file name, package version, and SHA-256 match the release manifest |
| Installation | The SDK can be installed and imported in separate environments for both target Python versions |
| Integration | Initialize according to the bundled guide, then generate and download a test report through public interfaces |
| Update | After updating from v1.9.0 to v2.0.0, existing calls can still complete the same business operation |
| Verification cleanup | All reports and objects from this test have been deleted |

### 3.2 Distribution Failures

- Not yet uploaded: Stop delivery, retain verification records, and lock in and distribute a corrected version
- Available through the channel: Mark 2.0.0 as withdrawn, stop recommending installation, and retain the original file and release manifest
- Installed or integrated: Notify integrators to stop updating and restore the dependency lock file to 1.9.0, then reinstall in a separate environment and verify business operations
- Rollback unavailable: Use a new fixed version, complete delivery through this workflow, and have integrators update and verify it

Withdrawing a channel version does not delete code that integrators have already installed
Record a project's recovery as complete only after its integrator confirms the actual version and verification results

### 3.3 Subsequent Updates and Retention

Updates use a new locked-in version and repeat the build, verification, and upload workflow in §2
Integrators verify compatibility before modifying the dependency lock file, and follow the [integration guide](../user-guide/integration-guide.md) for upgrade instructions

Retain delivered artifacts, manifests, and verification records indefinitely, and do not overwrite published files of the same version
Retain failed builds that were not uploaded for 30 days before cleanup
See [deployment](deployment.md) for report service deployment and failure handling
````

## 5 Checklist

- [ ] The version comes from a Tag locked in by release, and the artifact name, version, digest, and source commit are traceable
- [ ] Recipients, target platforms, channels, build and signing requirements, and required permissions are defined
- [ ] The distribution workflow covers all necessary operations, and each step has an execution method, pass criteria, failure handling, and a point to resume from
- [ ] Credential sources, usage, and behavior when credentials are missing or invalid are defined, with no actual credential values
- [ ] When review, caching, or staged delivery is involved, waiting, query, and activation conditions are defined
- [ ] Overall verification covers artifact identity, retrieval through the channel, installation or integration, and version updates
- [ ] Bundled docs match the actual artifacts, and examples work on the target platforms
- [ ] Failure handling is defined separately for states where delivery has not occurred, the release is available through the channel, and users have installed or integrated it
- [ ] Applicable boundaries for withdrawal, rollback, and updates are defined, with alternative handling and result verification when rollback is not possible
- [ ] Resuming execution does not publish duplicates or overwrite the wrong artifacts, and the scope of retention and cleanup for old artifacts and verification records is defined