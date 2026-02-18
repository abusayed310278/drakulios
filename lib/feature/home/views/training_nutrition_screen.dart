import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';

class TrainingNutritionScreen extends StatefulWidget {
  const TrainingNutritionScreen({super.key});

  @override
  State<TrainingNutritionScreen> createState() => _TrainingNutritionScreenState();
}

class _TrainingNutritionScreenState extends State<TrainingNutritionScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      const SizedBox(width: 6),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning 🔥',
                            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pramuditya Uzumaki',
                            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Image.asset(Images.bellImage, width: 20, height: 20, color: const Color(0xFFC9CDD3)),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF2A2F39),
                        child: ClipOval(child: Image.asset(Images.profileImage, width: 24, height: 24, fit: BoxFit.cover)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _TabSwitcher(activeIndex: _tabIndex, onChange: (index) => setState(() => _tabIndex = index)),
                  if (_tabIndex == 0) ...[
                    const SizedBox(height: 12),
                    const _DateCard(title: 'Today\'s Challenge!', date: '3rd Feb 2026'),
                    const SizedBox(height: 12),
                    _TrainingCard(),
                  ] else ...[
                    const SizedBox(height: 12),
                    const _DateCard(title: 'Today\'s Meal!', date: '3rd Feb 2026'),
                    const SizedBox(height: 12),
                    const _MealCard(title: 'Breakfast', time: '7am - 8am', asset: Images.breakfastImage),
                    const SizedBox(height: 10),
                    const _MealCard(title: 'Lunch', time: '12pm - 1pm', asset: Images.lunchImage),
                    const SizedBox(height: 10),
                    const _MealCard(title: 'Dinner', time: '6pm - 8pm', asset: Images.dinnerImage),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.activeIndex, required this.onChange});

  final int activeIndex;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(label: 'Training', asset: Images.gymImage, selected: activeIndex == 0, onTap: () => onChange(0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TabButton(label: 'Nutrition', icon: Icons.restaurant, selected: activeIndex == 1, onTap: () => onChange(1)),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, this.icon, this.asset, required this.selected, required this.onTap});

  final String label;
  final IconData? icon;
  final String? asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2C6CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF2A2F39), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              Image.asset(asset!, width: 16, height: 16, color: Colors.white)
            else
              Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: const Color(0xFF0C224E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFFB7C0D0), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 94,
                height: 19,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            // decoration: BoxDecoration(color: const Color(0xFFF2B31A), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Image.asset(Images.solarCalendarImage, width: 32, height: 32, color: const Color(0xFFF2B31A))),
          ),
        ],
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E2024), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(Images.gym1Image, height: 170, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          const _WorkoutRow(title: 'Dumble Squat', chips: ['3 Set', '2 kg', '10 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Bench Press', chips: ['4 Set', '2 min', '5 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Lat Pulldowns', chips: ['4 Set', '90 sec', '8 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Overhead Press', chips: ['3 Set', '90 sec', '6 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Bicep Curls', chips: ['3 Set', '45 sec', '15 Reps']),
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.title, required this.chips});

  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2513),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF2B31A), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF7B5C16), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      chip,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.title, required this.time, required this.asset});

  final String title;
  final String time;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2513),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(asset, width: 54, height: 54, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                const SizedBox(height: 4),
                const Text(
                  'Chicken Breast (100 gm)',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text('P: 31g  C: 0g  F: 3.6g  165cal', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
