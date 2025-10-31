// import 'package:flutter/material.dart';
// import 'package:g_solution/src/Model/SaleReport/SaleReportModule.dart';
// import 'package:g_solution/src/module/widgets/constant.dart';
// import 'package:g_solution/src/module/widgets/custom_drawer.dart';
// import 'package:g_solution/src/module/widgets/main_container.dart';
// import 'package:search_choices/search_choices.dart';
// import 'package:pluto_grid/pluto_grid.dart';
// import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;

// class SaleReportView extends StatefulWidget {
//   const SaleReportView({Key? key}) : super(key: key);

//   @override
//   State<SaleReportView> createState() => _SaleReportViewState();
// }

// class _SaleReportViewState extends State<SaleReportView> {
//   String selectedGroub = "";
//   List<int> selectedItemsMultiMenu = [];
//   Widget table = Table(children: const []);
//   PlutoGridStateManager? stateManager;
//   @override
//   void initState() {
//     super.initState();
//   }

//   final List<DropdownMenuItem> itemsMesures = [
//     const DropdownMenuItem(
//       key: Key("price_total"),
//       value: "price_total",
//       child: Text("TOTAL"),
//     ),
//     const DropdownMenuItem(
//       key: Key("margin"),
//       value: "margin",
//       child: Text("MARGE"),
//     ),
//     const DropdownMenuItem(
//       key: Key("qty_delivered"),
//       value: "qty_delivered",
//       child: Text("QTE LIVRE"),
//     ),
//     const DropdownMenuItem(
//       key: Key("qty_to_invoice"),
//       value: "qty_to_invoice",
//       child: Text("QTE FACTURE"),
//     ),
//     const DropdownMenuItem(
//       key: Key("product_uom_qty"),
//       value: "product_uom_qty",
//       child: Text("QTE COMMANDE"),
//     )
//   ];
//   final List<DropdownMenuItem> itemsGroup = [
//     const DropdownMenuItem(
//       key: Key("product_tmpl_id"),
//       value: "product_tmpl_id",
//       child: Text("ARTICLE"),
//     ),
//     const DropdownMenuItem(
//       key: Key("date:day"),
//       value: "date:day",
//       child: Text("DATE DAY"),
//     ),
//     const DropdownMenuItem(
//       key: Key("date:month"),
//       value: "date:month",
//       child: Text("DATE MONTH"),
//     ),
//     const DropdownMenuItem(
//       key: Key("user_id"),
//       value: "user_id",
//       child: Text("VENDEUR"),
//     ),
//     const DropdownMenuItem(
//       key: Key("team_id"),
//       value: "team_id",
//       child: Text("EQUIPE CEOMMERCIAL"),
//     ),
//     const DropdownMenuItem(
//       key: Key("categ_id"),
//       value: "categ_id",
//       child: Text("CATEGORIES ARTICLES"),
//     ),
//     const DropdownMenuItem(
//       key: Key("partner_id"),
//       value: "partner_id",
//       child: Text("CLIENT"),
//     ),
//     const DropdownMenuItem(
//       key: Key("state"),
//       value: "state",
//       child: Text("ETAT"),
//     )
//   ];

//   void _printToPdfAndShareOrSave() async {
//     var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
//       title: "Pluto Grid Sample pdf print",
//       creator: "Pluto Grid Rocks!",
//       format: pluto_grid_export.PdfPageFormat.a4.landscape,
//     );

//     await pluto_grid_export.Printing.sharePdf(
//         bytes: await plutoGridPdfExport.export(stateManager!),
//         filename: plutoGridPdfExport.getFilename());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MainContainer(
//       appBarTitle: "Sales Report",
//       drawer: CustomDrawer(),
//       child: Stack(
//         children: <Widget>[
//           dashBg,
//         ],
//       ),
//     );
//   }

