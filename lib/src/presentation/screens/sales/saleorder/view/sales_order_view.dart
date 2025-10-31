// import 'package:g_solution/import/import_file.dart';

// class SalesOrderView extends StatefulWidget {
//   const SalesOrderView({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _SalesOrderState createState() => _SalesOrderState();
// }

// class _SalesOrderState extends State<SalesOrderView> {
//   final Controller _controller = Get.put(Controller());
//   var salesOrder = <OrderModel>[].obs;
//   var accountMove = <AccountMoveModel>[].obs;
//   var partners = <PartnerModel>[].obs;

//   List<AccountJournalModel> ownAccountJournal = [];
//   var thisAccountMove;

//   ScrollController scrollController = ScrollController();
//   bool isLoading = false;
//   int size = 0;
//   String? startDateFormat;
//   DateTime? endDateFormat;

//   var initTime;
//   var firstMonth = DateTime.now().month;

//   var firstYear = DateTime.now().year;
//   getRangeTime() {
//     var month = firstMonth.toString().padLeft(2, '0');
//     showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(
//           start: DateTime.parse("$firstYear-$month-01"), end: DateTime.now()),
//       lastDate: DateTime.now(),
//       firstDate: DateTime(firstYear),
//     ).then((picked) {
//       startDateFormat = picked!.start.toString();
//       endDateFormat = picked.end;
//     }).whenComplete(() {
//       salesOrder;
//       size = 0;
//       onResponse();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     scrollController.addListener(() {
//       if (salesOrder.length < size && !isLoading) {
//         startLoader();
//       }
//     });

//     _controller.getAccuontMoveController(
//       domain: [],
//       onResponse: (response) {
//         if (response != null) {
//           accountMove = _controller.accountMove;
//         }
//       },
//     );

//     var month = firstMonth.toString().padLeft(2, '0');
//     initTime =
//         DateFormat("yyyy-MM-dd").format(DateTime.parse('$firstYear-$month-01'));

//     List<dynamic> domain = [
//       [
//         "state",
//         "in",
//         ["draft", "sent", "sale", "done", "cancel"]
//       ],
//       ['create_date', ">=", startDateFormat ?? initTime],
//       [
//         'create_date',
//         '<=',
//         endDateFormat != null
//             ? endDateFormat!.add(Duration(days: 1)).toString()
//             : DateTime.now().toString()
//       ],
//     ];

//     _controller.getSaleOrderController(
//       domain: domain,
//       onResponse: (response) {
//         if (response != null) {
//           salesOrder = _controller.salesOrder;
//           PrefUtils.setSaleOrder(salesOrder);
//         }
//       },
//     );

//     if (PrefUtils.partners.isNotEmpty) {
//       partners = RxList<PartnerModel>.from(
//           PrefUtils.partners.where((p0) => p0.customerRank > 0).toList());
//     } else {
//       List<dynamic> domain = [
//         ['customer_rank', '>', 0],
//       ];
//       _controller.getPartnersController(
//           domain: domain,
//           onResponse: (response) {
//             setState(() {
//               if (response != null && _controller.partner.isNotEmpty) {
//                 partners = _controller.partner;
//               }
//             });
//           });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     scrollController.dispose();
//   }

//   void startLoader() {
//     setState(() {
//       isLoading = !isLoading;
//       fetchData();
//     });
//   }

//   fetchData() async {
//     return Timer(const Duration(seconds: 1), onResponse);
//   }

//   void onResponse() async {
//     // var month = firstMonth.toString().padLeft(2, '0');
//     PrefUtils.getSaleOrder();
//     // List<dynamic> domain = [
//     //   [
//     //     "state",
//     //     "in",
//     //     ["draft", "sent", "sale", "done"]
//     //   ],
//     //   [
//     //     'create_date',
//     //     ">=",
//     //     startDateFormat ?? DateTime.parse("$firstYear-$month-01").toString()
//     //   ],
//     //   [
//     //     'create_date',
//     //     '<=',
//     //     endDateFormat != null
//     //         ? endDateFormat!.add(const Duration(days: 1)).toString()
//     //         : DateTime.now().toString()
//     //   ],
//     // ];
//     // await OrderModule.searchReadOrders(
//     //     domain: domain,
//     //     offset: salesOrder.length,
//     //     onResponse: ((response) {
//     //       setState(() {
//     //         size = response.keys.toList()[0];
//     //         salesOrder.addAll(response[response.keys.toList()[0]]!);
//     //         isLoading = !isLoading;
//     //       });
//     //     }));
//   }

