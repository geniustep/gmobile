import 'dart:collection';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/update/res_partner_update.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/create_new_order_form.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';

class Partner extends StatefulWidget {
  final PartnerModel partner;
  const Partner({super.key, required this.partner});

  @override
  State<Partner> createState() => _PartnerState();
}

class _PartnerState extends State<Partner> with SingleTickerProviderStateMixin {
  GoogleMapController? _googleMapController;
  CameraPosition? _kGooglePlex;
  final Set<Circle> _circles = {};
  final HashSet<Marker> _markers = HashSet<Marker>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _subTotal = 0;
  var childs = <PartnerModel>[].obs;

  bool _isValidValue(dynamic value) {
    return value != null &&
        value != false &&
        value != "" &&
        value != 0 &&
        value != false &&
        value != "false";
  }

  String _getStringValue(dynamic value, [String defaultValue = 'N/A']) {
    if (!_isValidValue(value)) return defaultValue;
    if (value is Map) {
      return value['display_name']?.toString() ?? defaultValue;
    }
    return value.toString();
  }

  double _getDoubleValue(dynamic value) {
    if (!_isValidValue(value)) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _getIntValue(dynamic value) {
    if (!_isValidValue(value)) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeGoogleMap();
    _setupAnimation();
    _calculateSubTotal();
    if (_isValidValue(widget.partner.childIds)) {
      List<dynamic> childIdsList = [];
      if (widget.partner.childIds is List) {
        childIdsList = widget.partner.childIds as List<dynamic>;
      }
      if (childIdsList.isNotEmpty) {
        childs.assignAll(
          PrefUtils.partners.where((partner) {
            return childIdsList.contains(partner.id);
          }).toList(),
        );
      }
    }
  }

  void _initializeGoogleMap() {
    var lat = _getDoubleValue(widget.partner.partnerLatitude);
    var long = _getDoubleValue(widget.partner.partnerLongitude);

    if (lat != 0.0 && long != 0.0) {
      setState(() {
        _kGooglePlex = CameraPosition(target: LatLng(lat, long), zoom: 14);
        _markers.add(
          Marker(
            markerId: const MarkerId('marker'),
            position: LatLng(lat, long),
          ),
        );
      });
    }
  }

  void _calculateSubTotal() {
    setState(() {
      double totalInvoiced = _getDoubleValue(widget.partner.totalInvoiced);
      // Since credit field is not available, we'll use totalInvoiced as subtotal
      _subTotal = totalInvoiced;
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3498DB),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.partner.name ?? "Customer Details",
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          DraftAppBarBadge(
            showOnlyWhenHasDrafts: true,
            iconColor: FunctionalColors.buttonSecondary,
            badgeColor: Colors.orange,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
            onPressed: _showContactOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoogleMap(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPartnerHeader(),
                  const SizedBox(height: 20),
                  _buildContactInformation(),
                  const SizedBox(height: 20),
                  _buildFinancialCards(),
                  const SizedBox(height: 20),
                  _buildBusinessInformation(),
                  const SizedBox(height: 20),
                  if (childs.isNotEmpty) ...[
                    _buildSectionTitle("Branches"),
                    const SizedBox(height: 12),
                    _buildPartnerChilds(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.raleway(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildGoogleMap() {
    if (_kGooglePlex == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3498DB).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                "Location not available",
                style: GoogleFonts.nunito(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GoogleMap(
        initialCameraPosition: _kGooglePlex!,
        myLocationEnabled: true,
        circles: _circles,
        markers: _markers,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
      ),
    );
  }

  Widget _buildPartnerHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFF3498DB).withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'partner_image_${widget.partner.id}',
                child: InkWell(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) {
                        final String imageToShow = kReleaseMode
                            ? (_isValidValue(widget.partner.image1920)
                                  ? _getStringValue(widget.partner.image1920)
                                  : "assets/images/other/empty_product.png")
                            : "assets/images/other/empty_product.png";

                        return ImageTap(imageToShow);
                      },
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3498DB),
                          const Color(0xFF2980B9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: buildImage(
                          image:
                              kReleaseMode &&
                                  _isValidValue(widget.partner.image1920)
                              ? widget.partner.image1920
                              : "assets/images/other/empty_product.png",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStringValue(widget.partner.name),
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: const Color(0xFF2C3E50),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isValidValue(widget.partner.companyType))
                      _buildBadge(
                        _getStringValue(widget.partner.companyType) == "company"
                            ? "Company"
                            : "Individual",
                        _getStringValue(widget.partner.companyType) == "company"
                            ? Icons.business
                            : Icons.person,
                        const Color(0xFF3498DB),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 14,
                          color: const Color(0xFF7F8C8D),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "ID: ${_getStringValue(widget.partner.id)}",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isValidValue(widget.partner.street)) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStringValue(widget.partner.street),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF5D6571),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    bool hasContactInfo =
        _isValidValue(widget.partner.phone) ||
        _isValidValue(widget.partner.mobile) ||
        _isValidValue(widget.partner.email) ||
        _isValidValue(widget.partner.website);

    if (!hasContactInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Contact Information",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isValidValue(widget.partner.phone))
            _buildContactItem(
              Icons.phone_rounded,
              "Phone",
              _getStringValue(widget.partner.phone),
              const Color(0xFF27AE60),
            ),
          if (_isValidValue(widget.partner.mobile))
            _buildContactItem(
              Icons.phone_android_rounded,
              "Mobile",
              _getStringValue(widget.partner.mobile),
              const Color(0xFF3498DB),
            ),
          if (_isValidValue(widget.partner.email))
            _buildContactItem(
              Icons.email_rounded,
              "Email",
              _getStringValue(widget.partner.email),
              const Color(0xFFE74C3C),
            ),
          if (_isValidValue(widget.partner.website))
            _buildContactItem(
              Icons.language_rounded,
              "Website",
              _getStringValue(widget.partner.website),
              const Color(0xFF9B59B6),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF95A5A6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCards() {
    int orderCount = _getIntValue(widget.partner.saleOrderCount);
    double totalInvoiced = _getDoubleValue(widget.partner.totalInvoiced);

    return Column(
      children: [
        if (orderCount > 0)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Orders",
                  orderCount.toString(),
                  Icons.shopping_cart_rounded,
                  const Color(0xFF3498DB),
                ),
              ),
            ],
          ),
        if (orderCount > 0) const SizedBox(height: 12),
        _buildInfoCard(
          "Total Amount",
          "${_subTotal.toStringAsFixed(2)} MAD",
          Icons.account_balance_wallet_rounded,
          const Color(0xFF3498DB),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          "Total Invoiced",
          "${totalInvoiced.toStringAsFixed(2)} MAD",
          Icons.receipt_long_rounded,
          const Color(0xFF27AE60),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInformation() {
    bool hasBusinessInfo =
        _isValidValue(widget.partner.vat) ||
        _isValidValue(widget.partner.countryId) ||
        _isValidValue(widget.partner.city) ||
        _isValidValue(widget.partner.zip);

    if (!hasBusinessInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Business Information",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isValidValue(widget.partner.vat))
            _buildBusinessItem(
              Icons.receipt_rounded,
              "VAT",
              _getStringValue(widget.partner.vat),
            ),
          if (_isValidValue(widget.partner.countryId))
            _buildBusinessItem(
              Icons.flag_rounded,
              "Country",
              _getStringValue(widget.partner.countryId[1]),
            ),
          if (_isValidValue(widget.partner.city))
            _buildBusinessItem(
              Icons.location_city_rounded,
              "City",
              _getStringValue(widget.partner.city),
            ),
          if (_isValidValue(widget.partner.zip))
            _buildBusinessItem(
              Icons.pin_drop_rounded,
              "ZIP Code",
              _getStringValue(widget.partner.zip),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFF39C12), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF95A5A6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerChilds() {
    if (childs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.business_outlined,
                size: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "No branches available",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: childs.length,
      itemBuilder: (context, index) {
        final branch = childs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Partner(partner: branch),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) {
                            final String imageToShow = kReleaseMode
                                ? (_isValidValue(branch.image1920)
                                      ? _getStringValue(branch.image1920)
                                      : "assets/images/other/empty_product.png")
                                : "assets/images/other/empty_product.png";

                            return ImageTap(imageToShow);
                          },
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE0E6ED),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: buildImage(
                            image:
                                kReleaseMode && _isValidValue(branch.image1920)
                                ? branch.image1920
                                : "assets/images/other/empty_product.png",
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStringValue(branch.name, "No Name"),
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isValidValue(branch.function))
                            Text(
                              "Function: ${_getStringValue(branch.function)}",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          if (_isValidValue(branch.phone))
                            Text(
                              "Phone: ${_getStringValue(branch.phone)}",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7F8C8D),
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

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionBubble(
      iconColor: Colors.white,
      backGroundColor: const Color(0xFF3498DB),
      animation: _animation,
      iconData: Icons.add,
      onPress: () => _animationController.isCompleted
          ? _animationController.reverse()
          : _animationController.forward(),
      items: <Bubble>[
        Bubble(
          title: "Check In",
          iconColor: Colors.white,
          bubbleColor: const Color(0xFF9B59B6),
          icon: Icons.checklist_sharp,
          titleStyle: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
          onPress: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: Text("Check-in feature")),
                );
              },
            );
            _animationController.reverse();
          },
        ),
        Bubble(
          title: "Update Customer",
          iconColor: Colors.white,
          bubbleColor: const Color(0xFF27AE60),
          icon: Icons.edit_outlined,
          titleStyle: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
          onPress: () {
            Get.to(() => UpdatePartner(widget.partner));
            _animationController.reverse();
          },
        ),
        Bubble(
          title: "Create Sales Order",
          iconColor: Colors.white,
          bubbleColor: const Color(0xFFF39C12),
          icon: Icons.shopping_cart_outlined,
          titleStyle: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
          onPress: () {
            Get.off(() => CreateNewOrder(partner: widget.partner));
            _animationController.reverse();
          },
        ),
      ],
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone, color: Color(0xFF27AE60)),
              ),
              title: Text(
                "Call Customer",
                style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
