import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerbase/main.dart';
import 'package:careerbase/store.dart';
void main(){
 for(final admin in [false,true]){
  for(final width in [320.0,390.0,768.0,1280.0]){
   for(final scale in [1.0,1.8]){
    testWidgets('${admin?'admin':'intern'} $width px text $scale management modules',(tester)async{
     tester.view.devicePixelRatio=1;tester.view.physicalSize=Size(width,1000);tester.platformDispatcher.textScaleFactorTestValue=scale;
     addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
     SharedPreferences.setMockInitialValues({});final s=CareerStore(await SharedPreferences.getInstance(),demo:true);
     try{await s.initialize();s.switchDemo(admin);s.interns.first['name']='Alex Morgan With A Long Professional Name';s.interns.first['department']='Software Development and Infrastructure';
      for(var i=0;i<(admin?12:11);i++){await tester.pumpWidget(CareerApp(store:s,initialPage:i));await tester.pumpAndSettle();expect(tester.takeException(),isNull,reason:'Module $i');}
     }finally{await tester.pumpWidget(const SizedBox.shrink());await tester.pumpAndSettle();s.dispose();}
    });
   }
  }
 }
 testWidgets('small screen deliverable dialog cancels cleanly',(tester)async{
  tester.view.devicePixelRatio=1;tester.view.physicalSize=const Size(320,900);addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});final s=CareerStore(await SharedPreferences.getInstance(),demo:true);
  try{await s.initialize();s.switchDemo(true);await tester.pumpWidget(CareerApp(store:s));await tester.pumpAndSettle();final button=find.widgetWithText(OutlinedButton,'Create deliverable');await tester.ensureVisible(button);await tester.pumpAndSettle();await tester.tap(button);await tester.pumpAndSettle();expect(find.byType(Dialog),findsOneWidget);expect(tester.takeException(),isNull);final cancel=find.descendant(of:find.byType(Dialog),matching:find.widgetWithText(TextButton,'Cancel'));await tester.ensureVisible(cancel);await tester.pumpAndSettle();await tester.tap(cancel);await tester.pumpAndSettle();expect(find.byType(Dialog),findsNothing);expect(tester.takeException(),isNull);}finally{await tester.pumpWidget(const SizedBox.shrink());await tester.pumpAndSettle();s.dispose();}
 });
 testWidgets('mobile more menu reaches finance',(tester)async{
  tester.view.devicePixelRatio=1;tester.view.physicalSize=const Size(390,844);addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);SharedPreferences.setMockInitialValues({});final s=CareerStore(await SharedPreferences.getInstance(),demo:true);
  try{await s.initialize();await tester.pumpWidget(CareerApp(store:s));await tester.pumpAndSettle();await tester.tap(find.text('More'));await tester.pumpAndSettle();await tester.ensureVisible(find.text('Finance'));await tester.tap(find.text('Finance'));await tester.pumpAndSettle();expect(find.text('Stipend ledger'),findsOneWidget);expect(tester.takeException(),isNull);}finally{await tester.pumpWidget(const SizedBox.shrink());s.dispose();}
 });
}
