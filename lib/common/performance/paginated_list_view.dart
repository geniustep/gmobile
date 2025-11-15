// ════════════════════════════════════════════════════════════
// PaginatedListView - قوائم محسّنة مع Pagination
// ════════════════════════════════════════════════════════════
//
// الميزات:
// - Lazy Loading تلقائي
// - Cache للصفحات
// - Pull to Refresh
// - Loading States
// - Error Handling
// - Empty State
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
// Pagination Controller
// ════════════════════════════════════════════════════════════

class PaginationController<T> extends GetxController {
  // ════════════════════════════════════════════════════════════
  // Configuration
  // ════════════════════════════════════════════════════════════

  final int itemsPerPage;
  final Future<List<T>> Function(int page, int limit) fetchFunction;

  PaginationController({
    required this.fetchFunction,
    this.itemsPerPage = 20,
  });

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 0.obs;

  // ════════════════════════════════════════════════════════════
  // Lifecycle
  // ════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  // ════════════════════════════════════════════════════════════
  // Loading Methods
  // ════════════════════════════════════════════════════════════

  /// تحميل الصفحة الأولى
  Future<void> loadInitial() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      error.value = '';
      currentPage.value = 0;

      final results = await fetchFunction(0, itemsPerPage);

      items.value = results;
      hasMore.value = results.length >= itemsPerPage;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل الصفحة التالية
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      error.value = '';

      final nextPage = currentPage.value + 1;
      final results = await fetchFunction(nextPage, itemsPerPage);

      if (results.isNotEmpty) {
        items.addAll(results);
        currentPage.value = nextPage;
        hasMore.value = results.length >= itemsPerPage;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// إعادة التحميل (Pull to Refresh)
  Future<void> refresh() async {
    await loadInitial();
  }

  /// إعادة المحاولة بعد خطأ
  Future<void> retry() async {
    if (items.isEmpty) {
      await loadInitial();
    } else {
      await loadMore();
    }
  }
}

// ════════════════════════════════════════════════════════════
// Paginated ListView Widget
// ════════════════════════════════════════════════════════════

class PaginatedListView<T> extends StatelessWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const PaginatedListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.separator,
    this.emptyWidget,
    this.errorWidget,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ════════════════════════════════════════════════════════════
      // Loading State (Initial)
      // ════════════════════════════════════════════════════════════

      if (controller.isLoading.value && controller.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'جاري التحميل...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      // ════════════════════════════════════════════════════════════
      // Error State (Initial)
      // ════════════════════════════════════════════════════════════

      if (controller.error.value.isNotEmpty && controller.items.isEmpty) {
        return errorWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
      }

      // ════════════════════════════════════════════════════════════
      // Empty State
      // ════════════════════════════════════════════════════════════

      if (controller.items.isEmpty) {
        return emptyWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم يتم العثور على أي عناصر',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
      }

      // ════════════════════════════════════════════════════════════
      // List View
      // ════════════════════════════════════════════════════════════

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // تحميل المزيد عند الوصول لـ 80% من القائمة
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.separated(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            padding: padding,
            shrinkWrap: shrinkWrap,
            itemCount: controller.items.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) {
              if (index == controller.items.length - 1) {
                return const SizedBox.shrink();
              }
              return separator ?? const Divider(height: 1);
            },
            itemBuilder: (context, index) {
              // ════════════════════════════════════════════════════════════
              // Loading Indicator (للصفحات التالية)
              // ════════════════════════════════════════════════════════════

              if (index == controller.items.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: controller.isLoadingMore.value
                        ? const CircularProgressIndicator()
                        : controller.error.value.isNotEmpty
                            ? Column(
                                children: [
                                  Text(
                                    'فشل تحميل المزيد',
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: controller.retry,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                  ),
                );
              }

              // ════════════════════════════════════════════════════════════
              // Item Widget
              // ════════════════════════════════════════════════════════════

              final item = controller.items[index];
              return itemBuilder(context, item, index);
            },
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
// Grid Version
// ════════════════════════════════════════════════════════════

class PaginatedGridView<T> extends StatelessWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final EdgeInsetsGeometry? padding;

  const PaginatedGridView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.emptyWidget,
    this.errorWidget,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading State
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // Error State
      if (controller.error.value.isNotEmpty && controller.items.isEmpty) {
        return errorWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(controller.error.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.retry,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
      }

      // Empty State
      if (controller.items.isEmpty) {
        return emptyWidget ??
            const Center(child: Text('لا توجد بيانات'));
      }

      // Grid View
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
              controller.loadMore();
            }
            return false;
          },
          child: GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: controller.items.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading Indicator
              if (index == controller.items.length) {
                return Center(
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                );
              }

              // Item Widget
              final item = controller.items[index];
              return itemBuilder(context, item, index);
            },
          ),
        ),
      );
    });
  }
}
