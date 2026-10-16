import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

class CareerStore extends ChangeNotifier {
 CareerStore(this.prefs, {this.demo = false});
 final SharedPreferences prefs;
 final bool demo;
 String demoIdentity = 'demo-intern';
 final _uuid = const Uuid();
 FirebaseFirestore get db => FirebaseFirestore.instance;
 FirebaseAuth get auth => FirebaseAuth.instance;
 User? get user => demo ? null : auth.currentUser;
 Record? account;
 List<Record> interns = [], tasks = [], submissions = [];
 List<Record> programs=[],attendance=[],leaves=[],announcements=[],stipends=[],applications=[];
 Record workspace={'name':'CareerBase','description':'Manage Internships. Build Careers.'};
 StreamSubscription<User?>? _auth;
 StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _account;
 final List<StreamSubscription<dynamic>> _data = [];
 int _generation = 0, _watcher = 0;
 bool _disposed = false, loading = false;
 String? error;
 bool get admin => account?['role'] == 'admin';
 bool get signedIn => demo || user != null;
 bool get verified => demo || user?.emailVerified == true;
 bool get dark => prefs.getBool('careerbase.dark') ?? false;
 String get internId => str(account ?? {}, 'internId');
 Record? get mine {
  for (final r in interns) { if (r['id'] == internId) { return r; } }
  return null;
 }
 bool get canWork => account?['active'] == true && verified && (admin || mine?['active'] == true);
 List<Record> get visibleTasks => admin ? tasks : tasks.where((t) => t['internId'] == internId).toList();
 List<Record> attempts(String taskId) {
  final rows = submissions.where((s) => s['taskId'] == taskId).toList();
  rows.sort((a,b) => numOf(b,'attempt').compareTo(numOf(a,'attempt')));
  return rows;
 }
 void emit() { if (!_disposed) { notifyListeners(); } }
 Future<void> initialize() async {
  if (demo) {
   final saved = prefs.getString('careerbase.demo.v1');
   if (saved != null) {
    try {
     final r = jsonDecode(saved) as Map<String,dynamic>;
     interns = (r['interns'] as List).map((x) => Map<String,dynamic>.from(x as Map)).toList();
     tasks = (r['tasks'] as List).map((x) => Map<String,dynamic>.from(x as Map)).toList();
     submissions = (r['submissions'] as List).map((x) => Map<String,dynamic>.from(x as Map)).toList();
     programs=rows(r['programs']);attendance=rows(r['attendance']);leaves=rows(r['leaves']);announcements=rows(r['announcements']);stipends=rows(r['stipends']);applications=rows(r['applications']);workspace=Map<String,dynamic>.from(r['workspace'] as Map? ?? workspace);
    } catch (_) { seed(); }
   } else { seed(); }
   demoIdentity=prefs.getString('careerbase.demo.identity')??'demo-intern';
   if(!interns.any((r)=>r['id']==demoIdentity)){demoIdentity='demo-intern';}
   account = {'role':'intern','internId':demoIdentity,'active':true};
   emit(); return;
  }
  loading = true;
  _auth = auth.idTokenChanges().listen((u) { unawaited(bind(u)); });
 }
 void seed() {
  final now = DateTime.now();
  interns = [internRecord(id:'demo-intern',name:'Alex Morgan',email:'alex@example.com',department:'Engineering',supervisor:'Jordan Lee',startMs:now.subtract(const Duration(days:25)).millisecondsSinceEpoch,endMs:now.add(const Duration(days:60)).millisecondsSinceEpoch)..addAll({'university':'Demo University','skills':'Flutter, Dart, Firebase','accountUid':'demo'}),
   internRecord(id:'demo-design',name:'Taylor Quinn',email:'taylor@example.com',department:'Design',supervisor:'Casey Park',startMs:now.subtract(const Duration(days:20)).millisecondsSinceEpoch,endMs:now.add(const Duration(days:65)).millisecondsSinceEpoch)];
  tasks = [
   taskRecord(id:'demo-1',internId:'demo-intern',title:'Build an accessible profile screen',description:'Create a profile editor with clear validation and layouts that support large system text. Submit your repository and a short walkthrough.',priority:'High',dueMs:now.add(const Duration(days:3)).millisecondsSinceEpoch,reference:'',createdBy:'demo-admin'),
   taskRecord(id:'demo-2',internId:'demo-intern',title:'Document the onboarding journey',description:'Map the account verification and enrollment journey. Include empty and error states.',priority:'Normal',dueMs:now.subtract(const Duration(days:1)).millisecondsSinceEpoch,reference:'',createdBy:'demo-admin')..addAll({'status':'In Progress'}),
   taskRecord(id:'demo-3',internId:'demo-intern',title:'Review Firestore permissions',description:'Document the intern and administrator permission boundaries.',priority:'High',dueMs:now.add(const Duration(days:1)).millisecondsSinceEpoch,reference:'',createdBy:'demo-admin')..addAll({'status':'Approved','score':92,'feedback':'Clear reasoning and useful examples.'}),
   taskRecord(id:'demo-4',internId:'demo-design',title:'Create onboarding wireframes',description:'Design the sign-in and enrollment screens.',priority:'Normal',dueMs:now.add(const Duration(days:4)).millisecondsSinceEpoch,reference:'',createdBy:'demo-admin')];
  submissions = [];
  programs=[{'id':'demo-program','name':'Mobile Engineering Fellowship','department':'Engineering','supervisor':'Jordan Lee','capacity':12,'startMs':now.subtract(const Duration(days:25)).millisecondsSinceEpoch,'endMs':now.add(const Duration(days:60)).millisecondsSinceEpoch,'active':true,'role':'Flutter Development Intern','description':'A guided mobile engineering program focused on accessible interfaces, cloud data and reviewed deliverables. Clearly labelled demo program.','mode':'Remote','location':'Pakistan','supervisorContact':'jordan@example.com'}];
  interns.first['programId']='demo-program';
  announcements=[{'id':'demo-announcement','title':'Welcome to your internship workspace','body':'This is clearly labelled local sample content. Start a deliverable, submit your work, and switch to admin view to review it.','createdMs':now.millisecondsSinceEpoch,'active':true}];
  attendance=[];leaves=[];stipends=[];applications=[];
 }
 Future<void> persist() async {
  if (demo) {
   final ok = await prefs.setString('careerbase.demo.v1',jsonEncode({'interns':interns,'tasks':tasks,'submissions':submissions,'programs':programs,'attendance':attendance,'leaves':leaves,'announcements':announcements,'stipends':stipends,'applications':applications,'workspace':workspace}));
   if (!ok) {
    final old=prefs.getString('careerbase.demo.v1');
    if(old!=null){final r=jsonDecode(old) as Map<String,dynamic>;interns=(r['interns'] as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();tasks=(r['tasks'] as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();submissions=(r['submissions'] as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();}
    emit();throw StateError('Local storage could not save.');
   }
  }
  emit();
 }
 Future<void> setTheme(bool value) async { await prefs.setBool('careerbase.dark',value); emit(); }
 void switchDemo(bool value, {String? identity}) {
  if (!demo) { return; }
  if(identity!=null){
   if(!interns.any((r)=>r['id']==identity)){throw StateError('Choose an existing demo intern.');}
   demoIdentity=identity;
  }
  account = {'role':value ? 'admin':'intern','internId':value ? '':demoIdentity,'active':true}; emit();
 }
 Future<void> joinDemo(String name,String email,String university,String skills) async {
  if(!demo){throw StateError('This action is only available in the local demo.');}
  name=name.trim();email=email.trim().toLowerCase();
  if(name.length<2||name.length>80){throw StateError('Enter a name between 2 and 80 characters.');}
  if(emailError(email)!=null){throw StateError('Enter a valid email address.');}
  if(university.length>120||skills.length>500){throw StateError('Shorten the university or skills field.');}
  final existing=interns.where((r)=>str(r,'email').toLowerCase()==email).firstOrNull;
  if(existing!=null&&str(existing,'accountUid').isNotEmpty){throw StateError('This demo email is already registered. Select that intern instead.');}
  final previous=demoIdentity;
  final now=DateTime.now();
  final id=existing==null?newId():str(existing,'id');
  final record=existing==null?internRecord(id:id,name:name,email:email,department:'Unassigned',supervisor:'Unassigned',startMs:now.millisecondsSinceEpoch,endMs:now.add(const Duration(days:90)).millisecondsSinceEpoch):Map<String,dynamic>.from(existing);
  record.addAll({'name':name,'university':university.trim(),'skills':skills.trim(),'accountUid':'demo-$id'});
  if(existing==null){record.addAll({'active':false,'enrollmentStatus':'Pending','programId':''});interns.add(record);}else{interns[interns.indexOf(existing)]=record;}
  try{await persist();await prefs.setString('careerbase.demo.identity',id);}catch(_){if(existing==null){interns.remove(record);}else{interns[interns.indexWhere((r)=>r['id']==id)]=existing;}demoIdentity=previous;rethrow;}
  switchDemo(false,identity:id);
 }
 void clearData() {
  ++_watcher;
  for (final s in _data) { unawaited(s.cancel()); }
  _data.clear(); interns=[];tasks=[];submissions=[];programs=[];attendance=[];leaves=[];announcements=[];stipends=[];applications=[];
 }
 Future<void> bind(User? u) async {
  final g = ++_generation;
  await _account?.cancel(); if(g != _generation || _disposed){return;} clearData(); account=null; error=null;loading=u != null;emit();
  if (u == null) { loading=false;emit();return; }
  _account = db.collection('users').doc(u.uid).snapshots().listen((snap) {
   if (g != _generation) { return; }
   final next = snap.data();
   final changed = account?['role'] != next?['role'] || account?['internId'] != next?['internId'] || account?['active'] != next?['active'];
   account=next;loading=false;
   if (changed || _data.isEmpty) { watch(g); }
   emit();
  },onError:(Object e) { if(g==_generation){loading=false;error=friendly(e);emit();} });
 }
 void watch(int g) {
  clearData();
  final w=_watcher;
  if (account?['active'] != true || !verified) { return; }
  void listen(Query<Map<String,dynamic>> query, void Function(List<Record>) apply) {
   _data.add(query.snapshots().listen((snap) {
    if(g==_generation&&w==_watcher){apply(snap.docs.map((d)=> {...d.data(),'id':d.id}).toList());error=null;emit();}
   },onError:(Object e){if(g==_generation&&w==_watcher){error=friendly(e);emit();}}));
  }
  listen(db.collection('programs'),(v)=>programs=v);
  listen(db.collection('announcements').where('active',isEqualTo:true),(v)=>announcements=v);
  _data.add(db.collection('settings').doc('workspace').snapshots().listen((snap){if(g==_generation&&w==_watcher){workspace=snap.data()??workspace;emit();}},onError:(Object e){if(g==_generation&&w==_watcher){error=friendly(e);emit();}}));
  for(final collection in ['attendance','leaves','stipends','applications']){
   final q=admin?db.collection(collection):db.collection(collection).where('internId',isEqualTo:internId);
   listen(q,(v){switch(collection){case 'attendance':attendance=v;break;case 'leaves':leaves=v;break;case 'stipends':stipends=v;break;case 'applications':applications=v;break;}});
  }
  if(admin){listen(db.collection('interns'),(v)=>interns=v);listen(db.collection('tasks'),(v)=>tasks=v);listen(db.collection('submissions'),(v)=>submissions=v);}
  else if(internId.isNotEmpty){
   _data.add(db.collection('interns').doc(internId).snapshots().listen((s){if(g==_generation&&w==_watcher){interns=s.exists?[{...s.data()!,'id':s.id}]:[];emit();}},onError:(Object e){if(g==_generation&&w==_watcher){error=friendly(e);emit();}}));
   listen(db.collection('tasks').where('internId',isEqualTo:internId),(v)=>tasks=v);
   listen(db.collection('submissions').where('internId',isEqualTo:internId),(v)=>submissions=v);
  }
 }
 Future<void> signIn(String email,String password) async { await auth.signInWithEmailAndPassword(email:email.trim().toLowerCase(),password:password); }
 Future<void> register(String email,String password) async {
  final c=await auth.createUserWithEmailAndPassword(email:email.trim().toLowerCase(),password:password);
  await c.user!.sendEmailVerification();
 }
 Future<void> resetPassword(String email) => auth.sendPasswordResetEmail(email:email.trim().toLowerCase());
 Future<void> resendVerification() => user!.sendEmailVerification();
 Future<void> reloadSession() async {
  await user?.reload(); await auth.currentUser?.getIdToken(true);
  await bind(auth.currentUser);
 }
 Future<void> enroll() async {
  if(!verified){throw StateError('Verify your email first.');}
  final u=user!;
  await db.runTransaction((tx) async {
   final ur=db.collection('users').doc(u.uid);
   final existing=await tx.get(ur);
   if(existing.exists){return;}
   final inv=await tx.get(db.collection('invitations').doc(u.email!.toLowerCase()));
   if(!inv.exists){throw StateError('Your administrator has not added this email yet.');}
   final id=inv.data()!['internId'] as String;
   final ir=db.collection('interns').doc(id);final profile=await tx.get(ir);
   if(!profile.exists || profile.data()!['active']!=true){throw StateError('This internship is archived or unavailable.');}
   if(str(profile.data()!,'accountUid').isNotEmpty && profile.data()!['accountUid']!=u.uid){throw StateError('This profile is already linked.');}
   tx.set(ur,{'role':'intern','internId':id,'active':true});
   tx.update(ir,{'accountUid':u.uid});
  });
  await bind(auth.currentUser);
 }
 Future<void> logout() async {
  if(demo){switchDemo(false);return;}
  ++_generation;await _account?.cancel();clearData();account=null;emit();await auth.signOut();
 }
 Record person(String id) => interns.firstWhere((x)=>x['id']==id,orElse:()=>{'name':'Unknown intern'});
 Record task(String id) => tasks.firstWhere((x)=>x['id']==id);
 void needAdmin(){if(!admin || !canWork){throw StateError('Administrator access is required.');}}
 Future<void> saveIntern(Record data,{bool create=false}) async {
  needAdmin();
  if(requiredText(str(data,'name'),80,min:2)!=null || emailError(str(data,'email'))!=null || numOf(data,'endMs')<numOf(data,'startMs')){throw StateError('Check name, email and internship dates.');}
  if(data['active']==true && str(data,'programId').isNotEmpty){final cohort=programs.where((p)=>p['id']==data['programId']&&p['active']==true).toList();if(cohort.isEmpty){throw StateError('Choose an active program.');}final used=interns.where((i)=>i['id']!=data['id']&&i['programId']==data['programId']&&i['active']==true).length;if(used>=numOf(cohort.first,'capacity')){throw StateError('This program has reached its intake capacity.');}}
  if(demo){
   if(create && interns.any((i)=>i['email']==data['email'])){throw StateError('This email is already enrolled.');}
   if(create){interns.add(data);}else{final i=interns.indexWhere((x)=>x['id']==data['id']);interns[i]={...interns[i],...data};}
   await persist();return;
  }
  final ref=db.collection('interns').doc(data['id'] as String);
  if(create){await db.runTransaction((tx)async{
   final inv=db.collection('invitations').doc(data['email'] as String);
   if((await tx.get(inv)).exists){throw StateError('This email is already enrolled.');}
   tx.set(ref,Map<String,dynamic>.of(data)..remove('id'));tx.set(inv,{'internId':data['id']});
  });}else{await ref.update(Map<String,dynamic>.of(data)..remove('id'));}
 }
 Future<void> profile(Record patch) async {
  if(!canWork || admin){throw StateError('An active intern profile is required.');}
  const allowed={'name','university','skills','phone','bio','photo'};
  if(patch.keys.any((k)=>!allowed.contains(k))){throw StateError('Protected profile field.');}
  if(demo){final i=interns.indexWhere((r)=>r['id']==internId);interns[i]={...interns[i],...patch};await persist();}
  else{await db.collection('interns').doc(internId).update(patch);}
 }
 Future<void> saveTask(Record data,{bool create=false}) async {
  needAdmin();
  if(person(str(data,'internId'))['active']!=true){throw StateError('Select an active intern.');}
  if(requiredText(str(data,'title'),120,min:3)!=null||requiredText(str(data,'description'),5000,min:10)!=null||!priorities.contains(data['priority'])||str(data,'reference').length>1000||!validLink(str(data,'reference')) || numOf(data,'dueMs')<=DateTime.now().millisecondsSinceEpoch){throw StateError('Choose a future deadline and valid HTTPS reference.');}
  if(!create && !actionable(task(str(data,'id')))){throw StateError('This task is locked for review or already approved.');}
  if(demo){if(create){tasks.add(data);}else{final i=tasks.indexWhere((x)=>x['id']==data['id']);tasks[i]={...tasks[i],...data};}await persist();}
  else{final ref=db.collection('tasks').doc(data['id'] as String);if(create){await ref.set({...(Map<String,dynamic>.of(data)..remove('id')),'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});}else{await ref.update({...(Map<String,dynamic>.of(data)..remove('id')),'updatedAt':FieldValue.serverTimestamp()});}}
 }
 Future<void> archiveTask(String id,bool value)async{needAdmin();if(demo){task(id)['archived']=value;await persist();}else{await db.collection('tasks').doc(id).update({'archived':value,'updatedAt':FieldValue.serverTimestamp()});}}
 Future<void> startTask(String id)async{
  if(!canWork || admin){throw StateError('An active intern account is required.');}
  if(demo){final t=task(id);if(t['internId']!=internId || t['status']!='Assigned'||t['archived']==true){throw StateError('Task is no longer available to start.');}t['status']='In Progress';await persist();return;}
  await db.runTransaction((tx)async{final ref=db.collection('tasks').doc(id);final snap=await tx.get(ref);final t=snap.data()!;if(t['internId']!=internId || t['status']!='Assigned'||t['archived']==true){throw StateError('Task is no longer available to start.');}tx.update(ref,{'status':'In Progress','updatedAt':FieldValue.serverTimestamp()});});
 }
 Future<void> submit(String id,String github,String demoLink,String notes)async{
  if(!canWork || admin){throw StateError('An active intern account is required.');}
  if(github.length>1000||demoLink.length>1000||!validLink(github)||github.isEmpty||!validLink(demoLink)||requiredText(notes,3000,min:10)!=null){throw StateError('Add a HTTPS work link and notes of at least 10 characters.');}
  final sid=_uuid.v4();
  Record submission(Record t)=>{'taskId':id,'internId':internId,'attempt':numOf(t,'attempt')+1,'workUrl':github.trim(),'demoUrl':demoLink.trim(),'notes':notes.trim(),'feedback':'','score':null,'review':'Pending'};
  String state(Record t)=>t['status']=='Revision Required'?'Resubmitted':'Submitted';
  if(demo){final t=task(id);if(t['internId']!=internId||!actionable(t)){throw StateError('This task already has a submission waiting for review.');}submissions.add({'id':sid,...submission(t),'submittedMs':DateTime.now().millisecondsSinceEpoch});t.addAll({'status':state(t),'attempt':numOf(t,'attempt')+1,'latestId':sid,'feedback':'','score':null});await persist();return;}
  await db.runTransaction((tx)async{
   final ref=db.collection('tasks').doc(id);final snap=await tx.get(ref);final t=snap.data()!;
   if(t['internId']!=internId||!actionable(t)){throw StateError('Task changed. Refresh before submitting again.');}
   tx.set(db.collection('submissions').doc(sid),{...submission(t),'submittedAt':FieldValue.serverTimestamp()});
   tx.update(ref,{'status':state(t),'attempt':numOf(t,'attempt')+1,'latestId':sid,'feedback':'','score':null,'updatedAt':FieldValue.serverTimestamp()});
  });
 }
 Future<void> review(String id,bool approve,String feedback,int? score)async{
  needAdmin();
  if(requiredText(feedback,1500,min:3)!=null || (approve&&(score==null||score<0||score>100))){throw StateError('Add feedback and a score from 0 to 100 when approving.');}
  final stage=approve?'Approved':'Revision Required';
  if(demo){final t=task(id);if(!pendingReview(t)||t['archived']==true){throw StateError('This submission has already been reviewed.');}t.addAll({'status':stage,'feedback':feedback.trim(),'score':approve?score:null});final s=submissions.firstWhere((s)=>s['id']==t['latestId']);s.addAll({'review':stage,'feedback':feedback.trim(),'score':approve?score:null});await persist();return;}
  await db.runTransaction((tx)async{
   final ref=db.collection('tasks').doc(id);final snap=await tx.get(ref);final t=snap.data()!;
   if(!pendingReview(t)||t['archived']==true){throw StateError('This submission has already been reviewed.');}
   tx.update(ref,{'status':stage,'feedback':feedback.trim(),'score':approve?score:null,'updatedAt':FieldValue.serverTimestamp()});
   tx.update(db.collection('submissions').doc(t['latestId'] as String),{'review':stage,'feedback':feedback.trim(),'score':approve?score:null,'reviewedAt':FieldValue.serverTimestamp()});
  });
 }
 List<Record> rows(dynamic data)=>data is List?data.map((x)=>Map<String,dynamic>.from(x as Map)).toList():[];
 Future<void> requestEnrollment(String name,String university,String skills)async{
  if(!verified||demo||account!=null){throw StateError('Verify your email and use an account without an existing enrollment.');}
  if(requiredText(name,80,min:2)!=null||requiredText(university,120,min:2)!=null||skills.length>1000){throw StateError('Check your enrollment details.');}
  final u=user!;final now=DateTime.now();
  final p=internRecord(id:u.uid,name:name.trim(),email:u.email!.toLowerCase(),department:'Unassigned',supervisor:'Unassigned',startMs:now.millisecondsSinceEpoch,endMs:now.add(const Duration(days:90)).millisecondsSinceEpoch)..addAll({'university':university.trim(),'skills':skills.trim(),'active':false,'accountUid':u.uid,'programId':'','enrollmentStatus':'Pending'});
  await db.runTransaction((tx)async{final ur=db.collection('users').doc(u.uid);if((await tx.get(ur)).exists){throw StateError('This account already has a workspace role.');}final invite=await tx.get(db.collection('invitations').doc(u.email!.toLowerCase()));if(invite.exists){throw StateError('An enrollment already exists for this email. Use Connect my internship instead.');}tx.set(db.collection('interns').doc(u.uid),Map<String,dynamic>.of(p)..remove('id'));tx.set(ur,{'role':'intern','internId':u.uid,'active':true});});
  await bind(auth.currentUser);
 }
 Future<void> saveEntity(String collection,Record data,{bool create=false})async{
  needAdmin();
  if(!['programs','announcements','stipends'].contains(collection)){throw StateError('Unsupported module.');}
  if(collection=='programs'&&(requiredText(str(data,'name'),100,min:3)!=null||numOf(data,'capacity')<1||numOf(data,'endMs')<numOf(data,'startMs'))){throw StateError('Check program name, capacity and dates.');}
  if(collection=='announcements'&&(requiredText(str(data,'title'),120,min:3)!=null||requiredText(str(data,'body'),3000,min:5)!=null)){throw StateError('Check the announcement title and message.');}
  if(collection=='stipends'&&(numOf(data,'amountMinor')<1||numOf(data,'amountMinor')>1000000000||!['PKR','USD','GBP','EUR'].contains(data['currency'])||!['Pending','Paid'].contains(data['status']))){throw StateError('Check stipend amount, currency and status.');}
  final list=switch(collection){'programs'=>programs,'announcements'=>announcements,_=>stipends};
  if(demo){if(create){list.add(data);}else{final i=list.indexWhere((r)=>r['id']==data['id']);if(i<0){throw StateError('Record not found.');}list[i]=data;}await persist();return;}
  final ref=db.collection(collection).doc(str(data,'id'));final cloud=Map<String,dynamic>.of(data)..remove('id')..remove('createdMs');
  if(create){await ref.set({...cloud,'createdAt':FieldValue.serverTimestamp()});}else{await ref.update(cloud);}
 }
 Future<void> saveWorkspace(String name,String description)async{needAdmin();if(requiredText(name,80,min:2)!=null||description.length>300){throw StateError('Check workspace details.');}if(demo){workspace={'name':name.trim(),'description':description.trim()};await persist();}else{await db.collection('settings').doc('workspace').set({'name':name.trim(),'description':description.trim()});}}
 Future<void> clock(bool checkout)async{
  if(admin||!canWork){throw StateError('An active intern account is required.');}
  final now=DateTime.now();final business=now.toUtc().add(const Duration(hours:5));final day='${business.year}-${business.month.toString().padLeft(2,'0')}-${business.day.toString().padLeft(2,'0')}';final id='${internId}_$day';
  if(demo){final i=attendance.indexWhere((r)=>r['id']==id);if(checkout){if(i<0||attendance[i]['outMs']!=null){throw StateError('No open check-in today.');}attendance[i]['outMs']=now.millisecondsSinceEpoch;}else{if(i>=0){throw StateError('You have already checked in today.');}attendance.add({'id':id,'internId':internId,'day':day,'inMs':now.millisecondsSinceEpoch,'outMs':null});}await persist();return;}
  await db.runTransaction((tx)async{final ref=db.collection('attendance').doc(id);final snap=await tx.get(ref);if(checkout){if(!snap.exists||snap.data()!['checkedOutAt']!=null){throw StateError('No open check-in today.');}tx.update(ref,{'checkedOutAt':FieldValue.serverTimestamp()});}else{if(snap.exists){throw StateError('You have already checked in today.');}tx.set(ref,{'internId':internId,'day':day,'checkedInAt':FieldValue.serverTimestamp(),'checkedOutAt':null});}});
 }
 Future<void> requestLeave(int fromMs,int toMs,String reason)async{
  if(admin||!canWork){throw StateError('An active intern account is required.');}
  if(fromMs>toMs||toMs-fromMs>90*86400000||requiredText(reason,1500,min:10)!=null){throw StateError('Choose a valid period (up to 90 days) and explain your request.');}
  if(leaves.any((r)=>r['internId']==internId&&['Pending','Approved'].contains(r['status'])&&numOf(r,'fromMs')<=toMs&&numOf(r,'toMs')>=fromMs)){throw StateError('An open or approved request overlaps these dates.');}
  final Record data={'id':newId(),'internId':internId,'fromMs':fromMs,'toMs':toMs,'reason':reason.trim(),'status':'Pending','feedback':''};
  if(demo){leaves.add(data);await persist();}else{await db.collection('leaves').doc(str(data,'id')).set({...(Map<String,dynamic>.of(data)..remove('id')),'createdAt':FieldValue.serverTimestamp()});}
 }
 Future<void> decideLeave(String id,String status,String feedback)async{
  needAdmin();if(!['Approved','Rejected'].contains(status)||requiredText(feedback,1500,min:3)!=null){throw StateError('Add a review decision and feedback.');}
  if(demo){final r=leaves.firstWhere((r)=>r['id']==id);if(r['status']!='Pending'){throw StateError('This request has already been reviewed.');}r.addAll({'status':status,'feedback':feedback.trim()});await persist();return;}
  await db.runTransaction((tx)async{final ref=db.collection('leaves').doc(id);final r=await tx.get(ref);if(r.data()?['status']!='Pending'){throw StateError('This request has already been reviewed.');}tx.update(ref,{'status':status,'feedback':feedback.trim()});});
 }

 Future<void> applyProgram(String programId,String motivation)async{
  if(admin||account?['active']!=true||!verified||mine==null){throw StateError('A verified intern profile is required.');}
  if(str(mine!,'programId').isNotEmpty){throw StateError('You already have an internship program. Contact your administrator for changes.');}
  if(requiredText(motivation,1500,min:10)!=null){throw StateError('Add at least 10 characters explaining your interest.');}
  final id='${internId}_$programId';
  if(demo){if(applications.any((r)=>r['id']==id)){throw StateError('You already applied to this program.');}final p=programs.firstWhere((p)=>p['id']==programId);if(p['active']!=true){throw StateError('This program is closed.');}applications.add(<String,dynamic>{'id':id,'internId':internId,'programId':programId,'motivation':motivation.trim(),'status':'Pending','feedback':'','createdMs':DateTime.now().millisecondsSinceEpoch});await persist();return;}
  await db.runTransaction((tx)async{final ref=db.collection('applications').doc(id);final previous=await tx.get(ref);final p=await tx.get(db.collection('programs').doc(programId));final i=await tx.get(db.collection('interns').doc(internId));if(previous.exists){throw StateError('You already applied to this program.');}if(p.data()?['active']!=true||str(i.data()??{},'programId').isNotEmpty){throw StateError('The program or your enrollment has changed. Refresh and try again.');}tx.set(ref,{'internId':internId,'programId':programId,'motivation':motivation.trim(),'status':'Pending','feedback':'','createdAt':FieldValue.serverTimestamp()});});
 }
 Future<void> decideApplication(String id,bool approve,String feedback)async{
  needAdmin();if(requiredText(feedback,1500,min:3)!=null){throw StateError('Add a decision note.');}
  Record placement(Record i,Record p,String programId)=>{...i,'programId':programId,'department':p['department'],'supervisor':p['supervisor'],'startMs':p['startMs'],'endMs':p['endMs'],'active':true,'enrollmentStatus':'Active'};
  if(demo){final a=applications.firstWhere((r)=>r['id']==id);if(a['status']!='Pending'){throw StateError('This application has already been reviewed.');}if(approve){final i=person(str(a,'internId'));final p=programs.firstWhere((p)=>p['id']==a['programId']);if(str(i,'programId').isNotEmpty||p['active']!=true){throw StateError('This enrollment is not available.');}await saveIntern(placement(i,p,str(a,'programId')));}a.addAll({'status':approve?'Accepted':'Rejected','feedback':feedback.trim()});await persist();return;}
  await db.runTransaction((tx)async{final ar=db.collection('applications').doc(id);final snap=await tx.get(ar);final a=snap.data();if(a==null||a['status']!='Pending'){throw StateError('This application has already been reviewed.');}final ir=db.collection('interns').doc(a['internId'] as String);final i=await tx.get(ir);final p=await tx.get(db.collection('programs').doc(a['programId'] as String));if(approve){if(i.data()==null||p.data()?['active']!=true||str(i.data()!,'programId').isNotEmpty){throw StateError('This intern already has a program, or the program is closed.');}final used=interns.where((r)=>r['active']==true&&r['programId']==a['programId']).length;if(used>=numOf(p.data()!,'capacity')){throw StateError('Program capacity has been reached.');}tx.update(ir,Map<String,dynamic>.of(placement(i.data()!,p.data()!,a['programId'] as String))..remove('id'));}tx.update(ar,{'status':approve?'Accepted':'Rejected','feedback':feedback.trim(),'reviewedAt':FieldValue.serverTimestamp()});});
 }
 String newId()=>_uuid.v4();
 @override void dispose(){_disposed=true;++_generation;unawaited(_auth?.cancel());unawaited(_account?.cancel());clearData();super.dispose();}
}
String friendly(Object e){
 if(e is FirebaseAuthException){return switch(e.code){'email-already-in-use'=>'An account already exists. Sign in or reset your password.','invalid-credential'=>'Email or password is incorrect.','weak-password'=>'Choose a stronger password.','too-many-requests'=>'Too many attempts. Please try again later.','network-request-failed'=>'Check your internet connection and try again.',_=>e.message??'Authentication failed.'};}
 if(e is FirebaseException){return switch(e.code){'permission-denied'=>'Access denied. Check email verification, enrollment and deployed Firestore rules.','unavailable'=>'Connection unavailable. Try again when online.',_=>e.message??'The request failed.'};}
 if(e is StateError){return e.message.toString();}
 return 'Could not complete this action. Please retry.';
}
