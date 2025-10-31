import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/partner.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/update/res_partner_update.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';

class CustomerListSection extends StatefulWidget {
  final List<PartnerModel> partners;
  const CustomerListSection(this.partners, {super.key});

  @override
  State<CustomerListSection> createState() => _CustomerListSectionState();
}

class _CustomerListSectionState extends State<CustomerListSection> {
  bool isChampsValid(dynamic champs) {
    return champs != null && champs != false && champs != "";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.partners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 80,
                color: const Color(0xFF3498DB).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No customers found",
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start by adding your first customer",
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 8),
      itemCount: widget.partners.length,
      itemBuilder: (context, index) {
        final customer = widget.partners[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.to(() => Partner(partner: customer)),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'customer_${customer.id}',
                      child: InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (_) {
                              final String imageToShow = kReleaseMode
                                  ? (isChampsValid(customer.image1920)
                                        ? customer.image1920
                                        : "assets/images/other/empty_product.png")
                                  : "assets/images/other/empty_product.png";

                              return ImageTap(imageToShow);
                            },
                          );
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF3498DB).withOpacity(0.1),
                                const Color(0xFF2980B9).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF3498DB).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: buildImage(
                              width: 90,
                              image: customer.image_512,
                              height: 90,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: GoogleFonts.raleway(
                                        color: const Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: customer.active
                                            ? const Color(
                                                0xFF27AE60,
                                              ).withOpacity(0.1)
                                            : const Color(
                                                0xFFE74C3C,
                                              ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: customer.active
                                                  ? const Color(0xFF27AE60)
                                                  : const Color(0xFFE74C3C),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            customer.active
                                                ? "Active"
                                                : "Inactive",
                                            style: GoogleFonts.nunito(
                                              color: customer.active
                                                  ? const Color(0xFF27AE60)
                                                  : const Color(0xFFE74C3C),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isChampsValid(customer.saleOrderCount))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(
                                          0xFFFEB019,
                                        ).withOpacity(0.2),
                                        const Color(
                                          0xFFF39C12,
                                        ).withOpacity(0.15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFF39C12,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/icon_svg/reward_icon.svg",
                                        width: 16,
                                        color: const Color(0xFFF39C12),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        customer.saleOrderCount.toString(),
                                        style: GoogleFonts.nunito(
                                          color: const Color(0xFFF39C12),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isChampsValid(customer.email))
                            _buildInfoRow(
                              Icons.email_rounded,
                              customer.email.toString(),
                            ),
                          if (isChampsValid(customer.mobile))
                            _buildInfoRow(
                              Icons.phone_rounded,
                              customer.mobile.toString(),
                            ),
                          if (isChampsValid(customer.street))
                            _buildInfoRow(
                              Icons.location_on_rounded,
                              customer.street.toString(),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionButton(
                                icon: Icons.edit_rounded,
                                color: const Color(0xFF3498DB),
                                onPressed: () {
                                  buildModalBottomSheet(context, customer);
                                },
                              ),
                              const SizedBox(width: 12),
                              _buildActionButton(
                                icon: Icons.delete_rounded,
                                color: const Color(0xFFE74C3C),
                                onPressed: () {
                                  DeleteToast.showDeleteToast(
                                    context,
                                    customer.name,
                                  );
                                  setState(() {
                                    widget.partners.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF3498DB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: const Color(0xFF5D6571),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  void buildModalBottomSheet(BuildContext context, customer) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: UpdatePartner(customer),
        );
      },
    );
  }
}
