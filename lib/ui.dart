import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
const charcoal=Color(0xff101e36), gold=Color(0xffd8ac25);
const ocean=Color(0xff3977ee), mint=Color(0xff17a58b);
class Brand extends StatelessWidget{
 const Brand({super.key,this.large=false});final bool large;
 @override Widget build(BuildContext context)=>Row(children:[Container(width:large?58:38,height:large?58:38,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12)),clipBehavior:Clip.antiAlias,child:Image.asset('assets/logo.png',fit:BoxFit.cover)),const SizedBox(width:10),const Expanded(child:Text('CareerBase',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w800,letterSpacing:-.5)))]);
}
class Panel extends StatelessWidget{
 const Panel({super.key,required this.child,this.padding=20});final Widget child;final double padding;
 @override Widget build(BuildContext context)=>Material(color:Theme.of(context).colorScheme.surface,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24),side:BorderSide(color:Theme.of(context).dividerColor.withValues(alpha:.14))),clipBehavior:Clip.antiAlias,child:Padding(padding:EdgeInsets.all(padding),child:child));
}
class Heading extends StatelessWidget{
 const Heading(this.title,this.subtitle,{super.key,this.action});final String title,subtitle;final Widget? action;
 @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800,letterSpacing:-.7)),const SizedBox(height:8),Text(subtitle,style:Theme.of(context).textTheme.bodyMedium),if(action!=null)...[const SizedBox(height:16),action!]]));
}
class Tiles extends StatelessWidget{
 const Tiles({super.key,required this.children,this.minimum=220});final List<Widget> children;final double minimum;
 @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){final count=((c.maxWidth+14)/(minimum+14)).floor().clamp(1,4);final width=(c.maxWidth-14*(count-1))/count;return Wrap(spacing:14,runSpacing:14,children:children.map((x)=>SizedBox(width:width,child:x)).toList());});
}
class CareerBadge extends StatelessWidget{
 const CareerBadge(this.label,{super.key,this.color});final String label;final Color? color;
 @override Widget build(BuildContext context){final c=color??statusColor(label);return Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:6),decoration:BoxDecoration(color:c.withValues(alpha:.13),borderRadius:BorderRadius.circular(9)),child:Text(label,style:TextStyle(color:Theme.of(context).brightness==Brightness.dark?Color.lerp(c,Colors.white,.35):c,fontSize:12,fontWeight:FontWeight.w700)));}
}
Color statusColor(String s)=>switch(s){'Approved'||'Active'=>const Color(0xff167b56),'Submitted'||'Resubmitted'=>const Color(0xff3067b5),'Revision Required'||'Overdue'||'High'=>const Color(0xffb95825),'In Progress'=>const Color(0xff7961ac),_=>const Color(0xff687480)};
class EmptyPanel extends StatelessWidget{
 const EmptyPanel(this.title,this.message,{super.key,this.icon=Icons.inbox_outlined});final String title,message;final IconData icon;
 @override Widget build(BuildContext context)=>Panel(child:Column(children:[Icon(icon,size:40,color:gold),const SizedBox(height:14),Text(title,style:Theme.of(context).textTheme.titleMedium,textAlign:TextAlign.center),const SizedBox(height:8),Text(message,textAlign:TextAlign.center)]));
}
class PersonAvatar extends StatelessWidget{
 const PersonAvatar(this.person,{super.key,this.radius=26});final Record person;final double radius;
 @override Widget build(BuildContext context){MemoryImage? image;try{if(str(person,'photo').isNotEmpty){image=MemoryImage(base64Decode(str(person,'photo')));}}catch(_){image=null;}return CircleAvatar(radius:radius,backgroundColor:gold.withValues(alpha:.18),backgroundImage:image,child:image==null?Text(str(person,'name').isEmpty?'C':str(person,'name').substring(0,1).toUpperCase(),style:const TextStyle(fontWeight:FontWeight.w800,color:charcoal)):null);}
}
DropdownButtonFormField<String> selectField({required String label,required String value,required List<String> options,required ValueChanged<String?> onChanged})=>DropdownButtonFormField<String>(initialValue:options.contains(value)?value:null,isExpanded:true,decoration:InputDecoration(labelText:label),items:options.map((v)=>DropdownMenuItem(value:v,child:Text(v.contains(' | ')?v.split(' | ').first:v,maxLines:1,overflow:TextOverflow.ellipsis))).toList(),onChanged:onChanged);
Future<void> openLink(BuildContext context,String link)async{
 if(!validLink(link)||link.trim().isEmpty){return;}
 try{final ok=await launchUrl(Uri.parse(link.trim()),mode:LaunchMode.externalApplication);if(!ok&&context.mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to open this link.')));}}catch(_){if(context.mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to open this link.')));}}
}

