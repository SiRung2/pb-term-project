import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Term To-Do',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _textCtrl = TextEditingController();

  Future<void> _loginWithGoogle() async {
    // 에뮬레이터에 구글 로그인 환경이 없으면 실패할 수 있음(아래 "막히는 경우" 참고)
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // 사용자가 취소

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    setState(() {});
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    setState(() {});
  }

  Future<void> _addTodo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    await _db.collection('todos').add({
      'text': text,
      'done': false,
      'ownerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _textCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          if (user == null)
            TextButton(
              onPressed: _loginWithGoogle,
              child: const Text('Google 로그인'),
            )
          else
            TextButton(
              onPressed: _logout,
              child: const Text('로그아웃'),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('로그인 후 사용 가능합니다'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textCtrl,
                          decoration: const InputDecoration(
                            hintText: '할 일을 입력',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTodo,
                        child: const Text('추가'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection('todos')
                        .where('ownerUid', isEqualTo: user.uid)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('에러: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snap.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final data = d.data() as Map<String, dynamic>;
                          final text = (data['text'] ?? '') as String;
                          final done = (data['done'] ?? false) as bool;

                          return ListTile(
                            leading: Checkbox(
                              value: done,
                              onChanged: (_) => d.reference.update({'done': !done}),
                            ),
                            title: Text(
                              text,
                              style: TextStyle(
                                decoration: done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => d.reference.delete(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
