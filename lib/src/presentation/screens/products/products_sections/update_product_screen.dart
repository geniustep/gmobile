import 'dart:io';
import 'dart:convert';

import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductScreen extends StatefulWidget {
  final ProductModel product;

  const UpdateProductScreen({super.key, required this.product});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  bool isImageTaken = false;
  XFile? _selectedImage;
  final Map<String, dynamic> _dataMap = {};
  final _formKey = GlobalKey<FormBuilderState>();

  void takePhoto({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          isImageTaken = true;
          _dataMap['image_1920'] = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error while picking image: $e");
    }
  }

  InputDecoration inputDecoration(String? name, Widget? suffixIcon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      suffixIcon: suffixIcon,
      labelText: name,
    );
  }

  Widget? suffixIcon(bool hasError) {
    return hasError
        ? const Icon(Icons.error, color: Colors.red)
        : const Icon(Icons.check, color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(navigateName: "Update Product"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white70,
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade50.withOpacity(0.3),
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : widget.product.image_1920 != null
                          ? MemoryImage(
                              base64Decode(widget.product.image_1920!),
                            )
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
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      takePhoto(source: ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Gallery'),
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
              const SizedBox(height: 30),
              // Name
              FormBuilderTextField(
                name: 'name',
                decoration: inputDecoration('Product', suffixIcon(false)),
                initialValue: widget.product.name ?? '',
              ),
              const SizedBox(height: 20),
              // Description
              FormBuilderTextField(
                name: 'description',
                decoration: inputDecoration('Description', suffixIcon(false)),
                maxLines: 2,
                initialValue: widget.product.description == false
                    ? ''
                    : widget.product.description ?? '',
              ),
              const SizedBox(height: 20),
              // Category
              FormBuilderDropdown(
                name: "categ_id",
                decoration: inputDecoration('Category', suffixIcon(false)),
                initialValue: widget.product.categ_id[0],
                items: PrefUtils.categoryProduct
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v.id, child: Text(v.name!)),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'default_code',
                      decoration: inputDecoration(
                        'Reference Product',
                        suffixIcon(false),
                      ),
                      initialValue: widget.product.default_code == false
                          ? ''
                          : widget.product.default_code ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormBuilderRadioGroup<bool>(
                      name: 'active',
                      initialValue: widget.product.active ?? true,
                      decoration: inputDecoration('Active', suffixIcon(false)),
                      options: const [
                        FormBuilderFieldOption(
                          value: true,
                          child: Text("True"),
                        ),
                        FormBuilderFieldOption(
                          value: false,
                          child: Text("False"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Barcode
              FormBuilderTextField(
                name: 'barcode',
                decoration: inputDecoration('Barcode', suffixIcon(false)),
                initialValue: widget.product.barcode == false
                    ? ''
                    : widget.product.barcode ?? '',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'list_price',
                      decoration: inputDecoration('Price', suffixIcon(false)),
                      keyboardType: TextInputType.number,
                      initialValue: widget.product.list_price?.toString() ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'standard_price',
                      decoration: inputDecoration('Cout', suffixIcon(false)),
                      keyboardType: TextInputType.number,
                      initialValue:
                          widget.product.standard_price?.toString() ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              CustomElevatedButton(
                buttonName: "Update",
                showToast: () {
                  Map<String, dynamic> newMap = {};
                  Map<String, dynamic>? formData = _formKey.currentState?.value;

                  if (formData != null) {
                    newMap.addAll(formData);
                  }

                  if (_selectedImage != null) {
                    String imageString = base64Encode(
                      File(_selectedImage!.path).readAsBytesSync(),
                    );
                    newMap['image_1920'] = imageString;
                  }

                  if (formData?['barcode'] != null &&
                      formData!['barcode'].toString().isNotEmpty) {
                    newMap['barcode'] = formData['barcode'];
                  }

                  ProductModule.updateProduct(
                    maps: newMap,
                    id: widget.product.id!,
                    onResponse: (response) {
                      SuccessToast.showSuccessToast(
                        context,
                        "Update Complete",
                        "Product updated successfully",
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
