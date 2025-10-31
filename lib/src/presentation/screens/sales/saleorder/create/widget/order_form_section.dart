import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/partner_selection_dialog.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/partner_controller.dart';

class OrderFormSection extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<PartnerModel> partners;
  final List<PricelistModel> priceLists;
  final List<dynamic> paymentTerms;
  final dynamic selectedPartnerId;
  final dynamic selectedPriceListId;
  final dynamic selectedPaymentTermId;
  final bool showDeliveryDate;
  final DateTime? deliveryDate;
  final bool hasProducts;
  final Function(int partnerId) onPartnerChanged;
  final Function(dynamic priceListId) onPriceListChanged;
  final Function(dynamic paymentTermId) onPaymentTermChanged;
  final Function(bool show) onDeliveryDateToggled;
  final Function(DateTime? date) onDeliveryDateChanged;

  const OrderFormSection({
    super.key,
    required this.formKey,
    required this.partners,
    required this.priceLists,
    required this.paymentTerms,
    required this.selectedPartnerId,
    required this.selectedPriceListId,
    required this.selectedPaymentTermId,
    required this.showDeliveryDate,
    required this.deliveryDate,
    required this.hasProducts,
    required this.onPartnerChanged,
    required this.onPriceListChanged,
    required this.onPaymentTermChanged,
    required this.onDeliveryDateToggled,
    required this.onDeliveryDateChanged,
  });

  @override
  State<OrderFormSection> createState() => _OrderFormSectionState();
}

class _OrderFormSectionState extends State<OrderFormSection> {
  final bool isAdmin = PrefUtils.user.value.isAdmin ?? false;
  bool _showAdvancedOptions = false;

  bool get _isLocked => widget.selectedPartnerId != null && widget.hasProducts;

