import 'package:flutter/material.dart';
import 'package:icemacha/utils/validation.dart';

class PageBodyNarrow extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageBodyNarrow({super.key, required this.child, this.maxWidth = 520});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;

  const EmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: Validators.email(label),
      autofillHints: const [AutofillHints.email],
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
    );
  }
}

class PrimaryBusyButton extends StatelessWidget {
  final bool busy;
  final String label;
  final String? busyLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const PrimaryBusyButton({
    super.key,
    required this.busy,
    required this.label,
    required this.icon,
    this.busyLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(busy ? (busyLabel ?? '$label…') : label),
      onPressed: busy ? null : onPressed,
    );
  }
}

/// Quantity selector with – / + and a tap-to-pick wheel.
class QuantitySelector extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 20,
    required this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value.clamp(widget.min, widget.max);
  }

  @override
  void didUpdateWidget(covariant QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent changes value/min/max, keep us in sync
    final next = widget.value.clamp(widget.min, widget.max);
    if (next != _value) _value = next;
    if (_value > widget.max) _value = widget.max;
    if (_value < widget.min) _value = widget.min;
  }

  void _set(int v) {
    final clamped = v.clamp(widget.min, widget.max);
    if (clamped != _value) {
      setState(() => _value = clamped);
      widget.onChanged(clamped);
    }
  }

  void _openPicker() {
    final ctrl = FixedExtentScrollController(initialItem: _value - widget.min);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        final cs = Theme.of(ctx).colorScheme;
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    Text('Select quantity', style: tt.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final selected = ctrl.selectedItem + widget.min;
                        Navigator.pop(ctx);
                        _set(selected);
                      },
                      child: Text('Done', style: TextStyle(color: cs.primary)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: ctrl,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 44,
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, index) {
                      if (index < 0) return null; // guard
                      final v = widget.min + index;
                      if (v > widget.max) return null;
                      return Center(child: Text('$v', style: tt.titleLarge));
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabledMinus = _value <= widget.min;
    final disabledPlus = _value >= widget.max;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: cs.surface,
        shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: disabledMinus ? null : () => _set(_value - 1),
            icon: const Icon(Icons.remove),
          ),
          InkWell(
            onTap: _openPicker,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('$_value'),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: disabledPlus ? null : () => _set(_value + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
// Checkout page form widgets

// Compact key–value row (e.g., Order # / Date / Payment).
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const KeyValueRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: tt.bodyMedium)),
      ],
    );
  }
}

// Section title used across forms.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}

// Price chip/pill (“LKR 500”) used in summaries and receipts.
class PricePill extends StatelessWidget {
  final String text;
  const PricePill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// Light-weight summary line model for UI lists.
class SummaryLine {
  final String title;
  final int qty;
  final int unitPrice;
  const SummaryLine({
    required this.title,
    required this.qty,
    required this.unitPrice,
  });
  int get lineTotal => qty * unitPrice;
}

// Itemized summary card (list of lines + total). Reused on Checkout & Receipt.
class ItemsSummaryCard extends StatelessWidget {
  final List<SummaryLine> lines;
  final int total;
  const ItemsSummaryCard({super.key, required this.lines, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            ...lines.map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.qty > 1 ? '${l.title} × ${l.qty}' : l.title,
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    PricePill('LKR ${l.lineTotal}'),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Text(
                  'Total',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                PricePill('LKR $total'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
