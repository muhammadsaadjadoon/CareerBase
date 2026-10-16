"""One-time owner provisioning using an explicitly supplied credential file.
No Application Default Credentials fallback or metadata credential discovery.
"""
import argparse
import getpass
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description='Provision CareerBase owner without manual Firestore field editing.')
    parser.add_argument('--project', required=True)
    parser.add_argument('--email', required=True)
    parser.add_argument('--name', default='Workspace Owner')
    parser.add_argument('--workspace', default='CareerBase')
    parser.add_argument('--credentials', required=True, type=Path)
    args = parser.parse_args()
    email = args.email.strip().lower()
    credential = json.loads(args.credentials.read_text(encoding='utf-8-sig'))
    if credential.get('project_id') != args.project:
        parser.error('Credential project_id must match --project. No changes were made.')
    if '@' not in email or not args.workspace.strip():
        parser.error('Provide a valid email and workspace name.')
    import firebase_admin
    from firebase_admin import auth, credentials, firestore
    firebase_admin.initialize_app(credentials.Certificate(credential), {'projectId': args.project})
    db = firestore.client()
    owner = db.collection('settings').document('owner').get()
    if owner.exists and owner.to_dict().get('email') != email:
        parser.error('A different owner already exists. This setup tool will not replace them.')
    try:
        user = auth.get_user_by_email(email)
    except auth.UserNotFoundError:
        password = getpass.getpass('New owner password (12+ characters, not printed): ')
        confirm = getpass.getpass('Repeat password: ')
        if len(password) < 12 or password != confirm:
            parser.error('Passwords must match and contain at least 12 characters.')
        user = auth.create_user(email=email, password=password, display_name=args.name)
    old = db.collection('users').document(user.uid).get()
    if old.exists and old.to_dict().get('role') not in ('intern', 'admin'):
        parser.error('Unexpected existing role. No Firestore role was changed.')
    transaction = db.transaction()
    @firestore.transactional
    def provision(tx):
        owner_ref = db.collection('settings').document('owner')
        existing_owner = owner_ref.get(transaction=tx)
        if existing_owner.exists and existing_owner.to_dict().get('email') != email:
            raise RuntimeError('Another owner was provisioned. No role changes committed.')
        workspace_ref = db.collection('settings').document('workspace')
        existing_workspace = workspace_ref.get(transaction=tx)
        tx.set(db.collection('users').document(user.uid), {'role': 'admin', 'internId': '', 'active': True})
        tx.set(owner_ref, {'uid': user.uid, 'email': email})
        # Preserve existing workspace identity on reruns.
        if not existing_workspace.exists:
            tx.set(workspace_ref, {'name': args.workspace.strip(), 'description': 'Manage Internships. Build Careers.'})
    provision(transaction)
    print('Owner role and workspace configured. Sign in with this email, verify it, then Refresh session.')
    print('This tool does not mark the email verified. Keep the credential file private and outside the repository.')


if __name__ == '__main__':
    main()
