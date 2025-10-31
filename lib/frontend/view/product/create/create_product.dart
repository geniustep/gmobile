import 'dart:io';

import 'package:gsloution_mobile/common/api_factory/models/product/product_module.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/frontend/view/product/create/create_category_product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class CreateProducts extends StatefulWidget {
  const CreateProducts({Key? key}) : super(key: key);

  @override
  State<CreateProducts> createState() {
    return _CreateProductsState();
  }
}

class _CreateProductsState extends State<CreateProducts> {
  var prdtCategory = <ProductCategoryModel>[].obs;
  var products = <ProductModel>[].obs;
  // var accountTax = <AccountTaxModel>[].obs;
  // var employee = <EmployeeModel>[].obs;
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int size = 0;
  @override
  void initState() {
    products = PrefUtils.products;
    prdtCategory = PrefUtils.categoryProduct;
    // getAccountTax(accountTax);

    super.initState();
  }

  // Future<RxList<AccountTaxModel>> getAccountTax(
  //     RxList<AccountTaxModel> accountTax) async {
  //   await AccountTaxModule.searchReadAccountTax(
  //       onResponse: ((response) {
  //         setState(() {
  //           accountTax.addAll(response[response.keys.toList()[0]]!);
  //         });
  //       }),
  //       domain: []);
  //   return accountTax;
  // }

//function Non Terminer in form get just camera without Gallerie
  final ImagePicker _picker = ImagePicker();
  XFile? image;

  takePhoto(Image i) async {
    image = await _picker.pickImage(source: ImageSource.camera);
  }

  // Variable FormBuilder
  final _formKey = GlobalKey<FormBuilderState>();
  bool isVisible = true;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  bool _noteHasError = false;
  void _onChanged(dynamic val) => debugPrint(val.toString());

  @override
  Widget build(BuildContext context) {
    debugPrint('Building CreateProducts page');
    return MainContainer(
      actions: [
        IconButton(
          icon: const Icon(
            Icons.calendar_month,
          ),
          onPressed: () {
            Get.to(const CreateCategoryProduct());
          },
        )
      ],
      appBarTitle: ' Create Product',
      drawer: CustomDrawer(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: _formKey,
                onChanged: () {
                  _formKey.currentState!.save();
                  debugPrint(_formKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.disabled,
                skipDisabled: true,
                child: Column(
                  children: <Widget>[
                    // barcode
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'barcode',
                      decoration: InputDecoration(
                        hintText: 'barcode product',
                        labelText: 'barcode product',
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: (val) {
                        debugPrint('Current value: $val');
                        debugPrint(
                            'Form state: ${_formKey.currentState?.saveAndValidate()}');
                      },
                    ),
                    //reference
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'default_code',
                      decoration: InputDecoration(
                        hintText: 'reference product',
                        labelText: 'reference product',
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: (val) {
                        debugPrint('Current value: $val');
                        debugPrint(
                            'Form state: ${_formKey.currentState?.saveAndValidate()}');
                      },
                    ),
                    const SizedBox(height: 15),
                    // name Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'name',
                      decoration: InputDecoration(
                        hintText: 'Name product',
                        labelText: 'Name product',
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    //product Categories
                    FormBuilderDropdown(
                      decoration: const InputDecoration(
                        hintText: 'select categories',
                        border: const OutlineInputBorder(),
                        icon: const Icon(
                          Icons.category,
                        ),
                      ),
                      name: "categ_id",
                      onChanged: _onChanged,
                      items: prdtCategory
                          .map((v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(v.name.toString()),
                              ))
                          .toList(),
                    ),
                    // is Actives ??
                    const SizedBox(height: 20),
                    FormBuilderRadioGroup(
                      initialValue: "true",
                      name: 'active',
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 40.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          labelText: 'Active'),
                      onChanged: _onChanged,
                      options: ["True", "False"]
                          .map((v) => FormBuilderFieldOption(
                                value: v.toLowerCase(),
                                child: Text(v.toString()),
                              ))
                          .toList(growable: true),
                    ),
                    // Price Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'list_price',
                      decoration: InputDecoration(
                        hintText: 'Price',
                        labelText: 'Price',
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _noteHasError = !(_formKey
                                  .currentState?.fields['list_price']
                                  ?.validate() ??
                              false);
                        });
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    // Couts Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'standard_price',
                      decoration: InputDecoration(
                        hintText: 'cost'.toUpperCase(),
                        labelText: 'cost'.toUpperCase(),
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _noteHasError = !(_formKey
                                  .currentState?.fields['standard_price']
                                  ?.validate() ??
                              false);
                        });
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    //Taxe 20%
                    // FormBuilderDropdown(
                    //   initialValue: 3,
                    //   decoration:
                    //       const InputDecoration(hintText: 'Select Taxes'),
                    //   name: "taxes_id",
                    //   items: accountTax
                    //       .map((v) => DropdownMenuItem(
                    //             value: v.id,
                    //             child: Text(v.name!),
                    //           ))
                    //       .toList(),
                    // ),
                    // Description Products
                    FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.always,
                      name: 'description',
                      decoration: InputDecoration(
                        hintText: 'description',
                        labelText: 'description',
                        suffixIcon: _noteHasError
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLines: 4,
                    ),
                    // const SizedBox(height: 15),
                    // Photo
                    const SizedBox(height: 20),
                    Expanded(
                      child: FormBuilderImagePicker(
                        onSaved: (val) {
                          val =
                              _formKey.currentState?.fields['image_256']!.value;
                        },
                        onChanged: (val) {
                          setState(() {
                            _noteHasError = !(_formKey
                                    .currentState?.fields['image_256']
                                    ?.validate() ??
                                false);
                          });
                        },
                        name: 'image_256',
                        onImage: takePhoto,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(29, 10, 10, 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          labelText: 'photo',
                        ),
                        fit: BoxFit.fitWidth,
                        // maxHeight: 20,
                        // imageQuality: 10,
                        maxImages: 1,
                        preferredCameraDevice: CameraDevice.rear,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          child: Text('create'.toUpperCase()),
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              debugPrint(
                                  _formKey.currentState?.value.toString());
                              Map<String, dynamic>? secondMaps =
                                  _formKey.currentState?.value;
                              Map<String, dynamic> newMap =
                                  Map.from(secondMaps!);
                              if (newMap['image_256'] != null) {
                                var images =
                                    newMap['image_256'] as List<dynamic>;
                                if (images.isNotEmpty) {
                                  String imageString = base64Encode(
                                      File(images[0].path).readAsBytesSync());
                                  newMap['image_256'] = imageString;
                                }
                              }
                              if (_formKey.currentState?.fields["taxes_id"] !=
                                  null) {
                                List<dynamic> taxesId = [
                                  [
                                    6,
                                    "False",
                                    [
                                      _formKey.currentState?.fields["taxes_id"]!
                                          .value
                                    ]
                                  ]
                                ];

                                newMap["taxes_id"] = taxesId;
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
                                  }));
                              debugPrint('validation OK');
                            } else {
                              debugPrint(
                                  _formKey.currentState?.value.toString());
                              debugPrint('validation failed');
                            }
                          },
                        )),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                      },
                      child: Text(
                        'reset'.toUpperCase(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
