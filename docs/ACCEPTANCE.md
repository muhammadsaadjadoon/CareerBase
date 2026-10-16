# Live acceptance checklist

Use a dedicated test Firebase project and three verified accounts: administrator, intern A and intern B.

- [ ] Public registration does not grant admin access; verify email before data access.
- [ ] Admin creates intern A by email. Wrong/unregistered email cannot claim their record.
- [ ] Intern A claims their own record. It cannot be claimed again by another UID.
- [ ] Admin adds dates, supervisor and department, then assigns a task to A.
- [ ] A sees it; B cannot read it, even with the task document ID.
- [ ] A changes status to In Progress, then submits work and notes.
- [ ] Double tap/second submission while pending creates no duplicate accepted attempt.
- [ ] Admin sees the submission in Reviews, opens HTTPS work link and requests revision.
- [ ] A sees feedback and resubmits. Previous notes and links remain unchanged.
- [ ] Admin approves attempt 2 with feedback and score. A cannot approve or change score.
- [ ] Both dashboards update from actual records; approved completion and score agree.
- [ ] Archived tasks leave metric totals; include-archived switch exposes history to admin.
- [ ] Archived intern can read history but cannot start/submit/edit profile.
- [ ] Profile photo and text survive restart; discard-navigation confirmation works.
- [ ] Password reset, verification, sign out and account switching behave correctly.
- [ ] Administrator CSV export opens in spreadsheet app with correct rows and quoted values.
- [ ] Long task/intern names fit at 320px and large text; every modal scrolls above keyboard.
- [ ] Light/dark appearance persists; controls stay readable.
- [ ] Loss of connectivity does not fabricate a successful review or approval.
- [ ] Android native photo/export/browser actions work; test iOS separately on macOS.

A demo APK passing is not proof of Firebase permissions or a production release.

## CareerBase 2.0 operations

- [ ] Owner script reuses an existing account, refuses a different owner and preserves settings on rerun.
- [ ] Verified new intern creates pending enrollment automatically; cannot self-approve.
- [ ] An existing email invitation uses Connect my internship instead of duplicate request.
- [ ] Admin selects a program; supervisor/department/dates fill; approval unlocks work.
- [ ] All operational modules are reachable from mobile More and desktop sidebar.
- [ ] Program create/edit/archive and admission capacity messages behave correctly.
- [ ] Attendance check-in and checkout work once per Karachi business date; backdating is denied.
- [ ] Leave request overlaps are warned; admin decision appears to the intern and cannot be overwritten.
- [ ] Administrator bulletin publish/edit/archive appears in intern workspace.
- [ ] Stipend amounts remain integer minor units; totals stay separate for each currency.
- [ ] Intern cannot read another stipend or change Paid/Pending state.
- [ ] Workspace name and description persist without manual Firestore field edits.

## Internship lifecycle

- [ ] Program brief, role, location, mode and supervisor contact can be edited by administrator.
- [ ] Unassigned intern applies once; motivation remains immutable.
- [ ] Administrator accepts application; profile/program/dates activate atomically.
- [ ] My Internship shows real placement fields, pending state and absent-data labels.
- [ ] Another intern cannot access the application or change its decision.
- [ ] Current assigned intern cannot open a second placement application.
- [ ] Calendar time and approved work percentages are labelled separately.
