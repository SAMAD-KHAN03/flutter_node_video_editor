import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/backend/dart/fetch_data.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';
import 'package:flutter_node_video_editor/providers/video_file_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const IP = "192.168.1.95";
const PORT = "3000";

class Videos extends ConsumerStatefulWidget {
  const Videos({super.key});

  @override
  ConsumerState<Videos> createState() => _VideosState();
}

class _VideosState extends ConsumerState<Videos> {
  late Future<List<QueryDocumentSnapshot>>? futureVideos;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // futureVideos = fetchVideos(ref);
      // fetchVideos(ref);

      setState(() {}); // Triggers rebuild once future is assigned
    });
  }

  Future<void> fetchVideos(WidgetRef ref) async {
    final response = await http.get(Uri.parse("http://$IP:$PORT/fetchvideos"));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
      ),
      body: Center(
        child: Text("something"),
      ),
    );
  }
}
//  body: futureVideos == null
//           ? const Center(child: CircularProgressIndicator())
//           : FutureBuilder<List<QueryDocumentSnapshot>>(
//               future: futureVideos,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No videos found"));
//                 } else {
//                   final docs = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final doc = docs[index];
//                       final resizeUrl = "";
//                       final createdAt = (doc['createdAt'] as Timestamp?)
//                           ?.toDate()
//                           .toLocal()
//                           .toString();

//                       return ListTile(
//                         title: Text(doc.id),
//                         subtitle: Text(createdAt ?? 'No date'),
//                         leading: FutureBuilder<String>(
//                           future: fetchThumbnail(ref),
//                           builder: (context, snapshot) {
//                             return CircleAvatar(
//                               backgroundImage: snapshot.hasData
//                                   ? NetworkImage(snapshot.data!)
//                                   : const AssetImage('assets/worker2.png')
//                                       as ImageProvider,
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }
//               },
//             )
