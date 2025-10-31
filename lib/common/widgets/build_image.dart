import 'dart:typed_data';
import 'package:gsloution_mobile/common/config/import.dart';

Widget buildImage({dynamic image, double? width, double? height}) {
  if (image != null && image is String) {
    if (_isValidBase64(image)) {
      // إذا كانت الصورة Base64
      try {
        Uint8List imageBytes = base64.decode(image);
        return _buildImageWidget(
          widget: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _errorWidget(height: height, width: width);
            },
          ),
          width: width,
          height: height,
        );
      } catch (e) {
        return _errorWidget(height: height, width: width);
      }
    } else if (_isAssetPath(image)) {
      // إذا كانت الصورة مسار أصول (assets path)
      return _buildImageWidget(
        widget: Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _errorWidget(height: height, width: width);
          },
        ),
        width: width,
        height: height,
      );
    }
  }

  // إذا كان النوع غير مدعوم أو غير صالح
  return _errorWidget(height: height, width: width);
}

Widget _buildImageWidget({
  required Widget widget,
  double? width,
  double? height,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(height: height, width: width, child: widget),
  );
}

Widget _errorWidget({double? height, double? width}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: height,
      width: width,
      child: const Icon(
        Icons.no_photography,
        color: Colors.blue, // عدّل اللون حسب احتياجك
        size: 50, // حجم الأيقونة
      ),
    ),
  );
}

bool _isValidBase64(String imageBase64) {
  try {
    base64.decode(imageBase64);
    return imageBase64.length % 4 == 0;
  } catch (e) {
    return false;
  }
}

bool _isAssetPath(String path) {
  // التحقق إذا كان المسار يبدأ بـ 'assets/'
  return path.startsWith('assets/');
}

class ImageTap extends StatelessWidget {
  final String mydata;
  const ImageTap(this.mydata, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onTap: () {
          // الانتقال إلى الشاشة الكاملة عند الضغط
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => FullScreenImage(mydata)),
          );
        },
        child: mydata.isNotEmpty
            ? _isValidBase64(mydata)
                  ? InteractiveViewer(
                      child: Image.memory(
                        base64.decode(mydata),
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _errorWidget();
                        },
                      ),
                    )
                  : InteractiveViewer(
                      child: Image.asset(
                        mydata,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _errorWidget();
                        },
                      ),
                    )
            : _errorWidget(),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String mydata;
  const FullScreenImage(this.mydata, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: mydata.isNotEmpty
            ? _isValidBase64(mydata)
                  ? InteractiveViewer(
                      child: Image.memory(
                        base64.decode(mydata),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _errorWidget();
                        },
                      ),
                    )
                  : InteractiveViewer(
                      child: Image.asset(
                        mydata,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _errorWidget();
                        },
                      ),
                    )
            : _errorWidget(),
      ),
    );
  }
}
