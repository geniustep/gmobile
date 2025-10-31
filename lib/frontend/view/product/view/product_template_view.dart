import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/build_image.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/product_details.dart';
import 'package:gsloution_mobile/src/presentation/widgets/floating_aciton_button/custom_floating_action_button.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> with TickerProviderStateMixin {
  late TabController _tabController;
  final RxList<ProductModel> products =
      PrefUtils.products; // المنتجات من PrefUtils
  final List<String> categories = <String>[];
  final RxString filter = ''.obs; // النص المدخل للبحث
  final TextEditingController searchController =
      TextEditingController(); // للتحكم في النص
  bool isSearching = false; // حالة البحث

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // تجهيز التصنيفات من products.categId[1]
    categories.addAll(
      products
          .map((product) => (product.categ_id[1] ?? "Uncategorized").toString())
          .toSet()
          .cast<String>(),
    );

    // إعداد TabController بناءً على عدد التصنيفات
    _tabController = TabController(length: categories.length, vsync: this);
  }

  Future<void> scanBarcode() async {
    String? barcode = await Get.to(() => const BarcodeScannerPage());

    if (barcode != null && barcode.isNotEmpty) {
      // إدخال الباركود في مربع البحث
      searchController.text = barcode;
      setState(() {
        filter.value = barcode; // تحديث النص المدخل للبحث
        isSearching = true; // تفعيل البحث
      });
    } else {
      Get.snackbar(
        "Scan Cancelled",
        "No barcode was scanned.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose(); // تنظيف الحقل عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: PrefUtils.user.value.isAdmin == true
          ? const CustomFloatingActionButton(
              buttonName: "Add Product",
              routeName: AppRoutes.creatProduct,
            )
          // FloatingActionButton.extended(
          //     onPressed: () {
          //       Get.to(() => CreateProducts());
          //     },
          //     label: Text('Add New Product'))
          : Container(),
      appBar: AppBar(title: const Text("Products")),
      body: Column(
        children: [
          // خانة البحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // حقل البحث بالنص
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      filter.value = value; // تحديث النص المدخل للبحث
                      setState(() {
                        isSearching =
                            value.isNotEmpty; // تفعيل البحث إذا تم إدخال نص
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "Search for products...",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // زر المسح باستخدام الكاميرا
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: scanBarcode,
                ),
              ],
            ),
          ),
          // TabBar إذا لم يكن البحث مفعلاً
          if (!isSearching)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          // محتوى الصفحة
          Expanded(
            child: isSearching
                ? Obx(() => _buildSearchResults()) // عرض نتائج البحث
                : TabBarView(
                    controller: _tabController,
                    children: categories
                        .map(
                          (category) => Obx(() => _buildProductList(category)),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // تصفية المنتجات بناءً على النص المدخل أو الباركود
    final filteredProducts = products
        .where(
          (product) =>
              (product.name?.toLowerCase().contains(
                    filter.value.toLowerCase(),
                  ) ??
                  false) ||
              ((product.barcode is String &&
                  product.barcode.toLowerCase().contains(
                    filter.value.toLowerCase(),
                  ))),
        )
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products match your search."));
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildProductList(String category) {
    // تصفية المنتجات حسب الفئة categId[1]
    final filteredProducts = products
        .where(
          (product) =>
              (product.categ_id[1]?.toString() ?? "Uncategorized") == category,
        )
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text("No products available in this category."),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    String removeHtmlTags(String input) {
      return input.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildImage(
              image: kReleaseMode
                  ? product.image_512
                  : "assets/images/other/empty_product.png",
              width: MediaQuery.of(context).size.width * 0.2,
              height: 200,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? "Unknown Product",
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // fontSize: widget.isSmallScreen ? 16 : 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.description != false && product.description != null
                      ? removeHtmlTags(product.description)
                      : "No description available.",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  '${product.lst_price?.toStringAsFixed(2) ?? "0.00"} Dh',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
