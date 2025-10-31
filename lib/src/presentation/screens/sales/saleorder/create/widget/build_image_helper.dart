// lib/src/presentation/screens/sales/saleorder/create/widget/build_image_helper.dart

import 'dart:convert';
import 'package:flutter/material.dart';

class BuildImageHelper {
  /// بناء صورة من base64
  static Widget buildImage(
    dynamic image, {
    double width = 60,
    double height = 60,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 8,
  }) {
    // إذا كانت الصورة null أو false
    if (image == null || image == false) {
      return _buildPlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        icon: Icons.image_not_supported,
        color: Colors.grey,
      );
    }

    // إذا كانت الصورة string
    if (image is String && image.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            base64Decode(image),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(
                width: width,
                height: height,
                borderRadius: borderRadius,
                icon: Icons.broken_image,
                color: Colors.grey,
              );
            },
          ),
        );
      } catch (e) {
        return _buildPlaceholder(
          width: width,
          height: height,
          borderRadius: borderRadius,
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    }

    // صورة غير صالحة
    return _buildPlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
      icon: Icons.image,
      color: Colors.grey,
    );
  }

  /// بناء placeholder للصورة
  static Widget _buildPlaceholder({
    required double width,
    required double height,
    required double borderRadius,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color.withOpacity(0.6), size: width * 0.4),
    );
  }

  /// بناء صورة دائرية
  static Widget buildCircleImage(dynamic image, {double size = 60}) {
    if (image == null || image == false) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[600]),
      );
    }

    if (image is String && image.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: MemoryImage(base64Decode(image)),
        );
      } catch (e) {
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.error, size: size * 0.5, color: Colors.red),
        );
      }
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.image, size: size * 0.5, color: Colors.grey[600]),
    );
  }
}
