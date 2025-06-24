// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/models/height_width.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/backend/dart/upload_video.dart';

class Functionalities extends ConsumerStatefulWidget {
  const Functionalities({super.key});

  @override
  ConsumerState<Functionalities> createState() => _Functionalities();
}

List<String> encoding = [
  "MP3",
  "WAV",
  "AAC",
  "FLAC",
  "OGG",
  "ALAC",
  "WMA",
  "AIFF",
  "M4A",
  "OPUS",
  "AMR"
];
late List<DropdownMenuEntry<String>> dropdownmenu;
List<DropdownMenuEntry<String>> dropdown() {
  dropdownmenu = []; // Initialize the list

  for (int i = 0; i < encoding.length; i++) {
    dropdownmenu.add(
      DropdownMenuEntry(value: encoding[i], label: encoding[i]),
    );
  }

  return dropdownmenu;
}

class _Functionalities extends ConsumerState<Functionalities> {
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    heightController.dispose();
    widthController.dispose();
  }

  final List<bool> _isOpen = [false, false]; // Ensure correct length
  @override
  Widget build(BuildContext context) {
    final resizefunc = ref.watch(uploadProvider.notifier);
    return Positioned(
      left: HeightWidth.width! * 0.05,
      right: HeightWidth.width! * 0.05,
      top: HeightWidth.height! * 0.3 + HeightWidth.height! * 0.02 + 50,
      child: Container(
        width: HeightWidth.width! * 0.8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpansionPanelList(
              dividerColor: Colors.black,
              // materialGapSize: 12,
              elevation: 12,
              expansionCallback: (panelIndex, isExpanded) {
                setState(() {
                  _isOpen[panelIndex] = isExpanded; // Toggle state
                  print("the value is ${_isOpen[panelIndex]}");
                });
              },
              children: [
                ExpansionPanel(
                  backgroundColor: Color.fromARGB(183, 199, 248, 255),
                  isExpanded: _isOpen[0],
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text("Resize Video"),
                    );
                  },
                  body: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Width",
                              border:
                                  OutlineInputBorder(), // Rectangular border
                            ),
                            keyboardType: TextInputType.number,
                            controller: widthController,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10), // Space between fields
                          child: Text(
                            "X",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            decoration: const InputDecoration(
                              labelText: "Height",
                              border:
                                  OutlineInputBorder(), // Rectangular border
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () async {
                              await resizefunc.resizeVideo(
                                  heightController.text,
                                  widthController.text,
                                  ref);
                              heightController.clear();
                              widthController.clear();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //Expansion panel number 2
                ExpansionPanel(
                  backgroundColor: Color.fromARGB(183, 199, 248, 255),
                  isExpanded: _isOpen[1],
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text("Extract Audio"),
                    );
                  },
                  body: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Output in'),
                        Spacer(),

                        Text(
                          "->",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        DropdownMenu<String>(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: Colors.black,
                          ),
                          menuHeight: 100,
                          dropdownMenuEntries: dropdown(),
                          hintText: "Select format",
                        ),
                        // Expanded(
                        //   child: IconButton(
                        //     icon: Icon(Icons.check),
                        //     onPressed: () async {
                        //       await resizefunc.resizeVideo(
                        //           heightController.text,
                        //           widthController.text,
                        //           ref);
                        //     },
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