//   // Future<RxList<PartnerModel>> getPartners(
//   //     RxList<PartnerModel> partners) async {
//   //   List<dynamic> domain = [];
//   //   // domain.add();
//   //   await PartnerModule.searchReadPartners(
//   //     domain: [],
//   //     onResponse: ((response) {
//   //       setState(() {
//   //         partners.addAll(response[response.keys.toList()[0]]!);
//   //       });
//   //     }),
//   //   );
//   //   return partners;
//   // }

// // Create advance payment
//   final _formKey = GlobalKey<FormBuilderState>();
//   bool _noteHasError = false;
//   createAdvancePaiment(OrderModel salesOrder) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         title: Text(
//           "Payment",
//           style: AppFont.Title_H4_Medium(),
//         ),
//         content: FormBuilder(
//           key: _formKey,
//           onChanged: () {
//             _formKey.currentState!.save();
//             debugPrint(_formKey.currentState!.value.toString());
//           },
//           autovalidateMode: AutovalidateMode.disabled,
//           skipDisabled: true,
//           child: FormBuilderTextField(
//             autovalidateMode: AutovalidateMode.always,
//             name: 'fixed_amount',
//             decoration: InputDecoration(
//               hintText: 'Payment',
//               labelText: 'Payment',
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
//               debugPrint(_formKey.currentState?.value.toString());
//               Map<String, dynamic>? maps = _formKey.currentState?.value;
//               Map<String, dynamic> newMap = Map.from(maps!);
//               if (_formKey.currentState!.value.isNotEmpty) {
//                 newMap['advance_payment_method'] = "fixed";
//                 newMap['amount'] = 0;
//                 newMap['deduct_down_payments'] = true;
//               } else {
//                 newMap['advance_payment_method'] = "delivered";
//                 newMap['fixed_amount'] = 0.00;
//                 newMap['amount'] = 0.00;
//               }
//               newMap['count'] = 1;
//               newMap['currency_id'] = 112;

