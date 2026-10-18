# Doc Design: changelog

## 1 Purpose

Record changes that matter to users by version

## 2 Structure

Follow the structure of [Keep a Changelog](../../SSOT.md#8-versions)
Place the unreleased block at the top
List released versions in reverse chronological order by release date

```text
# Changelog
## [Unreleased]
### <change category>
## [<version number>] — <YYYY-MM-DD>
### <change category>
```

Use Added, Changed, Deprecated, Removed, Fixed, and Security as change categories
Include only categories that have change entries
Describe a change that users can observe in each entry
If compatibility is affected, describe the scope of the impact
If migration is required, describe the migration steps
Keep version numbers and release dates consistent with actual release records

## 3 Writing Steps

1. Select changes that matter to users from the changes actually completed
2. Consolidate multiple commits for the same change into one entry
   Add it to the unreleased block under its change category
3. Check how the current changes affect contracts, configuration, and usage
   Add compatibility impacts and migration instructions according to the rules in [Structure](#2-structure)
4. At release time, move the entries actually delivered in this release into the corresponding version block
   Keep the unreleased block at the top
5. Check that the changelog for each released version matches what was actually delivered
   If a released record is incorrect, correct it to reflect what that version actually delivered

## 4 Example

See the [CHANGELOG template](../../templates/CHANGELOG.md.example) for a structural example

## 5 Checklist

- [ ] Entries describe changes that are actually completed and matter to users
- [ ] The unreleased block and released version blocks follow the organization and sorting rules in [Structure](#2-structure)
- [ ] Change categories follow the rules in [Structure](#2-structure)
- [ ] Version numbers and release dates match actual release records
- [ ] Compatibility impacts and migration instructions follow the rules in [Structure](#2-structure)
- [ ] Released records match what each version actually delivered
