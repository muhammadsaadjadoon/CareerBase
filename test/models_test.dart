import 'package:flutter_test/flutter_test.dart';
import 'package:careerbase/models.dart';
void main(){
 test('completion counts only approved nonarchived assignments',(){final m=Metrics([{'status':'Approved','score':90},{'status':'Submitted'},{'status':'Approved','score':20,'archived':true}]);expect(m.total,2);expect(m.completion,.5);expect(m.review,1);expect(m.averageScore,90);});
 test('empty metrics do not invent scores',(){final m=Metrics([]);expect(m.completion,0);expect(m.averageScore,isNull);});
 test('deadline and actionable states are independent',(){final now=DateTime(2026,10,12);final t={'status':'Submitted','dueMs':now.subtract(const Duration(days:1)).millisecondsSinceEpoch};expect(overdue(t,now),isTrue);expect(actionable(t),isFalse);expect(pendingReview(t),isTrue);expect(overdue({...t,'status':'Approved'},now),isFalse);});
 test('external links restrict schemes and embedded credentials',(){expect(validLink('https://github.com/example/project'),isTrue);expect(validLink(''),isTrue);expect(validLink('javascript:alert(1)'),isFalse);expect(validLink('http://example.com'),isFalse);expect(validLink('https://name:pass@example.com'),isFalse);});
}