//   void createTableDynamic(
//     List<dynamic> response,
//   ) {
//     List<TableRow> rows = [];
//     Map<String, double> total = {};
//     if (response.isNotEmpty) {
//       for (int i = 0; i < response.length; ++i) {
//         for (var element in itemsMesures) {
//           if (response[i][element.value] != null) {
//             if (!total.containsKey(element.value)) {
//               total[element.value] = response[i][element.value];
//             } else {
//               total[element.value] =
//                   total[element.value]! + response[i][element.value]!;
//             }
//           }
//         }
//       }
//       List<Widget> children = [
//         Container(
//           height: 50,
//           width: 20,
//           color: Colors.grey,
//         )
//       ];
//       List<Widget> childrenCell = [
//         Container(
//           height: 50,
//           width: 20,
//         )
//       ];
//       for (var element in itemsMesures) {
//         if (response[0][element.value] != null) {
//           childrenCell.add(
//             TableCell(
//               key: Key(element.value),
//               verticalAlignment: TableCellVerticalAlignment.top,
//               child: Container(
//                 height: 32,
//                 width: 32,
//                 color: Colors.white,
//                 child: element.child,
//               ),
//             ),
//           );
//           children.add(
//             TableCell(
//               key: Key(element.value + "VALUE"),
//               verticalAlignment: TableCellVerticalAlignment.top,
//               child: Container(
//                 height: 32,
//                 width: 32,
//                 color: Colors.white,
//                 child: Text(total[element.value]!.toStringAsFixed(2)),
//               ),
//             ),
//           );
//         }
//       }
//       rows = [
//         TableRow(
//           children: childrenCell,
//         ),
//         TableRow(
//           children: children,
//         ),
//       ];

//       for (int i = 0; i < response.length; ++i) {
//         Map valor = response[i];
//         String selectedGroubValor = "";
//         if (valor[selectedGroub] is double) {
//           selectedGroubValor = valor[selectedGroub].toString();
//         } else if (valor[selectedGroub] is List<dynamic>) {
//           selectedGroubValor = valor[selectedGroub][1];
//         } else {
//           selectedGroubValor = valor[selectedGroub];
//         }
//         List<Widget> childrenRow = [];
//         childrenRow.add(Text(selectedGroubValor));
//         for (var element in itemsMesures) {
//           if (response[i][element.value] != null) {
//             childrenRow.add(Text(response[i][element.value].toString()));
//           }
//         }

//         rows.add(TableRow(children: childrenRow));
//       }
//     }
//     table = Table(children: rows);
//   }

//   void createTableDynamicPluto(List<dynamic> response, List<dynamic> args) {
//     if (response.isNotEmpty) {
//       List<PlutoColumn> columns = [
//         PlutoColumn(
//           enableColumnDrag: false,
//           enableContextMenu: false,
//           enableRowDrag: false,
//           title: '',
//           field: 'Grupby',
//           type: PlutoColumnType.text(),
//           titleTextAlign: PlutoColumnTextAlign.center,
//         ),
//       ];

//       List<PlutoColumnGroup> columnGroups = [];
//       List<PlutoColumnGroup> columnGroupsChild = [];
//       for (var mapGroupBy in args[0]) {
//         for (var itemGrup in itemsGroup) {
//           if (mapGroupBy[itemGrup.value] != null) {
//             List<String> columnGroupsChildFields = [];
//             for (var element in itemsMesures) {
//               if (response[0][element.value] != null) {
//                 String columnName = mapGroupBy[itemGrup.value][0].toString() +
//                     ":" +
//                     element.value;
//                 columns.add(PlutoColumn(
//                   title: element.value,
//                   field: columnName,
//                   type: PlutoColumnType.text(),
//                   titleTextAlign: PlutoColumnTextAlign.center,
//                 ));
//                 columnGroupsChildFields.add(columnName);
//               }
//             }
//             columnGroupsChild.add(PlutoColumnGroup(
//               title: mapGroupBy[itemGrup.value][1],
//               backgroundColor: Colors.greenAccent,
//               fields: columnGroupsChildFields,
//             ));
//           }
//         }
//       }

