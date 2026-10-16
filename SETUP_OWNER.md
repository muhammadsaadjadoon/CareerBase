# One-time owner setup without manual database fields

If an administrator already exists, skip this file. No Python backend needs to run during normal app use.

1. Create a dedicated Firebase project, enable Email/Password Authentication and create Firestore.
2. Generate native platform files with scripts/bootstrap.ps1.
3. Configure your project and deploy the supplied rules:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID --platforms=android
firebase deploy --only firestore --project YOUR_PROJECT_ID
```

4. Firebase Console → Project settings → Service accounts → Generate new private key. Save it OUTSIDE the repository, for example D:\Private\careerbase-service-account.json. This credential is for the trusted setup script only. It must never enter Flutter assets or GitHub.
5. Run locally with Python 3.10+:

```powershell
py -m venv .setup-venv
.\.setup-venv\Scripts\python.exe -m pip install -r .\setup\requirements.txt
.\.setup-venv\Scripts\python.exe .\setup\provision_owner.py --project YOUR_PROJECT_ID --email "YOUR_OWNER_EMAIL" --name "YOUR_NAME" --workspace "CareerBase" --credentials "D:\Private\careerbase-service-account.json"
```

The script checks the credential project ID, reuses an existing Firebase account by email or asks for a new password privately, and provisions the owner role/workspace settings. It refuses to replace a different registered owner. Re-running with the same owner preserves workspace settings. Authentication account creation and Firestore writes are separate services, so a failed Firestore step may leave the account created; rerunning reuses it.

6. Start the normal app:

```powershell
flutter run -d emulator-5554
```

Sign in as owner. If email is not verified, Resend verification → open the email → Refresh session. The script never fabricates email verification.

7. Workspace → Edit workspace; Programs → Create program; People → approve enrollment requests or add interns. Supervisor/dates are filled from the selected program, with editable overrides.

Additional administrator provisioning is not exposed to public users. Account-level suspension remains a trusted console operation; internship archive/restore is managed in the application.
