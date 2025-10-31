import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/main_container.dart';
import 'package:gsloution_mobile/routes.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MainContainer(
      isAppBar: true,
      isAppBarWidget: true,
      name: PrefUtils.user.value.name.toString().toUpperCase(),
      post: PrefUtils.user.value.username.toString().toUpperCase(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Today Reports Section
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.blue.shade50,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today Reports',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('View'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: _buildReportItem(
                              title: 'Objectif',
                              value: '1 000 000 Dhs',
                              icon: Icons.sell,
                              color: Colors.lightBlue.shade100,
                            ),
                          ),
                          Flexible(
                            child: _buildReportItem(
                              title: 'Sales',
                              value: '70 000 Dhs',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.lightBlue.shade300,
                            ),
                          ),
                          Flexible(
                            child: _buildReportItem(
                              title: 'Pecentage',
                              value: '70%',
                              icon: Icons.account_balance_wallet,
                              color: Colors.lightBlue.shade100,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Grid Section
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              children: [
                _buildGridItem(
                  title: 'Products',
                  icon: Icons.inventory,
                  color: Colors.redAccent,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Trading',
                  icon: Icons.bar_chart,
                  color: Colors.green,
                  route: AppRoutes.sales,
                ),
                _buildGridItem(
                  title: 'Expenses',
                  icon: Icons.money_off,
                  color: Colors.orange,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'POS',
                  icon: Icons.point_of_sale,
                  color: Colors.pink,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Sale',
                  icon: Icons.shopping_cart,
                  color: Colors.red,
                  route: AppRoutes.sales,
                ),
                _buildGridItem(
                  title: 'Purchase',
                  icon: Icons.local_mall,
                  color: Colors.blueGrey,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Product',
                  icon: Icons.category,
                  color: Colors.greenAccent,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Expense',
                  icon: Icons.receipt,
                  color: Colors.lightBlue,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Manage',
                  icon: Icons.group,
                  color: Colors.pinkAccent,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Report',
                  icon: Icons.insert_chart,
                  color: Colors.brown,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Warehouse',
                  icon: Icons.warehouse,
                  color: Colors.tealAccent,
                  route: AppRoutes.products,
                ),
                _buildGridItem(
                  title: 'Peoples',
                  icon: Icons.people,
                  color: Colors.teal,
                  route: AppRoutes.products,
                ),
              ],
            ),

            // Banner Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    // Image.network(
                    //   'https://via.placeholder.com/300x100.png?text=20%+OFF',
                    //   fit: BoxFit.cover,
                    // ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Select Your Favourite Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildReportItem({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    height: 120,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: value.length <= 12
                ? 14
                : value.length <= 13
                ? 13
                : value.length <= 15
                ? 11
                : 8,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    ),
  );
}

Widget _buildGridItem({
  required String title,
  required IconData icon,
  required Color color,
  required String route,
}) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(route);
    },
    child: Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.01),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