//               AccountMoveModule.createInvoiceSales(
//                   maps: newMap,
//                   onResponse: (response) {
//                     AccountMoveModule.createInvoiceCall(
//                         args: [response],
//                         id: salesOrder.id!,
//                         onResponse: (responseSaleAdvance) {
//                           print(responseSaleAdvance);
//                           AccountMoveModule.comptabliseInvoiceSales(
//                               args: [responseSaleAdvance["res_id"]],
//                               onResponse: (response) {
//                                 print("created");
//                               });
//                         });
//                   },
//                   args: []);
//             },
//             child: Text(
//               Localize.create.tr,
//               style: AppFont.Body2_Regular(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _selectedItem = -1;
//   @override
//   Widget build(BuildContext context) {
//     return MainContainer(
//         leading: Center(
//             child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Badge(
//             backgroundColor: MyTheme.primaryTextLight,
//             label: Text(salesOrder.length.toString()),
//             child: Container(),
//           ),
//         )),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.calendar_month,
//             ),
//             onPressed: () {
//               getRangeTime();
//             },
//           )
//         ],
//         // appBarTitle: 'Bons de Commande',
//         // appBarTitleWidget: Text('test'),
//         padding: 1,
//         child: GroupedListView<OrderModel, String>(
//           elements: salesOrder,
//           groupBy: ((g) => g.dateOrder != false
//               ? g.dateOrder.toString().split(' ').first
//               : ""),
//           controller: scrollController,
//           groupSeparatorBuilder: (String groupByValue) {
//             return Card(
//                 color: MyTheme.appBarThemeLight,
//                 elevation: 9,
//                 child: ListTile(
//                     title: Text(
//                   groupByValue.toUpperCase(),
//                 )));
//           },
//           itemComparator: (item2, item1) => item1.name
//               .toString()
//               .toUpperCase()
//               .compareTo(item2.name.toString().toUpperCase()),
//           useStickyGroupSeparators: true,
//           order: GroupedListOrder.DESC,
//           indexedItemBuilder: (context, OrderModel salesOrders, int index) {
//             PartnerModel? newPartner = PartnerModel();
//             if (partners.isNotEmpty) {
//               newPartner = partners.firstWhereOrNull(
//                   (element) => element.id == salesOrders.partnerId[0]);
//             }
//             if (accountMove.isNotEmpty) {
//               var aux = accountMove.where((element) =>
//                   element.invoiceOrigin != false &&
//                   element.invoiceOrigin == salesOrders.name);
//               if (aux.isNotEmpty) {
//                 thisAccountMove = aux.first;
//               }
//             }
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 ExpansionTile(
//                   key: Key('selected $_selectedItem'),
//                   initiallyExpanded: index == _selectedItem,
//                   onExpansionChanged: ((isOpen) {
//                     if (isOpen) {
//                       setState(() {
//                         _selectedItem = index;
//                       });
//                     }
//                   }),
//                   title: ListTile(
//                     leading: Text(
//                       thisAccountMove != null
//                           ? thisAccountMove!.name.toString().toUpperCase()
//                           : "null",
//                     ),
//                     title: Text(
//                       salesOrders.name.toString().toUpperCase(),
//                     ),
//                     subtitle: Text(
//                       newPartner != null
//                           ? newPartner.name.toString().toUpperCase()
//                           : "",
//                     ),
//                     trailing: Text(
//                       "${salesOrders.userId[1]}\n is: ${salesOrders.state.toString().toUpperCase()}",
//                     ),
//                   ),
//                   children: <Widget>[
//                     Column(children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8.0),
//                             child: GestureDetector(
//                                 onTap: () {
//                                   PartnerModule.readPartners(
//                                       ids: [newPartner!.id],
//                                       onResponse: ((response) {
//                                         Get.to(Partner(newPartner!));
//                                       }));
//                                 },
//                                 child: const Icon(
//                                   Icons.manage_accounts,
//                                   color: Colors.green,
//                                 )),
//                           ),
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8.0),
//                             child: GestureDetector(
//                                 onTap: () {
//                                   OrderLineModule.readOrderLines(
//                                       ids: salesOrders.orderLine!.cast<int>(),
//                                       onResponse: (response) {
//                                         AccountJournalModule
//                                             .searchReadAccountJournal(
//                                                 domain: [],
//                                                 onResponse: ((responseJournal) {
//                                                   size = responseJournal.keys
//                                                       .toList()[0];
//                                                   if (PrefUtils
//                                                           .theUser!.banqeId !=
//                                                       null) {
//                                                     ownAccountJournal =
//                                                         responseJournal[size]!
//                                                             .where((e) =>
//                                                                 e.displayName ==
//                                                                 PrefUtils
//                                                                     .theUser!
//                                                                     .banqeId[1])
//                                                             .toList();
//                                                   } else {
//                                                     ownAccountJournal =
//                                                         responseJournal[size]!
//                                                             .where((e) =>
//                                                                 e.id == 6 ||
//                                                                 e.id == 7)
//                                                             .toList();
//                                                   }

//                                                   Get.to(SalesDetails(
//                                                       ownAccountJournal,
//                                                       thisAccountMove,
//                                                       salesOrders,
//                                                       response,
//                                                       newPartner!));
//                                                 }));
//                                       });
//                                 },
//                                 child: Icon(Icons.more_vert)),
//                           ),
//                           PrefUtils.Employee != null &&
//                                   PrefUtils.Employee!.jobTitle ==
//                                       'Sales Manager'
//                               ? salesOrders.state != "draft"
//                                   ? ElevatedButton(
//                                       onPressed: () {
//                                         OrderModule.confirmOrder(
//                                           args: [salesOrders.id!],
//                                           onResponse: (response) {
//                                             createAdvancePaiment(salesOrders);
//                                           },
//                                         );
//                                       },
//                                       child: Text("Confirm"))
//                                   : Container()
//                               : Container()
//                         ],
//                       )
//                     ]),
//                     ListTile(
//                       title: Text("Total: ${salesOrders.amountTotal} Dhs"),
//                       subtitle: Text(PrefUtils.Employee != null &&
//                               PrefUtils.Employee!.jobTitle == 'Sales Manager'
//                           ? "Marge: ${salesOrders.margin} Dhs"
//                           : ""),
//                       isThreeLine: true,
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ));
//   }
// }
