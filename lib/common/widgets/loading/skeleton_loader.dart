import 'package:flutter/material.dart';

/// Skeleton loader widget for better loading UX
/// Shows placeholder UI while content is loading
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card loader
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        height: 20,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        height: 16,
                        width: 150,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SkeletonLoader(
              height: 14,
              width: double.infinity,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            SkeletonLoader(
              height: 14,
              width: 200,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list loader
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}

/// Skeleton for invoice/expense detail screen
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonLoader(
                        width: 150,
                        height: 30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SkeletonLoader(
                        width: 80,
                        height: 30,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SkeletonLoader(
                    width: 120,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 100,
                    height: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const Divider(height: 24),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonLoader(
                            width: 80,
                            height: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          SkeletonLoader(
                            width: 150,
                            height: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Amounts Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 80,
                    height: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const Divider(height: 24),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonLoader(
                            width: 100,
                            height: index == 2 ? 20 : 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          SkeletonLoader(
                            width: 80,
                            height: index == 2 ? 24 : 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for grid view
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 120,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 12),
                SkeletonLoader(
                  height: 16,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: 14,
                  width: 100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
