import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/backend/dart/download.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const ip = "192.168.1.97";
const port = "3000";

class Videos extends ConsumerStatefulWidget {
  const Videos({super.key});

  @override
  ConsumerState<Videos> createState() => _VideosState();
}

class _VideosState extends ConsumerState<Videos> {
  late Future<List<Map<String, dynamic>>> futureVideos;
  final Map<String, String> thumbnailurls = {};
  @override
  void initState() {
    super.initState();
    futureVideos = fetchVideos(ref);
    // Future.microtask(() {
    //   // futureVideos = fetchVideos(ref);

    //   setState(() {}); // Triggers rebuild once future is assigned
    // });
  }

  Future<List<Map<String, dynamic>>> fetchVideos(WidgetRef ref) async {
    try {
      final response =
          await http.get(Uri.parse("http://$ip:$port/fetchvideos"));

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch videos: ${response.statusCode}");
      }

      final List<dynamic> nested = jsonDecode(response.body);

      final List<Map<String, dynamic>> flattened = nested
          .expand<Map<String, dynamic>>(
              (e) => List<Map<String, dynamic>>.from(e))
          .toList();

      // Convert timestamps
      for (final item in flattened) {
        final content = Map<String, dynamic>.from(item['content']);
        if (content.containsKey('createdAt')) {
          final ts = content['createdAt'];
          final date = DateTime.fromMillisecondsSinceEpoch(
            ts['_seconds'] * 1000 + (ts['_nanoseconds'] / 1000000).round(),
          );
          content['createdAt'] = date;
        }
        if (item['docId'] == 'thumbnail') {
          thumbnailurls[item['subcollection']] = content['thumbnail'];
          print("pushed ${thumbnailurls[item["subcollection"]]} to array");
        }
        item['content'] = content;
      }

      return flattened;
    } catch (e, st) {
      print("Fetch error: $e");
      print("Stack: $st");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final downlaodprovider = ref.watch(downlaodStateProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF377D9A),
        title: const Text('Videos'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              const Color(0xFF397E9B),
              const Color(0xFF1F6381).withValues(alpha: .8),
              const Color(0xFF142B35),
            ])),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureVideos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No videos found"));
            } else {
              final docs = snapshot.data!;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final content = doc['content'] as Map<String, dynamic>;
                  final docId = doc['docId'];
                  final subcollectionid = doc['subcollection'];
                  // print("the sub coillection is "+subcollectionid);
                  final createdAt =
                      content['createdAt']?.toString() ?? 'Unknown';
                  return ListTile(
                    trailing: InkWell(
                      splashColor: Colors.black,
                      enableFeedback: true,
                      onTap: () async {
                        await downlaodprovider.download(
                            content[docId], subcollectionid);
                      },
                      child: Icon(
                        Icons.download,
                        color: Colors.black,
                      ),
                    ),
                    style: ListTileStyle.list,
                    title: Text(docId),
                    subtitle: Text(
                      'Created: $createdAt',
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: thumbnailurls[subcollectionid] != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(thumbnailurls[subcollectionid]!))
                        : const CircleAvatar(child: Icon(Icons.play_arrow)),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
