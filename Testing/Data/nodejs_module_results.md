# Test Report: nodejs_module

## Summary

- **Total Tests:** 26
- **Passed:** 24
- **Failed:** 2
- **Success Rate:** 92.31%

## fileExistence

Verify all required backup/restore scripts exist

| Test | Status | Message |
|------|--------|---------|
| Backup Node Script Exists | ✅ PASS | File(s) exist. |
| Restore Node Script Exists | ✅ PASS | File(s) exist. |
| Backup NPM Script Exists | ✅ PASS | File(s) exist. |
| Restore NPM Script Exists | ✅ PASS | File(s) exist. |
| Backup NPM Globals Script Exists | ✅ PASS | File(s) exist. |
| Restore NPM Globals JSON Script Exists | ✅ PASS | File(s) exist. |
| Restore NPM Globals Text Script Exists | ✅ PASS | File(s) exist. |

**Category Summary:** 7 passed, 0 failed

## fileContent

Verify script files are not empty and have content

| Test | Status | Message |
|------|--------|---------|
| Backup Scripts Are Not Empty | ✅ PASS | All files contain content. |
| Restore Scripts Are Not Empty | ✅ PASS | All files contain content. |

**Category Summary:** 2 passed, 0 failed

## commandPresence

Verify scripts contain necessary command checks

| Test | Status | Message |
|------|--------|---------|
| Node Version Check in Backup Scripts | ✅ PASS | All patterns were found. |
| NPM Command Check in Backup Scripts | ✅ PASS | All patterns were found. |
| Restore Scripts Validate Commands | ✅ PASS | All patterns were found. |

**Category Summary:** 3 passed, 0 failed

## dataValidation

Verify data file references and formats

| Test | Status | Message |
|------|--------|---------|
| Data Directory References | ✅ PASS | All texts were found. |
| Version File References in Backup | ✅ PASS | All patterns were found. |
| NPM Version References in Backup | ✅ PASS | All patterns were found. |
| JSON Output Format Check | ✅ PASS | All patterns were found. |

**Category Summary:** 4 passed, 0 failed

## errorHandling

Verify error handling and validation logic

| Test | Status | Message |
|------|--------|---------|
| Error Handling in Backup Scripts | ✅ PASS | All patterns were found. |
| Error Handling in Restore Scripts | ✅ PASS | All patterns were found. |

**Category Summary:** 2 passed, 0 failed

## pathHandling

Verify correct path handling without undefined variables

| Test | Status | Message |
|------|--------|---------|
| No Undefined $file Usage in Backup Scripts | ✅ PASS | No unexpected patterns found. |
| Join-Path Usage in Path Construction | ❌ FAIL | Pattern not found in E:\Working\Learning\dev\nodejs\Windows\backup-node.ps1 |

**Category Summary:** 1 passed, 1 failed

## bugCheck

Verify no known bugs in scripts

| Test | Status | Message |
|------|--------|---------|
| Restore Node Does Not Use NPM Message | ✅ PASS | No unexpected patterns found. |
| Restore Node Uses Correct Message | ✅ PASS | All patterns were found. |
| Restore NPM Does Not Enforce Strict Semver Regex | ✅ PASS | No unexpected patterns found. |

**Category Summary:** 3 passed, 0 failed

## fileStructure

Verify proper file structure and organization

| Test | Status | Message |
|------|--------|---------|
| Backup and Restore Scripts Paired | ✅ PASS | Backup and restore scripts paired correctly. |

**Category Summary:** 1 passed, 0 failed

## outputFormats

Verify output format compatibility

| Test | Status | Message |
|------|--------|---------|
| Global Npm Backup Has Both Text and JSON Outputs | ❌ FAIL | Pattern not found in E:\Working\Learning\dev\nodejs\Windows\backup-npm-globals.ps1 |
| Restore Scripts Handle Both Formats | ✅ PASS | All texts were found. |

**Category Summary:** 1 passed, 1 failed

---

Generated: 2026-04-20 01:49:57

