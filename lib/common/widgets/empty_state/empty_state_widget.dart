import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Empty state widget with icon, message, and action button
/// Provides better UX when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D6571),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for invoices
class EmptyInvoicesState extends StatelessWidget {
  final VoidCallback? onCreateInvoice;

  const EmptyInvoicesState({super.key, this.onCreateInvoice});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long,
      title: 'لا توجد فواتير',
      message: 'لم يتم إنشاء أي فاتورة بعد.\nقم بإنشاء فاتورة جديدة للبدء',
      actionLabel: 'إنشاء فاتورة',
      onAction: onCreateInvoice,
      iconColor: Colors.blue.shade300,
    );
  }
}

/// Empty state for expenses
class EmptyExpensesState extends StatelessWidget {
  final VoidCallback? onCreateExpense;

  const EmptyExpensesState({super.key, this.onCreateExpense});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt,
      title: 'لا توجد مصاريف',
      message: 'لم يتم تسجيل أي مصروف بعد.\nقم بإضافة مصروف جديد للبدء',
      actionLabel: 'إضافة مصروف',
      onAction: onCreateExpense,
      iconColor: Colors.orange.shade300,
    );
  }
}

/// Empty state for payments
class EmptyPaymentsState extends StatelessWidget {
  final VoidCallback? onCreatePayment;

  const EmptyPaymentsState({super.key, this.onCreatePayment});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.payment,
      title: 'لا توجد دفعات',
      message: 'لم يتم تسجيل أي دفعة بعد.\nقم بإضافة دفعة جديدة للبدء',
      actionLabel: 'تسجيل دفعة',
      onAction: onCreatePayment,
      iconColor: Colors.green.shade300,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      message: 'لم يتم العثور على نتائج لـ "$searchQuery".\nجرب البحث بكلمات مختلفة',
      actionLabel: 'مسح البحث',
      onAction: onClearSearch,
      iconColor: Colors.grey.shade400,
    );
  }
}

/// Empty state for pending approvals
class EmptyApprovalsState extends StatelessWidget {
  const EmptyApprovalsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.check_circle_outline,
      title: 'لا توجد طلبات موافقة',
      message: 'جميع الطلبات تمت معالجتها.\nلا توجد طلبات معلقة تحتاج موافقة',
      iconColor: Colors.green.shade400,
    );
  }
}

/// Empty state for notifications
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'لا توجد إشعارات',
      message: 'ليس لديك أي إشعارات جديدة حالياً',
      iconColor: Colors.blue.shade300,
    );
  }
}

/// Empty state with custom animation
class AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.icon,
                size: 100,
                color: widget.iconColor ?? Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D6571),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.message,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.actionLabel != null && widget.onAction != null) ...[
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: widget.onAction,
                      icon: const Icon(Icons.add),
                      label: Text(widget.actionLabel!),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
