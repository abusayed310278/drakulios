import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';

class TrainingHeader extends StatelessWidget {
  const TrainingHeader({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
    required this.dateTitle,
    required this.dateValue,
  });

  final int activeIndex;
  final ValueChanged<int> onTabChange;
  final String dateTitle;
  final String dateValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFFC9CDD3),
              ),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
            const SizedBox(width: 6),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning 🔥',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pramuditya Uzumaki',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Image.asset(
              Images.bellImage,
              width: 20,
              height: 20,
              color: const Color(0xFFC9CDD3),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF2A2F39),
              child: ClipOval(
                child: Image.asset(
                  Images.profileImage,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TabSwitcher(activeIndex: activeIndex, onChange: onTabChange),
        const SizedBox(height: 12),
        _DateCard(title: dateTitle, date: dateValue),
      ],
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
          child: _TabButton(
            label: 'Training',
            asset: Images.traningImage,
            selected: activeIndex == 0,
            onTap: () => onChange(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TabButton(
            label: 'Nutrition',
            icon: Icons.restaurant,
            selected: activeIndex == 1,
            onTap: () => onChange(1),
          ),
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
          border: Border.all(
            color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF2A2F39),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              Image.asset(
                asset!,
                width: 16,
                height: 16,
                color: Colors.white,
              )
            else
              Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF0C224E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFB7C0D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF2B31A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                Images.solarCalendarImage,
                width: 16,
                height: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
