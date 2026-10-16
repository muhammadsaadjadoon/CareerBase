import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerbase/models.dart';
import 'package:careerbase/store.dart';
import 'package:careerbase/ui.dart';

void main() {
  test('enrollment identity preserves full case-sensitive stored ID', () {
    final person=<String,dynamic>{'id':'aBc123','name':'Alex'};
    final original=enrollmentId(person);
    person['name']='A different display name';
    expect(enrollmentId(person),original);
    expect(original,'CB-aBc123');
    expect(enrollmentId({'id':'Abc123'}),isNot(original));
    expect(enrollmentId({}),'Not enrolled');
  });
  test('editing profile name does not change assignment ownership', () async {
    SharedPreferences.setMockInitialValues({});
    final store=CareerStore(await SharedPreferences.getInstance(),demo:true);
    try {
      await store.initialize();
      final id=store.internId;
      final display=enrollmentId(store.mine!);
      final work=store.visibleTasks.map((r)=>r['id']).toList();
      await store.profile({'name':'Updated Professional Name'});
      expect(store.internId,id);
      expect(enrollmentId(store.mine!),display);
      expect(store.visibleTasks.map((r)=>r['id']).toList(),work);
    } finally {store.dispose();}
  });
  for(final scale in [1.0,1.8]) {
    testWidgets('identity panel at 320px and text $scale wraps long account details',(tester)async{
      tester.view.devicePixelRatio=1;
      tester.view.physicalSize=const Size(320,1100);
      tester.platformDispatcher.textScaleFactorTestValue=scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:SingleChildScrollView(child:IdentityCard({
        'id':'aBcd1234567890AccountDocumentFullID',
        'accountUid':'AbCdEFg123456789012345678901234',
        'name':'Alex Morgan With A Long Professional Name',
        'email':'a.long.professional.email@example.com',
        'department':'Software Development and Infrastructure',
        'supervisor':'Jordan Lee With A Long Supervisor Name',
        'active':true,
      },demo:false)))));
      await tester.pumpAndSettle();
      expect(find.text('ACCOUNT CONNECTED'),findsOneWidget);
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
