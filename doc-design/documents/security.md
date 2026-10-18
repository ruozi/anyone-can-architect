# Doc Design: security

## 1 Purpose

Analyze this unit's actual attack surfaces from an attacker's perspective, reason through safeguards and their prerequisites, and define residual risks and acceptance decisions

External contracts belong in [interface](interface.md), and internal mechanisms belong in [class-design](class-design.md)
Resources and permissions belong in [infrastructure](infrastructure.md), and configuration delivery and emergency operations belong in [deployment](deployment.md)
This doc references specific designs to analyze attack paths and protection boundaries

## 2 Structure

Use an overview table in the first chapter to list attack surfaces, attackers who can reach them, risk conclusions, and links to detailed chapters
After the table, list inapplicable attack paths and their reasons as needed

Each subsequent chapter analyzes one actual attack surface, using [drill-down](../../skills/references/drill-down.md) for specific attack methods
Threat headings describe attack actions, such as "Confirm on someone else's behalf" or "Read images from another repository"

- Attacker defines the identity, existing permissions, and inputs or environments under the attacker's control
- Method describes how the attacker uses these capabilities to carry out the attack
- Objective defines the assets the attacker wants to read or tamper with, or the behavior they want to trigger
- Defense references specific designs that block the attack path and explains the role and prerequisites of each defense
- Assessment explains protection coverage and residual risks, defining the worst-case impact and acceptance decision when residual risks exist

The overview references each threat's assessment without separately maintaining worst-case impacts and acceptance decisions

Structure outline:

```text
## 1 Attack Surface Overview
## 2 <attack surface>
### 2.1 <attack action>
### 2.2 <attack action>
## 3 <attack surface>
…
```

## 3 Writing Steps

1. Inventory entry points, target assets, and trust boundaries, and identify attackers who can reach them
   - Include legitimate users, external content authors, and attackers who gain permissions after another attack surface is compromised
   - Exclude inapplicable attack paths and record the reasons
2. Group threats by actual attack surface, and derive attack paths and objectives from attackers' existing capabilities
   - Cover unauthorized access, malicious input, and subsequent attacks after credential compromise
   - When credential exposure is involved, analyze the attacker's capabilities and scope of impact after obtaining the credentials, based on actual permissions
3. Analyze defenses against each attack path, referencing the corresponding contract, mechanism, resource, or deployment design
   - Explain the permissions, configuration, and external safeguards that each defense depends on
   - Define request rejection or deployment blocking behavior when authentication, authorization, or validation lacks required configuration
   - When protection depends on a conclusion for another attack surface, reference that conclusion and its prerequisites
   - When credential exposure is involved, reference delivery, rotation, revocation, and follow-up verification measures
4. Assess protection coverage and residual risks
   - When measures that depend on external parties are not yet in place, assess based on the current boundaries and do not count them as established defenses
5. Organize chapters according to [§2](#2-structure) and summarize attack surfaces and risk conclusions
   - Check that the overview matches the detailed analysis and that references point to the corresponding designs and assessments

## 4 Example

```markdown
# Security

## 1 Attack Surface Overview

| Attack surface | Attackers who can reach it | Risk conclusion | Detailed analysis |
| --- | --- | --- | --- |
| Report download | Anyone on the public internet, logged-in users, and download link holders | Issuance is restricted by report ownership, with residual risk from link forwarding | [§2](#2-report-download) |
| File gateway credentials | Anyone who obtains the report service's API credentials | Can issue report file links, with residual risk | [§3](#3-file-gateway-credentials) |

## 2 Report Download

### 2.1 Download Someone Else's Report

**Attacker**: A logged-in user who can submit any report identifier but does not hold service credentials

**Method**: Request a download link using someone else's report identifier

**Objective**: Read a report that does not belong to the attacker

**Defense**

- The server obtains the user identity from the authenticated session and does not accept a user identity claimed in the request
- Before issuance, check report ownership and reject the request if the report does not belong to the current user, see [Report download contract §3](module-report/interface.md#3-download-report)
- The download entry point accepts only report identifiers, so users cannot specify storage addresses
- Read the object key from the report record that passed the ownership check, see [Report download implementation §4](module-report/class-design.md#4-download-report)

**Assessment**: These checks block the path of downloading someone else's report by changing the report identifier
This assumes that the authenticated session has not been hijacked and service credentials have not been exposed, see [§3](#3-file-gateway-credentials) for credential compromise

### 2.2 Download a Report Using a Forwarded Link

**Attacker**: Anyone who obtains a valid download link, with no login required

**Method**: Open the download link forwarded by the original user

**Objective**: Read the report that the link points to

**Defense**

- The link allows reading only one specified object and is valid for 15 minutes, see [File gateway constraints §4.2](infrastructure.md#42-usage-constraints)
- Downloads validate only the link, without checking the visitor's identity

**Assessment**: Residual risk exists
The worst-case impact is that the recipient of a forwarded link reads the report while the link is valid
Accept this risk because the download feature allows users to share individual reports, and the link does not provide ongoing access

## 3 File Gateway Credentials

### 3.1 Issue Report Links Using Exposed Service Credentials

**Attacker**: Anyone who obtains the report service's file gateway API credentials and can send requests directly to the gateway

**Method**: Bypass the report service's user ownership check and request link issuance directly from the gateway

**Objective**: Read files in the report bucket

**Defense**

- The API credentials can issue links only for the `reports/` prefix in the report bucket and cannot write or delete objects or access other buckets, see [Gateway permissions §4.1](infrastructure.md#41-integration)
- These service credentials do not represent an end user, and the gateway does not use them to check report ownership
- For credential delivery, see [Gateway credentials §2.3](deployment.md#23-file-gateway)
- After exposure, revoke the API credentials and the links issued with them, check issuance records, and then deliver new credentials, see [Credential exposure response §5.2](deployment.md#52-credential-leak)

**Assessment**: Residual risk exists
The worst-case impact is that, before the response is complete, the attacker issues links and reads report files whose object keys are known
Accept this risk because the impact is limited to reading report files and does not grant access to other buckets or the ability to write or delete objects
Limiting damage after exposure depends on revoking the API credentials and issued links, and files already downloaded cannot be recovered
```

## 5 Checklist

- [ ] The first chapter covers actual attack surfaces, attackers who can reach them, risk conclusions, and links to detailed chapters
- [ ] Inapplicable attack paths have supporting reasons, and actual attack surfaces are not excluded because defenses already exist
- [ ] Each threat defines the attacker, method, objective, defense, and assessment
- [ ] The attacker's capabilities support the described attack path, and defenses correspond to each part of the path
- [ ] Protection prerequisites and dependent measures are defined, and pending measures are not assessed as established
- [ ] Worst-case impacts and acceptance decisions for residual risks are defined, and the overview matches detailed assessments
- [ ] When credential exposure is involved, capabilities after obtaining credentials, scope of impact, and response measures are defined
- [ ] Requests are rejected or deployment is blocked when authentication, authorization, or validation lacks required configuration
- [ ] Specific mechanisms, resource permissions, and deployment operations reference the corresponding designs, with no secret values or implementation code