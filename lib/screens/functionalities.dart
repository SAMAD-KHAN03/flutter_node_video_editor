import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:govideoeditor/backend/dart/upload_video.dart';

class Functionalities extends ConsumerStatefulWidget {
  const Functionalities({super.key});

  @override
  ConsumerState<Functionalities> createState() => _Functionalities();
}

class _Functionalities extends ConsumerState<Functionalities> {
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  List<bool> _isOpen = [false]; // Ensure correct length

  @override
  Widget build(BuildContext context) {
    final resizefunc = ref.watch(uploadProvider.notifier);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              _isOpen[panelIndex] = isExpanded; // Toggle state
              // print("the value is ${_isOpen[panelIndex]}");
            });
          },
          children: [
            ExpansionPanel(
              isExpanded: _isOpen[0],
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text("Resize Video"));
              },
              body: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Width",
                            border: OutlineInputBorder(), // Rectangular border
                          ),
                          keyboardType: TextInputType.number,
                          controller: widthController,
                        ),
                      ),
                      const Padding(
                        padding: const EdgeInsets.symmetric(
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
                          decoration: InputDecoration(
                            labelText: "Height",
                            border: OutlineInputBorder(), // Rectangular border
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                          child: TextButton(
                              onPressed: () async {
                                await resizefunc.resizeVideo(
                                    heightController.text,
                                    widthController.text,
                                    ref);
                              },
                              child: Text("go")))
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
