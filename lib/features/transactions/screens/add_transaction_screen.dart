import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/categories.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionPage({super.key, this.existingTransaction});

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState
    extends State<AddTransactionPage> {

  final _formKey = GlobalKey<FormState>();

  late String transactionType;
  late String selectedCategory;
  late final TextEditingController amountController;
  late final TextEditingController descriptionController;

  bool get isEditing => widget.existingTransaction != null;

  List<String> get categoryOptions =>
      transactionType == "Income" ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;

    transactionType = existing?.type ?? "Expense";
    selectedCategory = existing?.category ?? categoryOptions.first;

    amountController = TextEditingController(
      text: existing == null ? "" : existing.amount.abs().toStringAsFixed(2),
    );
    descriptionController = TextEditingController(
      text: existing?.title ?? "",
    );
  }

  void _setType(String type) {
    setState(() {
      transactionType = type;
      if (!categoryOptions.contains(selectedCategory)) {
        selectedCategory = categoryOptions.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cloudWhite,

      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Add Transaction"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Transaction Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Income"),
                      selected: transactionType == "Income",
                      onSelected: (value) => _setType("Income"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Expense"),
                      selected: transactionType == "Expense",
                      onSelected: (value) => _setType("Expense"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              const Text(
                "Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: categoryOptions
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(categoryIcon(cat), size: 20),
                            const SizedBox(width: 10),
                            Text(cat),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount (GH₵)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter an amount";
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return "Enter a valid number";
                  }
                  if (parsed <= 0) {
                    return "Amount must be greater than zero";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Example: Lunch",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final enteredAmount = double.parse(amountController.text);
                    final signedAmount =
                        transactionType == "Income" ? enteredAmount : -enteredAmount;

                    final tx = Transaction(
                      id: widget.existingTransaction?.id,
                      title: descriptionController.text.trim(),
                      type: transactionType,
                      category: selectedCategory,
                      amount: signedAmount,
                      // New transactions get "now"; edits keep their original date.
                      date: widget.existingTransaction?.date ?? DateTime.now(),
                    );

                    Navigator.pop(context, tx);
                  },
                  child: Text(isEditing ? "Update Transaction" : "Save Transaction"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}