import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Numeric input with − / + buttons. The value can also be typed directly.
class NumberStepper extends StatefulWidget {
  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.icon,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  /// Amount added/removed per tap.
  final int step;
  final IconData? icon;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(NumberStepper old) {
    super.didUpdateWidget(old);
    // Keep the text in sync when the value changes from outside (e.g. +/- or form reset).
    if (int.tryParse(_controller.text) != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bump(int delta) {
    final next = (widget.value + delta).clamp(0, 999999999);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final fill = context.theme.inputDecorationTheme.fillColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 15, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Row(
            children: [
              _StepButton(icon: LucideIcons.minus, onTap: widget.value > 0 ? () => _bump(-widget.step) : null),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
                ),
              ),
              _StepButton(icon: LucideIcons.plus, onTap: () => _bump(widget.step)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: onTap == null ? Colors.transparent : AppColors.violet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? context.colors.onSurfaceVariant.withValues(alpha: 0.4) : AppColors.violet,
            ),
          ),
        ),
      ),
    );
  }
}
