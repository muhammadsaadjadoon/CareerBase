import 'dart:io';
void main(){
 final manifest=File('android/app/src/main/AndroidManifest.xml');
 if(manifest.existsSync()){
  var text=manifest.readAsStringSync().replaceAll('android:label="careerbase"','android:label="CareerBase"');
  if(!text.contains('android.permission.INTERNET')){text=text.replaceFirst('<application','<uses-permission android:name="android.permission.INTERNET"/>\n    <application');}
  manifest.writeAsStringSync(text);
 }
 final gradle=File('android/app/build.gradle.kts');
 if(gradle.existsSync()){gradle.writeAsStringSync(gradle.readAsStringSync().replaceAll('minSdk = flutter.minSdkVersion','minSdk = 24'));}
 final groovy=File('android/app/build.gradle');
 if(groovy.existsSync()){groovy.writeAsStringSync(groovy.readAsStringSync().replaceAll('minSdkVersion flutter.minSdkVersion','minSdkVersion 24'));}
 final plist=File('ios/Runner/Info.plist');
 if(plist.existsSync()){
  var text=plist.readAsStringSync();
  if(!text.contains('NSPhotoLibraryUsageDescription')){text=text.replaceFirst('</dict>','<key>NSPhotoLibraryUsageDescription</key><string>Select a professional profile photo for CareerBase.</string>\n</dict>');}
  text=text.replaceAll('<string>careerbase</string>','<string>CareerBase</string>');plist.writeAsStringSync(text);
 }
 final pod=File('ios/Podfile');
 if(pod.existsSync()){pod.writeAsStringSync(pod.readAsStringSync().replaceAll(RegExp(r"#?\s*platform :ios, '[0-9.]+'"),"platform :ios, '15.0'"));}
 final pbx=File('ios/Runner.xcodeproj/project.pbxproj');
 if(pbx.existsSync()){pbx.writeAsStringSync(pbx.readAsStringSync().replaceAll(RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;'),'IPHONEOS_DEPLOYMENT_TARGET = 15.0;'));}
 final generated=File('test/widget_test.dart');
 if(generated.existsSync()&&generated.readAsStringSync().contains('MyApp')){generated.deleteSync();}
}
