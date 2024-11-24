import 'dart:async';

import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'dart:typed_data';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> with TickerProviderStateMixin {
  TabController? controller;
  List<String> prdtCategory = [];
  Map<int, ProductModel> productsFiltry = {};
  var products = <ProductModel>[].obs;
  // var stockQuant = <StockQuantModel>[].obs;
  // var stockWarehouse = <StockWarehouseModel>[].obs;
  // var stockLocation = <StockLocationModel>[].obs;
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int size = 0;

  // Future<RxList<StockQuantModel>> getStockQuant(
  //     RxList<StockQuantModel> stockQuant) async {
  //   await StockQuantModule.searchStockQuant(
  //     domain: [
  //       ["on_hand", "=", true],
  //     ],
  //     onResponse: ((response) {
  //       setState(() {
  //         stockQuant.addAll(response[response.keys.toList()[0]]!);
  //       });
  //     }),
  //   );
  //   return stockQuant;
  // }

  // Future<RxList<StockWarehouseModel>> getStockwarhouse(
  //     RxList<StockWarehouseModel> stockWarehouse) async {
  //   await StockWarehouseModule.searchStockWarehouse(
  //     domain: [],
  //     onResponse: ((response) {
  //       setState(() {
  //         stockWarehouse.addAll(response[response.keys.toList()[0]]!);
  //       });
  //     }),
  //   );
  //   return stockWarehouse;
  // }

  String filter = "";
  var producto = <ProductModel>[].obs;
  var productFilter;

  @override
  void initState() {
    super.initState();
    // PrefUtils.theUser;
    // PrefUtils.Employee;
    PrefUtils.products;
    // getStockwarhouse(stockWarehouse);
    // getStockQuant(stockQuant);
    // scrollController.addListener(() {
    //   if (PrefUtils.products.length < size && !isLoading) {
    //     startLoader();
    //   }
    // });

    setState(() {
      getProductCategory();
      for (ProductModel element in PrefUtils.products) {
        // productsFiltry[element.id] = element;
        producto.add(element);
      }
      controller = TabController(length: prdtCategory.length, vsync: this, initialIndex: 0);
      controller!.addListener(onPositionChange);
    });

    // List<dynamic> domain = [
    //   "&",
    //   "&",
    //   "&",
    //   ["sale_ok", "=", "True"],
    //   [
    //     "type",
    //     "in",
    //     ["consu", "product"]
    //   ],
    //   ["can_be_expensed", "!=", "True"],
    //   ["active", "=", "True"],
    // ];
    // ProductModule.searchReadProducts(
    //     domain: domain,
    //     onResponse: (response) {
    //       setState(() {
    //         size = response.keys.toList()[0];
    //         products.addAll(response[size]!);
    //         getProductCategory();
    //         for (ProductModel element in products
    //             .where((element) => element.categId[1] == prdtCategory[0])
    //             .toList()) {
    //           productsFiltry[element.id] = element;
    //           producto.add(element);
    //         }
    //         controller = TabController(
    //             length: prdtCategory.length, vsync: this, initialIndex: 0);
    //         controller!.addListener(onPositionChange);
    //       });
    //     });
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller!.removeListener(onPositionChange);
      controller!.dispose();
    }
    scrollController.dispose();
  }

  void startLoader() {
    setState(() {
      isLoading = !isLoading;
      fetchData();
    });
  }

  fetchData() async {
    return Timer(const Duration(milliseconds: 10), onResponse);
  }

  void onResponse() {
    setState(() {
      getProductCategory();
      // for (ProductModel element in PrefUtils.products
      //     .where((element) => element.categId[1] == prdtCategory[0])
      //     .toList()) {
      //   productsFiltry[element.id] = element;
      //   producto.add(element);
      // }

      controller = TabController(length: prdtCategory.length, vsync: this, initialIndex: 0);
    });

    // List<dynamic> domain = [
    //   "&",
    //   "&",
    //   "&",
    //   ["sale_ok", "=", "True"],
    //   [
    //     "type",
    //     "in",
    //     ["consu", "product"]
    //   ],
    //   ["can_be_expensed", "!=", "True"],
    //   ["active", "=", "True"],
    // ];
    // ProductModule.searchReadProducts(
    //     domain: domain,
    //     offset: products.length,
    //     onResponse: (response) {
    //       setState(() {
    //         products.addAll(response[response.keys.toList()[0]]!);
    //         isLoading = !isLoading;
    //         getProductCategory();
    //         for (ProductModel element in products
    //             .where((element) => element.categId[1] == prdtCategory[0])
    //             .toList()) {
    //           productsFiltry[element.id] = element;
    //           producto.add(element);
    //         }

    //         controller = TabController(
    //             length: prdtCategory.length, vsync: this, initialIndex: 0);
    //       });
    //     });
  }

  onPositionChange() {
    if (!controller!.indexIsChanging) {
      setState(() {
        producto.clear();
        // for (ProductModel element in PrefUtils.products
        //     .where((element) =>
        //         element.categId[1] == prdtCategory[controller!.index])
        //     .toList()) {
        //   productsFiltry[element.id] = element;
        //   producto.add(element);
        // }

        controller = TabController(length: prdtCategory.length, vsync: this, initialIndex: controller!.index);
        controller!.addListener(onPositionChange);
      });
    }
  }

  getProductCategory() {
    prdtCategory.clear();
    // for (ProductModel element in PrefUtils.products) {
    //   if (!prdtCategory.contains(element.categId[1])) {
    //     prdtCategory.add(element.categId[1]);
    //   }
    // }
  }

  bool isVisible = false;
  @override
  Widget build(BuildContext ctxt) {
    return MainContainer(
        appBarTitleWidget: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: isVisible,
                child: SizedBox(
                  width: 210,
                  height: 50,
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filter = value;
                      });
                    },
                    // style: TextStyle(color: MyTheme.primaryTextLight),
                    decoration: InputDecoration(
                      filled: true,
                      // fillColor: MyTheme.appBarThemeLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      hintText: "eg: Search Products",
                      // hintStyle: TextStyle(color: MyTheme.primaryTextLight),
                    ),
                  ),
                ),
              ),
              Visibility(visible: !isVisible, child: Text('Products List')),
              SizedBox(
                width: 40,
                height: 40,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isVisible = !isVisible;
                        // filter = '';
                      });
                    },
                    child: Icon(isVisible == false ? Icons.search : Icons.close)),
              ),
            ],
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Get.to(CreateProducts());
          },
          child: Icon(Icons.add),
        ),
        drawer: CustomDrawer(),
        appBarTitle: "products",
        // appBarBottom: TabBar(
        //   isScrollable: true,
        //   controller: controller,
        //   tabs: List<Widget>.generate(prdtCategory.length, (index) {
        //     return Tab(text: prdtCategory[index]);
        //   }),
        // ),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: PrefUtils.products.length,
            itemBuilder: (_, i) {
              var p = PrefUtils.products[i];
              return buildImageWidget(p.image_128);
            }));
  }

  List<ProductModel> getProduct() {
    setState(() {});
    var result = producto.where((element) => (element.name).toString().toLowerCase().contains(filter.toLowerCase())).toList();
    print(result.length);
    return result;
  }

  Widget buildImageWidget(dynamic imageData) {
    if (imageData is String && imageData.isNotEmpty) {
      Uint8List? imageBytes = decodeBase64Image(imageData);
      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 300,
            );
          },
        );
      }
    }

    return const Icon(
      Icons.no_photography,
      color: Colors.blue,
      size: 300,
    );
  }

  Uint8List? decodeBase64Image(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Error al decodificar la imagen: $e");
      return null;
    }
  }
}

class ImageGet extends StatelessWidget {
  final String image;

  const ImageGet(this.image, {Key? key}) : super(key: key);

  bool isValidBase64(String base64String) {
    try {
      base64.decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isValidBase64(image)) {
      try {
        Uint8List imageBytes = base64.decode(image);
        return Dialog(
          child: Image.memory(
            imageBytes,
            height: 300,
            width: 300,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return _errorWidget("Invalid image data");
      }
    } else {
      return _errorWidget("Invalid Base64 string");
    }
  }

  Widget _errorWidget(String message) {
    return Dialog(
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 300,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
