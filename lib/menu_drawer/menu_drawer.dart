import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  final String uid;

  const AppDrawer({super.key, required this.uid});

  void _copyUid(BuildContext context) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('UID скопирован: $uid')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
      DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Text("Your UID. Tap to copy"),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _copyUid(context),
                  child: Text(
                    uid,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
         ),
        ],
      ),
    );
  }
}
