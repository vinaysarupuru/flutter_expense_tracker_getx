import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/category_model.dart';
import '../../../domain/models/transaction_model.dart';
import '../controllers/transaction_form_controller.dart';
import '../../widgets/custom_button.dart';

class TransactionFormView extends GetView<TransactionFormController> {
  const TransactionFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.transactionToEdit == null
              ? 'Add Transaction'
              : 'Edit Transaction',
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildSubcategoryField(),
              const SizedBox(height: 16),
              _buildNoteField(),
              const SizedBox(height: 16),
              _buildTagsField(),
              const SizedBox(height: 24),
              if (controller.error.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    controller.error.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              CustomButton(
                onPressed: controller.isLoading.value
                    ? (){}
                    : () async {
                        final success = await controller.saveTransaction();
                        if (success) {
                          Get.back();
                        }
                      },
                text: controller.transactionToEdit == null ? 'Add' : 'Update',
                isLoading: controller.isLoading.value,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTypeSelector() {
    return Obx(() {
      return SegmentedButton<TransactionType>(
        segments: const [
          ButtonSegment<TransactionType>(
            value: TransactionType.expense,
            label: Text('Expense'),
            icon: Icon(Icons.arrow_downward),
          ),
          ButtonSegment<TransactionType>(
            value: TransactionType.income,
            label: Text('Income'),
            icon: Icon(Icons.arrow_upward),
          ),
        ],
        selected: {controller.type.value},
        onSelectionChanged: (Set<TransactionType> newSelection) {
          controller.setType(newSelection.first);
        },
      );
    });
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: controller.titleController,
      decoration: const InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter transaction title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: controller.amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '\$',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: controller.validateAmount,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.date.value,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.setDate(picked);
          }
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          child: Text(
            DateFormat('MMM d, y').format(controller.date.value),
          ),
        ),
      );
    });
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      return DropdownButtonFormField<CategoryModel>(
        value: controller.selectedCategory.value,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        items: controller.categories.map((CategoryModel category) {
          return DropdownMenuItem<CategoryModel>(
            value: category,
            child: Text(category.name),
          );
        }).toList(),
        onChanged: controller.setCategory,
        validator: controller.validateCategory,
      );
    });
  }

  Widget _buildSubcategoryField() {
    return Obx(() {
      final selectedCategory = controller.selectedCategory.value;
      if (selectedCategory == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SubcategoryModel>(
            value: controller.selectedSubcategory.value,
            decoration: const InputDecoration(
              labelText: 'Subcategory',
              border: OutlineInputBorder(),
            ),
            items: [
              if (selectedCategory.subcategories != null)
                ...selectedCategory.subcategories!.map(
                  (subcategory) => DropdownMenuItem(
                    value: subcategory,
                    child: Text(subcategory.name),
                  ),
                ),
            ],
            onChanged: controller.setSubcategory,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddSubcategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Subcategory'),
          ),
        ],
      );
    });
  }

  void _showAddSubcategoryDialog() {
  final TextEditingController nameController = TextEditingController();
  
  Get.dialog(
    AlertDialog(
      title: const Text('Add New Subcategory'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Subcategory Name',
          hintText: 'Enter subcategory name',
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () {
            nameController.dispose();
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              controller.addSubcategory(name);
              // nameController.dispose();
              Get.back();
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
  Widget _buildNoteField() {
    return TextFormField(
      controller: controller.noteController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.tagController,
          decoration: InputDecoration(
            labelText: 'Tags',
            hintText: 'Add tags',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.tagController.text.isNotEmpty) {
                  controller.addTag(controller.tagController.text);
                }
              },
            ),
          ),
          onChanged: (value) => controller.updateTagSuggestions(value),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.addTag(value);
            }
          },
        ),
        Obx(() {
          if (controller.tagSuggestions.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: controller.tagSuggestions.map((tag) => 
                InkWell(
                  onTap: () => controller.addTag(tag),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(tag),
                  ),
                ),
              ).toList(),
            ),
          );
        }),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          children: controller.tags.map((tag) => Chip(
            label: Text(tag),
            onDeleted: () => controller.removeTag(tag),
          )).toList(),
        )),
      ],
    );
  }
}