class SectionTitle extends StatelessWidget {
 const SectionTitle(this.title,{super.key,this.caption,this.action});final String title;final String? caption;final Widget? action;
 @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),if(caption!=null)...[const SizedBox(height:5),Text(caption!,style:Theme.of(context).textTheme.bodySmall)],if(action!=null)...[const SizedBox(height:10),action!]]));
}
class ProgressRow extends StatelessWidget {
 const ProgressRow(this.title,this.value,this.detail,{super.key,this.color=gold});final String title,detail;final double value;final Color color;
 @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Wrap(spacing:12,runSpacing:4,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w600)),Text(detail,style:Theme.of(context).textTheme.bodySmall)]),const SizedBox(height:8),LinearProgressIndicator(value:value.clamp(0,1).toDouble(),minHeight:7,color:color,backgroundColor:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(6))]));
}
String initials(String name)=>name.trim().split(RegExp(r'\s+')).take(2).where((p)=>p.isNotEmpty).map((p)=>p[0]).join().toUpperCase();

class WorkspaceHero extends StatelessWidget {
 const WorkspaceHero({super.key,required this.eyebrow,required this.title,required this.description,required this.actions});
 final String eyebrow,title,description; final List<Widget> actions;
 @override Widget build(BuildContext context)=>Container(
  width:double.infinity,padding:const EdgeInsets.all(26),
  decoration:BoxDecoration(gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff14284d),Color(0xff214a76)]),borderRadius:BorderRadius.circular(28)),
  child:Theme(data:Theme.of(context).copyWith(colorScheme:Theme.of(context).colorScheme.copyWith(primary:gold,onPrimary:charcoal)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Wrap(spacing:8,runSpacing:6,children:[const Icon(Icons.auto_awesome,size:16,color:gold),Text(eyebrow,style:const TextStyle(color:Color(0xffe9c861),fontSize:12,fontWeight:FontWeight.w700,letterSpacing:1))]),
   const SizedBox(height:18),Text(title,style:Theme.of(context).textTheme.headlineMedium?.copyWith(color:Colors.white,fontWeight:FontWeight.w800,height:1.15)),
   const SizedBox(height:12),Text(description,style:const TextStyle(color:Color(0xffd3dfef),height:1.6)),
   if(actions.isNotEmpty)...[const SizedBox(height:22),Wrap(spacing:10,runSpacing:10,children:actions)],
  ])));
}
class IdentityCard extends StatelessWidget {
 const IdentityCard(this.person,{super.key,required this.demo});final Record person;final bool demo;
 @override Widget build(BuildContext context){
 final linked=str(person,'accountUid').isNotEmpty;
 return Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Row(crossAxisAlignment:CrossAxisAlignment.start,children:[PersonAvatar(person,radius:30),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(str(person,'name'),style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:5),Text(str(person,'email'),style:Theme.of(context).textTheme.bodySmall)]))]),
  const SizedBox(height:20),Wrap(spacing:8,runSpacing:8,children:[CareerBadge(demo?'SAMPLE IDENTITY':linked?'ACCOUNT CONNECTED':'AWAITING SIGNUP'),CareerBadge(person['enrollmentStatus']=='Pending'?'Pending approval':person['active']==true?'Active':'Archived')]),
  const Divider(height:32),const Text('ENROLLMENT ID',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.2)),const SizedBox(height:7),SelectableText(enrollmentId(person),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w600)),
  const SizedBox(height:18),Text('Department: ${str(person,'department')}'),const SizedBox(height:6),Text('Supervisor: ${str(person,'supervisor')}'),
  const SizedBox(height:14),Text(demo?'Local sample account. No real Firebase identity is verified in demo mode.':linked?'Linked to a Firebase Authentication account through the verified email enrollment flow.':'This is an invitation record. The intern must sign up with this exact email, verify it and connect the enrollment.',style:Theme.of(context).textTheme.bodySmall?.copyWith(height:1.6)),
  if(!demo&&linked)...[const SizedBox(height:12),const Text('ACCOUNT UID',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700)),const SizedBox(height:5),SelectableText(str(person,'accountUid'),style:const TextStyle(fontSize:12))],
 ]));
 }
}
class WorkspaceStat extends StatelessWidget {
 const WorkspaceStat(this.label,this.value,this.icon,this.tint,{super.key});final String label,value;final IconData icon;final Color tint;
 @override Widget build(BuildContext context)=>Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:tint.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:tint,size:22)),const SizedBox(height:20),Text(value,style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:6),Text(label,style:Theme.of(context).textTheme.bodyMedium)]));
}

class AuthScaffold extends StatelessWidget {
 const AuthScaffold({super.key,required this.child});final Widget child;
 @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:LayoutBuilder(builder:(context,c){
 final wide=c.maxWidth>=960;
 final intro=WorkspaceHero(eyebrow:'MANAGE INTERNSHIPS. BUILD CAREERS.',title:'Where potential\nbecomes progress.',description:'A shared workspace for your people, programs and meaningful work. Clear assignments. Thoughtful feedback. One connected internship journey.',actions:const []);
 return SingleChildScrollView(padding:EdgeInsets.all(wide?48:20),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1180),child:wide?Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Brand(large:true),const SizedBox(height:32),intro,const SizedBox(height:24),const Text('CONNECTED ACCOUNTS  /  REVIEWED WORK  /  REAL PROGRESS',style:TextStyle(fontSize:11,letterSpacing:1))])),const SizedBox(width:56),Expanded(child:Padding(padding:const EdgeInsets.only(top:20),child:Panel(padding:30,child:child))) ]):Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Brand(large:true),const SizedBox(height:28),intro,const SizedBox(height:24),Panel(child:child)]))));
 })));
}
