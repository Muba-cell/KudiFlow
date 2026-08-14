import 'package:flutter/material.dart';

void main() => runApp(const KudiFlowApp());

class KudiFlowApp extends StatelessWidget {
  const KudiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0B6B4F);
    return MaterialApp(
      title: 'KudiFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: green, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7FAF8)),
      ),
      home: const KudiFlowHome(),
    );
  }
}

class TransactionItem {
  TransactionItem(
      {required this.title,
      required this.category,
      required this.amount,
      required this.isIncome,
      required this.icon,
      required this.date});
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final DateTime date;
}

class KudiFlowHome extends StatefulWidget {
  const KudiFlowHome({super.key});

  @override
  State<KudiFlowHome> createState() => _KudiFlowHomeState();
}

class _KudiFlowHomeState extends State<KudiFlowHome> {
  int _index = 0;
  final List<TransactionItem> _transactions = [
    TransactionItem(
        title: 'Monthly salary',
        category: 'Income',
        amount: 4200,
        isIncome: true,
        icon: Icons.account_balance_wallet_outlined,
        date: DateTime.now()),
    TransactionItem(
        title: 'Melcom groceries',
        category: 'Food & groceries',
        amount: 286.50,
        isIncome: false,
        icon: Icons.shopping_bag_outlined,
        date: DateTime.now()),
    TransactionItem(
        title: 'Uber ride',
        category: 'Transport',
        amount: 54,
        isIncome: false,
        icon: Icons.directions_car_outlined,
        date: DateTime.now().subtract(const Duration(days: 1))),
    TransactionItem(
        title: 'Freelance project',
        category: 'Income',
        amount: 850,
        isIncome: true,
        icon: Icons.laptop_mac_outlined,
        date: DateTime.now().subtract(const Duration(days: 2))),
  ];

  double get _income => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);
  double get _expenses => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  void _addTransaction() async {
    final item = await showModalBottomSheet<TransactionItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTransactionSheet(),
    );
    if (item != null) setState(() => _transactions.insert(0, item));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
          income: _income,
          expenses: _expenses,
          transactions: _transactions,
          onAdd: _addTransaction),
      TransactionsPage(transactions: _transactions, onAdd: _addTransaction),
      const BudgetsPage(),
      const GoalsPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      floatingActionButton: _index < 2
          ? FloatingActionButton.extended(
              onPressed: _addTransaction,
              icon: const Icon(Icons.add),
              label: const Text('Add transaction'))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Transactions'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Budgets'),
          NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings),
              label: 'Goals'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage(
      {super.key,
      required this.income,
      required this.expenses,
      required this.transactions,
      required this.onAdd});
  final double income;
  final double expenses;
  final List<TransactionItem> transactions;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final balance = income - expenses;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Row(children: [
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Good morning,',
                    style: TextStyle(color: Color(0xFF64748B))),
                Text('Mubarak 👋',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              ])),
          IconButton(
              onPressed: () {},
              icon: const Badge(child: Icon(Icons.notifications_none_rounded))),
        ]),
        const SizedBox(height: 24),
        BalanceCard(balance: balance, income: income, expenses: expenses),
        const SizedBox(height: 24),
        const Text('This month',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(
              child: StatCard(
                  label: 'Budget left',
                  value: 'GHS 1,060',
                  icon: Icons.account_balance_outlined,
                  color: Color(0xFF2563EB))),
          SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  label: 'Saved',
                  value: 'GHS 480',
                  icon: Icons.savings_outlined,
                  color: Color(0xFFB7791F)))
        ]),
        const SizedBox(height: 28),
        const Row(children: [
          Expanded(
              child: Text('Recent activity',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          Text('See all',
              style: TextStyle(
                  color: Color(0xFF0B6B4F), fontWeight: FontWeight.w600))
        ]),
        const SizedBox(height: 8),
        ...transactions.take(4).map((item) => TransactionTile(item: item)),
        const SizedBox(height: 16),
        InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EF),
                    borderRadius: BorderRadius.circular(16)),
                child: const Row(children: [
                  Icon(Icons.add_circle_outline, color: Color(0xFF0B6B4F)),
                  SizedBox(width: 12),
                  Text('Record a transaction',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B6B4F)))
                ]))),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard(
      {super.key,
      required this.balance,
      required this.income,
      required this.expenses});
  final double balance, income, expenses;
  String money(double value) => 'GHS ${value.toStringAsFixed(2)}';
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF07553F), Color(0xFF0B8060)]),
            borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Text('Available balance', style: TextStyle(color: Colors.white70)),
            Spacer(),
            Icon(Icons.visibility_outlined, color: Colors.white70)
          ]),
          const SizedBox(height: 8),
          Text(money(balance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: AmountLabel(
                    label: 'Income',
                    value: money(income),
                    icon: Icons.arrow_downward)),
            const SizedBox(width: 16),
            Expanded(
                child: AmountLabel(
                    label: 'Expenses',
                    value: money(expenses),
                    icon: Icons.arrow_upward))
          ]),
        ]),
      );
}

class AmountLabel extends StatelessWidget {
  const AmountLabel(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: Colors.white)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600))
        ])
      ]);
}

