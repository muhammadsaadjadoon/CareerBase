import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerbase/store.dart';
import 'package:careerbase/models.dart';

void main() {
  late CareerStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = CareerStore(await SharedPreferences.getInstance(), demo: true);
    await store.initialize();
  });
  tearDown(() => store.dispose());

  test('joining through placement, assignment and approval retains identity', () async {
    await store.joinDemo('Jamie Ahmed', 'jamie@example.com', 'Demo University', 'Flutter');
    final id = store.internId;
    expect(store.mine!['enrollmentStatus'], 'Pending');
    expect(store.canWork, isFalse);
    expect(store.visibleTasks, isEmpty);
    await store.applyProgram('demo-program', 'I want to build accessible mobile applications.');
    store.switchDemo(true);
    await store.decideApplication(store.applications.single['id'] as String, true, 'Welcome to the fellowship.');
    await store.saveTask(taskRecord(id: 'joining-task', internId: id,
      title: 'Build the onboarding flow', description: 'Implement and document an accessible onboarding flow.',
      priority: 'High', dueMs: DateTime.now().add(const Duration(days:7)).millisecondsSinceEpoch,
      reference: '', createdBy: 'demo-admin'), create: true);
    store.switchDemo(false);
    expect(store.internId, id);
    expect(store.canWork, isTrue);
    expect(store.visibleTasks.single['id'], 'joining-task');
    await store.startTask('joining-task');
    await store.submit('joining-task', 'https://example.com/sample-work', '', 'Sample submission for testing the review workflow.');
    store.switchDemo(true);
    await store.review('joining-task', true, 'Requirements verified in the sample workflow.', 90);
    store.switchDemo(false);
    expect(Metrics(store.visibleTasks).approved, 1);
    final restored = CareerStore(await SharedPreferences.getInstance(), demo:true);
    try {
      await restored.initialize();
      expect(restored.internId, id);
      expect(restored.visibleTasks.single['status'], 'Approved');
    } finally { restored.dispose(); }
  });

  test('unclaimed invitation connects and registered demo email cannot join twice', () async {
    await store.joinDemo('Taylor Quinn', 'taylor@example.com', 'Demo University', 'Design');
    expect(store.internId, 'demo-design');
    expect(store.interns.length, 2);
    await expectLater(store.joinDemo('Taylor Quinn', 'taylor@example.com', 'Demo University', 'Design'), throwsStateError);
    store.switchDemo(false, identity:'demo-intern');
    expect(store.internId, 'demo-intern');
  });
}
