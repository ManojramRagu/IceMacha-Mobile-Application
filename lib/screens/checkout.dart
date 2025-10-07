import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/input_formatters.dart';
import 'package:icemacha/utils/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contact
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  // Delivery
  final _address = TextEditingController();
  final _city = TextEditingController();

  // Payment
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController(); // MM/YY
  final _cvv = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500)); // fake processing
    cart.clear();

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
    Navigator.of(context).pop(); // close checkout
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cart = context.watch<CartProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: PageBodyNarrow(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Checkout',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (!cart.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Items: ${cart.totalQty}   •   Subtotal: LKR ${cart.subtotal}',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionTitle('Contact Details'),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      textInputAction: TextInputAction.next,
                      validator: Validators.required('Full name'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email('Email'),
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: Formatters.phoneLoose(),
                      validator: Validators.phone('Phone'),
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),

                    const SizedBox(height: 16),
                    _SectionTitle('Delivery'),
                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(labelText: 'Address'),
                      textInputAction: TextInputAction.next,
                      validator: Validators.required('Address'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'City'),
                      textInputAction: TextInputAction.next,
                      validator: Validators.required('City'),
                    ),

                    const SizedBox(height: 16),
                    _SectionTitle('Payment'),
                    TextFormField(
                      controller: _cardNumber,
                      decoration: const InputDecoration(
                        labelText: 'Card number',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: Formatters.cardNumberGrouped(),
                      validator: Validators.cardNumberLuhn('Card number'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiry,
                            decoration: const InputDecoration(
                              labelText: 'Expiry (MM/YY)',
                            ),
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            inputFormatters: Formatters.expiryMmYy(),
                            validator: Validators.expiryMmYy('Expiry'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvv,
                            decoration: const InputDecoration(labelText: 'CVV'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              Formatters.digitsOnly,
                              Formatters.maxLength(3),
                            ],
                            validator: Validators.cvv('CVV'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryBusyButton(
                        busy: _submitting,
                        label: 'Place Order',
                        busyLabel: 'Placing order',
                        icon: Icons.lock,
                        onPressed: _submitting ? null : _placeOrder,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

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
