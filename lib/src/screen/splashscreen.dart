import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/home/model/res_partner_model.dart';
import 'package:gsloution_mobile/src/screen/homepage.dart';

class SplashScreenApp extends StatefulWidget {
  const SplashScreenApp({super.key});

  @override
  State<SplashScreenApp> createState() => _SplashScreenAppState();
}

class _SplashScreenAppState extends State<SplashScreenApp> {
  bool isReady = false;
  int progress = 0;
  final Controller _controller = Get.put(Controller());
  var products = <ProductModel>[].obs;
  var partners = <PartnerModel>[].obs;
  // var employees = <EmployeeModel>[].obs;
  // var secteurs = <Secteurs>[].obs;
  // var users = <UserModel>[].obs;
  // var user = UserModel().obs;
  // var employee = EmployeeModel().obs;
  // var salesOrder = <OrderModel>[].obs;
  // var purchaseOrder = <PurchaseModel>[].obs;
  // var accountMove = <AccountMoveModel>[].obs;
  // var accountJournalModel = <AccountJournalModel>[].obs;
  // var hrExpense = <HrExpenseModel>[].obs;
  @override
  initState() {
    super.initState();
    //logoutApi();
    loadFromFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.products.isNotEmpty) {
        return isReady ? Homepage() : const CircularProgressIndicator();
      } else {
        return Material(
          child: Center(
            child: Text("$progress %"),
          ),
        );
      }
    });
  }

  Future<void> loadFromFuture() async {
    try {
      await _controller.getProductsController(
        onResponse: (resProducts) async {
          if (resProducts != null && resProducts.isNotEmpty) {
            var firstKey = resProducts.keys.toList()[0];
            if (firstKey != null && resProducts[firstKey] != null) {
              products.addAll(resProducts[firstKey]!);
              await PrefUtils.setProducts(products);
              setState(() {
                progress = 100;
                isReady = true;
              });
            } else {
              print('Error: Invalid key or null data in resProducts');
            }
          } else {
            print('Error: resProducts is null or empty');
          }
        },
      );
    } catch (e) {
      print('Error in loadFromFuture: $e');
      rethrow;
    }
  }

//   Future<void> loadFromFuture() async {
//     try {
//       int? uid;
//       // PrefUtils.clearPrefs();
//       await _controller.getProductsController(
//         onResponse: (resProducts) async {
//           if (resProducts != null) {
//             products.addAll(resProducts[resProducts.keys.toList()[0]]!);
//             await PrefUtils.setProducts(products);
//             setState(() {
//               progress = 100;
//               isReady = true;
//             });
//           }
//           // var userLogin = PrefUtils.getUserlogin();

//           // if (userLogin["uid"] != null) {
//           //   uid = userLogin["uid"];
//           // } else {
//           //   uid = userLogin["id"];
//           // }
//           // await _controller.getUserControllers(
//           //   id: uid,
//           //   onResponse: (resUser) async {
//           //     if (resUser != null) {
//           //       user = resUser;
//           //       PrefUtils.setUser(user.value);
//           //       setState(() {
//           //         progress = 20;
//           //       });

//           //       if (user.value.employeeIds != null) {
//           //         await _controller.getEmployeesController(
//           //           // id: user.value.employeeIds![0],
//           //           onResponse: (resEmployee) async {
//           //             if (resEmployee != null) {
//           //               employees
//           //                   .addAll(resEmployee[resEmployee.keys.toList()[0]]!);
//           //               PrefUtils.setEmployees(employees);
//           //               employee.value = employees.firstWhere(
//           //                   (p0) => p0.id == user.value.employeeIds![0]);
//           //               PrefUtils.setEmployee(employee.value);
//           //               setState(() {
//           //                 progress = 40;
//           //               });
//           //             }
//           //             // List<dynamic> domainPartners = [
//           //             //   ['customer_rank', '>', 0],
//           //             // ];
//           //             await _controller.getPartnersController(
//           //               domain: [],
//           //               onResponse: (resPartners) async {
//           //                 if (resPartners != null) {
//           //                   partners.addAll(
//           //                       resPartners[resPartners.keys.toList()[0]]!);
//           //                   PrefUtils.setPartners(partners);
//           //                   setState(() {
//           //                     progress = 60;
//           //                   });
//           //                   setState(() {});
//           //                 }
//           //                 await _controller.getSecteurController(
//           //                   onResponse: (resSecteurs) async {
//           //                     if (resSecteurs != null) {
//           //                       secteurs.addAll(
//           //                           resSecteurs[resSecteurs.keys.toList()[0]]!);
//           //                       PrefUtils.setSecteurs(secteurs);
//           //                       setState(() {
//           //                         progress = 80;
//           //                       });
//           //                     }
//           //                     setState(() {});
//           //                     List<dynamic> domain = [
//           //                       [
//           //                         "state",
//           //                         "in",
//           //                         ["draft", "sent", "sale", "done", "cancel"]
//           //                       ],
//           //                     ];
//           //                     try {
//           //                       await _controller.getSaleOrderController(
//           //                         domain: domain,
//           //                         onResponse: (response) async {
//           //                           if (response != null) {
//           //                             salesOrder = _controller.salesOrder;
//           //                             await PrefUtils.setSaleOrder(salesOrder);
//           //                             setState(() {
//           //                               progress = 90;
//           //                             });
//           //                           }
//           //                           await _controller.getUsersController(
//           //                             domain: [],
//           //                             onResponse: (resUsers) async {
//           //                               if (resUsers != null) {
//           //                                 users = _controller.users;
//           //                                 await PrefUtils.setUsers(users);
//           //                                 List<dynamic> domaine = [
//           //                                   [
//           //                                     "type",
//           //                                     "in",
//           //                                     [
//           //                                       "out_invoice",
//           //                                       "out_refund",
//           //                                       "out_receipt"
//           //                                     ]
//           //                                   ],
//           //                                   ["journal_id", "=", 1]
//           //                                 ];

