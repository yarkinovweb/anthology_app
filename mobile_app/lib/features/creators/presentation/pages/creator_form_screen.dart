import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/creator_form_params.dart';
import '../bloc/creator_manage_bloc.dart';

class CreatorFormScreen extends StatelessWidget {
  /// Pass an existing creator to enter edit mode; null = create mode.
  final CreatorEntity? existing;

  const CreatorFormScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreatorManageBloc>()
        ..add(LoadCreatorFormDataEvent(existing: existing)),
      child: _CreatorFormView(existing: existing),
    );
  }
}

class _CreatorFormView extends StatefulWidget {
  final CreatorEntity? existing;
  const _CreatorFormView({this.existing});

  @override
  State<_CreatorFormView> createState() => _CreatorFormViewState();
}

class _CreatorFormViewState extends State<_CreatorFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _bornCtrl;
  late final TextEditingController _diedCtrl;
  String? _selectedCountryId;
  String? _selectedCategoryId;

  // Cached once form data loads so the UI survives state transitions (e.g. saving)
  List<CountryEntity> _countries = [];
  List<CategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _bioCtrl  = TextEditingController(text: e?.bio ?? '');
    _bornCtrl = TextEditingController(text: e?.bornYear?.toString() ?? '');
    _diedCtrl = TextEditingController(text: e?.diedYear?.toString() ?? '');
    _selectedCountryId  = e?.countryId;
    _selectedCategoryId = e?.categoryId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _bornCtrl.dispose();
    _diedCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final params = CreatorFormParams(
      name:       _nameCtrl.text.trim(),
      bio:        _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      bornYear:   int.tryParse(_bornCtrl.text.trim()),
      diedYear:   int.tryParse(_diedCtrl.text.trim()),
      countryId:  _selectedCountryId,
      categoryId: _selectedCategoryId,
    );
    context.read<CreatorManageBloc>().add(
          SaveCreatorEvent(params, editId: widget.existing?.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return BlocConsumer<CreatorManageBloc, CreatorManageState>(
      listener: (context, state) {
        if (state is CreatorManageFormReady) {
          setState(() {
            _countries  = state.countries;
            _categories = state.categories;
            // Pre-fill dropdowns from loaded data if they weren't already set
            _selectedCountryId  ??= state.existing?.countryId;
            _selectedCategoryId ??= state.existing?.categoryId;
          });
        }
        if (state is CreatorManageSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isNew
                  ? 'creator_create_success'.tr()
                  : 'creator_update_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(state.creator);
        }
        if (state is CreatorManageDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('creator_delete_success'.tr()),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/home');
        }
        if (state is CreatorManageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            title: Text(
              isEdit ? 'creator_edit_title'.tr() : 'creator_create_title'.tr(),
            ),
            actions: [
              if (isEdit)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'delete'.tr(),
                  onPressed: state is CreatorManageSaving
                      ? null
                      : () => _confirmDelete(context),
                ),
            ],
          ),
          body: state is CreatorManageFormLoading
              ? const Center(child: CircularProgressIndicator())
              : state is CreatorManageFormReady || state is CreatorManageSaving || state is CreatorManageError
                  ? _buildForm(context, state)
                  : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, CreatorManageState state) {
    final isSaving = state is CreatorManageSaving;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              controller: _nameCtrl,
              label: 'creator_name'.tr(),
              hint: 'creator_name_hint'.tr(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'creator_name_required'.tr() : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              value: _selectedCategoryId,
              label: 'creators_filter_category'.tr(),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              value: _selectedCountryId,
              label: 'creators_filter_country'.tr(),
              items: _countries
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.flagEmoji}  ${c.name}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCountryId = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _bornCtrl,
                    label: 'creators_born'.tr(),
                    hint: 'creator_year_hint'.tr(),
                    keyboardType: TextInputType.number,
                    validator: _validateYear,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _diedCtrl,
                    label: 'creators_died'.tr(),
                    hint: 'creator_year_hint'.tr(),
                    keyboardType: TextInputType.number,
                    validator: _validateYear,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _bioCtrl,
              label: 'creators_bio'.tr(),
              hint: 'creator_bio_hint'.tr(),
              maxLines: 6,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSaving ? null : () => _submit(context),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text('save'.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true,
    );
  }

  String? _validateYear(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n < 1000 || n > 2100) return 'creator_year_invalid'.tr();
    return null;
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('creator_delete_confirm_title'.tr()),
        content: Text('creator_delete_confirm_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<CreatorManageBloc>().add(
              DeleteCreatorEvent(widget.existing!.id),
            );
      }
    });
  }
}
