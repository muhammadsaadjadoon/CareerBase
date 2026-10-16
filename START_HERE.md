# Start CareerBase 2.0

## Existing CareerBase installation

Follow UPGRADE.md first. Keep your local configured lib/firebase_options.dart and android/app/google-services.json. The uploaded archive supplied to this redesign contained the unconfigured placeholder; this output cannot reconstruct your private local setup.

```powershell
flutter pub get
dart format lib test scripts
flutter analyze
flutter test
firebase deploy --only firestore --project YOUR_PROJECT_ID
flutter run -d emulator-5554
```

No Storage deployment. Existing administrator users do not need owner provisioning again. New settings and operational records are created in-app.

## Fresh source checkout

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
flutter doctor -v
.\scripts\bootstrap.ps1
.\scripts\verify.ps1
flutter emulators
flutter emulators --launch YOUR_AVD_ID
flutter devices
flutter run -d emulator-5554 --dart-define=DEMO=true
```

Replace emulator IDs. Bootstrap generates Android/iOS/web, retrieves dependencies, configures permissions/icons, formats and runs analysis/tests. Verify additionally builds an Android demo APK. iOS native builds require macOS.

## Live Firebase

Use a dedicated project; do not replace NextRole/Flow Desk rules. Enable Email/Password Authentication and create the default Firestore database.

If CLI tools are missing, install them once:

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Then:

```powershell
firebase login
firebase projects:list
dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID --platforms=android
firebase deploy --only firestore --project YOUR_PROJECT_ID
```

Use the actual Project ID. Android application ID is com.saadi.careerbase. See SETUP_OWNER.md for first owner automation. If you already provisioned your administrator, skip that step.

Stop demo with q, then:

```powershell
flutter run -d emulator-5554
```

## Daily workflow

Owner creates program → intern signup/verifies/requests enrollment → admin approves and selects cohort → admin creates deliverable → intern submits → admin reviews → records/dashboard update. Intern can check in/out, request leave, read updates and inspect stipend entries. Admin manages all these operations from the module menu. Mobile operational modules are under More.

Profiles, program defaults, tasks, attendance, requests and stipend records are created by app actions. Firebase project creation, enabling services, rules deployment and first trusted owner provisioning remain one-time infrastructure steps.

## Troubleshooting

- Firebase not configured: run FlutterFire and fully restart; preserve that generated file on updates.
- Access denied on new modules: deploy this package's firestore.rules to the same configured project.
- Enrollment pending: admin People → Pending → View intern → Review enrollment → approve and save.
- Existing email invitation: use Connect my internship instead of creating another request.
- Attendance denied: device business date must agree with server date; keep device clock correct. Day boundaries are UTC+05:00.
- Capacity reached: use another active program or edit capacity; not an atomic server quota.
- Stipend recorded Paid: a bookkeeping status, not proof of a bank transfer.
- Newer dependency notices: not failures; actual analyzer/test/build failures must be resolved.

GitHub: source at root, include .gitignore and .github; exclude build caches, node_modules, .setup-venv, Python __pycache__, service-account credentials and signing keys.
