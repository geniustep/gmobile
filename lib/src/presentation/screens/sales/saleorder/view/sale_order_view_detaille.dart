// ignore: must_be_immutable
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/update_order_form.dart';

// ignore: must_be_immutable
class SaleOrderViewDetaille extends StatefulWidget {
  OrderModel salesOrder;
  SaleOrderViewDetaille({super.key, required this.salesOrder});

  @override
  State<SaleOrderViewDetaille> createState() => _SaleOrderViewDetailleState();
}

class _SaleOrderViewDetailleState extends State<SaleOrderViewDetaille> {
  PartnerModel partner = PartnerModel();

  bool isOrderLine = false;
  Map<String, dynamic> maps = <String, dynamic>{};

  var orderLine = <OrderLineModel>[].obs;
  var accountMove = <AccountMoveModel>[].obs;

  @override
  void initState() {
    partner = PrefUtils.partners
        .firstWhere((element) => element.id == widget.salesOrder.partnerId[0]);

    if (orderLine.isNotEmpty) {
      orderLine.assignAll(
        PrefUtils.orderLine
            .where((e) => widget.salesOrder.orderLine.contains(e.id))
            .toList(),
      );
    } else {
      List<int> ids = widget.salesOrder.orderLine.cast<int>();
      OrderLineModule.readOrderLines(
          ids: ids,
          onResponse: (response) {
            PrefUtils.orderLine.addAll(response);
            orderLine.assignAll(response);
          });
    }

    print(orderLine.length.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devis / ${widget.salesOrder.name}'),
        actions: <Widget>[
          if (widget.salesOrder.state != "sale" &&
              widget.salesOrder.state != "cancel")
            // update Order
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Get.to(() => UpdateOrder(
                    salesOrder: widget.salesOrder, orderLine: orderLine));
              },
            ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: Colors.grey.shade100,
            child: Column(
              children: [
                _buildButtonheader(),
                const Divider(),
                _buildButtonAction(),
                const Divider(),
              ],
            ),
          ), // الجزء الثابت العلوي

          Flexible(flex: 1, child: _bodyInfoOrder()), // محتوى الجسم
          const Divider(),
          Flexible(flex: 1, child: _buildItemsTableOrderLine()),
        ],
      ),
      bottomNavigationBar: _buildTotalSection(),
    );
  }

  Widget _buildButtonheader() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.salesOrder.invoiceCount > 0,
            child: TextButton(
                onPressed: () {
                  accountMove.assignAll(PrefUtils.accountMove
                      .where((p0) => p0.invoiceOrigin == widget.salesOrder.name)
                      .toList());
                  if (accountMove.isNotEmpty) {
                    if (accountMove.length == 1) {
                      // Get.find<Controller>().currentScreen.value = ScreenInfo(
                      //     builder: () => AccountMoveWindowsViewDetaille(
                      //         accountMove: accountMove[0]));
                    } else {
                      Get.dialog(
                        AlertDialog(
                          content: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                    List.generate(accountMove.length, (i) {
                                  return InkWell(
                                    child: Text(accountMove[i].name),
                                    onTap: () {
                                      // Get.find<Controller>()
                                      //         .currentScreen
                                      //         .value =
                                      //     ScreenInfo(
                                      //         builder: () =>
                                      //             AccountMoveWindowsViewDetaille(
                                      //                 accountMove:
                                      //                     accountMove[i]));
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.feed),
                    const SizedBox(
                      width: 6,
                    ),
                    Text("${widget.salesOrder.invoiceCount} Factures")
                  ],
                )),
          ),
          Visibility(
            visible: widget.salesOrder.deliveryCount > 0,
            child: TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    const Icon(Icons.delivery_dining_outlined),
                    const SizedBox(
                      width: 6,
                    ),
                    Text("${widget.salesOrder.deliveryCount} Livraisons")
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonAction() {
    setState(() {
      if (widget.salesOrder.orderLine.isEmpty) {
        isOrderLine = true;
      }
    });
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Button
                Visibility(visible: !isOrderLine, child: _buildLeftButtons()),
                // Status
                _buildDevisStatusWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyInfoOrder() {
    return Container(
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم العملاء
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSection("Clients:", [
                  Text(
                    widget.salesOrder.partnerId[1],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    partner.city.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ]), // قسم الاتصال
                _buildSection("Contact:", [
                  Text(
                    partner.phone.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    partner.email.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ]),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // قسم معلومات الطلب
                _buildSection("Date Order:", [
                  Text(widget.salesOrder.dateOrder.toString()),
                ]),
                const Divider(),
                _buildSection("Date Livraison:", [
                  Text(widget.salesOrder.commitmentDate.toString()),
                ]),
              ],
            ),

            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSection("Liste de Prix:", [
                  Text(
                    widget.salesOrder.pricelistId != false &&
                            widget.salesOrder.pricelistId != null
                        ? widget.salesOrder.pricelistId[1].toString()
                        : "null",
                  ),
                ]),
                _buildSection("Condition de paiment:", [
                  Text(
                    widget.salesOrder.paymentTermId != false &&
                            widget.salesOrder.paymentTermId != null
                        ? widget.salesOrder.paymentTermId[1].toString()
                        : "null",
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...content,
      ],
    );
  }

  void updateSaleOrderList(OrderModel order) {
    int index = PrefUtils.sales.indexWhere((element) => element.id == order.id);

    if (index != -1) {
      PrefUtils.sales[index] = order;
      PrefUtils.sales.refresh();
      setState(() {
        widget.salesOrder = order;
      });
    }
  }

  // void updateAccountMoveList(AccountMoveModel updatedMove) {
  //   int index = _controller.accountMove
  //       .indexWhere((element) => element.id == updatedMove.id);

  //   if (index != -1) {
  //     _controller.accountMove[index] = updatedMove;
  //     _controller.accountMove.refresh();
  //     PrefUtils.accountMove[index] = updatedMove;
  //     PrefUtils.accountMove.refresh();
  //   } else {
  //     _controller.accountMove.add(updatedMove);
  //     _controller.accountMove.refresh();
  //     PrefUtils.accountMove.add(updatedMove);
  //     PrefUtils.accountMove.refresh();
  //   }
  // }

  Future<void> updateOrder(int idAccount) async {
    await OrderModule.readOrders(
        ids: [widget.salesOrder.id],
        onResponse: (resOrder) async {
          if (resOrder.isNotEmpty) {
            OrderModel order = resOrder.first;
            updateSaleOrderList(order);
            // await AccountMoveModule.readInvoice(
            //     ids: [idAccount],
            //     onResponse: (resInvoice) async {
            //       PrefUtils.accountMove.addAll(resInvoice);
            //       for (var element in resInvoice) {
            //         updateAccountMoveList(element);
            //       }
            //     });
          }
        });
  }

  Widget _buildLeftButtons() {
    return Row(
      children: <Widget>[
        ButtonOrder(
          state: widget.salesOrder.state,
          order: widget.salesOrder,
          onUpdate: (idAccount) => updateOrder(idAccount),
        ),
        const SizedBox(width: 8.0),
        ButtonOrder(
          state: "annuler",
          order: widget.salesOrder,
          onUpdate: (idAccount) => updateOrder(idAccount),
        ),
      ],
    );
  }

  Widget _buildDevisStatusWidget() {
    bool isSale = false;
    bool isDraft = false;
    if (widget.salesOrder.state == 'sale') {
      setState(() {
        isSale = true;
        isDraft = true;
      });
    }
    if (widget.salesOrder.state == 'draft') {
      setState(() {
        isDraft = true;
      });
    }
    return Flexible(
        fit: FlexFit.loose,
        child: Container(
          width: 200,
          // padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StepItem(title: 'Devis', isActive: isDraft),
              const Expanded(child: Divider(color: Colors.green, thickness: 2)),
              StepItem(title: 'Bon de Commande', isActive: isSale),
            ],
          ),
        ));
  }

  Widget _buildItemsTableOrderLine() {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Obx(() {
            if (orderLine.isNotEmpty) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                        label: Text(
                      'Article',
                      // style: TextStyle(color: MyTheme.primaryTextLight),
                    )),
                    DataColumn(
                        label: Text(
                      'Quantité',
                      // style: TextStyle(color: MyTheme.primaryTextLight),
                    )),
                    DataColumn(
                        label: Text(
                      'Udm',
                      // style: TextStyle(color: MyTheme.primaryTextLight),
                    )),
                    DataColumn(
                        label: Text(
                      'Prix Unitaire',
                      // style: TextStyle(color: MyTheme.primaryTextLight),
                    )),
                    DataColumn(
                        label: Text(
                      'Sous-Total',
                      // style: TextStyle(color: MyTheme.primaryTextLight),
                    )),
                  ],
                  rows: List<DataRow>.generate(
                    orderLine.length,
                    (index) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text(orderLine[index].productId![1].toString())),
                        DataCell(
                            Text(orderLine[index].productUomQty.toString())),
                        DataCell(
                            Text(orderLine[index].productUom![1].toString())),
                        DataCell(Text(orderLine[index].priceUnit.toString())),
                        DataCell(Text(orderLine[index].priceTotal.toString())),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return BottomAppBar(
      shadowColor: Colors.blue,
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Montant HT: ${widget.salesOrder.amountUntaxed} DH'),
            Text('Taxes: ${widget.salesOrder.amountTax} DH'),
            Text('Total: ${widget.salesOrder.amountTotal} DH'),
          ],
        ),
      ),
    );
  }
}

class StepperWidget extends StatelessWidget {
  const StepperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StepItem(title: 'Devis', isActive: true),
          Expanded(child: Divider(color: Colors.green, thickness: 2)),
          StepItem(title: 'Bon de Commande', isActive: false),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonOrder extends StatefulWidget {
  final String state;
  OrderModel order;
  final Future<void> Function(int) onUpdate;

  ButtonOrder({
    super.key,
    required this.state,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<ButtonOrder> createState() => _ButtonOrderState();
}

class _ButtonOrderState extends State<ButtonOrder> {
  @override
  Widget build(BuildContext context) {
    String buttonText;
    void Function()? onPresseded;
    switch (widget.state) {
      case 'draft':
        buttonText = 'Confirm';
        onPresseded = () async {
          await OrderModule.confirmOrder(
              args: [widget.order.id],
              onResponse: (resConfirm) async {
                // Map<String, dynamic> maps = {};
                // maps['advance_payment_method'] = "delivered";
                // maps['fixed_amount'] = 0.00;
                // maps['amount'] = 0.00;
                if (widget.order.invoiceCount == 0) {
                  await widget.onUpdate(widget.order.id);
                  // await AccountMoveModule.createInvoiceSales(
                  // maps: maps,
                  // args: [],
                  // onResponse: (resCreateInvoice) async {

                  // await AccountMoveModule.createInvoiceCall(
                  //   id: widget.order.id,
                  //   args: [resCreateInvoice],
                  //   onResponse: (resCreateInvoCell) async {
                  //     int idAccount = resCreateInvoCell["res_id"];
                  //     await AccountMoveModule.comptabliseInvoiceSales(
                  //         args: [idAccount],
                  //         onResponse: (resCompta) async {
                  //           await widget.onUpdate(idAccount);
                  //         });
                  //   },
                  // );
                  // });
                }
              });
        };
        break;
      case 'annuler':
        buttonText = 'Annuler';
        onPresseded = () {
          OrderModule.cancelMethod(
              args: [widget.order.id],
              onResponse: (response) async {
                var newOrders = <OrderModel>[].obs;

                await Get.find<Controller>().getSalesController(
                  domain: [
                    [
                      "state",
                      "in",
                      ["draft", "sent", "sale", "done", "cancel"]
                    ],
                  ],
                  onResponse: (response) {
                    if (response != null) {
                      newOrders = Get.find<Controller>().sales;
                      PrefUtils.sales(newOrders);
                      widget.order =
                          newOrders.firstWhere((e) => e.id == widget.order.id);
                      if (widget.order.id != null) {
                        // Get.find<Controller>().currentScreen.value = ScreenInfo(
                        //     builder: () => SaleOrderWindowsViewDetaille(
                        //           salesOrder: widget.order,
                        //         ));
                      }
                    }
                  },
                );
              });
        };
        break;
      case 'cancel':
        buttonText = 'Mettre en Devis';
        onPresseded = () async {
          await OrderModule.Draft_method(
              args: [widget.order.id],
              onResponse: (response) async {
                if (response) {
                  var newOrders = <OrderModel>[].obs;
                  await Get.find<Controller>().getSalesController(
                    domain: [
                      [
                        "state",
                        "in",
                        ["draft", "sent", "sale", "done", "cancel"]
                      ],
                    ],
                    onResponse: (response) {
                      if (response != null) {
                        newOrders = Get.find<Controller>().sales;
                        PrefUtils.sales(newOrders);
                        widget.order = newOrders
                            .firstWhere((e) => e.id == widget.order.id);
                        if (widget.order.id != null) {
                          // Get.find<Controller>().currentScreen.value =
                          //     ScreenInfo(
                          //         builder: () => SaleOrderWindowsViewDetaille(
                          //               salesOrder: widget.order,
                          //             ));
                        }
                      }
                    },
                  );
                }
              });
        };
        break;
      default:
        buttonText = "";
    }
    return Center(
      child: buttonText == ""
          ? Container()
          : ElevatedButton(
              onPressed: onPresseded,
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Circular border
                  side: BorderSide.none, // No border
                ),
                padding: EdgeInsets.zero, // No padding
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.state == "annuler"
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : [Colors.lightBlue.shade300, Colors.blue.shade600],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                      maxWidth: 100.0, maxHeight: 30.0), // Button size
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class StepItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const StepItem({super.key, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF000000),
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
