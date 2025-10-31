import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'create_partner_controller.dart';
import 'widgets/partner_type_toggle.dart';
import 'widgets/basic_info_form.dart';
import 'widgets/location_form.dart';
import 'widgets/review_section.dart';

class CreatePartnerScreen extends StatefulWidget {
  const CreatePartnerScreen({super.key});

  @override
  State<CreatePartnerScreen> createState() => _CreatePartnerScreenState();
}

class _CreatePartnerScreenState extends State<CreatePartnerScreen> {
  final _basicInfoFormKey = GlobalKey<FormBuilderState>();
  final _locationFormKey = GlobalKey<FormBuilderState>();

  CreatePartnerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _controller = Get.put(CreatePartnerController());
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      Get.delete<CreatePartnerController>();
    }
    super.dispose();
  }

  void _goToStep(int step) {
    if (_controller == null) return;
    _controller!.state.value = _controller!.state.value.copyWith(
      currentStep: step,
    );
  }

  bool _validateCurrentStep() {
    if (_controller == null) return false;
    final currentStep = _controller!.state.value.currentStep;

    if (currentStep == 0) {
      if (_basicInfoFormKey.currentState?.saveAndValidate() ?? false) {
        _controller!.updateFormData(_basicInfoFormKey.currentState!.value);
        return true;
      }
      return false;
    } else if (currentStep == 1 && _controller!.state.value.isClient) {
      if (_locationFormKey.currentState?.saveAndValidate() ?? false) {
        _controller!.updateFormData(_locationFormKey.currentState!.value);
        return true;
      }
      return false;
    }

    return true;
  }

  void _onStepContinue() {
    if (_validateCurrentStep()) {
      _controller!.nextStep();
    }
  }

  void _onStepCancel() {
    if (_controller == null) return;
    if (_controller!.state.value.currentStep > 0) {
      _controller!.previousStep();
    } else {
      Get.back();
    }
  }

  Future<void> _onSubmit() async {
    if (_controller == null) return;
    final allData = Map<String, dynamic>.from(
      _controller!.state.value.formData,
    );
    await _controller!.submitForm(allData);
  }

  List<Step> _buildSteps() {
    if (_controller == null) return [];

    final isClient = _controller!.state.value.isClient;

    final steps = [
      Step(
        title: const Text('الأساسيات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PartnerTypeToggle(),
            const SizedBox(height: 16),
            BasicInfoForm(formKey: _basicInfoFormKey),
          ],
        ),
        isActive: _controller!.state.value.currentStep >= 0,
        state: _controller!.state.value.currentStep > 0
            ? StepState.complete
            : StepState.indexed,
      ),
    ];

    if (isClient) {
      steps.add(
        Step(
          title: const Text('الموقع'),
          content: LocationForm(formKey: _locationFormKey),
          isActive: _controller!.state.value.currentStep >= 1,
          state: _controller!.state.value.currentStep > 1
              ? StepState.complete
              : StepState.indexed,
        ),
      );
    }

    steps.add(
      Step(
        title: const Text('المراجعة'),
        content: ReviewSection(
          basicInfo: _basicInfoFormKey.currentState?.value ?? {},
          locationInfo: isClient ? _locationFormKey.currentState?.value : null,
          onEditBasicInfo: () => _goToStep(0),
          onEditLocation: isClient ? () => _goToStep(1) : null,
        ),
        isActive: _controller!.state.value.currentStep >= (isClient ? 2 : 1),
        state: StepState.indexed,
      ),
    );

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return MainContainer(
        appBarTitle: 'إنشاء شريك جديد',
        drawer: CustomDrawer(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return MainContainer(
      appBarTitle: 'إنشاء شريك جديد',
      drawer: CustomDrawer(),
      child: Obx(() {
        final state = _controller!.state.value;
        final isLastStep = state.currentStep == (state.isClient ? 2 : 1);

        return Stack(
          children: [
            Stepper(
              type: StepperType.horizontal,
              physics: const ClampingScrollPhysics(),
              currentStep: state.currentStep,
              onStepContinue: isLastStep ? null : _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (isLastStep)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading ? null : _onSubmit,
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              state.isLoading ? 'جاري الحفظ...' : 'حفظ',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('التالي'),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isLoading
                              ? null
                              : details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text(
                            state.currentStep == 0 ? 'إلغاء' : 'السابق',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: _buildSteps(),
            ),

            if (state.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('جاري إنشاء الشريك...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
