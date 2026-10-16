import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerbase/store.dart';
void main(){
 late CareerStore s;
 setUp(()async{SharedPreferences.setMockInitialValues({});s=CareerStore(await SharedPreferences.getInstance(),demo:true);await s.initialize();});
 tearDown(()=>s.dispose());
 test('submission revision resubmission approval and immutable attempts persist',()async{
  await s.startTask('demo-1');await s.submit('demo-1','https://github.com/demo/project','','First complete submission with notes.');
  expect(s.task('demo-1')['status'],'Submitted');
  await expectLater(s.submit('demo-1','https://github.com/demo/project','','Duplicate submission should fail.'),throwsStateError);
  s.switchDemo(true);await s.review('demo-1',false,'Please improve accessibility.',null);expect(s.task('demo-1')['status'],'Revision Required');
  s.switchDemo(false);await s.submit('demo-1','https://github.com/demo/project','https://example.com','Updated accessibility and validation.');expect(s.task('demo-1')['status'],'Resubmitted');expect(s.attempts('demo-1').length,2);expect(s.attempts('demo-1').last['feedback'],'Please improve accessibility.');
  s.switchDemo(true);await s.review('demo-1',true,'All requested changes verified.',95);expect(s.task('demo-1')['status'],'Approved');
  await expectLater(s.review('demo-1',true,'Second review should fail.',50),throwsStateError);
  final restored=CareerStore(await SharedPreferences.getInstance(),demo:true);await restored.initialize();expect(restored.task('demo-1')['score'],95);expect(restored.attempts('demo-1').length,2);restored.dispose();
 });
 test('intern cannot assign review or start another intern task',()async{
  await expectLater(s.startTask('demo-4'),throwsStateError);
  await expectLater(s.review('demo-1',true,'Unauthorized review.',100),throwsStateError);
  await expectLater(s.archiveTask('demo-1',true),throwsStateError);
  await expectLater(s.profile({'active':true}),throwsStateError);
 });
 test('archived internship retains visibility but blocks work',()async{
  s.switchDemo(true);final profile={...s.person('demo-intern'),'active':false};await s.saveIntern(profile);s.switchDemo(false);
  expect(s.visibleTasks,isNotEmpty);expect(s.canWork,isFalse);await expectLater(s.submit('demo-1','https://example.com','','Submission on archived internship.'),throwsStateError);
 });
}
