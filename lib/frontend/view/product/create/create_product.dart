// import 'package:g_solution/import/import_file.dart';
// import 'package:g_solution/src/model/invoice/account_tax/account_tax_module.dart';
// import 'package:g_solution/src/model/product/categories/category_product_model.dart';
// import 'package:g_solution/src/model/product/categories/category_product_module.dart';
// import 'package:g_solution/view/product/create/create_category_product.dart';

// class CreateProducts extends StatefulWidget {
//   const CreateProducts({Key? key}) : super(key: key);

//   @override
//   State<CreateProducts> createState() {
//     return _CreateProductsState();
//   }
// }

// class _CreateProductsState extends State<CreateProducts> {
//   var prdtCategory = <ProductCategoryModel>[].obs;
//   var product = <ProductModel>[].obs;
//   var accountTax = <AccountTaxModel>[].obs;
//   var employee = <EmployeeModel>[].obs;
//   ScrollController scrollController = ScrollController();
//   bool isLoading = false;
//   int size = 0;
//   @override
//   void initState() {
//     List domain = [];

//     ProductModule.searchReadProducts(
//         domain: domain,
//         onResponse: ((response) {
//           size = response.keys.toList()[0];
//           product.addAll(response[size]!);
//         }));
//     getAccountTax(accountTax);
//     getProductCategory(prdtCategory);

//     super.initState();
//   }

//   Future<RxList<ProductCategoryModel>> getProductCategory(
//       RxList<ProductCategoryModel> prdtCategory) async {
//     await ProductCategoryModule.searchReadProductsCategory(
//         onResponse: ((response) {
//       setState(() {
//         prdtCategory.addAll(response[response.keys.toList()[0]]!);
//       });
//     }));
//     return prdtCategory;
//   }

//   Future<RxList<AccountTaxModel>> getAccountTax(
//       RxList<AccountTaxModel> accountTax) async {
//     await AccountTaxModule.searchReadAccountTax(
//         onResponse: ((response) {
//           setState(() {
//             accountTax.addAll(response[response.keys.toList()[0]]!);
//           });
//         }),
//         domain: []);
//     return accountTax;
//   }

// //function Non Terminer in form get just camera without Gallerie
//   final ImagePicker _picker = ImagePicker();
//   XFile? image;

//   takePhoto(Image i) async {
//     image = await _picker.pickImage(source: ImageSource.camera);
//   }

//   // Variable FormBuilder
//   final _formKey = GlobalKey<FormBuilderState>();
//   bool isVisible = true;
//   bool autoValidate = true;
//   bool readOnly = false;
//   bool showSegmentedControl = true;
//   bool _noteHasError = false;
//   void _onChanged(dynamic val) => debugPrint(val.toString());

