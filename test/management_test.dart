import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerbase/store.dart';
void main(){
 late CareerStore s;setUp(()async{SharedPreferences.setMockInitialValues({});s=CareerStore(await SharedPreferences.getInstance(),demo:true);await s.initialize();});tearDown(()=>s.dispose());
 test('check in and checkout are each allowed once',()async{await s.clock(false);await expectLater(s.clock(false),throwsStateError);await s.clock(true);await expectLater(s.clock(true),throwsStateError);expect(s.attendance.length,1);expect(s.attendance.first['outMs'],isNotNull);});
 test('leave decision prevents another decision and overlap',()async{final start=DateTime.now().millisecondsSinceEpoch;await s.requestLeave(start,start+86400000,'Medical appointment and recovery time.');await expectLater(s.requestLeave(start,start+86400000,'Duplicate overlapping absence request.'),throwsStateError);s.switchDemo(true);await s.decideLeave(s.leaves.first['id'] as String,'Approved','Approved with coverage arranged.');await expectLater(s.decideLeave(s.leaves.first['id'] as String,'Rejected','Already decided.'),throwsStateError);});
 test('intern cannot publish finance or program records',()async{await expectLater(s.saveEntity('programs',{}),throwsStateError);await expectLater(s.saveEntity('stipends',{}),throwsStateError);});
 test('finance ledger and program persist across restart',()async{s.switchDemo(true);await s.saveEntity('stipends',{'id':'payment','internId':'demo-intern','amountMinor':150000,'currency':'PKR','period':'October','reference':'Demo ledger reference','status':'Pending'},create:true);final other=CareerStore(await SharedPreferences.getInstance(),demo:true);await other.initialize();expect(other.stipends.single['amountMinor'],150000);expect(other.programs,isNotEmpty);other.dispose();});
 test('program application prevents duplicates and acceptance fills placement',()async{
  s.mine!['programId']='';s.mine!['active']=false;s.mine!['enrollmentStatus']='Pending';
  await s.applyProgram('demo-program','I want to develop professional Flutter applications.');
  await expectLater(s.applyProgram('demo-program','A duplicate application should be rejected.'),throwsStateError);
  s.switchDemo(true);await s.decideApplication(s.applications.single['id'] as String,true,'Welcome to the engineering program.');
  expect(s.person('demo-intern')['programId'],'demo-program');expect(s.person('demo-intern')['active'],isTrue);expect(s.applications.single['status'],'Accepted');
  s.switchDemo(false);await expectLater(s.applyProgram('demo-program','I cannot apply while already assigned.'),throwsStateError);
 });

}
