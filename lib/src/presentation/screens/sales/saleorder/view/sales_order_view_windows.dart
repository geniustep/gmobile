// import 'package:g_solution/import/import_file.dart';
// import 'package:g_solution/view/saleorder/create/create_order_form.dart';

// class SalesOrderWindowsView extends StatefulWidget {
//   final RxList<OrderModel> salesOrder;
//   final RxList<AccountMoveModel> accountMove;
//   final RxList<PartnerModel> partners;
//   const SalesOrderWindowsView(
//       {required this.salesOrder,
//       required this.accountMove,
//       required this.partners,
//       super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _SalesOrderState createState() => _SalesOrderState();
// }

// class _SalesOrderState extends State<SalesOrderWindowsView> {
//   List<AccountJournalModel> ownAccountJournal = [];
//   AccountMoveModel thisAccountMove = AccountMoveModel();
//   var salesOrder = <OrderModel>[].obs;
//   ScrollController scrollController = ScrollController();
//   bool isLoading = false;
//   int size = 0;
//   String? startDateFormat;
//   DateTime? endDateFormat;
//   bool byMonth = true;
//   String? initTime;
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
//       if (picked != null) {
//         startDateFormat = picked.start.toString();
//         endDateFormat = picked.end;
//       }
//     }).whenComplete(() {
//       widget.salesOrder;
//       size = 0;
//       onResponse();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     scrollController.addListener(() {
//       if (widget.salesOrder.length < size && !isLoading) {
//         startLoader();
//       }
//     });

//     var month = firstMonth.toString().padLeft(2, '0');
//     initTime =
//         DateFormat("yyyy-MM-dd").format(DateTime.parse('$firstYear-$month-01'));
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
//     var month = firstMonth.toString().padLeft(2, '0');
//     List<dynamic> domain = [
//       [
//         "state",
//         "in",
//         ["draft", "sent", "sale", "done"]
//       ],
//       [
//         'create_date',
//         ">=",
//         startDateFormat ?? DateTime.parse("$firstYear-$month-01").toString()
//       ],
//       [
//         'create_date',
//         '<=',
//         endDateFormat != null
//             ? endDateFormat!.add(const Duration(days: 1)).toString()
//             : DateTime.now().toString()
//       ],
//     ];
//   }

// // Create advance payment
//   final _formKey = GlobalKey<FormBuilderState>();
//   final bool _noteHasError = false;
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
//                           AccountMoveModule.comptabliseInvoiceSales(
//                               args: [responseSaleAdvance["res_id"]],
//                               onResponse: (response) {
//                                 // don't invoke 'print' in production code. try using a logging framework.
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

//   List<OrderModel>? getsalesOrder() {
//     if (byMonth) {
//       salesOrder.assignAll(widget.salesOrder.where((p0) {
//         final isAfterStart =
//             p0.dateOrder.compareTo(startDateFormat ?? initTime) >= 0;
//         final isBeforeEnd = p0.dateOrder.compareTo(endDateFormat != null
//                 ? endDateFormat!.add(const Duration(days: 1)).toString()
//                 : DateTime.now().toString()) <=
//             0;
//         return isAfterStart && isBeforeEnd;
//       }).toList());
//     } else {
//       return widget.salesOrder;
//     }
//     return widget.salesOrder;
//   }

//   @override
//   Widget build(BuildContext context) {
//     String formattedMonth = DateFormat('MMMM').format(DateTime.now());
//     return Scaffold(
//         appBar: AppBar(
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   Get.find<Controller>().currentScreen.value =
//                       ScreenInfo(builder: () => const CreateOrder());
//                 },
//                 icon: const Icon(Icons.shop)),
//             // const Icon(Icons.keyboard_arrow_down),
//             IconButton(
//               tooltip: !byMonth ? 'Display $formattedMonth' : 'display All',
//               icon: Icon(
//                 byMonth ? Icons.check_box : Icons.check_box_outline_blank,
//               ),
//               onPressed: () {
//                 setState(() {
//                   byMonth = !byMonth;
//                 });
//               },
//             ),
//             IconButton(
//               icon: const Icon(
//                 Icons.calendar_month,
//               ),
//               onPressed: () {
//                 getRangeTime();
//               },
//             )
//           ],
//         ),
//         body: GroupedListView<OrderModel, String>(
//           elements: getsalesOrder()!,
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

//             newPartner = widget.partners.firstWhereOrNull(
//                 (element) => element.id == salesOrders.partnerId[0]);

//             if (widget.accountMove.isNotEmpty) {
//               var aux = widget.accountMove.where((element) =>
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
//                       thisAccountMove.id != null
//                           ? thisAccountMove.name.toString().toUpperCase()
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
//                                         Get.find<Controller>()
//                                                 .currentScreen
//                                                 .value =
//                                             ScreenInfo(
//                                                 builder: () =>
//                                                     ProfilePage(newPartner!));
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
//                                   Get.find<Controller>().currentScreen.value =
//                                       ScreenInfo(
//                                           builder: () =>
//                                               SaleOrderWindowsViewDetaille(
//                                                 salesOrder: salesOrders,
//                                               ));
//                                   // OrderLineModule.readOrderLines(
//                                   //     ids: salesOrders.orderLine!.cast<int>(),
//                                   //     onResponse: (response) {
//                                   //       AccountJournalModule
//                                   //           .searchReadAccountJournal(
//                                   //               domain: [],
//                                   //               onResponse: ((responseJournal) {
//                                   //                 size = responseJournal.keys
//                                   //                     .toList()[0];
//                                   //                 if (PrefUtils
//                                   //                         .theUser!.banqeId !=
//                                   //                     false) {
//                                   //                   ownAccountJournal =
//                                   //                       responseJournal[size]!
//                                   //                           .where((e) =>
//                                   //                               e.displayName ==
//                                   //                               PrefUtils
//                                   //                                   .theUser!
//                                   //                                   .banqeId[1])
//                                   //                           .toList();
//                                   //                 } else {
//                                   //                   ownAccountJournal =
//                                   //                       responseJournal[size]!
//                                   //                           .where((e) =>
//                                   //                               e.id == 6 ||
//                                   //                               e.id == 7)
//                                   //                           .toList();
//                                   //                 }

//                                   //                 Get.find<Controller>()
//                                   //                         .currentScreen
//                                   //                         .value =
//                                   //                     ScreenInfo(
//                                   //                         builder: () => SalesDetails(
//                                   //                             ownAccountJournal,
//                                   //                             thisAccountMove,
//                                   //                             salesOrders,
//                                   //                             response,
//                                   //                             newPartner!));
//                                   //               }));
//                                   //     });
//                                 },
//                                 child: Icon(Icons.more_vert)),
//                           ),
//                           ElevatedButton(
//                               onPressed: () {
//                                 OrderModule.confirmOrder(
//                                   args: [salesOrders.id!],
//                                   onResponse: (response) {
//                                     createAdvancePaiment(salesOrders);
//                                   },
//                                 );
//                               },
//                               child: Text("Confirm"))
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