//   @override
//   Widget build(BuildContext context) {
//     return MainContainer(
//       actions: [
//         IconButton(
//           icon: const Icon(
//             Icons.calendar_month,
//           ),
//           onPressed: () {
//             Get.to(const CreateCategoryProduct());
//           },
//         )
//       ],
//       appBarTitle:
//           '${Localize.create.tr.toUpperCase()} ${Localize.product.tr.toUpperCase()}',
//       drawer: CustomDrawer(),
//       child: Scaffold(
//         body: Builder(builder: (context) {
//           return Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 children: <Widget>[
//                   FormBuilder(
//                     key: _formKey,
//                     onChanged: () {
//                       _formKey.currentState!.save();
//                       debugPrint(_formKey.currentState!.value.toString());
//                     },
//                     autovalidateMode: AutovalidateMode.disabled,
//                     skipDisabled: true,
//                     child: Column(
//                       children: <Widget>[
//                         //reference
//                         FormBuilderTextField(
//                           autovalidateMode: AutovalidateMode.always,
//                           name: 'default_code',
//                           decoration: InputDecoration(
//                             hintText:
//                                 '${Localize.reference.tr.toUpperCase()} ${Localize.product.tr.toUpperCase()}',
//                             labelText:
//                                 '${Localize.reference.tr.toUpperCase()} ${Localize.product.tr.toUpperCase()}',
//                             suffixIcon: _noteHasError
//                                 ? const Icon(Icons.error, color: Colors.red)
//                                 : const Icon(Icons.check, color: Colors.green),
//                           ),
//                           keyboardType: TextInputType.text,
//                           textInputAction: TextInputAction.next,
//                         ),
//                         const SizedBox(height: 15),
//                         // name Products
//                         FormBuilderTextField(
//                           autovalidateMode: AutovalidateMode.always,
//                           name: 'name',
//                           decoration: InputDecoration(
//                             hintText:
//                                 '${Localize.name.tr.toUpperCase()} ${Localize.product.tr.toUpperCase()}',
//                             labelText:
//                                 '${Localize.name.tr.toUpperCase()} ${Localize.product.tr.toUpperCase()}',
//                             suffixIcon: _noteHasError
//                                 ? const Icon(Icons.error, color: Colors.red)
//                                 : const Icon(Icons.check, color: Colors.green),
//                           ),
//                           keyboardType: TextInputType.text,
//                           textInputAction: TextInputAction.next,
//                         ),
//                         const SizedBox(height: 15),
//                         //product Categories
//                         FormBuilderDropdown(
//                           decoration: InputDecoration(
//                             hintText:
//                                 '${Localize.select.tr.toUpperCase()} ${Localize.categories.tr.toUpperCase()}',
//                             border: const OutlineInputBorder(),
//                             icon: const Icon(
//                               Icons.category,
//                             ),
//                           ),
//                           name: "categ_id",
//                           onChanged: _onChanged,
//                           items: prdtCategory
//                               .map((v) => DropdownMenuItem(
//                                     value: v.id,
//                                     child: Text(v.displayName.toString()),
//                                   ))
//                               .toList(),
//                         ),
//                         // is Actives ??
//                         const SizedBox(height: 20),
//                         FormBuilderRadioGroup(
//                           initialValue: "true",
//                           name: 'active',
//                           decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 40.0, horizontal: 10.0),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(32.0),
//                               ),
//                               labelText: PrefUtils.getLanguage() == "ar"
//                                   ? '${Localize.active.tr.toUpperCase()}؟'
//                                   : '${Localize.isS.tr.toUpperCase()} ${Localize.active.tr.toUpperCase()}?'),
//                           onChanged: _onChanged,
//                           options: ["True", "False"]
//                               .map((v) => FormBuilderFieldOption(
//                                     value: v.toLowerCase(),
//                                     child: Text(v.toString()),
//                                   ))
//                               .toList(growable: true),
//                         ),
//                         // Price Products
//                         FormBuilderTextField(
//                           autovalidateMode: AutovalidateMode.always,
//                           name: 'list_price',
//                           decoration: InputDecoration(
//                             hintText: Localize.price.tr.toUpperCase(),
//                             labelText: Localize.price.tr.toUpperCase(),
//                             suffixIcon: _noteHasError
//                                 ? const Icon(Icons.error, color: Colors.red)
//                                 : const Icon(Icons.check, color: Colors.green),
//                           ),
//                           onChanged: (val) {
//                             setState(() {
//                               _noteHasError = !(_formKey
//                                       .currentState?.fields['list_price']
//                                       ?.validate() ??
//                                   false);
//                             });
//                           },
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                         ),
//                         // Couts Products
//                         FormBuilderTextField(
//                           autovalidateMode: AutovalidateMode.always,
//                           name: 'standard_price',
//                           decoration: InputDecoration(
//                             hintText: Localize.cost.tr.toUpperCase(),
//                             labelText: Localize.cost.tr.toUpperCase(),
//                             suffixIcon: _noteHasError
//                                 ? const Icon(Icons.error, color: Colors.red)
//                                 : const Icon(Icons.check, color: Colors.green),
//                           ),
//                           onChanged: (val) {
//                             setState(() {
//                               _noteHasError = !(_formKey
//                                       .currentState?.fields['standard_price']
//                                       ?.validate() ??
//                                   false);
//                             });
//                           },
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                         ),
//                         //Taxe 20%
//                         FormBuilderDropdown(
//                           initialValue: 3,
//                           decoration:
//                               const InputDecoration(hintText: 'Select Taxes'),
//                           name: "taxes_id",
//                           items: accountTax
//                               .map((v) => DropdownMenuItem(
//                                     value: v.id,
//                                     child: Text(v.name!),
//                                   ))
//                               .toList(),
//                         ),
//                         // Description Products
//                         FormBuilderTextField(
//                           autovalidateMode: AutovalidateMode.always,
//                           name: 'description',
//                           decoration: InputDecoration(
//                             hintText: Localize.description.tr.toUpperCase(),
//                             labelText: Localize.description.tr.toUpperCase(),
//                             suffixIcon: _noteHasError
//                                 ? const Icon(Icons.error, color: Colors.red)
//                                 : const Icon(Icons.check, color: Colors.green),
//                           ),
//                           keyboardType: TextInputType.text,
//                           textInputAction: TextInputAction.next,
//                           maxLines: 4,
//                         ),
//                         const SizedBox(height: 15),
//                         // Photo
//                         const SizedBox(height: 20),
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     children: [
//                                       const SizedBox(height: 20),
//                                       FormBuilderImagePicker(
//                                         onSaved: (val) {
//                                           val = _formKey.currentState
//                                               ?.fields['image_1920']!.value;
//                                         },
//                                         onChanged: (val) {
//                                           setState(() {
//                                             _noteHasError = !(_formKey
//                                                     .currentState
//                                                     ?.fields['image_1920']
//                                                     ?.validate() ??
//                                                 false);
//                                           });
//                                         },
//                                         name: 'image_1920',
//                                         onImage: takePhoto,
//                                         decoration: InputDecoration(
//                                           contentPadding:
//                                               const EdgeInsets.fromLTRB(
//                                                   29, 10, 10, 10),
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(25.0),
//                                           ),
//                                           labelText:
//                                               Localize.photo.tr.toUpperCase(),
//                                         ),
//                                         fit: BoxFit.fitWidth,
//                                         // maxHeight: 20,
//                                         // imageQuality: 10,
//                                         maxImages: 1,
//                                         preferredCameraDevice:
//                                             CameraDevice.rear,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: Container(
//                             margin: const EdgeInsets.all(20),
//                             child: ElevatedButton(
//                               child: Text(Localize.create.tr.toUpperCase()),
//                               onPressed: () {
//                                 if (_formKey.currentState?.saveAndValidate() ??
//                                     false) {
//                                   debugPrint(
//                                       _formKey.currentState?.value.toString());
//                                   Map<String, dynamic>? secondMaps =
//                                       _formKey.currentState?.value;
//                                   Map<String, dynamic> newMap =
//                                       Map.from(secondMaps!);
//                                   var images =
//                                       newMap['image_1920'] as List<dynamic>;
//                                   if (images.isNotEmpty) {
//                                     String imageString = base64Encode(
//                                         File(images[0].path).readAsBytesSync());
//                                     newMap['image_1920'] = imageString;
//                                   }
//                                   List<dynamic> taxesId = [
//                                     [
//                                       6,
//                                       "False",
//                                       [
//                                         _formKey.currentState
//                                             ?.fields["taxes_id"]!.value
//                                       ]
//                                     ]
//                                   ];
//                                   newMap["type"] = "product";
//                                   newMap["taxes_id"] = taxesId;
//                                   String name = newMap['name'];
//                                   if (name.isNotEmpty) {
//                                     newMap['name'] = name.toUpperCase();
//                                   }
//                                   ProductModule.createProduct(
//                                       maps: newMap,
//                                       onResponse: ((response) {
//                                         debugPrint('Created product id');
//                                       }));
//                                   debugPrint('validation OK');
//                                 } else {
//                                   debugPrint(
//                                       _formKey.currentState?.value.toString());
//                                   debugPrint('validation failed');
//                                 }
//                               },
//                             )),
//                       ),
//                       const SizedBox(width: 20),
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             _formKey.currentState?.reset();
//                           },
//                           child: Text(
//                             Localize.reset.tr.toUpperCase(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
