typedef Record = Map<String, dynamic>;
const stages = ['Assigned', 'In Progress', 'Submitted', 'Revision Required', 'Resubmitted', 'Approved'];
const priorities = ['Low', 'Normal', 'High'];
String str(Record r, String key) => r[key]?.toString() ?? '';
int numOf(Record r, String key) => (r[key] as num?)?.toInt() ?? 0;
bool pendingReview(Record t) => ['Submitted', 'Resubmitted'].contains(t['status']);
bool actionable(Record t) => t['archived'] != true && ['Assigned', 'In Progress', 'Revision Required'].contains(t['status']);
bool overdue(Record t, DateTime now) => t['archived'] != true && t['status'] != 'Approved' && numOf(t, 'dueMs') < now.millisecondsSinceEpoch;
String dateText(int ms) {
 if (ms <= 0) { return 'Not set'; }
 final d = DateTime.fromMillisecondsSinceEpoch(ms);
 return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
bool validLink(String s) {
 if (s.trim().isEmpty) { return true; }
 final u = Uri.tryParse(s.trim());
 return u != null && u.scheme == 'https' && u.host.contains('.') && u.userInfo.isEmpty;
}
String? requiredText(String? value, int max, {int min = 1}) {
 final s = value?.trim() ?? '';
 if (s.length < min) { return 'Enter at least $min characters'; }
 if (s.length > max) { return 'Use $max characters or fewer'; }
 return null;
}
String? emailError(String? value) => RegExp(r'^[^\s@/]+@[^\s@/]+\.[^\s@/]+$').hasMatch(value?.trim() ?? '') ? null : 'Enter a valid email address';
class Metrics {
 final List<Record> tasks;
 Metrics(Iterable<Record> source) : tasks = source.where((t) => t['archived'] != true).toList();
 int get total => tasks.length;
 int count(String status) => tasks.where((t) => t['status'] == status).length;
 int get approved => count('Approved');
 int get review => tasks.where(pendingReview).length;
 double get completion => total == 0 ? 0 : approved / total;
 double? get averageScore {
  final graded = tasks.where((t) => t['status'] == 'Approved' && t['score'] is num).toList();
  return graded.isEmpty ? null : graded.fold<int>(0, (sum, t) => sum + numOf(t, 'score')) / graded.length;
 }
 int late(DateTime now) => tasks.where((t) => overdue(t, now)).length;
}
Record internRecord({required String id, required String name, required String email, required String department, required String supervisor, required int startMs, required int endMs}) => {
 'id': id, 'name': name, 'email': email, 'department': department, 'supervisor': supervisor,
 'startMs': startMs, 'endMs': endMs, 'university': '', 'skills': '', 'phone': '', 'bio': '',
 'photo': '', 'active': true, 'accountUid': '',
};
Record taskRecord({required String id, required String internId, required String title, required String description, required String priority, required int dueMs, required String reference, required String createdBy}) => {
 'id': id, 'internId': internId, 'title': title, 'description': description, 'priority': priority,
 'dueMs': dueMs, 'reference': reference, 'createdBy': createdBy, 'status': 'Assigned',
 'attempt': 0, 'latestId': '', 'feedback': '', 'score': null, 'archived': false,
};

/// Uses the complete stored document ID; never a name or editable profile field.
String enrollmentId(Record person) {
 final id=str(person,'id');
 return id.isEmpty?'Not enrolled':'CB-$id';
}
