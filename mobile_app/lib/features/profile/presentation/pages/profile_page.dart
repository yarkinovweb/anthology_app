import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const FetchProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool  _obscurePass    = true;
  bool  _obscureConfirm = true;
  bool  _nameInitialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(UserEntity currentUser) {
    if (!_formKey.currentState!.validate()) return;

    final newName     = _nameCtrl.text.trim();
    final newPassword = _passwordCtrl.text;

    final nameChanged     = newName.isNotEmpty && newName != currentUser.name;
    final passwordChanged = newPassword.isNotEmpty;

    if (!nameChanged && !passwordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_nothing_changed'.tr()),
          backgroundColor: AppTheme.textMuted,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    context.read<ProfileBloc>().add(UpdateProfileEvent(
          name:     nameChanged ? newName : null,
          password: passwordChanged ? newPassword : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState && !_nameInitialized) {
          _nameCtrl.text   = state.user.name;
          _nameInitialized = true;
        }
        if (state is ProfileUpdateSuccessState) {
          _passwordCtrl.clear();
          _confirmCtrl.clear();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('profile_update_success'.tr(),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ));
        }
        if (state is ProfileErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(state.message.tr(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4),
            ));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: Text(
            'nav_profile'.tr(),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            // Language picker
            PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: Colors.white),
              onSelected: (lang) {
                context.setLocale(Locale(lang));
                sl<HiveStorage>().saveLanguage(lang);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'uz', child: Text("O'zbek")),
                PopupMenuItem(value: 'tr', child: Text('Türkçe')),
                PopupMenuItem(value: 'az', child: Text('Azərbaycan')),
                PopupMenuItem(value: 'kk', child: Text('Қазақша')),
                PopupMenuItem(value: 'ky', child: Text('Кыргызча')),
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'ru', child: Text('Русский')),
              ],
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileInitialState ||
                state is ProfileLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileErrorState &&
                state is! ProfileUpdatingState) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    Text(state.message.tr(),
                        style:
                            const TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ProfileBloc>()
                          .add(const FetchProfileEvent()),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            final user = state is ProfileLoadedState
                ? state.user
                : state is ProfileUpdatingState
                    ? state.user
                    : state is ProfileUpdateSuccessState
                        ? state.user
                        : null;

            if (user == null) return const SizedBox.shrink();

            final isUpdating = state is ProfileUpdatingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 28),
                  _buildForm(user, isUpdating),
                  const SizedBox(height: 16),
                  _buildLogoutButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final roleColor = _roleColor(user.role);

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: roleColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: roleColor.withAlpha(80)),
          ),
          child: Text(
            _roleLabel(user.role),
            style: TextStyle(
              fontSize: 12,
              color: roleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(UserEntity user, bool isUpdating) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'profile_edit_info'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'auth_name'.tr(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v != null && v.trim().isEmpty) {
                    return 'profile_name_empty'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 8),

              Text(
                'profile_change_password'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // New password field
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePass,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'profile_new_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) {
                    return 'auth_password_hint'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password field
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => isUpdating ? null : _submit(user),
                decoration: InputDecoration(
                  labelText: 'profile_confirm_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (_passwordCtrl.text.isNotEmpty &&
                      v != _passwordCtrl.text) {
                    return 'profile_passwords_mismatch'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: isUpdating ? null : () => _submit(user),
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('save'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout, color: AppTheme.error),
      label: Text(
        'auth_logout'.tr(),
        style: const TextStyle(color: AppTheme.error),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.error),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () =>
          context.read<AuthBloc>().add(const LogoutRequested()),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':      return AppTheme.primary;
      case 'specialist': return AppTheme.primaryLight;
      case 'researcher': return AppTheme.accentDark;
      default:           return AppTheme.textMuted;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':      return 'role_admin'.tr();
      case 'specialist': return 'role_specialist'.tr();
      case 'researcher': return 'role_researcher'.tr();
      case 'user':       return 'role_user'.tr();
      default:           return role;
    }
  }
}
