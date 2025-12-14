import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatelessWidget {
  final String content;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool bold;
  final FontWeight? fontWeight;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;

  const MyText(
      this.content, {
        super.key,
        this.fontSize,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.bold = false,
        this.fontWeight,
        this.height,
        this.letterSpacing,
        this.decoration,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.inter(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? (bold ? FontWeight.bold : FontWeight.w400),
        color: color ?? CupertinoColors.label,
        height: height ?? 1.25,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}