import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class _Bone extends StatelessWidget {
  const _Bone({
    this.width,
    this.height = 14,
    this.radius = 10,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  static const Color _base = Color(0xFFE6E0D4);
  static const Color _highlight = Color(0xFFFBF7EE);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      period: const Duration(milliseconds: 1300),
      child: child,
    );
  }
}

class AppShimmerCompact extends StatelessWidget {
  const AppShimmerCompact({super.key, this.width = 72, this.height = 12});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: _Bone(width: width, height: height, radius: 8),
    );
  }
}

class AppShimmerCircle extends StatelessWidget {
  const AppShimmerCircle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: _Bone(height: size, circle: true),
    );
  }
}

class AppShimmerBlocking extends StatelessWidget {
  const AppShimmerBlocking({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: AppShimmer(
            child: SizedBox(
              width: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _Bone(height: 56, circle: true),
                  SizedBox(height: 16),
                  _Bone(width: double.infinity, height: 12),
                  SizedBox(height: 8),
                  _Bone(width: 120, height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShimmerHome extends StatelessWidget {
  const AppShimmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _Bone(width: 44, height: 44, radius: 12),
                Spacer(),
                _Bone(width: 36, height: 36, circle: true),
                SizedBox(width: 10),
                _Bone(width: 36, height: 36, circle: true),
              ],
            ),
            const SizedBox(height: 22),
            const _Bone(width: 140, height: 16),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (_, __) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppShimmerGrid extends StatelessWidget {
  const AppShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, __) => DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShimmerList extends StatelessWidget {
  const AppShimmerList({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const Row(
          children: [
            _Bone(height: 52, circle: true),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  _Bone(width: 140, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppShimmerProfile extends StatelessWidget {
  const AppShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            _Bone(height: 88, circle: true),
            SizedBox(height: 16),
            _Bone(width: 160, height: 16),
            SizedBox(height: 8),
            _Bone(width: 220, height: 12),
            SizedBox(height: 28),
            _Bone(width: double.infinity, height: 56, radius: 14),
            SizedBox(height: 12),
            _Bone(width: double.infinity, height: 56, radius: 14),
            SizedBox(height: 12),
            _Bone(width: double.infinity, height: 56, radius: 14),
            SizedBox(height: 12),
            _Bone(width: double.infinity, height: 56, radius: 14),
          ],
        ),
      ),
    );
  }
}

class AppShimmerCards extends StatelessWidget {
  const AppShimmerCards({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const _Bone(
          width: double.infinity,
          height: 120,
          radius: 18,
        ),
      ),
    );
  }
}
