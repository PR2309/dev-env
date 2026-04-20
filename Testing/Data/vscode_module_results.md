# Test Report: vscode_module

## Summary

- **Total Tests:** 14
- **Passed:** 12
- **Failed:** 2
- **Success Rate:** 85.71%

## fileExistence

Verify all required backup/restore scripts exist

| Test | Status | Message |
|------|--------|---------|
| Backup VSCode Script Exists (PowerShell) | ✅ PASS | File(s) exist. |
| Restore VSCode Script Exists (PowerShell) | ✅ PASS | File(s) exist. |
| Backup VSCode Script Exists (Bash) | ❌ FAIL | Expected file not found: E:\Working\Learning\dev\vscode\Windows\backup-vscode.sh |
| Restore VSCode Script Exists (Bash) | ❌ FAIL | Expected file not found: E:\Working\Learning\dev\vscode\Windows\restore-vscode.sh |

**Category Summary:** 2 passed, 2 failed

## fileContent

Verify script files are not empty and have content

| Test | Status | Message |
|------|--------|---------|
| VSCode Scripts Are Not Empty | ✅ PASS | All files contain content. |

**Category Summary:** 1 passed, 0 failed

## dataReferences

Verify data directory references for extensions and settings

| Test | Status | Message |
|------|--------|---------|
| Data Directory References in Backup | ✅ PASS | All texts were found. |
| Extensions File References | ✅ PASS | All patterns were found. |
| Settings File References | ✅ PASS | All patterns were found. |
| Keybindings File References | ✅ PASS | All patterns were found. |

**Category Summary:** 4 passed, 0 failed

## commandPresence

Verify proper command structure and execution

| Test | Status | Message |
|------|--------|---------|
| Code Command Check in Scripts | ✅ PASS | All patterns were found. |

**Category Summary:** 1 passed, 0 failed

## errorHandling

Verify error handling and validation logic

| Test | Status | Message |
|------|--------|---------|
| Error Handling in Backup Script | ✅ PASS | All patterns were found. |
| Error Handling in Restore Script | ✅ PASS | All patterns were found. |

**Category Summary:** 2 passed, 0 failed

## pathHandling

Verify safe path handling

| Test | Status | Message |
|------|--------|---------|
| Safe Path Construction | ✅ PASS | All patterns were found. |

**Category Summary:** 1 passed, 0 failed

## sniptetHandling

Verify snippet files are handled properly

| Test | Status | Message |
|------|--------|---------|
| Snippets Directory References | ✅ PASS | All patterns were found. |

**Category Summary:** 1 passed, 0 failed

---

Generated: 2026-04-20 00:43:41

