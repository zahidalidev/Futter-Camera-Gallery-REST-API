import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text('Camera, Gallery, Crop, Compress, Constraint, API',
          style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Icon is clicked')));
              print("clicked");
            })
      ],
    );
  }
}
