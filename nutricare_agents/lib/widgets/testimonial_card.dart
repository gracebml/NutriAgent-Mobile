import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A styled testimonial card widget that displays a quote and its author.
///
/// This widget is primarily used on the login screen to display testimonials
/// from users of the application.
class TestimonialCard extends StatelessWidget {
  final String quote;
  final String author;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  
  /// Creates a testimonial card with a quote and author information.
  ///
  /// [quote] The testimonial text to display.
  /// [author] The name and title/description of the person giving the testimonial.
  /// [backgroundColor] Optional background color of the card.
  /// [textColor] Optional text color for the quote.
  /// [borderColor] Optional border color for the left edge accent.
  const TestimonialCard({
    Key? key,
    required this.quote,
    required this.author,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.colorScheme.surface;
    final defaultTextColor = theme.colorScheme.onSurface;
    final defaultBorderColor = theme.colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: borderColor ?? defaultBorderColor,
            width: 4.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dấu ngoặc kép trang trí
            Text(
              '"',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: (textColor ?? defaultTextColor).withOpacity(0.3),
                height: 1,
              ),
            ),
            
            // Nội dung lời chứng thực
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
              child: Text(
                quote,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: textColor ?? defaultTextColor,
                ),
              ),
            ),
            
            // Tên tác giả
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '- $author',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: (textColor ?? defaultTextColor).withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}