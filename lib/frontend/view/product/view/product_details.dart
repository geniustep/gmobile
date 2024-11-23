// // ignore: must_be_immutable

// import 'package:gsloution_mobile/common/config/import.dart';

// class ProductDetails extends StatefulWidget {
//   ProductModel product;
//   ProductDetails(this.product, {super.key});

//   @override
//   State<ProductDetails> createState() => _ProductDetailsState();
// }

// class _ProductDetailsState extends State<ProductDetails> {
//   // var stockQuant = <StockQuantModel>[].obs;
//   // var stockLocation = <StockLocationModel>[].obs;

//   var productPackage = ProductPackageModel();
//   String pack = "";
//   @override
//   void initState() {
//     if (widget.product.packagingIds.isNotEmpty) {
//       ProductPackageModule.readProductsPackage(
//           ids: [widget.product.productTemplateVariantValueIds[0]],
//           onResponse: ((response) {
//             if (response.isNotEmpty) {
//               productPackage = response[0];
//             }
//             if (widget.product.virtualAvailable > 0 &&
//                 widget.product.virtualAvailable != false &&
//                 productPackage.qty != null) {
//               var t = widget.product.virtualAvailable / productPackage.qty;
//               pack =
//                   "${t.toString().split('.').first} x ${productPackage.qty.toString().split('.').first}";
//             }
//           }));
//     }
//     super.initState();
//     // getStockQuant(stockQuant);
//     // getStockLocation(stockLocation);

//     // PrefUtils.Employee;
//   }

//   // form builder variable
//   final _formKeyProductQty = GlobalKey<FormBuilderState>();
//   bool isVisible = true;
//   bool autoValidate = true;
//   bool readOnly = false;
//   bool showSegmentedControl = true;
//   bool _noteHasError = false;

//   // Future<RxList<StockLocationModel>> getStockLocation(
//   //     RxList<StockLocationModel> stockLocation) async {
//   //   List<dynamic> domain = [
//   //     ["usage", "=", "internal"]
//   //   ];
//   //   // domain.add();
//   //   await StockLocationModule.searchReadStockLocation(
//   //     domain: domain,
//   //     onResponse: ((response) {
//   //       setState(() {
//   //         stockLocation.addAll(response[response.keys.toList()[0]]!);
//   //       });
//   //     }),
//   //   );
//   //   return stockLocation;
//   // }

//   // Future<RxList<StockQuantModel>> getStockQuant(
//   //     RxList<StockQuantModel> stockQuant) async {
//   //   // domain.add();
//   //   await StockQuantModule.searchStockQuant(
//   //     domain: [
//   //       ["on_hand", "=", true],
//   //       [
//   //         "product_id",
//   //         "in",
//   //         [widget.product.productVariantId[0]]
//   //       ],
//   //       ["quantity", ">", 0]
//   //     ],
//   //     onResponse: ((response) {
//   //       setState(() {
//   //         stockQuant.addAll(response[response.keys.toList()[0]]!);
//   //       });
//   //     }),
//   //   );
//   //   return stockQuant;
//   // }

