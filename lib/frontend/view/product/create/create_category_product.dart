import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/categories/category_product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/categories/category_product_module.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/custom_drawer.dart';
import 'package:gsloution_mobile/common/widgets/main_container.dart';
import 'package:grouped_list/grouped_list.dart';

class CreateCategoryProduct extends StatefulWidget {
  const CreateCategoryProduct({Key? key}) : super(key: key);

  @override
  State<CreateCategoryProduct> createState() => _CreateCategoryProductState();
}

class _CreateCategoryProductState extends State<CreateCategoryProduct> {
  var prdtCategory = <ProductCategoryModel>[].obs;
  var prdtCategoryWithoutParent = <ProductCategoryModel>[].obs;
  @override
  void initState() {
    prdtCategory = PrefUtils.categoryProduct;
    prdtCategoryWithoutParent
        .addAll(prdtCategory.where((p0) => p0.parentId != false));
    super.initState();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  bool _noteHasError = false;
  void _onChanged(dynamic val) => debugPrint(val.toString());
  int _selectedItem = -1;
  @override
  Widget build(BuildContext context) {
    return MainContainer(
      drawer: CustomDrawer(),
      appBarTitle: 'Create Category',
      // "${Localize.create.tr.toUpperCase()} ${Localize.categories.tr.toUpperCase()}",
      child: Column(
        children: [
          FormBuilder(
            key: _formKey,
            onChanged: () {
              _formKey.currentState!.save();
              debugPrint(_formKey.currentState!.value.toString());
            },
            autovalidateMode: AutovalidateMode.disabled,
            skipDisabled: true,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    // controller: _controllerName,
                    decoration: const InputDecoration(
                      hintText: 'Name Caty',
                      labelText: 'Name Caty',
                    ),
                    onChanged: (val) {
                      setState(() {
                        _noteHasError = !(_formKey.currentState?.fields['name']
                                ?.validate() ??
                            false);
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  FormBuilderDropdown(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: const Icon(
                          Icons.person_pin,
                        ),
                        labelText: "Localize."),
                    name: "parent_id",
                    onChanged: _onChanged,
                    items: prdtCategory
                        .map((v) => DropdownMenuItem(
                              value: v.id,
                              child: Text(v.displayName.toString()),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          ElevatedButton(
              child: Text("Create"),
              onPressed: (() {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  debugPrint(_formKey.currentState?.value.toString());
                  Map<String, dynamic>? maps = _formKey.currentState?.value;
                  Map<String, dynamic> newMap = Map.from(maps!);
                  String name = newMap['name'];
                  if (name != null) {
                    newMap['name'] = name.toUpperCase();
                  }
                  ProductCategoryModule.CreateProductCategory(
                      maps: newMap,
                      onResponse: ((response) {
                        ProductCategoryModule.readProductsCategory(
                            ids: [response],
                            onResponse: (resProduct) {
                              if (resProduct.isNotEmpty) {
                                PrefUtils.categoryProduct.add(resProduct[0]);
                              }
                            });
                        _formKey.currentState?.reset();
                      }));
                  debugPrint('validation OK');
                } else {
                  debugPrint(_formKey.currentState?.value.toString());
                  debugPrint('validation failed');
                }
              })),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: GroupedListView<ProductCategoryModel, String>(
                  elements: prdtCategoryWithoutParent,
                  groupBy: ((g) =>
                      g.parentId != false ? g.parentId[1].toString() : ""),
                  groupSeparatorBuilder: (String groupByValue) {
                    return Card(
                        // color: MyTheme.appBarThemeLight,
                        elevation: 9,
                        child: ListTile(
                            title: Text(
                          groupByValue.toUpperCase(),
                        )));
                  },
                  itemComparator: (item1, item2) => item1.parentId
                      .toString()
                      .toUpperCase()
                      .compareTo(item2.parentId.toString().toUpperCase()),
                  useStickyGroupSeparators: true,
                  order: GroupedListOrder.DESC,
                  indexedItemBuilder:
                      (context, ProductCategoryModel prdtcategory, int index) {
                    return ExpansionTile(
                      key: Key('selected $_selectedItem'),
                      initiallyExpanded: index == _selectedItem,
                      onExpansionChanged: ((isOpen) {
                        if (isOpen) {
                          setState(() {
                            _selectedItem = index;
                          });
                        }
                      }),
                      title: ListTile(
                        title: Text(
                          prdtcategory.name.toString().toUpperCase(),
                        ),
                      ),
                      children: <Widget>[
                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Icon(
                                      Icons.done,
                                      color: Colors.green,
                                    )),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Icon(
                                    Icons.remove_done,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]),
                        ListTile(
                          title: Text("${prdtcategory.name}"),
                          subtitle: Text(prdtcategory.parentId != false
                              ? "${prdtcategory.parentId[1].toString()} \n ${prdtcategory.id} "
                              : " ${prdtcategory.id} "),
                          // trailing:
                          //     Text(" ${prdtsCategory.totalAmount} Dhs"),
                          isThreeLine: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
