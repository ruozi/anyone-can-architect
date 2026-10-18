# Doc Design: deployment

## 1 Purpose

Define deployment, runtime verification, and failure handling procedures for a locked-in version in the target environment, including failure recovery and version rollback methods

## 2 Structure

Chapter 1 defines deployment prerequisites, including versions and artifacts, the target environment, deployment units, configuration and credential sources, and dependencies
Reference [infrastructure](infrastructure.md) for resource structure and permissions, and [security](security.md) for protection requirements

Chapter 2 presents the deployment procedure in the actual execution order for this project
Define the execution method, pass criteria, failure handling, and recovery point for each step
Include environment preparation, dependency provisioning, and checks in their actual execution order

Chapter 3 defines runtime verification and failure handling, including business availability checks, routine inspection, recovery, version rollback, and cleanup
Define overall verification criteria for relevant deployment and handling steps to reference
Define rollback boundaries for versions, configuration, and persistent data, and define alternative handling methods when rollback is not possible

Use [drill-down](../../skills/references/drill-down.md) in each chapter based on its actual content, without prescribing a runtime environment or subsection template

Structure outline:

```text
## 1 Deployment Prerequisites
## 2 Deployment Procedure
### 2.1 <execution stage>
### 2.2 <execution stage>
…
## 3 Runtime Verification and Failure Handling
### 3.1 <verification or handling content>
### 3.2 <verification or handling content>
…
```

## 3 Writing Steps

1. Determine deployment prerequisites
   - Define the source of the version locked in by release, how to obtain artifacts, and the mapping between source commits and artifact identities
   - Define the target environment, deployment units, permitted version combinations, and required permissions, configuration, credentials, and dependencies
   - Distinguish prerequisites for the first deployment from those for subsequent updates
2. Design the deployment procedure
   - Arrange artifact retrieval, environment preparation, dependency checks, data migration, startup, and switchover operations according to their dependencies
   - Define the execution method, pass criteria, failure handling, and recovery point for each step
   - Define how configuration and credentials are delivered, behavior when they are missing, and access permissions required at runtime
   - Define how concurrent deployments, reloads, and rollbacks are coordinated
   - When downtime or switchover is involved, define how to handle requests, tasks, and connections in progress
3. Define runtime verification
   - Define check actions, pass criteria, and failure symptoms for versions, processes, dependencies, and business capabilities
   - Define check timeouts, retries, and whether execution can continue after failure, as needed
   - Define overall verification criteria after deployment completion and failure recovery
4. Define failure handling and subsequent maintenance
   - For each failure scenario, define how to inspect status, logs, and dependencies, along with recovery operations and result verification
   - Define compatibility between versions, configuration, and persistent data, and determine rollback conditions, operation order, and failure handling
   - When rollback is not possible, define procedures for restoring data, fixing the current version, or other applicable handling
   - Define retention and cleanup scopes for artifacts, backups, logs, and business data, and reference relevant resource constraints
