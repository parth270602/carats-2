import 'package:flutter/material.dart';

class CommentsWidget extends StatefulWidget {
  final String comments;
  const CommentsWidget({required this.comments, Key?key}):super(key:key);

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  bool _isExpanded=false;
  @override
  Widget build(BuildContext context) {
    String displayText=widget.comments.length > 30
    ? _isExpanded
      ? widget.comments
      :'${widget.comments.substring(0,30)}...'
    :widget.comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayText),
         if (widget.comments.length > 30)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              
              _isExpanded ? 'Read less' : 'Read more',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}