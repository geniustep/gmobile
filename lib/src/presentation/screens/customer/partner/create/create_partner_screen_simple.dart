import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'create_partner_controller.dart';

class CreatePartnerScreenSimple extends StatefulWidget {
  const CreatePartnerScreenSimple({super.key});

  @override
  State<CreatePartnerScreenSimple> createState() =>
      _CreatePartnerScreenSimpleState();
}

class _CreatePartnerScreenSimpleState extends State<CreatePartnerScreenSimple> {
  final _formKey = GlobalKey<FormBuilderState>();
  CreatePartnerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _controller = Get.put(CreatePartnerController());
        });
      }
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      Get.delete<CreatePartnerController>();
    }
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      await _controller?.submitForm(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
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

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Partner Type Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'نوع الشريك:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('عميل'),
                            selected: state.isClient,
                            onSelected: (selected) {
                              if (selected && !state.isClient) {
                                _controller?.togglePartnerType();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('جهة اتصال'),
                            selected: !state.isClient,
                            onSelected: (selected) {
                              if (selected && state.isClient) {
                                _controller?.togglePartnerType();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: 'الاسم *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'الحقل مطلوب',
                        ),
                        FormBuilderValidators.minLength(
                          3,
                          errorText: 'الاسم يجب أن يكون 3 أحرف على الأقل',
                        ),
                      ]),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // Mobile
                    FormBuilderTextField(
                      name: 'mobile',
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'الحقل مطلوب',
                        ),
                        FormBuilderValidators.minLength(
                          8,
                          errorText: 'رقم الهاتف قصير جداً',
                        ),
                      ]),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // Email
                    FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: FormBuilderValidators.email(
                        errorText: 'أدخل بريد إلكتروني صحيح',
                      ),
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton.icon(
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
                      label: Text(state.isLoading ? 'جاري الحفظ...' : 'حفظ'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: state.isLoading ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ],
                ),
              ),
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
