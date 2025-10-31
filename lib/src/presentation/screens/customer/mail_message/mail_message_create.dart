// ignore: must_be_immutable
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateMailPartner extends StatefulWidget {
  PartnerModel? partner;
  CreateMailPartner(this.partner, {Key? key}) : super(key: key);

  @override
  State<CreateMailPartner> createState() {
    return _CreateMailPartnerState();
  }
}

class _CreateMailPartnerState extends State<CreateMailPartner> {
  final Controller _Controller = Get.put(Controller());
  Map<String, dynamic> mapas = <String, dynamic>{};
  // List<TourModel> tour = [];

  // Future<void> getTour() async {
  //   List<dynamic> domain = [
  //     [
  //       'state',
  //       'in',
  //       ['ready']
  //     ]
  //   ];
  //   // await TourModule.searchReadTour(
  //   //     domain: domain,
  //   //     onResponse: ((response) {
  //   //       setState(() {
  //   //         tour.addAll(response);
  //   //       });
  //   //     }));
  // }

  @override
  void initState() {
    super.initState();
    getLatAndLong();
    // getTour();
    // _Controller.getActivityTypeController();
    // _Controller.getActivityController();
  }

  // Fonction Get Current Position
  late Position position;
  var lat;
  var long;

  CameraPosition? _kGooglePlex;
  Future<dynamic> getLatAndLong() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .then((value) => value);
    lat = position.latitude;
    long = position.longitude;

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(lat, long),
        zoom: 14.4746,
      );
    });
    print(lat);
    final distanceInMeters = await Geolocator.distanceBetween(lat, long,
        widget.partner!.partnerLatitude, widget.partner!.partnerLongitude);
    debugPrint(distanceInMeters.toString());
    mapas['body'] =
        "Distance est : ${distanceInMeters.toStringAsFixed(2)} m from ${widget.partner!.displayName}";
    debugPrint(mapas.toString());
  }

