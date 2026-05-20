import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/upload_work_params.dart';
import '../bloc/upload_bloc.dart';

class UploadScreen extends StatelessWidget {
  final String creatorId;
  final String creatorName;

  const UploadScreen({
    super.key,
    required this.creatorId,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UploadBloc>(),
      child: _UploadView(creatorId: creatorId, creatorName: creatorName),
    );
  }
}

class _UploadView extends StatefulWidget {
  final String creatorId;
  final String creatorName;
  const _UploadView({required this.creatorId, required this.creatorName});

  @override
  State<_UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<_UploadView> {
  final _formKey        = GlobalKey<FormState>();
  final _titleCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _contentCtrl    = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final hasContent =
        _selectedFile != null || _contentCtrl.text.trim().isNotEmpty;
    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('upload_need_file_or_text'.tr())),
      );
      return;
    }

    context.read<UploadBloc>().add(
          SubmitWorkEvent(
            UploadWorkParams(
              creatorId:   widget.creatorId,
              title:       _titleCtrl.text.trim(),
              description: _descCtrl.text.trim().isEmpty
                  ? null
                  : _descCtrl.text.trim(),
              contentText: _contentCtrl.text.trim().isEmpty
                  ? null
                  : _contentCtrl.text.trim(),
              filePath:  _selectedFile?.path,
              fileName:  _selectedFile?.name,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('upload_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
        if (state is UploadErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: Text('works_upload'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        body: BlocBuilder<UploadBloc, UploadState>(
          builder: (context, state) {
            final isUploading = state is UploadInProgressState;
            final progress = isUploading ? state.progress : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_empty_outlined,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'upload_pending_info'.tr(),
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Creator tag
                    _SectionLabel('upload_for'.tr()),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.primary.withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.creatorName,
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    _SectionLabel('${'auth_name'.tr()} *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      enabled: !isUploading,
                      decoration: InputDecoration(
                          hintText: 'upload_title_hint'.tr()),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'upload_title_required'.tr()
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _SectionLabel('upload_description'.tr()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      enabled: !isUploading,
                      maxLines: 3,
                      decoration:
                          InputDecoration(hintText: 'upload_desc_hint'.tr()),
                    ),
                    const SizedBox(height: 20),

                    // File picker
                    _SectionLabel('upload_file'.tr()),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: isUploading ? null : _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _selectedFile != null
                                  ? AppTheme.primary
                                  : AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedFile != null
                                  ? Icons.check_circle_outline
                                  : Icons.attach_file,
                              color: _selectedFile != null
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedFile?.name ??
                                    'upload_pick_file'.tr(),
                                style: TextStyle(
                                  color: _selectedFile != null
                                      ? AppTheme.textDark
                                      : AppTheme.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedFile != null)
                              IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 18, color: AppTheme.textMuted),
                                onPressed: isUploading
                                    ? null
                                    : () =>
                                        setState(() => _selectedFile = null),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'upload_or'.tr(),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Content text
                    _SectionLabel('works_content'.tr()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _contentCtrl,
                      enabled: !isUploading,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'upload_text_hint'.tr(),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Progress indicator
                    if (isUploading) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                          minHeight: 8,
                          backgroundColor: AppTheme.cardBorder,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUploading ? null : () => _submit(context),
                        child: isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('works_upload'.tr()),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppTheme.textDark,
      ),
    );
  }
}
