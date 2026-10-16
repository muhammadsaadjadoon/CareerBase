# CareerBase 3.0 · Connected people, visible work

## What changed

The presentation layer has a new navy, blue and gold direction, gradient welcome panel, operational metric cards, action queues, redesigned people cards, an identity panel and a responsive sign-in experience. Original logo and charcoal/gold brand cues are retained. Compact screens use bottom navigation and More; wide screens use the management sidebar. Text scaling remains enabled.

## Intern identity is a record, not a name

Each enrollment uses the full immutable Firestore document ID. The displayed `CB-...` enrollment ID is a formatting of that complete ID, not a name, sequence guess or truncated random number. Directory search and CSV export include it. It is an identifier, not a password or access token.

The profile shows these separate facts:

- **Awaiting signup:** an administrator prepared a profile/invitation. A real account is not yet connected.
- **Account connected:** the enrollment has an account UID linked by the verified email claim/self-enrollment flow. The full UID is available in the private identity panel.
- **Pending approval / Active / Archived:** workspace activation, separate from account connection.
- **Sample identity:** local demo data. It is never presented as a verified live account.

Firebase Authentication proves control of an email account through verification; it does not prove a person's legal identity, education or employment. Administrators still review the applicant. This release does not add government ID checking or background checks.

## Real joining and assignment

1. Configure your existing Firebase project and deploy the supplied Firestore rules.
2. Provision the first owner once using `SETUP_OWNER.md` if you have no administrator yet.
3. As administrator, create the program and invite an intern using their actual email. The new record has its own enrollment ID and initially shows Awaiting signup. No automatic invitation email is sent by this application.
4. The intern creates a Firebase account with that email, verifies it, and selects Connect my internship. The app links the UID atomically. Alternatively they request enrollment and wait for approval.
5. Administrator checks the connected identity, assigns the program/supervisor/dates, and creates deliverables for the selected profile.
6. Intern signs in from their own device, sees their assigned work, submits links/notes, and receives the administrator's review.

Tasks are linked by stored internId, not by display name. Editing a name does not reassign work or change the enrollment ID. Administrator-prepared assignments can exist before signup; the intern receives access only after the account is linked and the relevant approval/activation requirements are met. Firestore rules enforce role and own-record access independently of the visible UI.

## Update your working project without replacing Firebase configuration

Extract this ZIP into a separate folder. Open PowerShell in the extracted CareerBase folder, then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\update_existing.ps1 -Target "D:\ARTIFICIAL INTELLIGENCE\PROJECTS\CAREERBASE"
cd "D:\ARTIFICIAL INTELLIGENCE\PROJECTS\CAREERBASE"
flutter pub get
dart format lib test scripts
flutter analyze
flutter test
flutter devices
flutter run -d emulator-5554
```

The update script preserves your local `lib/firebase_options.dart`, `firebase.json`, `.firebaserc` and existing native platform folders, including `android/app/google-services.json`. It copies new source over existing source; it does not delete Firebase records or create users. Stop your running app before updating.

If you already replaced your generated Firebase options with the ZIP's placeholder, restore them or run FlutterFire configure for your actual existing project. No project ID is guessed or supplied in this ZIP. If using this as a fresh checkout, follow START_HERE.md instead.

## Verification

See VERIFICATION.md. Source syntax and packaging checks are distinct from executing Flutter analysis, tests, building an APK or checking live Firebase. Those runtime checks have not been executed in this environment. Included navigation tests still cover small screens and 1.8 text scale; identity tests verify that changing a display name cannot change the enrollment ID or reassign work.

## Boundaries

This remains a single-organization internship management app. It does not include external internship listings, legal identity verification, a separate project/milestone entity, automated email invitations, push delivery, or actual financial transfers. Program briefs and detailed deliverables provide current work context. Do not present unimplemented features as included.
