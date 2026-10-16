# CareerBase 3.0 upgrade

Use [RELEASE_3.md](RELEASE_3.md) and scripts/update_existing.ps1 to preserve your configured Firebase files.

# CareerBase 2.2 upgrade

This package is based on your uploaded source archive. It includes the Badge naming fix and corrected scroll-before-tap widget tests. The uploaded archive contained a Firebase placeholder, not your local configured firebase_options.dart.

## Preserve your working configuration

Stop the app. Keep your existing lib/firebase_options.dart, android/app/google-services.json and generated platform folders. Copy the new lib files EXCEPT firebase_options.dart into your project. Copy assets, test, tests, scripts, setup, docs, pubspec.yaml, firestore.rules, firestore.indexes.json, firebase.json, README.md and other documentation. Do not delete existing database records or authentication accounts.

The Android package remains com.saadi.careerbase. Existing users/interns/tasks/submissions keep their document IDs. programId and enrollmentStatus are optional on old intern records. Existing active/inactive profiles keep their behavior. New self enrollment requests have enrollmentStatus=Pending and cannot approve themselves.

Run from your existing root:

```powershell
flutter pub get
dart format lib test scripts
flutter analyze
flutter test
firebase deploy --only firestore --project YOUR_PROJECT_ID
flutter run -d emulator-5554
```

Replace YOUR_PROJECT_ID with your CareerBase Firebase project. No Storage deployment. New module rules must be deployed before testing programs, attendance, leave, announcements or finance.

## Existing administrator

If your users/{uid} administrator record already exists, do not provision it again. Open Workspace → Edit workspace to set the title/description. Create a program, then review pending enrollment or add an intern and assign that program.

## Fresh workspace owner

See SETUP_OWNER.md. Owner provisioning is a privileged one-time command. Do not expose a public first-user-admin shortcut. Normal data entry after that is in-app.

## Enrollment options

- Self service: signup → verify → Request workspace enrollment → admin People → Pending → View intern → Review enrollment → approve, choose program → Save intern.
- Administrator-created invitation: admin People → Add intern → normalized email/program → intern signs up and verifies → Connect my internship.

If an invitation already exists for an email, use Connect my internship; do not create a duplicate request.

## Day boundaries

Attendance uses a fixed Asia/Karachi business date (UTC+05:00), validated against server time in security rules. Actual check-in/out timestamps use server time; display times use device local time. There is one check-in and one checkout per business date. Overnight shift handling is not included. Leave overlap checking is client-side convenience, not a cross-record rules invariant.

Program capacity checks are client-side admission guards, not an atomic server quota; concurrent administrative approvals can exceed capacity. No financial transactions or funds are processed by the ledger.

## Program applications

The applications collection and extended program fields require this version's Firestore rules. Existing program details may be blank: admin Programs → Manage program fills the real role, brief, mode, location and contact. Existing placements appear in My Internship without inventing an application record. New unassigned interns apply through Programs; admin Applications reviews the request. Accepting a request atomically fills the placement and activates the profile.

## Demo upgrade

See DEMO_WALKTHROUGH.md for simulated signup and selectable intern identities. Existing demo records are preserved. Joining uses local sample profiles only; real Firebase registration stays unchanged.
