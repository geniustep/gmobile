import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_module.dart';

class ButtonOrder extends StatefulWidget {
  final String state;
  final OrderModel order;
  final Future<void> Function(int) onUpdate;

  const ButtonOrder({
    super.key,
    required this.state,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<ButtonOrder> createState() => _ButtonOrderState();
}

class _ButtonOrderState extends State<ButtonOrder> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();

    if (buttonConfig.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32, // تصغير من 44 إلى 32
      child: ElevatedButton(
        onPressed: isLoading ? null : buttonConfig.onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonConfig.color,
          disabledBackgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12), // تصغير من 16
        ),
        child: isLoading
            ? SizedBox(
                width: 16, // تصغير من 20
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonConfig.icon,
                    size: 14, // تصغير من 18
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6), // تصغير من 8
                  Flexible(
                    child: Text(
                      buttonConfig.text,
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 12, // تصغير من 14
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.state) {
      case 'draft':
        return _ButtonConfig(
          text: 'Confirmer',
          icon: Icons.check_circle_outline,
          color: StatusColors.sale,
          onPressed: _handleConfirm,
        );

      case 'annuler':
        return _ButtonConfig(
          text: 'Annuler',
          icon: Icons.cancel_outlined,
          color: AppColors.textMuted,
          onPressed: _handleCancel,
          isDestructive: true,
        );

      case 'cancel':
        return _ButtonConfig(
          text: 'Remettre en Devis',
          icon: Icons.refresh,
          color: StatusColors.draft,
          onPressed: _handleSetToDraft,
        );

      default:
        return _ButtonConfig(
          text: '',
          icon: Icons.info,
          color: Colors.grey,
          onPressed: () {},
        );
    }
  }

  Future<void> _handleConfirm() async {
    final confirmed = await _showConfirmDialog(
      title: 'Confirmer le devis',
      message: 'Voulez-vous confirmer ce devis et le transformer en commande?',
      confirmText: 'Confirmer',
      icon: Icons.check_circle_outline,
      iconColor: StatusColors.sale,
    );

    if (!confirmed) return;

    await _executeAction(
      action: () async {
        await OrderModule.confirmOrder(
          args: [widget.order.id],
          onResponse: (resConfirm) async {
            if (widget.order.invoiceCount == 0) {
              await widget.onUpdate(widget.order.id);
            }
          },
        );
      },
      successMessage: 'Commande confirmée avec succès',
      isSuccess: true,
    );
  }

  Future<void> _handleCancel() async {
    final confirmed = await _showConfirmDialog(
      title: 'Annuler la commande',
      message: 'Êtes-vous sûr de vouloir annuler cette commande?',
      confirmText: 'Annuler',
      icon: Icons.cancel_outlined,
      iconColor: StatusColors.cancel,
      isDestructive: true,
    );

    if (!confirmed) return;

    await _executeAction(
      action: () async {
        await OrderModule.cancelMethod(
          args: [widget.order.id],
          onResponse: (response) async {},
        );
      },
      successMessage: 'Commande annulée',
      isError: true,
    );
  }

  Future<void> _handleSetToDraft() async {
    final confirmed = await _showConfirmDialog(
      title: 'Remettre en Devis',
      message: 'Voulez-vous remettre cette commande en devis?',
      confirmText: 'Confirmer',
      icon: Icons.refresh,
      iconColor: StatusColors.draft,
    );

    if (!confirmed) return;

    await _executeAction(
      action: () async {
        await OrderModule.Draft_method(
          args: [widget.order.id],
          onResponse: (response) async {},
        );
      },
      successMessage: 'Commande remise en devis',
      isSuccess: true,
    );
  }

  /// دالة موحدة لتنفيذ العمليات مع إدارة الحالة والأخطاء
  Future<void> _executeAction({
    required Future<void> Function() action,
    required String successMessage,
    bool isSuccess = false,
    bool isError = false,
  }) async {
    setState(() => isLoading = true);

    try {
      await action();

      if (mounted) {
        _showSnackBar(successMessage, isSuccess: isSuccess, isError: isError);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required IconData icon,
    required Color iconColor,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            height: 1.5,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? FunctionalColors.buttonDanger
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? FunctionalColors.buttonDanger
            : isSuccess
            ? StatusColors.sale
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ButtonConfig {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isDestructive;

  _ButtonConfig({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isDestructive = false,
  });
}
