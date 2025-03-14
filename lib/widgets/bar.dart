import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "HomeScreen",
              style: TextStyle(fontSize: 20, color: Colors.white),
            )
          ],
        )
      ],
    );
  }
}
