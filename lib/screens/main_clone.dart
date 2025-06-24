import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/models/height_width.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ion.dart';

class MainClone extends StatefulWidget {
  const MainClone({super.key});

  @override
  State<MainClone> createState() => _MainCloneState();
}

outlinedButton(Iconify icon, double containerSize, double padding) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8)),
      child: icon,
    ),
  );
}

class _MainCloneState extends State<MainClone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF377D9A),
        actions: [
          outlinedButton(Iconify(Ic.arrow_back), 28, 16),
          Spacer(),
          Text("DashBoard"),
          Spacer(),
          outlinedButton(Iconify(Ic.outline_person), 28, 16)
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  const Color(0xFF397E9B),
                  const Color(0xFF1F6381).withValues(alpha: .8),
                  const Color(0xFF142B35),
                ])),
          ),
          Positioned(
            top: HeightWidth.height! * 0.05,
            left: HeightWidth.width! * 0.1,
            right: HeightWidth.width! * 0.1,
            child: Container(
              child: Center(
                  child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Iconify(
                        Ep.upload,
                        size: 24,
                      ))),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
            ),
          ),
          Center(
              child: SizedBox(
                  width: 10,
                  height: 10,
                  child: const CircularProgressIndicator()))
        ],
      ),
    );
  }
}
