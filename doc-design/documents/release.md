# Doc Design: release

## 1 Purpose

Define the complete process for this repository from pre-release verification to merging into main and locking the Tag, including the execution method, pass criteria, failure handling, and recovery point for each step

## 2 Structure

Chapter 1 defines release prerequisites, including the version source, version records that must be consistent, the merge chain, and execution requirements
Chapter 2 presents the release process in the actual order used by this repository, through merging into main and locking the Tag
Each step defines the execution method, pass criteria, failure handling, and recovery point
Use [drill-down](../../skills/references/drill-down.md) for complex stages based on their actual content

Arrange verification steps as needed by the repository, including tests, builds, verification on real platforms, and other necessary operations
Include the release summary in the step that locks the Tag, and expand its format under that step when a detailed definition is needed
Add a separate chapter for release announcements as needed, defining triggers, content sources, channels, and retries after failure

Structure outline:

```text
## 1 Release Prerequisites
## 2 Release Process
### 2.1 <execution stage>
### 2.2 <execution stage>
…
## 3 Release Announcements              As needed
```

## 3 Writing Steps

1. Determine release prerequisites
   - Define the version number source, version records that must be consistent, the merge chain, and the target Tag
   - Determine the environment, permissions, tools, and external dependencies required for execution
2. Design the release process for this repository
   - Arrange operations such as closing out version records, verification, and merging according to dependencies
   - Define commands or operating procedures, pass criteria, failure handling, and a recovery point for each step
   - When verification involves real platforms, define the required environment, data, and result evaluation criteria
3. Define the steps to lock in the version
   - Check that the final commit includes the content for this version, version records are consistent, and verification results apply to this commit
   - Confirm that the version is merged into main through the merge chain, and define the source, format, and validation method for the release summary
   - Create and push an annotated Tag on the final main commit, and check the commit referenced by the remote Tag
   - Do not move or recreate the Tag after creation, and only retry the push if it fails
   - Stop if a Tag with the same name already exists and points to another commit, and check the existing Tag's target and annotation when resuming execution
4. Define release announcements as needed
   - Define triggers, content sources, channels, and recipients
   - Extract content from the Tag annotation, and reference the tools and validation rules used
   - When using Lark (Feishu) cards, draw them according to the [card mockup](../patterns/lark-card-mockup.md)
   - Define credential sources, behavior when credentials are missing, and retries after failure, and reference the security or deployment design for handling credential leaks
   - Announcement failure does not change the fact that the version is locked in, and retries use the locked Tag