class StatCard extends StatelessWidget {
  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 13),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))
      ]));
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage(
      {super.key, required this.transactions, required this.onAdd});
  final List<TransactionItem> transactions;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 100), children: [
        const Text('Transactions',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Keep track of every cedi.',
            style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 20),
        TextField(
            decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height: 18),
        ...transactions.map((item) => TransactionTile(item: item)),
      ]);
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.item});
  final TransactionItem item;
  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: CircleAvatar(
          backgroundColor:
              item.isIncome ? const Color(0xFFE5F6EE) : const Color(0xFFFFF2E4),
          foregroundColor:
              item.isIncome ? const Color(0xFF0B8060) : const Color(0xFFD97706),
          child: Icon(item.icon)),
      title:
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(item.category),
      trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                '${item.isIncome ? '+' : '-'}GHS ${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.isIncome
                        ? const Color(0xFF0B8060)
                        : const Color(0xFFB45309))),
            Text('${item.date.day}/${item.date.month}/${item.date.year}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))
          ]));
}

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 100), children: [
        const Text('Budgets',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Spend with intention this month.',
            style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 24),
        const BudgetProgress(
            name: 'Food & groceries',
            used: 286.5,
            limit: 800,
            icon: Icons.shopping_basket_outlined,
            color: Color(0xFFF59E0B)),
        const SizedBox(height: 14),
        const BudgetProgress(
            name: 'Transport',
            used: 154,
            limit: 300,
            icon: Icons.directions_bus_outlined,
            color: Color(0xFF3B82F6)),
        const SizedBox(height: 14),
        const BudgetProgress(
            name: 'Entertainment',
            used: 120,
            limit: 200,
            icon: Icons.movie_outlined,
            color: Color(0xFF8B5CF6)),
        const SizedBox(height: 24),
        OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create a budget'))
      ]);
}

class BudgetProgress extends StatelessWidget {
  const BudgetProgress(
      {super.key,
      required this.name,
      required this.used,
      required this.limit,
      required this.icon,
      required this.color});
  final String name;
  final double used, limit;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final p = used / limit;
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                foregroundColor: color,
                child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('GHS ${used.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))
          ]),
          const SizedBox(height: 16),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                  value: p,
                  minHeight: 9,
                  color: color,
                  backgroundColor: const Color(0xFFE8EDF0))),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  '${(p * 100).toStringAsFixed(0)}% used · GHS ${(limit - used).toStringAsFixed(0)} left',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))))
        ]));
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 100), children: [
        const Text('Savings goals',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Small steps build a stronger future.',
            style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 24),
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                CircleAvatar(
                    backgroundColor: Color(0xFFFFF5D6),
                    foregroundColor: Color(0xFFB7791F),
                    child: Icon(Icons.laptop_mac_outlined)),
                SizedBox(width: 12),
                Expanded(
                    child: Text('New laptop',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17))),
                Icon(Icons.more_horiz)
              ]),
              const SizedBox(height: 26),
              const Text('GHS 2,350 of GHS 8,000',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const LinearProgressIndicator(
                  value: .294,
                  minHeight: 10,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              const SizedBox(height: 12),
              const Text('29% complete · Target: Dec 2026',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 18),
              FilledButton(
                  onPressed: () {}, child: const Text('Add contribution'))
            ])),
        const SizedBox(height: 24),
        OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create a savings goal'))
      ]);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 100), children: [
        const Text('Profile',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
                radius: 28, child: Text('M', style: TextStyle(fontSize: 22))),
            title:
                Text('Mubarak', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Your money, under control.')),
        const SizedBox(height: 20),
        const Divider(),
        const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Personal details'),
            trailing: Icon(Icons.chevron_right)),
        const ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Currency'),
            subtitle: Text('Ghana cedi (GHS)'),
            trailing: Icon(Icons.chevron_right)),
        const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Security'),
            trailing: Icon(Icons.chevron_right)),
        const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            trailing: Icon(Icons.chevron_right)),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFB91C1C)),
            title: const Text('Sign out',
                style: TextStyle(color: Color(0xFFB91C1C))),
            onTap: () {})
      ]);
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});
  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  bool _income = false;
  String _category = 'Food & groceries';
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
          key: _formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add transaction',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                          value: false,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward)),
                      ButtonSegment(
                          value: true,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward))
                    ],
                    selected: {
                      _income
                    },
                    onSelectionChanged: (value) =>
                        setState(() => _income = value.first)),
                const SizedBox(height: 14),
                TextFormField(
                    controller: _title,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'What was this for?'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a description'
                        : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Amount (GHS)'),
                    validator: (value) => double.tryParse(value ?? '') == null
                        ? 'Enter a valid amount'
                        : null),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      'Food & groceries',
                      'Transport',
                      'Entertainment',
                      'Bills',
                      'Salary',
                      'Freelance'
                    ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!)),
                const SizedBox(height: 22),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(
                                context,
                                TransactionItem(
                                    title: _title.text.trim(),
                                    category: _category,
                                    amount: double.parse(_amount.text),
                                    isIncome: _income,
                                    icon: _income
                                        ? Icons.account_balance_wallet_outlined
                                        : Icons.receipt_outlined,
                                    date: DateTime.now()));
                          }
                        },
                        child: const Text('Save transaction')))
              ])));
}