//   // update Product Qty
//   // updateProductQty() {
//   //   var thisStockQuant = stockQuant
//   //       .where((e) => e.productId[0] == widget.product.productVariantId[0])
//   //       .toList();
//   //   Get.dialog(
//   //     AlertDialog(
//   //       shape: RoundedRectangleBorder(
//   //         borderRadius: BorderRadius.circular(16.0),
//   //       ),
//   //       title: Text(
//   //         "Update Qty",
//   //         style: AppFont.Title_H4_Medium(),
//   //       ),
//   //       content: FormBuilder(
//   //         key: _formKeyProductQty,
//   //         onChanged: () {
//   //           _formKeyProductQty.currentState!.save();
//   //           debugPrint(_formKeyProductQty.currentState!.value.toString());
//   //         },
//   //         autovalidateMode: AutovalidateMode.disabled,
//   //         skipDisabled: true,
//   //         child: Column(
//   //           children: [
//   //             Container(
//   //               width: 300,
//   //               height: 200,
//   //               child: ListView.builder(
//   //                   itemCount: thisStockQuant.length,
//   //                   itemBuilder: ((context, index) {
//   //                     var stock = thisStockQuant[index];
//   //                     return ListTile(
//   //                       title: Text(stock.locationId[1]),
//   //                       leading: Text(stock.quantity.toString()),
//   //                     );
//   //                   })),
//   //             ),
//   //             FormBuilderDropdown(
//   //               decoration: InputDecoration(
//   //                   hintText: '${Localize.select.tr.toUpperCase()} Stock}'),
//   //               name: "location_id",
//   //               items: stockLocation
//   //                   .map((v) => DropdownMenuItem(
//   //                         value: v.id,
//   //                         child: Text(v.completeName.toString()),
//   //                       ))
//   //                   .toList(),
//   //             ),
//   //             FormBuilderTextField(
//   //               autovalidateMode: AutovalidateMode.always,
//   //               name: 'inventory_quantity',
//   //               decoration: InputDecoration(
//   //                 hintText: 'qty available',
//   //                 labelText: 'Qty Available',
//   //                 suffixIcon: _noteHasError
//   //                     ? const Icon(Icons.error, color: Colors.red)
//   //                     : const Icon(Icons.check, color: Colors.green),
//   //               ),
//   //               keyboardType: TextInputType.number,
//   //               textInputAction: TextInputAction.next,
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       actions: <Widget>[
//   //         TextButton(
//   //           onPressed: () async {
//   //             if ((_formKeyProductQty
//   //                         .currentState?.value["inventory_quantity"] !=
//   //                     null) &&
//   //                 (_formKeyProductQty.currentState?.value["location_id"] !=
//   //                     null)) {
//   //               debugPrint(_formKeyProductQty.currentState?.value.toString());
//   //               Map<String, dynamic> maps = {
//   //                 "inventory_quantity": _formKeyProductQty
//   //                     .currentState?.value["inventory_quantity"]
//   //               };

//   //               int locationId =
//   //                   _formKeyProductQty.currentState?.value["location_id"];
//   //               List<StockQuantModel> stockQuantModel = thisStockQuant
//   //                   .where((element) => element.locationId[0] == locationId)
//   //                   .toList();
//   //               if (stockQuantModel.isNotEmpty) {
//   //                 StockQuantModule.updateStockQuant(
//   //                     locationId: stockQuantModel[0].id,
//   //                     maps: maps,
//   //                     product: widget.product,
//   //                     onResponse: ((response) {
//   //                       print("Actualizado");
//   //                     }));
//   //               } else {
//   //                 //Create
//   //                 Map<String, dynamic> maps = {
//   //                   "product_id": widget.product.productVariantId[0],
//   //                   "location_id": locationId,
//   //                   "inventory_quantity": _formKeyProductQty
//   //                       .currentState?.value["inventory_quantity"]
//   //                 };
//   //                 StockQuantModule.createStockQuant(
//   //                     maps: maps,
//   //                     product: widget.product,
//   //                     onResponse: ((response) {
//   //                       print("Actualizado");
//   //                     }));
//   //               }
//   //               debugPrint('validation OK');
//   //             } else {
//   //               debugPrint(_formKeyProductQty.currentState?.value.toString());
//   //               debugPrint('validation failed');
//   //             }
//   //           },
//   //           child: Text(
//   //             Localize.done.tr,
//   //             style: AppFont.Body2_Regular(),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

// // Create Product Package

//   createProductPackage() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         title: Text(
//           "Create Package",
//           style: AppFont.Title_H4_Medium(),
//         ),
//         content: FormBuilder(
//           key: _formKeyProductQty,
//           onChanged: () {
//             _formKeyProductQty.currentState!.save();
//             debugPrint(_formKeyProductQty.currentState!.value.toString());
//           },
//           autovalidateMode: AutovalidateMode.disabled,
//           skipDisabled: true,
//           child: FormBuilderTextField(
//             autovalidateMode: AutovalidateMode.always,
//             name: 'qty_available',
//             decoration: InputDecoration(
//               hintText: 'qty available',
//               labelText: 'Qty Available',
//               suffixIcon: _noteHasError
//                   ? const Icon(Icons.error, color: Colors.red)
//                   : const Icon(Icons.check, color: Colors.green),
//             ),
//             keyboardType: TextInputType.number,
//             textInputAction: TextInputAction.next,
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async {
//               if (_formKeyProductQty.currentState?.saveAndValidate() ?? false) {
//                 debugPrint(_formKeyProductQty.currentState?.value.toString());
//                 Map<String, dynamic>? maps =
//                     _formKeyProductQty.currentState?.value;
//                 ProductPackageModule.CreateProductPackage(
//                     maps: maps, onResponse: ((response) {}));

//                 debugPrint('validation OK');
//               } else {
//                 debugPrint(_formKeyProductQty.currentState?.value.toString());
//                 debugPrint('validation failed');
//               }
//             },
//             child: Text(
//               Localize.done.tr,
//               style: AppFont.Body2_Regular(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MainContainer(
//       drawer: CustomDrawer(),
//       // backgroundColor: MyTheme.appBarThemeLight,
//       appBarTitle: widget.product.name.toString().length > 20
//           ? widget.product.name.toString().toUpperCase().substring(0, 20)
//           : widget.product.name.toString().toUpperCase(),
//       actions: [
//         // PrefUtils.Employee!.jobTitle == 'Sales Manager'
//         //     ? IconButton(
//         //         onPressed: () {
//         //           print("object");
//         //           Get.to(UpdateProducts(widget.product));
//         //         },
//         //         icon: Icon(Icons.update),
//         //       )
//         //     : Container(),
//         // PrefUtils.Employee!.jobTitle == 'Sales Manager'
//         //     ? IconButton(
//         //         icon: const Icon(Icons.shopping_bag),
//         //         onPressed: () {
//         //           updateProductQty();
//         //         },
//         //       )
//         //     : Container()
//       ],
//       // leading: IconButton(
//       //   onPressed: () {},
//       //   icon: const Icon(
//       //     Ionicons.chevron_back,
//       //     color: Colors.black,
//       //   ),
//       // ),

//       child: Column(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height * .35,
//             padding: const EdgeInsets.only(bottom: 30),
//             width: double.infinity,
//             child: widget.product != false
//                 ? Image.memory(
//                     base64.decode(widget.product.image512!),
//                     fit: BoxFit.scaleDown,
//                   )
//                 : Align(
//                     alignment: Alignment.center,
//                     child: Image.asset(
//                       "assets/images/logo_c.png",
//                       fit: BoxFit.contain,
//                       width: 100,
//                     ),
//                   ),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.only(top: 40, right: 14, left: 14),
//                   decoration: const BoxDecoration(
//                     // color: MyTheme.primaryLight,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               widget.product.defaultCode != false
//                                   ? widget.product.defaultCode
//                                   : "",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 15,
//                                 // color: MyTheme.scaffoldBackgroundColorLight,
//                               ),
//                             ),
//                             Text(
//                               "${widget.product.lstPrice} DH",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w600,
//                                 // color: MyTheme.scaffoldBackgroundColorLight,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Text(
//                             widget.product.name,
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               // color: MyTheme.scaffoldBackgroundColorLight,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           "Catégorie: ${widget.product.categId[1]}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             // color: MyTheme.scaffoldBackgroundColorLight,
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           "Type d'article: ${widget.product.runtimeType.toString().toUpperCase()}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             // color: MyTheme.scaffoldBackgroundColorLight,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Description: ${widget.product.name}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             // color: MyTheme.scaffoldBackgroundColorLight,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // Padding(
//                         //   padding: EdgeInsets.all(8),
//                         //   child: Row(
//                         //     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         //     children: [
//                         //       GestureDetector(
//                         //           onTap: () {
//                         //             createProductPackage();
//                         //           },
//                         //           child: Icon(Ionicons.add_circle)),
//                         //       Tags(
//                         //         key: _keyTags,
//                         //         itemCount: tags.length,
//                         //         columns: 6,
//                         //         textField: TagsTextField(
//                         //             textStyle: TextStyle(fontSize: 14),
//                         //             onSubmitted: ((string) {
//                         //               setState(() {
//                         //                 tags.add(Item(title: string));
//                         //               });
//                         //             })),
//                         //         itemBuilder: ((index) {
//                         //           Item currentItem = tags[index];
//                         //           return ItemTags(
//                         //             index: index,
//                         //             title: currentItem.title,
//                         //             customData: currentItem.customData,
//                         //             textStyle: TextStyle(fontSize: 14),
//                         //             combine: ItemTagsCombine.withTextBefore,
//                         //             onPressed: (i) => print(i),
//                         //             onLongPressed: (i) => print(i),
//                         //             removeButton:
//                         //                 ItemTagsRemoveButton(onRemoved: (() {
//                         //               setState(() {
//                         //                 tags.removeAt(index);
//                         //               });
//                         //               return true;
//                         //             })),
//                         //           );
//                         //         }),
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ),
//                         SizedBox(
//                           height: 110,
//                           child: ListView(
//                             scrollDirection: Axis.horizontal,
//                             padding: EdgeInsets.all(8),
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.all(6),
//                                 width: 160,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   // color: MyTheme.appBarThemeLight,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Center(
//                                     child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Pack: $pack',
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             fontSize: 18)),
//                                     Text(
//                                         'Unity: ${widget.product.virtualAvailable}',
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             fontSize: 18)),
//                                   ],
//                                 )),
//                               ),
//                               Container(
//                                 margin: const EdgeInsets.all(6),
//                                 width: 140,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   // color: MyTheme.appBarThemeLight,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Center(
//                                     child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Text(widget.product.salesCount.toString(),
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             fontSize: 18)),
//                                     Text('Vendu dans les 365 derniers jours',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             )),
//                                   ],
//                                 )),
//                               ),
//                               Container(
//                                 margin: const EdgeInsets.all(6),
//                                 width: 140,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   // color: MyTheme.appBarThemeLight,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Center(
//                                     child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                         widget.product.purchasedProductQty
//                                             .toString(),
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             fontSize: 18)),
//                                     Text('Acheté dans les 365 derniers jours',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             // color: MyTheme.primaryTextLight,
//                                             )),
//                                   ],
//                                 )),
//                               )
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 10),
//                     width: 50,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       // color: MyTheme.kGreyColor,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: Container(
//       //   height: 70,
//       //   color: Colors.white,
//       //   padding: EdgeInsets.all(10),
//       //   child: Row(
//       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //     children: [
//       //       Container(
//       //         width: 50,
//       //         height: 50,
//       //         alignment: Alignment.center,
//       //         decoration: BoxDecoration(
//       //           borderRadius: BorderRadius.circular(10),
//       //           border: Border.all(color: MyTheme.kGreyColor),
//       //         ),
//       //         child: Icon(
//       //           Ionicons.heart_outline,
//       //           size: 30,
//       //           color: Colors.grey,
//       //         ),
//       //       ),
//       //       SizedBox(width: 20),
//       //       Expanded(
//       //         child: InkWell(
//       //           onTap: () {
//       //             addToCart();
//       //           },
//       //           child: Container(
//       //             alignment: Alignment.center,
//       //             decoration: BoxDecoration(
//       //               color: Colors.black,
//       //               borderRadius: BorderRadius.circular(15),
//       //             ),
//       //             child: Obx(
//       //               () => isAddLoading.value
//       //                   ? SizedBox(
//       //                       width: 20,
//       //                       height: 20,
//       //                       child: CircularProgressIndicator(
//       //                         color: Colors.white,
//       //                         strokeWidth: 3,
//       //                       ),
//       //                     )
//       //                   : Text(
//       //                       '+ Add to Cart',
//       //                       style: GoogleFonts.poppins(
//       //                         fontSize: 15,
//       //                         fontWeight: FontWeight.w500,
//       //                         color: Colors.white,
//       //                       ),
//       //                     ),
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }
