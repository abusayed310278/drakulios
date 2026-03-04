import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';

class FreezeAccountScreen extends StatefulWidget {
  const FreezeAccountScreen({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.phone,
    required this.email,
    required this.memberSince,
    required this.avatarUrl,
  });

  final String memberName;
  final String memberId;
  final String phone;
  final String email;
  final String memberSince;
  final String avatarUrl;

  @override
  State<FreezeAccountScreen> createState() => _FreezeAccountScreenState();
}

class _FreezeAccountScreenState extends State<FreezeAccountScreen> {
  DateTime? _selectedDate;
  bool _indefinite = true;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _indefinite = false;
    });
  }

  String _dateLabel() {
    final d = _selectedDate;
    if (d == null) return 'Enter end Date..';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _confirmFreeze() {
    CustomSnackbar.show(
      _indefinite
          ? 'Membership freeze set to indefinite'
          : 'Membership freeze set until ${_dateLabel()}',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: IconButton(
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
                      ),
                      Text(
                        'Freeze Account',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 34 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FreezeAvatar(imageUrl: widget.avatarUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.memberName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 34 / 2,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _InfoText('Member ID : ${widget.memberId}'),
                            _InfoText('Contact no. : ${widget.phone}'),
                            _InfoText('Email : ${widget.email}'),
                            _InfoText('Member Since : ${widget.memberSince}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Freeze Duration',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18 / 1.3,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionButton(
                          text: _dateLabel(),
                          selected: !_indefinite,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OptionButton(
                          text: 'Indefinite',
                          selected: _indefinite,
                          onTap: () => setState(() => _indefinite = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _BottomButton(
                          title: 'Cancel',
                          bg: const Color(0xFF2A2513),
                          border: const Color(0xFFF2B31A),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BottomButton(
                          title: 'Confirm Freeze',
                          bg: const Color(0xFFF2B31A),
                          border: const Color(0xFFF2B31A),
                          textColor: Colors.white,
                          onTap: _confirmFreeze,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 38,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C224E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2C6CFF), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: selected ? Colors.white : const Color(0xFF707070),
              fontSize: 16 / 1.3,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.title,
    required this.bg,
    required this.border,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String title;
  final Color bg;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 16 / 1.3,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _FreezeAvatar extends StatelessWidget {
  const _FreezeAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFF2A2F39),
      child: ClipOval(
        child: trimmed.isNotEmpty
            ? Image.network(
                trimmed,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FreezeAvatarPlaceholder(),
              )
            : const _FreezeAvatarPlaceholder(),
      ),
    );
  }
}

class _FreezeAvatarPlaceholder extends StatelessWidget {
  const _FreezeAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFF2A2F39),
      child: const Icon(Icons.person, color: Color(0xFFB1B1B1), size: 28),
    );
  }
}
