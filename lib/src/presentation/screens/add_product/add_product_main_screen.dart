import 'dart:io';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/scaffold/app_scaffold.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';
import 'package:image_picker/image_picker.dart';

class AddProductMainScreen extends StatefulWidget {
  const AddProductMainScreen({super.key});

  @override
  State<AddProductMainScreen> createState() => _AddProductMainScreenState();
}

class _AddProductMainScreenState extends State<AddProductMainScreen> {
  bool isImageTaken = false;
  XFile? _selectedImage;
  final Map<String, dynamic> _dataMap = {};

  Future<void> scanBarcode() async {
    String? barcode = await Get.to(() => const BarcodeScannerPage());

    if (barcode != null && barcode.isNotEmpty) {
      // تحديث قيمة الحقل barcode داخل النموذج
      _formKey.currentState?.fields['barcode']?.didChange(barcode);

      // تحديث الخريطة المحلية _dataMap
      _dataMap['barcode'] = barcode;

      // إظهار SnackBar للتأكيد
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Scanned Barcode: $barcode")));
    } else {
      Get.snackbar(
        "Scan Cancelled",
        "No barcode was scanned.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void takePhoto({required ImageSource source}) async {
    try {
      // إنشاء كائن ImagePicker
      final ImagePicker picker = ImagePicker();

      // اختيار الصورة من المصدر المحدد (الكاميرا أو المعرض)
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        debugPrint("Image Path: ${pickedFile.path}");

        // تحديث الحالة فقط إذا تم تحديد صورة
        setState(() {
          _selectedImage = pickedFile; // حفظ الصورة المحددة
          isImageTaken = true; // تعيين العلامة إلى true
          _dataMap['image_1920'] = pickedFile.path; // تحديث البيانات بالخريطة
        });
      } else {
        debugPrint(
          "No image selected.",
        ); // طباعة رسالة في حال لم يتم اختيار صورة
      }
    } catch (e) {
      // التعامل مع الأخطاء
      debugPrint("Error while picking image: $e");
    }
  }

  InputDecoration inputDecoration(String? name, Widget? suffixIcon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      suffixIcon: suffixIcon!,
      labelText: name!,
    );
  }

  Widget sizeBoxWidth() {
    return const SizedBox(width: 10);
  }

  Widget sizeBoxHeight() {
    return const SizedBox(height: 20);
  }

  bool noteHasError = false;
  final _formKey = GlobalKey<FormBuilderState>();
  void _onChanged(dynamic val) {
    debugPrint(val.toString());
    _formKey.currentState!.save();
    debugPrint(_formKey.currentState!.value.toString());
  }

  Widget? suffixIcon() {
    return noteHasError != false
        ? const Icon(Icons.error, color: Colors.red)
        : const Icon(Icons.check, color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Add Product",
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white70,
        child: FormBuilder(
          key: _formKey,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint(_formKey.currentState!.value.toString());
          },
          autovalidateMode: AutovalidateMode.disabled,
          skipDisabled: true,
          child: ListView(
            children: [
              sizeBoxHeight(),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade50.withOpacity(0.3),
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : const AssetImage(
                                  "assets/images/products/apple_device.png",
                                )
                                as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Wrap(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      takePhoto(source: ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_library),
                                    title: Text('Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      takePhoto(source: ImageSource.gallery);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: ColorSchema.primaryColor,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // UploadImage(
              //   image: _selectedImage != null
              //       ? _selectedImage!.path
              //       : "assets/images/products/apple_device.png",
              // ),
              sizeBoxHeight(),
              sizeBoxHeight(),
              // name Products
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.always,
                name: 'name',
                decoration: inputDecoration('Product', suffixIcon()),
                onChanged: _onChanged,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              sizeBoxHeight(),
              // Description Products
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.always,
                name: 'description',
                decoration: inputDecoration('Description', suffixIcon()),
                onChanged: _onChanged,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                maxLines: 2,
              ),
              sizeBoxHeight(),
              FormBuilderDropdown(
                name: "categ_id",
                decoration: inputDecoration('Category', suffixIcon()),
                onChanged: _onChanged,
                items: PrefUtils.categoryProduct
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v.id, child: Text(v.name!)),
                    )
                    .toList(),
                initialValue: 1,
              ),
              sizeBoxHeight(),
              //reference
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'default_code',
                      decoration: inputDecoration(
                        'Reference Product',
                        suffixIcon(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: _onChanged,
                    ),
                  ),
                  sizeBoxWidth(),
                  Expanded(
                    child: FormBuilderRadioGroup(
                      initialValue: "true",
                      name: 'active',
                      decoration: inputDecoration('Active', suffixIcon()),
                      onChanged: _onChanged,
                      options: ["True", "False"]
                          .map(
                            (v) => FormBuilderFieldOption(
                              value: v.toLowerCase(),
                              child: Text(v.toString()),
                            ),
                          )
                          .toList(growable: true),
                    ),
                  ),
                ],
              ),
              sizeBoxHeight(),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'barcode',
                      decoration: inputDecoration('Barcode', suffixIcon()),
                      onChanged: _onChanged,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFCFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E4E7),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: scanBarcode,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: // Price Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'list_price',
                      decoration: inputDecoration('Price', suffixIcon()),
                      onChanged: _onChanged,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  sizeBoxWidth(),
                  Expanded(
                    child: // Couts Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'standard_price',
                      decoration: inputDecoration('Cout', suffixIcon()),
                      onChanged: _onChanged,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              sizeBoxHeight(),
              sizeBoxHeight(),
              SizedBox(
                width: double.maxFinite,
                child: CustomElevatedButton(
                  buttonName: "Submit",
                  showToast: () {
                    // نسخ البيانات الحالية من الخريطة _dataMap
                    Map<String, dynamic> newMap = Map.from(_dataMap);

                    // الحصول على القيم من نموذج الإدخال
                    Map<String, dynamic>? formData =
                        _formKey.currentState?.value;

                    // التأكد من وجود صورة ومعالجتها
                    if (_selectedImage != null) {
                      // تحويل الصورة إلى Base64
                      String imageString = base64Encode(
                        File(_selectedImage!.path).readAsBytesSync(),
                      );

                      // تحديث الخريطة مع الصورة المحولة
                      newMap['image_1920'] = imageString;

                      debugPrint('Image Base64: $imageString');
                    } else {
                      debugPrint('No image selected!');
                    }

                    // دمج بيانات النموذج مع الخريطة الحالية
                    if (formData != null) {
                      newMap.addAll(formData);
                    }
                    if (formData?['barcode'] != null &&
                        formData!['barcode'].toString().isNotEmpty) {
                      newMap['barcode'] = formData['barcode'];
                    }
                    newMap["type"] = "consu";
                    newMap["is_storable"] = true;
                    newMap["invoice_policy"] = "delivery";
                    String name = newMap['name'];
                    if (name.isNotEmpty) {
                      newMap['name'] = name.toUpperCase();
                    }
                    ProductModule.createProduct(
                      maps: newMap,
                      onResponse: ((response) {
                        debugPrint('Created product id');
                      }),
                    );
                    // عرض رسالة النجاح

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Image saved successfully!"),
                      ),
                    );

                    SuccessToast.showSuccessToast(
                      context,
                      "Submit Complete",
                      "Product Submit Complete",
                    );

                    // طباعة الخريطة النهائية للبيانات
                    debugPrint('Final Data Map: $newMap');
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
