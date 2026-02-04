import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/input_formatters.dart';
import 'package:icemacha/providers/cart_provider.dart';
import 'package:icemacha/screens/order_placed.dart';

enum PaymentMethod { cash, card }

enum DeliveryOption { home, address }

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

  // Address (only if Other selected)
  final _address = TextEditingController();
  final _city = TextEditingController();

  // Card (only if Card selected)
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  PaymentMethod _pay = PaymentMethod.cash;
  DeliveryOption _delivery = DeliveryOption.home;

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

    // Validate only currently mounted fields
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Freeze lines BEFORE clearing the cart
    final frozenLines = cart.items
        .map(
          (i) => OrderLineView(
            title: i.product.title,
            qty: i.qty,
            unitPrice: i.product.price,
          ),
        )
        .toList(growable: false);

    final paymentMethod = _pay == PaymentMethod.card ? 'CARD' : 'CASH';

    // Delivery label for success page
    String deliveryLabel;
    if (_delivery == DeliveryOption.home) {
      deliveryLabel = 'Home';
    } else {
      final addr = _address.text.trim();
      final city = _city.text.trim();
      deliveryLabel = city.isEmpty ? addr : '$addr, $city';
    }

    final receipt = OrderReceipt(
      orderNo: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
      dateTime: DateTime.now(),
      paymentMethod: paymentMethod,
      city: deliveryLabel,
      lines: frozenLines,
      total: cart.subtotal,
    );

    cart.clear();

    if (!mounted) return;
    setState(() => _submitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderPlacedScreen(receipt: receipt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cart = context.watch<CartProvider>();

    final summaryLines = cart.items
        .map(
          (i) => SummaryLine(
            title: i.product.title,
            qty: i.qty,
            unitPrice: i.product.price,
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: PageBodyNarrow(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
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

              // Itemized order summary
              if (!cart.isEmpty) ...[
                ItemsSummaryCard(lines: summaryLines, total: cart.subtotal),
                const SizedBox(height: 16),
              ],

              // Form card
              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Contact
                    const SectionTitle('Contact Details'),

                    // Name & Email
                    NameField(controller: _name),
                    const SizedBox(height: 8),
                    EmailField(controller: _email),
                    const SizedBox(height: 8),

                    // Phone
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

                    // Delivery
                    const SectionTitle('Delivery'),
                    DropdownButtonFormField<DeliveryOption>(
                      initialValue: _delivery,
                      decoration: const InputDecoration(
                        labelText: 'Deliver to',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DeliveryOption.home,
                          child: Text('Home'),
                        ),
                        DropdownMenuItem(
                          value: DeliveryOption.address,
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _delivery = v ?? DeliveryOption.home),
                    ),

                    if (_delivery == DeliveryOption.address) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(
                          labelText: 'Enter your Address',
                        ),
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
                    ],

                    const SizedBox(height: 16),

                    // Payment
                    const SectionTitle('Payment'),
                    RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      value: PaymentMethod.cash,
                      groupValue: _pay,
                      title: const Text('Cash on Delivery'),
                      onChanged: (v) => setState(() => _pay = v!),
                    ),
                    RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      value: PaymentMethod.card,
                      groupValue: _pay,
                      title: const Text('Card'),
                      onChanged: (v) => setState(() => _pay = v!),
                    ),

                    if (_pay == PaymentMethod.card) ...[
                      const SizedBox(height: 8),
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
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                              ),
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
                    ],

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryBusyButton(
                        busy: _submitting,
                        label: 'Place Order',
                        busyLabel: 'Placing order',
                        icon: Icons.payments,
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
