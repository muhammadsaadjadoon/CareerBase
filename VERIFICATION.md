# CareerBase 3.0 verification record

## Executed for this redesign

- Dart source, widget tests and platform scripts parsed with tree-sitter Dart: no syntax errors.
- Python owner provisioning script syntax compiled without invoking Firebase or reading any credential.
- Node JavaScript syntax checked for security test file.
- JSON and dependency lock parsing, local documentation references and supplied PNG decoding.
- ZIP integrity and included source/asset paths checked.

## Not executed here

Flutter pub get, formatter, static analysis/type checking, Flutter tests, Firestore emulator tests, APK build, device rendering and live account/attendance/financial workflows. No passing runtime report or production audit is claimed. A previous Flutter SDK startup in this session was rejected by automatic approval review because it attempted a cloud instance-metadata endpoint; that action was not retried or bypassed.

## Included checks

- Role/private task access, immutable attempts, revision/resubmission and duplicate review tests.
- Enrollment self-promotion denial, stipend privacy, leave decision permissions and attendance rules tests.
- Navigation/module rendering for intern/admin at 320, 390, 768, 1280 logical pixels and 1.0/1.8 text scale.
- Small-screen deliverable dialog lifecycle and mobile More menu behavior.
- Demo attendance/leave/ledger persistence tests.

Run scripts/bootstrap.ps1 or the commands in UPGRADE.md on your machine, then scripts/verify.ps1 and Firestore emulator tests. Complete docs/ACCEPTANCE.md with separate live accounts. Included CI has not executed yet.

2.1 adds program application guards and acceptance placement tests. These tests are included, not executed here. Syntax, JSON, Python/JS parsing, local references and archive validation were repeated for the 2.1 package.

## 2.2 additions

Added simulated joining, selected intern role switching and two joining regression tests. Flutter execution remains unverified here; no new runtime pass is claimed.

2.2 packaging checks: 13 Dart files parsed with tree-sitter with no syntax errors; JSON and Python syntax parsed; rules test JavaScript passed node --check. These are syntax checks, not Dart type checking or runtime tests.

## 2.2.1 source correction

User-provided analysis log reported invalid_constant in the person details enrollment action and two avoid_types_as_parameter_names diagnostics. Removed const from the dynamic Text and renamed fold accumulators. Flutter analysis/tests still require local execution. The same log reports a Firestore IPv6 TCP connection refused; this source correction does not claim to resolve that network failure.

## 2.2.2 test-log corrections

The user ran Flutter tests and reported a runtime Map<String,Object> mismatch during leave review plus dashboard overflow at 320/390 pixels with 1.8 text scale. Leave records and demo program applications now explicitly use Map<String,dynamic>. The intern dashboard action is a full-width wrapping text button, and progress captions wrap instead of requiring a horizontal row. Existing size/text-scale and leave-review tests are retained. Dart syntax and ZIP checks were repeated here. Flutter tests still require rerunning on the user machine; the exact overflowing widget was not identified in the supplied test summary, so the dashboard correction remains to be verified. Earlier invalid-const and fold accumulator fixes are included.

## 3.0 redesign

New dashboard, responsive sign-in shell, people/identity panels and permanent enrollment IDs. Existing runtime test failures reported for 2.2 were addressed in 2.2.1/2.2.2; no later user pass has been supplied. This release includes those fixes. New identity tests and existing full navigation tests are included but not executed here. No screenshot/device rendering, Flutter analyzer pass or APK build is claimed for 3.0.

3.0 packaging checks executed: tree-sitter parsed all 14 Dart source/test/script files with no syntax errors; Python and JSON parsed; Node checked security test JavaScript syntax; relative Markdown document links resolved. The PowerShell updater has been source-reviewed but not executed on Windows.
