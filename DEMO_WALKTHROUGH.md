# CareerBase 2.2 · Try the complete workspace

Tagline: **Manage Internships. Build Careers.**

This is a Flutter internship management application for one organization. Administrators manage people and programs; interns work through their own placement. The local demo simulates roles and joining without Firebase. It is not real authentication. Sample links use example.com and do not point to completed work.

## Start the local demo

Open PowerShell in the project root. For a fresh source folder, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
flutter devices
flutter run -d emulator-5554 --dart-define=DEMO=true
```

Use the device ID actually printed by `flutter devices` if it differs. This command assumes the Android emulator is already running. Alternatively use `flutter run -d chrome --dart-define=DEMO=true` if Chrome is installed.

## Scenario A: a new intern joins your organization

1. At the top of the workspace, select **Try joining**. Enter a fictional name, a unique email such as jamie@example.com, university and skills, then Save. No email is sent.
2. The app opens that intern's workspace. Enrollment is **Pending**. Tasks are empty and work actions remain blocked.
3. Open **Programs** (on mobile: **More → Programs**), inspect the fellowship through **Program details**, and submit an application with a short motivation.
4. Select **Administrator** in the sample workspace panel. Open **Applications** and **Review and place intern**. Accept the application and add feedback. This activates the profile and fills the program, department, supervisor and dates.
5. Open **People**, find the person and inspect their profile. You can update details, dates and activation from the management UI. For a direct enrollment without a program application, use the pending profile's **Approve enrollment (save to confirm)** action and Save.
6. Open **Deliverables → Create deliverable**. Select the newly approved intern, enter clear instructions, choose priority and a future deadline, then Save.
7. Select **Intern**. The selected identity is retained when switching roles. The **View as intern** dropdown lets you inspect other sample identities.
8. Open **Deliverables**, inspect the assignment and start it. Submit an HTTPS work link plus meaningful notes. For a dummy test, use https://example.com/sample-work and label your notes as sample work.
9. Switch to **Administrator → Reviews**. Request a revision and supply feedback.
10. Switch back to the same intern, read the feedback and resubmit. As administrator, approve the resubmission with a score.
11. Inspect the intern's **Progress**, submission history and **My Internship**. Work progress comes from reviewed assignments; elapsed internship time is a separate measure.

The signup-created identity and its records survive a demo restart. A temporary dropdown identity selection is session-only; a restart returns to the most recently signup-created identity. Demo records are kept locally on this installation, not shared between devices.

## Scenario B: administrator enrolls someone first

1. Select Administrator and use **Enroll a person**. Enter a unique fictional email and internship details.
2. Select **Try joining**, use the same email and Save. In the local simulation, this connects the existing unclaimed profile instead of creating another person. Existing activation and assigned work are retained.
3. A registered demo email cannot sign up again. Use **View as intern** to revisit it.

## Other working modules to try

- **Attendance:** active interns check in and out once per business day. Business-day grouping uses Pakistan time (UTC+05:00); overnight attendance is outside this scope.
- **Leave:** interns request dated leave; administrators decide with feedback.
- **Announcements:** administrators publish and archive workspace updates.
- **Finance:** administrators record stipend amounts and payment status; interns see their own ledger. This records payments; it does not transfer money.
- **Profile:** edit personal details and a small compressed photo.
- **Workspace:** administrator changes organization name and description.

## Switch to real accounts

Preserve your actual Firebase configuration when upgrading. Follow `UPGRADE.md`, `SETUP_OWNER.md` and `START_HERE.md`. Provision the first owner through the trusted setup tool once. Real interns sign up with Firebase Authentication, verify email, and either connect an administrator-created enrollment or request enrollment. Administrators approve/place them through the UI. Deploy the provided Firestore rules to your own Firebase project. Do not use demo role switching as an authorization mechanism in production.

Live mode requires Firebase Authentication and Firestore; Firebase Storage is not required. Work attachments are HTTPS links. Setup still requires choosing your Firebase project and configuring Firebase once. Future intern profiles, programs and assignments are managed from the application rather than manual database edits.

## Validate on your computer

```powershell
flutter pub get
dart format lib test scripts
flutter analyze
flutter test
flutter build apk --debug --dart-define=DEMO=true
```

Then follow `docs/ACCEPTANCE.md` using two separate live accounts. Passing demo tests does not verify your live Firebase rules, configuration or device behavior. See `VERIFICATION.md` for checks performed on this package and those still requiring execution.
