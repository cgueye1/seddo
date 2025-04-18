// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 5,
    this.style = const TextStyle(fontSize: 16),
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  late TextPainter _textPainter;
  int? _numLines;
  bool _calculatedLines = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTextLines();
  }

  void _calculateTextLines() {
    // S'assurer que le widget est monté et que le contexte est disponible
    if (!mounted) return;

    _textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 100,
    );

    // Utiliser MediaQuery de façon sécurisée dans didChangeDependencies
    final width = MediaQuery.of(context).size.width - 32;
    _textPainter.layout(maxWidth: width);
    _numLines = _textPainter.computeLineMetrics().length;
    _calculatedLines = true;

    // Force un rebuild si nécessaire
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si les lignes ont été calculées
    final hasMoreLines = _calculatedLines && (_numLines ?? 0) > widget.maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Le texte principal
            Text(
              widget.text,
              style: widget.style,
              maxLines: _expanded ? null : widget.maxLines + 1,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.clip,
            ),

            // Effet d'opacité sur la dernière ligne visible si non expandé
            if (!_expanded && hasMoreLines)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Bouton "Voir plus" ou "Voir moins"
        if (hasMoreLines)
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Text(
              _expanded ? 'Voir moins' : 'Voir plus',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