  RxList<PartnerModel> myPartners = <PartnerModel>[].obs;
  RxList<PartnerModel> getPartner() {
    if (isAdmin) {
      myPartners.assignAll(widget.partners);
    } else {
      myPartners.assignAll(
        widget.partners.where((e) {
          if (e.customerRank != null && e.customerRank != false) {
            return e.customerRank > 0;
          }
          return false;
        }).toList(),
      );
    }
    return myPartners;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FormBuilder موجود دائمًا الآن في كلا الحالتين
    return FormBuilder(
      key: widget.formKey,
      child: Builder(
        builder: (context) {
          // ✅ تحقق من حالة FormBuilder
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // FormBuilder is ready
          });

          return _isLocked ? _buildCompactCard() : _buildFullForm();
        },
      ),
    );
  }

  Widget _buildCompactCard() {
    final partner = getPartner().firstWhere(
      (p) => p.id == widget.selectedPartnerId,
      orElse: () => getPartner().first,
    );

    final priceList = widget.priceLists.isNotEmpty
        ? widget.priceLists.firstWhere(
            (p) => p.id == widget.selectedPriceListId,
            orElse: () => widget.priceLists.first,
          )
        : null;

    return Column(
      children: [
        // ✅ إضافة حقول مخفية لحفظ القيم في FormBuilder
        FormBuilderField(
          name: 'partner_id',
          initialValue: widget.selectedPartnerId,
          builder: (field) => const SizedBox.shrink(),
        ),
        if (widget.selectedPriceListId != null)
          FormBuilderField(
            name: 'pricelist_id',
            initialValue: widget.selectedPriceListId,
            builder: (field) => const SizedBox.shrink(),
          ),
        if (widget.selectedPaymentTermId != null)
          FormBuilderField(
            name: 'payment_term_id',
            initialValue: widget.selectedPaymentTermId,
            builder: (field) => const SizedBox.shrink(),
          ),
        if (widget.showDeliveryDate && widget.deliveryDate != null)
          FormBuilderField(
            name: 'commitment_date',
            initialValue: widget.deliveryDate,
            builder: (field) => const SizedBox.shrink(),
          ),

        // الكارد المرئي
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              partner.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.selectedPriceListId != null)
                        const SizedBox(height: 4),
                      if (widget.selectedPriceListId != null)
                        Row(
                          children: [
                            Icon(
                              Icons.price_change,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                priceList?.displayName ?? priceList?.name ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(Icons.lock, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // ❌ إزالة FormBuilder من هنا لأنه موجود في الأعلى
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 24),
            _buildPartnerField(),
            const SizedBox(height: 16),
            // ✅ عرض قائمة الأسعار بناءً على العميل المحدد
            _buildPriceListSection(),
            const SizedBox(height: 16),
            _buildAdvancedOptionsToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'معلومات الطلب',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPartnerField() {
    final selectedPartner = getPartner().firstWhereOrNull(
      (p) => p.id == widget.selectedPartnerId,
    );

    return FormBuilderField<int>(
      name: 'partner_id',
      initialValue: widget.selectedPartnerId,
      validator: FormBuilderValidators.required(
        errorText: 'يرجى اختيار العميل',
      ),
      builder: (FormFieldState<int> field) {
        return InkWell(
          onTap: () {
            showPartnerSelectionDialog(
              partners: getPartner(),
              selectedPartnerId: widget.selectedPartnerId,
              onPartnerSelected: (partner) {
                field.didChange(partner.id);
                widget.onPartnerChanged(partner.id);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العميل *',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPartner?.name ?? 'اختر العميل',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedPartner != null
                              ? Colors.black87
                              : Colors.grey[600],
                          fontWeight: selectedPartner != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceListSection() {
    // ✅ التحقق من وجود عميل أولاً
    if (widget.selectedPartnerId == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'يرجى اختيار العميل أولاً',
                style: TextStyle(color: Colors.orange[700], fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ التحقق من وجود قائمة أسعار
    final partnerController = Get.find<PartnerController>();
    if (partnerController.partnerPriceLists.isNotEmpty) {
      return Column(
        children: [const SizedBox(height: 16), _buildPriceListField()],
      );
    }

    // ✅ رسالة عدم وجود قائمة أسعار
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'لا توجد قوائم أسعار متاحة لهذا العميل',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceListField() {
    final partnerController = Get.find<PartnerController>();

    if (!isAdmin && partnerController.partnerPriceLists.length == 1) {
      final priceList = partnerController.partnerPriceLists.first;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.price_change, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'قائمة الأسعار',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    priceList.displayName ?? priceList.name ?? 'غير محدد',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (priceList.items != null && priceList.items!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${priceList.items!.length} قاعدة',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.lock, size: 18, color: Colors.grey.shade400),
          ],
        ),
      );
    }

    // ✅ عرض قائمة الأسعار المحددة تلقائياً (غير قابل للتعديل)
    final selectedPriceList = partnerController.partnerPriceLists
        .firstWhereOrNull((p) => p.id == widget.selectedPriceListId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.price_change, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قائمة الأسعار',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedPriceList?.displayName ??
                      selectedPriceList?.name ??
                      'غير محدد',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedPriceList?.items != null &&
                    selectedPriceList!.items!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${selectedPriceList.items!.length} قاعدة',
                      style: TextStyle(fontSize: 10, color: Colors.green[700]),
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.lock, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildPaymentTermField() {
    if (widget.paymentTerms.isEmpty) {
      return const SizedBox.shrink();
    }

    return FormBuilderDropdown<int>(
      name: 'payment_term_id',
      decoration: InputDecoration(
        labelText: 'شروط الدفع',
        prefixIcon: const Icon(Icons.payment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: widget.paymentTerms.map((term) {
        return DropdownMenuItem(
          value: term[0] as int,
          child: Text(term[1] as String, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      initialValue: widget.selectedPaymentTermId,
      onChanged: (value) {
        widget.onPaymentTermChanged(value);
      },
    );
  }

  Widget _buildDeliveryDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => widget.onDeliveryDateToggled(!widget.showDeliveryDate),
          child: Row(
            children: [
              Checkbox(
                value: widget.showDeliveryDate,
                onChanged: (value) {
                  widget.onDeliveryDateToggled(value ?? false);
                },
              ),
              const Expanded(
                child: Text(
                  'تحديد تاريخ التسليم المتوقع',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (widget.showDeliveryDate) ...[
          const SizedBox(height: 8),
          FormBuilderDateTimePicker(
            name: 'commitment_date',
            decoration: InputDecoration(
              labelText: 'تاريخ التسليم',
              prefixIcon: const Icon(Icons.calendar_today, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            inputType: InputType.date,
            format: DateFormat('yyyy-MM-dd'),
            firstDate: DateTime.now(),
            initialValue: widget.deliveryDate,
            onChanged: (value) {
              widget.onDeliveryDateChanged(value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showAdvancedOptions = !_showAdvancedOptions;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'خيارات متقدمة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'اختياري',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showAdvancedOptions) ...[
          const SizedBox(height: 12),
          _buildPaymentTermField(),
          const SizedBox(height: 16),
          _buildDeliveryDateSection(),
        ],
      ],
    );
  }
}