5. Organize the chapters according to [§2](#2-structure) and check the complete procedure
   - Artifacts can be traced to a locked-in version, and environment and dependency conditions meet execution requirements
   - The results of each step meet subsequent prerequisites, and failure recovery and rollback operations do not conflict
   - Reference [infrastructure](infrastructure.md) for resource structure and permissions, and [security](security.md) for protection requirements

## 4 Example

````markdown
# Report Service Deployment

## 1 Deployment Prerequisites

| Item | Definition |
| --- | --- |
| Target environment | Linux server, service running in a container, gateway forwarding business requests |
| Deployment unit | Report service, with one instance accepting external requests |
| Version source | v2.0.0 locked in by release |
| Artifact source | Internal image registry, with image identity and source commit recorded in release-manifest.json |
| Current version | v1.9.0, with its image, configuration, and deployment records retained |
| State directory | /srv/report-service, recording the current version, image digest, and last successful version |
| Dependencies | PostgreSQL and object storage, with resource design in [infrastructure](infrastructure.md) |
| Configuration and credentials | Configuration file and read-only credential file, with delivery permissions in [Deployment Identity §3](security.md#3-deployment-identity) |

The deployment account can pull images, manage this service's containers, run migrations, and switch the gateway
For deployment, reload, and rollback, the deployment script acquires an exclusive lock for this service and rejects execution on conflict
For the first deployment, create the state directory, dependency resources, and service identity before running the deployment procedure
This example updates an existing service, and the current version keeps running until the new version passes verification

`scripts/deploy-report.sh` provides identity validation, environment preparation, candidate startup, switchover, verification, rollback, and cleanup operations
Each operation returns a nonzero exit code on failure, records the operation stage, and does not advance automatically on failure

## 2 Deployment Procedure

### 2.1 Obtain and Validate Artifacts

**Execute**: Run `bash scripts/deploy-report.sh prepare v2.0.0` to obtain the Tag, release manifest, and corresponding image

**Pass**: The Tag is locked in, the source commit in the manifest matches the commit referenced by the Tag, and the pulled image digest matches the manifest record

**Failure and recovery**: Stop deployment and keep the current version running
Fix the artifact source or permissions, then retry this stage without rebuilding an image to replace one with the same identity

### 2.2 Check Runtime Conditions

**Execute**: Run `bash scripts/deploy-report.sh preflight v2.0.0`

**Pass**: Configuration and credentials are complete, the database identity is correct and has the required permissions, and object storage supports writing, reading, and deleting temporary objects
The state directory is writable, the candidate service port is available, and the deployment lock can be acquired

**Failure and recovery**: Stop deployment without modifying the current version
Correct the relevant conditions and retry, first cleaning up temporary objects created by the checks

### 2.3 Run Data Migration

**Execute**: Run `bash scripts/deploy-report.sh migrate v2.0.0`

**Pass**: The migration record marks this migration as successful, and the reports table has a new nullable source_digest field
This change does not delete or alter existing fields, and v1.9.0 can still read and write
See [Database Migration §2.3](infrastructure.md#23-database-migration) for migration order and transaction boundaries

**Failure and recovery**: Do not start the candidate version, and use migration records to determine which operations have completed
This migration runs in a single transaction, so after rollback on failure, fix the problem and run the incomplete migration
Do not repeat successful migrations

### 2.4 Start and Verify the Candidate Version

**Execute**: Run `bash scripts/deploy-report.sh start-candidate v2.0.0` to start the candidate container on a separate port, then perform the verification in §3.1

**Pass**: The candidate version passes all verification checks, and verification data has been cleaned up

**Failure and recovery**: Stop the candidate container, retain logs, and keep the old version accepting requests
Correct the configuration and retry this stage, or if the code needs a fix, use a new locked-in version and start from §2.1

### 2.5 Switch Over and Confirm Operation

**Execute**: Run `bash scripts/deploy-report.sh activate v2.0.0` to route new gateway requests to the candidate version, then perform the verification in §3.1 through the gateway
The old version stops accepting new requests and waits up to 60 seconds for existing requests to complete
This service does not run independent background tasks

**Pass**: The new version passes verification, old requests have completed, and the state record is updated to show v2.0.0 as current and v1.9.0 as the last successful version

**Failure and recovery**: If verification fails, execute §3.2, and if old requests have not completed, retain the old container and report the condition without performing cleanup
Before resuming execution, check the gateway's actual target and the state record without repeating the switchover

## 3 Runtime Verification and Failure Handling

### 3.1 Runtime Verification

Run `bash scripts/deploy-report.sh verify v2.0.0`
Each check has a 10-second timeout, and execution stops on failure without automatic retries

| Check | Pass criteria |
| --- | --- |
| Version identity | The source commit reported by the service matches v2.0.0 |
| Database | Verification records can be read and written using the application identity |
| Report functionality | A report can be generated and downloaded using a dedicated verification account, and its content matches the request |
| Data cleanup | All records and objects from this verification run have been deleted |

### 3.2 New Version Verification Failure

1. Run `bash scripts/deploy-report.sh rollback` and confirm that the image and configuration for the last successful version are still available
2. Route new gateway requests back to v1.9.0, retaining the new version's container and logs for investigation
3. Verify the old version against the criteria in §3.1, changing the version identity to v1.9.0
4. After verification passes, record v1.9.0 as the current version, then stop the new version's container

This rollback retains successful data migrations without reverting the database schema or deleting business records written by the new version
If verification of the old version fails, preserve the failure state and raise an alert, investigate database and object storage failures, and do not repeatedly switch versions
If business data is abnormal, follow [Data Recovery §2.4](infrastructure.md#24-data-recovery), and do not overwrite existing business data directly with an old backup

### 3.3 Inspection and Cleanup

`bash scripts/deploy-report.sh status` shows the gateway target, running version, deployment stage, and last successful version
`bash scripts/deploy-report.sh logs` reads this service's container logs without outputting credentials

After deployment verification passes and old requests have completed, clean up the old container and data from this verification run
Retain images, configuration, and deployment records for the current and last successful versions
The database, report objects, and other project resources are outside the deployment cleanup scope
````

## 5 Checklist

- [ ] The version comes from a Tag locked in by release, and the artifact identity can be traced to the corresponding source commit
- [ ] The target environment, deployment units, version combinations, configuration, credentials, and dependency conditions are defined
- [ ] Prerequisites for the first deployment and subsequent updates are distinguished
- [ ] The deployment procedure covers all necessary operations, and each step has an execution method, pass criteria, failure handling, and recovery point
- [ ] Delivery, access permissions, and behavior when configuration and credentials are missing are defined
- [ ] Coordination of concurrent deployments, reloads, and rollbacks, and handling of requests, tasks, and connections during switchover are defined
- [ ] Overall verification covers version identity, runtime status, dependencies, and business availability
- [ ] Rollback conditions, compatibility boundaries, and handling when rollback is not possible are defined for versions, configuration, and persistent data
- [ ] Troubleshooting, recovery, and rollback procedures include result verification, and resumed execution matches the actual runtime state
- [ ] Retention and cleanup scopes for artifacts, backups, logs, and business data are defined
- [ ] Resource design and protection requirements reference the corresponding docs, with no actual credential values