import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/product_details.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/product_reels_viewer.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/update_product_screen.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';

class ProductListSection extends StatefulWidget {
  final bool isSmallScreen;
  final RxList<ProductModel> productList;
  final bool isGridView;
  final int gridColumns; // 🆕 عدد الأعمدة في GridView

  const ProductListSection({
    super.key,
    required this.isSmallScreen,
    required this.productList,
    required this.isGridView,
    this.gridColumns = 2, // افتراضيًا جوج أعمدة
  });

  @override
  State<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends State<ProductListSection> {
  bool isChampsValid(dynamic champs) {
    return champs != null && champs != false && champs != "";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.productList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/other/empty_product.png", width: 350),
              Text(
                "No Product Found",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        );
      } else {
        return widget.isGridView
            ? GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.gridColumns, // 🆕 نستخدم البارامتر
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: widget.productList.length,
                itemBuilder: (context, index) {
                  final product = widget.productList[index];
                  final int id = product.product_tmpl_id != null
                      ? product.product_tmpl_id[0]
                      : product.id;

                  return _buildProductCard(product, id, index);
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.productList.length,
                itemBuilder: (context, index) {
                  final product = widget.productList[index];
                  final int id = product.product_tmpl_id != null
                      ? product.product_tmpl_id[0]
                      : product.id;

                  return _buildProductRow(product, id, index);
                },
              );
      }
    });
  }

  /// 🆕 تصميم البطاقة للـ GridView
  Widget _buildProductCard(ProductModel product, int id, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                // Open Instagram Reels-style viewer on image tap
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductReelsViewer(
                      products: widget.productList,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDialogEdit(
                  context: context,
                  product: product,
                  id: id,
                  index: index,
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: buildImage(
                  image: kReleaseMode
                      ? (isChampsValid(product.image_512)
                            ? product.image_512
                            : "assets/images/other/empty_product.png")
                      : "assets/images/other/empty_product.png",
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // Go to product details
              Get.to(
                () => ProductDetails(product: product),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Stock: ${product.qty_available}",
                    style: GoogleFonts.nunito(),
                  ),
                  Text(
                    "Price: ${product.lst_price} Dh",
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 تصميم العنصر للـ ListView
  Widget _buildProductRow(ProductModel product, int id, int index) {
    return InkWell(
      onLongPress: () {
        showDialogEdit(
          context: context,
          product: product,
          id: id,
          index: index,
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // photo + code
            InkWell(
              onTap: () {
                // Open Instagram Reels-style viewer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductReelsViewer(
                      products: widget.productList,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImage(
                      image: kReleaseMode
                          ? product.image_512
                          : "assets/images/other/empty_product.png",
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                    ),
                  ),
                  Text(
                    "[ ${product.default_code ?? ""} ]",
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 10 : 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // texts name, stock, price
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      product.name,
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isSmallScreen ? 12 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(
                        () => ProductDetails(
                          product: product,
                          // productList: widget.productList,
                          // currentIndex: index,
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Stock: ${product.qty_available}",
                            style: GoogleFonts.nunito(),
                          ),
                          Text(
                            "Price: ${product.lst_price} Dh",
                            style: GoogleFonts.nunito(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 BottomSheet للتعديل
  void buildModalBottomSheet(BuildContext context, dynamic product) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: UpdateProductScreen(product: product),
        );
      },
    );
  }

  // 🗑️ Dialog للتعديل/الحذف
  void showDialogEdit({
    required BuildContext context,
    required dynamic product,
    required int id,
    required int index,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Product"),
          content: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue.shade50.withOpacity(0.3),
                  ),
                  child: IconButton(
                    icon: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SvgPicture.asset(
                        "assets/icons/icon_svg/edit_icon.svg",
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      buildModalBottomSheet(context, product);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.red.shade50.withOpacity(0.3),
                  ),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text("Delete!"),
                            content: Text(
                              'Do you want to delete "${product.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final validContext = context;

                                  // تنفيذ عملية الحذف
                                  ProductModule.deleteProduct(
                                    context: context,
                                    id: id,
                                    onResponse: (response) {
                                      if (response) {
                                        PrefUtils.products.removeWhere((p) {
                                          if (p.product_tmpl_id != null &&
                                              id == p.product_tmpl_id[0]) {
                                            return true;
                                          } else if (id == p.id) {
                                            return true;
                                          }
                                          return false;
                                        });

                                        PrefUtils.setProducts(
                                          PrefUtils.products,
                                        );
                                        DeleteToast.showDeleteToast(
                                          validContext,
                                          product.name,
                                        );

                                        if (mounted) {
                                          setState(() {
                                            widget.productList.removeAt(index);
                                          });
                                        }
                                      }
                                    },
                                  );
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/icon_svg/delete_icon.svg",
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
