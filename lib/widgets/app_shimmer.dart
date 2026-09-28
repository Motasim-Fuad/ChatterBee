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

class AppShimmerAacGrid extends StatelessWidget {
  const AppShimmerAacGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Expanded(
                child: Center(child: _Bone(width: 48, height: 48, radius: 10)),
              ),
              SizedBox(height: 6),
              _Bone(width: 56, height: 10, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Bone(height: 24, circle: true),
        SizedBox(width: 10),
        Expanded(child: _Bone(height: 14)),
        SizedBox(width: 12),
        _Bone(width: 18, height: 18, radius: 4),
      ],
    );
  }
}

class AppShimmerProfile extends StatelessWidget {
  const AppShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Center(child: _Bone(height: 100, circle: true)),
          SizedBox(height: 30),
          _Bone(width: double.infinity, height: 72, radius: 16),
          SizedBox(height: 16),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 160, height: 18),
                SizedBox(height: 16),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
              ],
            ),
          ),
          SizedBox(height: 16),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 90, height: 18),
                SizedBox(height: 16),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
                SizedBox(height: 12),
                _LineRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppShimmerForm extends StatelessWidget {
  const AppShimmerForm({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Center(child: _Bone(height: 85, circle: true)),
          SizedBox(height: 30),
          _Bone(width: 80, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 48, radius: 12),
          SizedBox(height: 20),
          _Bone(width: 80, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 48, radius: 12),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _Bone(height: 16)),
              SizedBox(width: 16),
              _Bone(width: 44, height: 24, radius: 12),
            ],
          ),
          SizedBox(height: 8),
          _Bone(width: 220, height: 12),
          SizedBox(height: 28),
          _Bone(width: double.infinity, height: 48, radius: 12),
        ],
      ),
    );
  }
}

class AppShimmerNotifications extends StatelessWidget {
  const AppShimmerNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const _Bone(width: 70, height: 16),
          const SizedBox(height: 16),
          ...List.generate(
            6,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Panel(
                child: Row(
                  children: [
                    _Bone(height: 48, circle: true),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(width: double.infinity, height: 14),
                          SizedBox(height: 8),
                          _Bone(width: 90, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppShimmerPrivacy extends StatelessWidget {
  const AppShimmerPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _Bone(width: 180, height: 18),
          SizedBox(height: 16),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: 260, height: 12),
          SizedBox(height: 20),
          _Bone(width: 140, height: 16),
          SizedBox(height: 12),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: 200, height: 12),
          SizedBox(height: 20),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: 240, height: 12),
        ],
      ),
    );
  }
}

class AppShimmerSupport extends StatelessWidget {
  const AppShimmerSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _Bone(width: 160, height: 24),
          SizedBox(height: 16),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _Bone(width: 220, height: 12),
          SizedBox(height: 24),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 90, height: 14),
                SizedBox(height: 10),
                _Bone(width: 200, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppShimmerInvite extends StatelessWidget {
  const AppShimmerInvite({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Bone(height: 44, circle: true),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(width: 140, height: 14),
                        SizedBox(height: 8),
                        _Bone(width: 180, height: 12),
                      ],
                    ),
                  ),
                  _Bone(width: 64, height: 22, radius: 12),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Bone(height: 40, radius: 12)),
                  SizedBox(width: 12),
                  Expanded(child: _Bone(height: 40, radius: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShimmerPeople extends StatelessWidget {
  const AppShimmerPeople({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const _Panel(
            child: Row(
              children: [
                _Bone(height: 42, circle: true),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      _Bone(width: 180, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _Bone(width: 150, height: 16),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Panel(
                child: Row(
                  children: [
                    _Bone(height: 52, circle: true),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(width: double.infinity, height: 14),
                          SizedBox(height: 8),
                          _Bone(width: 100, height: 12),
                        ],
                      ),
                    ),
                    _Bone(width: 64, height: 28, radius: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppShimmerSchedule extends StatelessWidget {
  const AppShimmerSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Bone(width: 140, height: 16),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const _Panel(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      _Bone(width: 48, height: 48, radius: 10),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bone(width: double.infinity, height: 14),
                            SizedBox(height: 8),
                            _Bone(width: 90, height: 12),
                          ],
                        ),
                      ),
                      _Bone(width: 18, height: 18, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
            const _Bone(width: double.infinity, height: 56, radius: 14),
          ],
        ),
      ),
    );
  }
}

class AppShimmerPlans extends StatelessWidget {
  const AppShimmerPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Center(child: _Bone(height: 64, circle: true)),
          SizedBox(height: 16),
          _Bone(width: double.infinity, height: 88, radius: 16),
          SizedBox(height: 16),
          _Bone(width: double.infinity, height: 170, radius: 18),
          SizedBox(height: 16),
          _Bone(width: double.infinity, height: 170, radius: 18),
        ],
      ),
    );
  }
}