//       List<String> columnGroupsChildDefaultString = [];
//       for (var element in itemsMesures) {
//         if (response[0][element.value] != null) {
//           columnGroupsChildDefaultString.add(element.value);
//           columns.add(PlutoColumn(
//             title: element.value,
//             field: element.value,
//             type: PlutoColumnType.text(),
//             titleTextAlign: PlutoColumnTextAlign.center,
//           ));
//         }
//       }
//       columnGroups.add(PlutoColumnGroup(
//         title: '',
//         fields: ['column1'],
//         expandedColumn: true,
//       ));
//       columnGroups.add(PlutoColumnGroup(
//         title: "Total",
//         backgroundColor: Colors.greenAccent,
//         children: columnGroupsChild,
//       ));

//       columnGroups.add(PlutoColumnGroup(
//         title: '',
//         children: [
//           PlutoColumnGroup(
//             title: '',
//             fields: columnGroupsChildDefaultString,
//           )
//         ],
//         expandedColumn: false,
//       ));

//       List<PlutoRow> rows = [];
//       for (int i = 0; i < response.length; ++i) {
//         Map valor = response[i];
//         String selectedGroubValor = "";
//         if (valor[selectedGroub] is double) {
//           selectedGroubValor = valor[selectedGroub].toString();
//         } else if (valor[selectedGroub] is List<dynamic>) {
//           selectedGroubValor = valor[selectedGroub][1];
//         } else {
//           selectedGroubValor = valor[selectedGroub];
//         }
//         List<Widget> childrenRow = [];
//         Map<String, PlutoCell> mapPlutoRow = {
//           "Grupby": PlutoCell(value: selectedGroubValor)
//         };
//         childrenRow.add(Text(selectedGroubValor));
//         for (var mapGroupBy in args[0]) {
//           for (var itemGrup in itemsGroup) {
//             if (mapGroupBy[itemGrup.value] != null) {
//               for (var element in itemsMesures) {
//                 if (response[i][element.value] != null) {
//                   mapPlutoRow[mapGroupBy[itemGrup.value][0].toString() +
//                           ":" +
//                           element.value] =
//                       PlutoCell(value: response[i][element.value].toString());
//                 }
//               }
//             }
//           }
//         }

//         for (int i = 0; i < response.length; ++i) {
//           Map valor = response[i];
//           for (var element in itemsMesures) {
//             if (valor[element.value] != null) {
//               if (response[i][element.value] != null) {
//                 // mapPlutoRow["Total"] =
//                 //     PlutoCell();
//                 mapPlutoRow[element.value] = PlutoCell(value: 0);
//               }
//             }
//           }
//         }
//         var raw = PlutoRow(cells: mapPlutoRow);
//         rows.add(raw);
//       }

//       table = PlutoGrid(
//         columns: columns,
//         rows: rows,
//         columnGroups: columnGroups,
//         onChanged: (PlutoGridOnChangedEvent event) {
//           print(event);
//         },
//         onLoaded: (PlutoGridOnLoadedEvent event) {
//           stateManager = event.stateManager;
//         },
//         configuration: const PlutoGridConfiguration(
//             enableMoveDownAfterSelecting: false,
//             enableMoveHorizontalInEditing: false),
//       );
//     }
//   }