//function Non Terminer in form get just camera without Gallerie
  final ImagePicker _picker = ImagePicker();
  XFile? image;

  takePhoto(Image i) async {
    image = await _picker.pickImage(source: ImageSource.camera);
  }

  // Variable FormBuilder
  static final GlobalKey<FormBuilderState> _formActivityKey =
      GlobalKey<FormBuilderState>();
  static final GlobalKey<FormBuilderState> _formMessageKey =
      GlobalKey<FormBuilderState>();
  static final GlobalKey<FormBuilderState> _formAttachmentKey =
      GlobalKey<FormBuilderState>();

  // visibility for 1th choise
  bool isVisibleCustomerIsClosed = false;
  bool isVisibleOrder = false;
  //
  bool isVisibleTemporaryClosed = false;
  bool isVisibleNote = false;
  bool isVisibleAttachement = false;
  bool isVisibleAllForme = false;
  bool isVisibleSubmit = false;

  //
  bool _noteHasError = false;
  void _onChanged(dynamic val) => debugPrint(val.toString());

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FormBuilder(
              key: _formMessageKey,
              onChanged: () {
                _formMessageKey.currentState!.save();
                debugPrint(_formMessageKey.currentState!.value.toString());
              },
              child: FormBuilderRadioGroup(
                activeColor: Colors.deepOrange,
                decoration: InputDecoration(
                  labelText: 'customer_case',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  final distanceInMeters = Geolocator.distanceBetween(
                      lat,
                      long,
                      widget.partner!.partnerLatitude,
                      widget.partner!.partnerLongitude);
                  double circle = 50;
                  if (distanceInMeters > circle) {
                    var thisDistance = distanceInMeters - circle;
                    return "you_are ${thisDistance.toStringAsFixed(2)} meters away from ${widget.partner!.name}";
                  }
                  return null;
                },
                onChanged: (value) {
                  final distanceInMeters = Geolocator.distanceBetween(
                      lat,
                      long,
                      widget.partner!.partnerLatitude,
                      widget.partner!.partnerLongitude);

                  double circle = 50;

                  if (value == "There is no customer") {
                    setState(() {
                      if (distanceInMeters < circle) {
                        setState(() {
                          isVisibleAttachement = true;
                        });
                      } else {
                        Get.snackbar("attention", 'You are away from client');
                      }
                      isVisibleAllForme = false;
                    });
                  } else {
                    setState(() {
                      isVisibleAttachement = false;
                      isVisibleAllForme = true;
                    });
                  }

                  if (value == "customer closed" || value != "no order") {
                    setState(() {
                      isVisibleCustomerIsClosed = true;
                      isVisibleOrder = false;
                    });
                  } else {
                    setState(() {
                      isVisibleCustomerIsClosed = false;
                      isVisibleOrder = true;
                    });
                  }
                },
                options: [
                  "customer closed",
                  "no order",
                  "There is no customer",
                ]
                    .map((lang) => FormBuilderFieldOption(
                          value: lang,
                          child: Text(
                            lang,
                          ),
                        ))
                    .toList(growable: false),
                name: 'note',
              ),
            ),
            // Customer Case ?? is Closed ?? Or No Order ?? Or No Clients Localisation

            const SizedBox(
              height: 15,
            ),
            // Customer Closed
            Visibility(
              visible: isVisibleAllForme,
              child: FormBuilder(
                key: _formActivityKey,
                onChanged: () {
                  _formActivityKey.currentState!.save();
                  debugPrint(_formActivityKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.disabled,
                skipDisabled: true,
                child: Column(
                  children: <Widget>[
                    // Temporary Closed // Change Activity // Permanon Closed
                    // add This in Activity :: Fields : summary
                    Visibility(
                      visible: isVisibleCustomerIsClosed,
                      child: FormBuilderRadioGroup(
                        activeColor: Colors.deepOrange,
                        decoration: InputDecoration(
                          labelText: "Localize.customer_case.tr",
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        name: "summary",
                        onChanged: ((value) {
                          setState(() {
                            isVisibleAttachement = true;
                          });
                        }),
                        options: [
                          "Localize.temporary_closure.tr",
                          "Localize.change_activity.tr",
                          "Localize.permanent_closure.tr"
                        ]
                            .map((v) => FormBuilderFieldOption(
                                  value: v.toLowerCase(),
                                  child: Text(v.toString()),
                                ))
                            .toList(growable: true),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // No Order Case
                    Visibility(
                      visible: isVisibleOrder,
                      child: Column(
                        children: [
                          FormBuilderRadioGroup(
                            validator: (onValidateVal) {
                              if (onValidateVal !=
                                  _formActivityKey
                                      .currentState?.fields['summary']!.value) {
                                return 'Case can\'t be empty.';
                              }
                              return null;
                            },
                            name: 'summary',
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                labelText: "no order"),
                            onChanged: (value) {
                              // open Drop Menu To do by Visibility: isVisibleTemporaryClosed
                              if (value ==
                                      "Localize.no_cashflow.tr".toLowerCase() ||
                                  value ==
                                      "Localize.products_in_stock.tr"
                                          .toLowerCase() ||
                                  value ==
                                      "Localize.lack_manager.tr"
                                          .toLowerCase()) {
                                setState(() {
                                  isVisibleAttachement = true;
                                });
                              } else {
                                setState(() {
                                  isVisibleAttachement = false;
                                });
                              }
                              if (value == "Localize.other.tr".toLowerCase()) {
                                setState(() {
                                  isVisibleNote = true;
                                });
                              } else {
                                isVisibleNote = false;
                              }
                            },
                            options: [
                              "Localize.no_cashflow.tr",
                              "Localize.products_in_stock.tr",
                              "Localize.lack_manager.tr",
                              "Localize.other.tr",
                            ]
                                .map((v) => FormBuilderFieldOption(
                                      value: v.toLowerCase(),
                                      child: Text(v.toString()),
                                    ))
                                .toList(growable: true),
                          ),
                          // other notes
                          Visibility(
                            visible: isVisibleNote,
                            child: FormBuilderTextField(
                              validator: (onValidateVal) {
                                if (onValidateVal !=
                                    _formActivityKey
                                        .currentState?.fields['note']!.value) {
                                  return 'other can\'t be empty.';
                                }
                                return null;
                              },
                              name: 'note',
                              initialValue: "",
                              onChanged: ((value) {
                                if (value!.length > 0) {
                                  setState(() {
                                    isVisibleAttachement = true;
                                  });
                                } else {
                                  setState(() {
                                    isVisibleAttachement = false;
                                  });
                                }
                              }),
                              decoration: InputDecoration(
                                hintText: "other",
                                labelText: "other",
                                suffixIcon: _noteHasError
                                    ? const Icon(Icons.error, color: Colors.red)
                                    : const Icon(Icons.check,
                                        color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // if  Temporary Closed  Open Menu To Do
                    // Visibility(
                    //   visible: isVisibleTemporaryClosed,
                    //   child: FormBuilderDropdown(
                    //     validator: (onValidateVal) {
                    //       if (onValidateVal !=
                    //           _formActivityKey.currentState
                    //               ?.fields['activity_type_id']!.value) {
                    //         return 'Activity can\'t be empty.';
                    //       }
                    //       return null;
                    //     },
                    //     name: 'activity_type_id',
                    //     // initialValue: 3,
                    //     items: listWithFilter,
                    //     onChanged: ((value) {
                    //       if (listWithFilter != null) {
                    //         setState(() {
                    //           isVisibleAttachement = true;
                    //         });
                    //       } else {
                    //         setState(() {
                    //           isVisibleAttachement = false;
                    //         });
                    //       }
                    //     }),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // // Date To DO
                    // Visibility(
                    //   visible: isVisibleTemporaryClosed,
                    //   child: FormBuilderDateTimePicker(
                    //     validator: (value) {
                    //       if (value!.isBefore(DateTime.now())) {
                    //         Get.snackbar(
                    //           "Dates",
                    //           'can\'t be before Date Now.',
                    //           colorText: Colors.red,
                    //         );
                    //       }
                    //       return null;
                    //     },
                    //     name: 'date_deadline',
                    //     initialEntryMode:
                    //         DatePickerEntryMode.calendarOnly,
                    //     inputType: InputType.date,
                    //     decoration: InputDecoration(
                    //       labelText: 'Appointment Time',
                    //       suffixIcon: IconButton(
                    //         icon: const Icon(Icons.close),
                    //         onPressed: () {
                    //           _formActivityKey
                    //               .currentState!.fields['date_deadline']
                    //               ?.didChange(null);
                    //         },
                    //       ),
                    //     ),
                    //     initialTime: const TimeOfDay(hour: 8, minute: 0),
                    //     // locale: const Locale.fromSubtags(languageCode: 'fr'),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Attachment Photo
            FormBuilder(
              key: _formAttachmentKey,
              onChanged: () {
                _formAttachmentKey.currentState!.save();
                debugPrint(_formAttachmentKey.currentState!.value.toString());
              },
              autovalidateMode: AutovalidateMode.disabled,
              skipDisabled: true,
              child: Visibility(
                visible: isVisibleAttachement,
                child: FormBuilderImagePicker(
                  validator: (value) {
                    if (value !=
                        _formAttachmentKey
                            .currentState?.fields['datas']!.value) {
                      Get.snackbar(
                        "Images",
                        'can\'t be empty.',
                        colorText: Colors.red,
                      );
                    }
                    return null;
                  },
                  onSaved: (val) {
                    val =
                        _formAttachmentKey.currentState?.fields['datas']!.value;
                  },
                  onChanged: (val) {
                    if (_formAttachmentKey
                            .currentState?.fields['datas']!.value !=
                        null) {
                      setState(() {
                        isVisibleSubmit = true;
                      });
                    } else {
                      setState(() {
                        isVisibleSubmit = false;
                      });
                    }
                    setState(() {
                      _noteHasError = !(_formAttachmentKey
                              .currentState?.fields['datas']
                              ?.validate() ??
                          false);
                    });
                  },
                  name: 'datas',
                  onImage: takePhoto,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(29, 10, 10, 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    labelText: 'Photo',
                  ),
                  fit: BoxFit.fitWidth,
                  // maxHeight: 20,
                  // imageQuality: 10,
                  maxImages: 1,
                  preferredCameraDevice: CameraDevice.rear,
                ),
              ),
            ),
            // Button Send Data
            Visibility(
              visible: isVisibleSubmit,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> _maps = <String, dynamic>{};
                        Map<String, dynamic> values = <String, dynamic>{};
                        // values['tour_id'] = tour[0].id;
                        values['action_tour_line'] = 'visit';
                        values['partner_id'] = widget.partner!.id;
                        values['tour_line_date'] =
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now());
                        values['the_day'] = DateTime.now().day;

                        // TourLineModule.readTourLine(
                        //     ids: tour[0].tourLineId.cast<int>(),
                        //     onResponse: ((responseTourLine) {
                        //       var p = responseTourLine
                        //           .where((e) =>
                        //               e.partnerId[1] == widget.partner!.name)
                        //           .toList();

                        //       if (p.isNotEmpty) {
                        //         TourLineModule.UpdateTourLine(
                        //             values: values,
                        //             onResponse: ((responseUpdateTourLine) {
                        //               print(responseUpdateTourLine);
                        //             }),
                        //             id: p[0].id);
                        //       } else {
                        //         TourLineModule.createTourLine(
                        //             values: values,
                        //             onResponse: ((response) {}));
                        //       }
                        //     }));

                        // if (validateAndSAveMessage()) {
                        //   mapas["res_id"] = tour[0].id;
                        //   mapas["model"] = 'gestion.tour';
                        //   _Controller.addMailPartner(
                        //     maps: mapas,
                        //     onResponse: (response) {
                        //       debugPrint('validation OK');
                        //     },
                        //   );
                        // } else {
                        //   Get.snackbar(Localize.attention.tr,
                        //       '${Localize.you_are.tr} ${Localize.away_from.tr} ${widget.partner!.name}');
                        // }
                        // if (validateAndSAveActivity()) {
                        //   Map<String, dynamic> maps = <String, dynamic>{};
                        //   maps["res_id"] = tour[0].id;
                        //   maps["res_model_id"] =
                        //       "449"; // model id: gestion.tour
                        //   Map<String, dynamic>? secondMaps =
                        //       _formActivityKey.currentState?.value;

                        //   maps.addAll(secondMaps!);
                        //   if (_formActivityKey
                        //           .currentState?.fields['date_deadline'] !=
                        //       null) {
                        //     var date = _formActivityKey
                        //         .currentState?.fields['date_deadline']!.value;
                        //     if (date != null) {
                        //       final DateFormat formatter =
                        //           DateFormat('yyyy-MM-dd');

                        //       final String item = formatter.format(date);

                        //       maps['date_deadline'] = item;
                        //     }
                        //     _Controller.addMsgActivityPartner(
                        //       maps: maps,
                        //       onResponse: (response) {
                        //         debugPrint('validation OK');
                        //       },
                        //     );
                        //   }
                        // }
                        // if (validateAndSAveAttachement()) {
                        //   if (_formAttachmentKey.currentState?.value != null) {
                        //     _maps["res_id"] = tour[0].id;
                        //     _maps["res_model"] = "gestion.tour";
                        //     _maps["name"] =
                        //         "photo of:  ${widget.partner!.name}";
                        //     Map<String, dynamic>? secondMaps =
                        //         _formAttachmentKey.currentState?.value;

                        //     _maps.addAll(secondMaps!);

                        //     if (_formAttachmentKey
                        //         .currentState!.value.isNotEmpty) {
                        //       var images = _formAttachmentKey
                        //           .currentState?.fields['datas']!.value;
                        //       if (images != null) {
                        //         String imageString = base64Encode(
                        //             File(images[0].path).readAsBytesSync());
                        //         _maps['datas'] = imageString;
                        //       }
                        //     }

                        //     _Controller.addAttachmentPartner(
                        //         maps: _maps,
                        //         onResponse: (response) {
                        //           debugPrint('validation OK');
                        //         });
                        //   }
                        // } else {
                        //   Get.snackbar(Localize.attention.tr,
                        //       '${Localize.upload_document.tr} is Empty');
                        // }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _formActivityKey.currentState?.reset();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  bool validateAndSAveMessage() {
    if (_formMessageKey.currentState != null) {
      final formMesage = _formMessageKey.currentState!;
      if (formMesage.validate()) {
        formMesage.save();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool validateAndSAveAttachement() {
    if (_formAttachmentKey.currentState != null) {
      final FormAttachment = _formAttachmentKey.currentState!;
      if (FormAttachment.validate()) {
        FormAttachment.save();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool validateAndSAveActivity() {
    if (_formActivityKey.currentState != null) {
      if (_formActivityKey.currentState!.validate()) {
        _formActivityKey.currentState!.save();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  // Text getValue(String? name) {
  //   switch (name) {
  //     case "Email":
  //       return Text(Localize.email.tr);
  //     case "Call":
  //       return Text(Localize.call.tr);
  //     case "Meeting":
  //       return Text(Localize.meeting.tr);
  //     case "Order Upsell":
  //       return Text(Localize.order_upsell.tr);
  //     case "To Do":
  //       return Text(Localize.todo.tr);
  //     case "a visité":
  //       return Text(Localize.visity.tr);
  //     case "Reminder":
  //       return Text(Localize.reminder.tr);
  //     case "Upload Document":
  //       return Text(Localize.upload_document.tr);
  //     case "Exception":
  //       return Text(Localize.exception.tr);
  //     default:
  //       return Text(name!);
  //   }
  // }
}
