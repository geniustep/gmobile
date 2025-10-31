import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class BasicInfoForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;

  const BasicInfoForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'الاسم *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'الحقل مطلوب'),
              FormBuilderValidators.minLength(
                3,
                errorText: 'الاسم يجب أن يكون 3 أحرف على الأقل',
              ),
            ]),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'mobile',
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف *',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'الحقل مطلوب'),
              FormBuilderValidators.minLength(
                8,
                errorText: 'رقم الهاتف قصير جداً',
              ),
            ]),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

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
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'function',
            decoration: const InputDecoration(
              labelText: 'الوظيفة',
              prefixIcon: Icon(Icons.work_outline),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'website',
            decoration: const InputDecoration(
              labelText: 'الموقع الإلكتروني',
              prefixIcon: Icon(Icons.language),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