//   onchanged(value, bool isSelectedGroub) {
//     setState(() {
//       table = Table(children: const []);
//       if (isSelectedGroub) {
//         selectedGroub = value;
//       } else {
//         selectedItemsMultiMenu = value;
//       }
//       if (selectedItemsMultiMenu.isNotEmpty && selectedGroub.isNotEmpty) {
//         List<String> fields = [];
//         for (var index in selectedItemsMultiMenu) {
//           fields.add(itemsMesures[index].value + ":sum");
//         }
//         List<dynamic> domain = [
//           [
//             "state",
//             "not in",
//             ["draft", "cancel", "sent"]
//           ]
//         ];
//         var groupby = [selectedGroub, "user_id"];
//         List<dynamic> timerange = [
//           [
//             "timeRangeMenuData",
//             [
//               ["comparisonField", "=", "date"],
//               [
//                 "timeRange",
//                 [
//                   "&",
//                   ["date", ">=", "2022-10-31 23:00:00"],
//                   ["date", "<", "2022-11-30 23:00:00"]
//                 ]
//               ]
//             ]
//           ]
//         ];
//         var kwargs = {
//           "domain": domain,
//           "fields": fields,
//           "groupby": groupby,
//           // "context": [timerange],
//         };
//         SaleReportModule.readAnalyse(
//             kwargs: kwargs,
//             onResponse: (response) {
//               kwargs["groupby"] = ["user_id"];
//               List<dynamic> args = [];
//               SaleReportModule.readAnalyse(
//                   kwargs: kwargs,
//                   onResponse: (response2) {
//                     args.add(response2);
//                     setState(() {
//                       createTableDynamicPluto(response, args);
//                     });
//                   });
//             });
//       }
//     });
//   }

//   get dashBg => Column(
//         children: <Widget>[
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 Container(
//                   color: MyTheme.appBarThemeLight,
//                   child: SearchChoices.multiple(
//                     items: itemsMesures,
//                     selectedItems: selectedItemsMultiMenu,
//                     hint: const Padding(
//                       padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
//                       child: Text("Select any"),
//                     ),
//                     searchHint: "Select any",
//                     onTap: () {},
//                     onChanged: (value) {
//                       onchanged(value, false);
//                     },
//                     closeButton: (selectedItems) {
//                       return (selectedItems.isNotEmpty
//                           ? "Save ${selectedItems.length == 1 ? '"' + itemsMesures[selectedItems.first].value.toString() + '"' : '(' + selectedItems.length.toString() + ')'}"
//                           : "Save without selection");
//                     },
//                     isExpanded: true,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Expanded(
//           //   flex: 1,
//           //   child: Column(
//           //     children: [
//           //       Container(
//           //         color: MyTheme.appBarThemeLight,
//           //         child: SearchChoices.single(
//           //           items: items,
//           //           value: selectedMesures,
//           //           // displayItem: items[0],
//           //           hint: const Padding(
//           //             padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
//           //             child: Text("Select any"),
//           //           ),
//           //           searchHint: "Select any",
//           //           onTap: () {},
//           //           onChanged: (value) {
//           //             setState(() {
//           //               selectedMesures = value;
//           //               if (selectedMesures.isNotEmpty) {
//           //                 dynamic kwargs = {};
//           //                 SaleReportModule.readAnalyse(
//           //                     kwargs: kwargs,
//           //                     onResponse: (response) {
//           //                       print(response);
//           //                     });
//           //               }
//           //             });
//           //           },
//           //           closeButton: (selectedItems) {
//           //             return (selectedItems.isNotEmpty
//           //                 ? "Save ${selectedItems.length == 1 ? '"' + items[selectedItems.first].value.toString() + '"' : '(' + selectedItems.length.toString() + ')'}"
//           //                 : "Save without selection");
//           //           },
//           //           isExpanded: true,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           Container(
//             color: MyTheme.appBarThemeLight,
//             child: SearchChoices.single(
//               items: itemsGroup,
//               value: selectedGroub,
//               hint: const Padding(
//                 padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
//                 child: Text("Select any"),
//               ),
//               searchHint: "Select any",
//               onTap: () {},
//               onChanged: (value) {
//                 onchanged(value, true);
//               },
//               closeButton: (selectedItems) {
//                 return (selectedItems.isNotEmpty
//                     ? "Save ${selectedItems.length == 1 ? '"' + itemsMesures[selectedItems.first].value.toString() + '"' : '(' + selectedItems.length.toString() + ')'}"
//                     : "Save without selection");
//               },
//               isExpanded: true,
//             ),
//           ),
//           ElevatedButton(
//               onPressed: _printToPdfAndShareOrSave,
//               child: const Text("Print to PDF and Share")),
//           Expanded(
//             flex: 7,
//             child: table,
//           )
//         ],
//       );
// }
