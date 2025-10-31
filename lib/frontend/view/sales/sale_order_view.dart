import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

import '../../../common/config/import.dart';

class SaleOrderView extends StatefulWidget {
  const SaleOrderView({super.key});

  @override
  _SaleOrderViewState createState() => _SaleOrderViewState();
}

class _SaleOrderViewState extends State<SaleOrderView> {
  var quotations = <OrderModel>[].obs;

  final List<Map<String, dynamic>> quotationsss = PrefUtils.sales.map((sale) {
    return {
      'customer': sale.partnerId[1]?.toString() ?? 'Unknown',
      'id': sale.name ?? 'N/A',
      'date': sale.dateOrder ?? 'Unknown',
      'status': sale.state ?? 'Unknown',
      'amount': sale.amountTotal?.toString() ?? '0.00 DH',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'activities': Icons.schedule_outlined,
    };
  }).toList();

  final List<Map<String, dynamic>> quotationss = [
    {
      'customer': PrefUtils.sales[0].partnerId[0].toString(),
      'id': PrefUtils.sales[0].name,
      'date': PrefUtils.sales[0].dateOrder,
      'status': PrefUtils.sales[0].state,
      'amount': PrefUtils.sales[0].amountTotal,
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'activities': Icons.schedule_outlined,
    },
    {
      'customer': 'Gemini Furniture',
      'id': 'S00007',
      'date': '11/19/2024 20:56:12',
      'status': 'Sales Order',
      'amount': '1,706.00 DH',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'activities': Icons.schedule_outlined,
    },
    {
      'customer': 'Ready Mat',
      'id': 'S00003',
      'date': '11/19/2024 20:56:12',
      'status': 'Quotation',
      'amount': '377.50 DH',
      'icon': Icons.mail_outline,
      'iconColor': Colors.orange,
      'activities': Icons.schedule_outlined,
    },
    {
      'customer': 'YourCompany, Joel Willis',
      'id': 'S00019',
      'date': '10/19/2024 20:56:00',
      'status': 'Quotation Sent',
      'amount': '1,740.00 DH',
      'icon': Icons.send,
      'iconColor': Colors.purple,
      'activities': Icons.schedule_outlined,
    },
  ];

  List<dynamic> filteredQuotations = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    quotations = PrefUtils.sales;
    filteredQuotations = quotations;
  }

  void _filterQuotations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredQuotations = quotations;
      } else {
        filteredQuotations = quotations
            .where((quotation) =>
                quotation.partnerId[1]
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                quotation.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: _filterQuotations,
              )
            : const Text('Quotations'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) filteredQuotations = quotations;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredQuotations.length,
        itemBuilder: (context, index) {
          final quotation = filteredQuotations[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: ListTile(
              // leading: Icon(
              //   quotation['icon'],
              //   color: quotation['iconColor'],
              // ),
              title: Text(
                quotation.partnerId[1],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Text(quotation.activityIds.toString()),
                  // Icon(
                  //   quotation['activities'],
                  //   color: Colors.grey,
                  //   size: 16.0,
                  // ),
                  const SizedBox(width: 5.0),
                  Text('${quotation.name} ${quotation.dateOrder}'),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quotation.amountTotal.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    quotation.state,
                    style: TextStyle(
                      color: _getStatusColor(quotation.state),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // _showDetails(context, quotation);
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.green;
      case 'sale':
        return Colors.blue;
      case 'sent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDetails(BuildContext context, Map<String, dynamic> quotation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quotation Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${quotation['customer']}'),
              Text('ID: ${quotation['id']}'),
              Text('Date: ${quotation['date']}'),
              Text('Status: ${quotation['status']}'),
              Text('Amount: ${quotation['amount']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