//           //                                 await _controller
//           //                                     .getAccuontMoveController(
//           //                                   domain: domaine,
//           //                                   onResponse: (resAccount) async {
//           //                                     if (resAccount != null) {
//           //                                       accountMove =
//           //                                           _controller.accountMove;
//           //                                       await PrefUtils.setAccountMove(
//           //                                           accountMove);

//           //                                       await _controller
//           //                                           .getAccountJournalController(
//           //                                               onResponse:
//           //                                                   (resJournal) async {
//           //                                         if (resJournal != null) {
//           //                                           accountJournalModel =
//           //                                               _controller
//           //                                                   .accountJournalModel;
//           //                                           await PrefUtils
//           //                                               .setAccountJournal(
//           //                                                   accountJournalModel);
//           //                                           await _controller
//           //                                               .getPurchaseOrderController(
//           //                                             onResponse:
//           //                                                 (resPurchase) async {
//           //                                               if (resPurchase !=
//           //                                                   null) {
//           //                                                 purchaseOrder =
//           //                                                     _controller
//           //                                                         .purchaseOrder;
//           //                                                 await PrefUtils
//           //                                                     .setPurchaseOrder(
//           //                                                         purchaseOrder);
//           //                                                 await _controller
//           //                                                     .getHrExpenseController(
//           //                                                   onResponse:
//           //                                                       (response) async {
//           //                                                     hrExpense =
//           //                                                         _controller
//           //                                                             .hrExpense;
//           //                                                     await PrefUtils
//           //                                                         .setHrExpense(
//           //                                                             hrExpense);
//           //                                                     setState(() {
//           //                                                       progress = 100;
//           //                                                       isReady = true;
//           //                                                     });
//           //                                                   },
//           //                                                 );
//           //                                               }
//           //                                             },
//           //                                           );
//           //                                         }
//           //                                       });
//           //                                     }
//           //                                   },
//           //                                 );
//           //                               }
//           //                             },
//           //                           );
//           //                         },
//           //                       );
//           //                     } catch (e) {
//           //                       Get.dialog(AlertDialog(
//           //                         shape: RoundedRectangleBorder(
//           //                           borderRadius: BorderRadius.circular(16.0),
//           //                         ),
//           //                         title: const Text(
//           //                           "Error",
//           //                         ),
//           //                         content: Text(
//           //                           "Sorry! Error : $e",
//           //                           style: AppFont.Body2_Regular(),
//           //                         ),
//           //                         actions: <Widget>[
//           //                           TextButton(
//           //                             onPressed: () {
//           //                               Get.to(const SplashScreenApp());
//           //                             },
//           //                             child: Text(
//           //                               'Ok',
//           //                               style: AppFont.Body2_Regular(),
//           //                             ),
//           //                           ),
//           //                         ],
//           //                       ));
//           //                     }
//           //                   },
//           //                 );
//           //               },
//           //             );
//           //           },
//           //         );
//           //       }
//           //     }
//           //   },
//           // );
//         },
//       );

//       // lOCATION
//       // if (!Platform.isWindows) {
//       //   await MyLocation.getLatAndLong();
//       //   await UserModule.searchUsersLocation(
//       //       domain: [
//       //         ["create_uid", "=", uid]
//       //       ],
//       //       onResponse: ((responsesearchUsersLocation) {
//       //         var t = responsesearchUsersLocation.where((e) {
//       //           DateTime dat = DateTime.parse(e.actionDate);
//       //           var dateBefore = DateTime.now().add(Duration(days: -5));
//       //           return dateBefore.isAfter(dat);
//       //         }).toList();

//       //         if (PrefUtils.getLatitude() != 0 &&
//       //             PrefUtils.getLongitude() != 0) {
//       //           if (uid != null) {
//       //             UserModule.writeUserLocation(
//       //                 userId: uid!,
//       //                 latitude: PrefUtils.getLatitude(),
//       //                 longitude: PrefUtils.getLongitude(),
//       //                 onResponse: (response) {
//       //                   List<int> id = t.map((e) => e.id!).toList();
//       //                   UserModule.deleteUserLocation(
//       //                       ids: id, onResponse: ((response) {}));
//       //                 });
//       //           } else {
//       //             PrefUtils.clearPrefs();
//       //           }
//       //         }
//       //       }));
//       // }
//     } catch (e) {
//       print('Erreur dans loadFromFuture : $e');
//       throw e;
//     }
//   }
}
