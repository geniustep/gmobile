import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/controllers/payment_controller.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:intl/intl.dart';

class PaymentListSection extends StatelessWidget {
  const PaymentListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.find<PaymentController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredPayments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No payments found',
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          itemCount: controller.filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = controller.filteredPayments[index];
            return _buildPaymentCard(context, payment, controller);
          },
        ),
      );
    });
  }

  Widget _buildPaymentCard(context, payment, PaymentController controller) {
    final paymentDate = payment.paymentDate != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(payment.paymentDate.toString()))
        : 'No date';

    final amount = payment.amount?.toString() ?? '0.00';
    final state = payment.state?.toString() ?? 'draft';
    final paymentType = payment.paymentType?.toString() ?? 'inbound';

    // Get partner name
    String partnerName = 'Unknown Partner';
    if (payment.partnerId != null) {
      if (payment.partnerId is List && (payment.partnerId as List).length > 1) {
        partnerName = (payment.partnerId as List)[1].toString();
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.paymentDetail,
            arguments: {'payment': payment},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      payment.name?.toString() ?? 'Payment',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF5D6571),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  _buildStateChip(state),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    paymentType == 'inbound'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                    size: 20,
                    color: paymentType == 'inbound'
                      ? Colors.green
                      : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.getPaymentTypeLabel(paymentType),
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFA0A0A3),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Color(0xFFA0A0A3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      partnerName,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFFA0A0A3),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 20,
                    color: Color(0xFFA0A0A3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    paymentDate,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFA0A0A3),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFA0A0A3),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$$amount',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF5D6571),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip(String state) {
    Color color;
    switch (state) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'posted':
        color = Colors.blue;
        break;
      case 'reconciled':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        state.toUpperCase(),
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
