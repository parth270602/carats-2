import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/rewards_page.dart';
 
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color? backgroundColor;

   CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: widget.centerTitle,
      actions:  [
          IconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const RewardsPage())
                );
            },
            icon:  const Icon(Icons.wallet_giftcard),
            color: Color.fromARGB(255, 250, 214, 8),
            
          ),
        ],
      backgroundColor: widget.backgroundColor ?? const Color(0xFFC0392B),
    );
  }
}