5. Organize chapters according to [§2](#2-structure) and check the complete process
   - The result of each step satisfies the prerequisites of the next, and resuming execution does not repeat non-reentrant operations
   - The version number, Tag, final main commit, and verification results are traceable to one another

## 4 Example

````markdown
# Report Service Release

## 1 Release Prerequisites

| Item | Definition |
| --- | --- |
| Version source | VERSION, 2.0.0 for this release |
| Version records | The finalized section for this version in CHANGELOG |
| Consistency requirements | VERSION, the project version in pyproject.toml, and the target Tag version must match |
| Merge chain | feature/report-export-v2.0.0 → main, merged through a Pull Request |
| Tag | v2.0.0, annotated Tag |
| Execution environment | Bash, Git, the project Python environment, and container build tools |
| Repository permissions | Commit version records, merge Pull Requests, and push Tags |
| Verification environment | A separate test database and object storage, with credential sources in [Test Environment §1](deployment.md#1-test-environment) |

`scripts/release-verify.sh` runs unit tests, database migration tests, an image build, and upload and download verification with real object storage in sequence
The script records the source commit, individual results, and image digest, and returns a nonzero exit code if any check fails
Keep verification records and images outside the repository, and clean up test data from this run after verification

## 2 Release Process

### 2.1 Close Out Version Records

**Execution**: Update VERSION and the project version in pyproject.toml to 2.0.0, close out the finalized section for this version in CHANGELOG, and commit

**Pass**: Running `bash scripts/check-version.sh 2.0.0` returns 0, and the working tree is clean

**Failure and recovery**: Stop at this stage, correct and commit the version records, then validate again

### 2.2 Verify the Version to Merge

**Execution**: Run `bash scripts/release-verify.sh`

**Pass**: The script returns 0, all checks pass, and the source commit in the verification records matches the current HEAD

**Failure and recovery**: Do not merge, and rerun this stage after committing fixes
If test data cleanup fails, clean up data from this run before verifying again

### 2.3 Merge into main

**Execution**: Create a Pull Request, complete reviews and required checks according to repository branch protection rules, then merge into main

**Pass**: The Pull Request is merged, and remote main contains all commits for this version

**Failure and recovery**: Stop at this stage if the merge is incomplete
After resolving conflicts or modifying code, return to §2.2 for verification, then update the Pull Request
Check the merge status before resuming execution, and do not merge a Pull Request that is already merged

### 2.4 Check the Final Commit

**Execution**: Run `git fetch origin`, switch to main, and synchronize with `git pull --ff-only origin main`
Rerun version validation and `bash scripts/release-verify.sh`

**Pass**: Local main matches remote main, the working tree is clean, version records are correct, and all verification passes
The source commit in the verification records matches the main commit to be locked in

**Failure and recovery**: Do not create a Tag
If code or version records need correction, verify the fixes on a new fix branch and merge into main, then rerun this stage
If main has new commits, verify the new final commit again

### 2.5 Lock In the Version

**Execution**: Generate a summary file outside the repository from the finalized section for this version in CHANGELOG, and validate its format with the [summary validation tool](../../bin/aca-tag-notify-check)
Record the verification results from §2.4 in the last summary entry

Summary example:

```text
v2.0.0: Report export

---NOTIFY-BEGIN---
📄 Reports · Support exporting and downloading business reports
✅ Verification · Unit tests, migration tests, image build, and object storage verification passed
---NOTIFY-END---
```

Synchronize with the remote again before creating the Tag, and confirm that main still points to the commit verified in §2.4 and the target Tag does not yet exist
Create the Tag with `git tag -a v2.0.0 -F /tmp/report-service-v2.0.0.md`, then run `git push origin v2.0.0`

**Pass**: The remote Tag exists, points to the verified main commit, and contains the summary for this version in its annotation

**Failure and recovery**: Return to §2.4 if main has changed
If validation fails before creation, correct the summary or prerequisites and retry
If the Tag has been created, check its target and annotation, and only complete the push if they match, without moving or recreating it
Stop and report the conflict if the target or annotation of a Tag with the same name does not match

## 3 Release Announcements

Pushing a remote v* Tag triggers the announcement pipeline, which extracts announcement content from the Tag annotation and sends it to the development release group
Use the [announcement extraction tool](../../bin/aca-tag-notify-extract) to extract content
See [Release Bot §3](security.md#3-release-bot) for bot credential sources and handling credential leaks

If credentials are missing or sending fails, the pipeline fails, and the version remains locked in
After fixing the issue, rerun the announcement job with the same Tag, without repeating the merge, verification, or Tag creation
````

## 5 Checklist

- [ ] Release prerequisites define the version source, version records, merge chain, target Tag, and execution requirements
- [ ] The process covers all necessary operations for this repository from pre-release verification to merging into main and locking the Tag
- [ ] Each step has an execution method, pass criteria, failure handling, and a recovery point
- [ ] The verification environment and result evaluation criteria are defined, and verification results correspond to the final locked commit
- [ ] Prerequisites and results connect across steps, and resuming execution does not repeat non-reentrant operations
- [ ] Version records are consistent, and the summary source, format, and validation method are defined
- [ ] The remote annotated Tag points to the verified final main commit, and the version, commit, and verification results are traceable
- [ ] Tags are not moved or recreated, failed pushes are only retried, and execution stops if the target or annotation of a Tag with the same name conflicts
- [ ] If announcements are configured, triggers, content extraction, channels, credential sources, failure behavior, and retry methods are defined
- [ ] Announcement failure does not change the fact that the version is locked in, and retries use the same Tag