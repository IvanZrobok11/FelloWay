import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/connectivity_failure.dart';
import '../../../shared/errors/result.dart';
import '../../onboarding/domain/interest_catalog_item.dart';
import '../domain/user_profile.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _city = TextEditingController();
  final _hobbies = TextEditingController();
  final _linkedin = TextEditingController();
  final _facebook = TextEditingController();

  UserProfile? _original;
  String? _avatarUrl;
  bool _loading = true;
  bool _saving = false;
  List<InterestCatalogItem> _catalog = const [];
  Set<String> _selectedInterestIds = {};
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    _hobbies.dispose();
    _linkedin.dispose();
    _facebook.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final users = AppScope.usersOf(context);
    final interestsRepo = AppScope.interestsOf(context);
    final catalogRes = await interestsRepo.fetchCatalog();
    final profileRes = await users.getMe();
    if (!mounted) return;
    switch (catalogRes) {
      case Success(:final value):
        _catalog = value;
        _catalogError = null;
      case Failure(:final error):
        _catalogError = error.message;
    }
    switch (profileRes) {
      case Success(:final value):
        _applyProfile(value);
        setState(() => _loading = false);
      case Failure():
        setState(() => _loading = false);
    }
  }

  void _applyProfile(UserProfile p) {
    _original = p;
    _avatarUrl = p.avatarUrl;
    _name.text = p.displayName;
    _bio.text = p.bio ?? '';
    _city.text = p.homeCityLabel;
    _hobbies.text = p.hobbies;
    _selectedInterestIds = p.interests.toSet();
    _linkedin.text = p.linkedinUrl ?? '';
    _facebook.text = p.facebookUrl ?? '';
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (x == null || !mounted) return;
    final users = AppScope.usersOf(context);
    setState(() => _saving = true);
    final up = await users.uploadAvatar(x.path);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (up) {
      case Success(:final value):
        if (value != null) {
          setState(() => _avatarUrl = value);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileEditAvatarDone)));
      case Failure(:final error):
        showActionFailureSnackBar(context, error);
    }
  }

  Future<void> _save() async {
    final orig = _original;
    final l10n = AppLocalizations.of(context)!;
    if (orig == null) return;
    final draft = UserProfile(
      id: orig.id,
      displayName: _name.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      avatarUrl: _avatarUrl,
      linkedinUrl: _linkedin.text.trim().isEmpty ? null : _linkedin.text.trim(),
      facebookUrl: _facebook.text.trim().isEmpty ? null : _facebook.text.trim(),
      interests: _selectedInterestIds.toList(),
      hobbies: _hobbies.text.trim(),
      homeCityLabel: _city.text.trim(),
      ratingAverage: orig.ratingAverage,
    );
    setState(() => _saving = true);
    final users = AppScope.usersOf(context);
    final res = await users.updateMe(draft);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (res) {
      case Success():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileEditSaved)));
        Navigator.of(context).pop();
      case Failure(:final error):
        showActionFailureSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_original == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileEditTitle)),
        body: Center(child: Text(l10n.commonErrorTitle)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEditTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null
                      ? Text(
                          _name.text.isNotEmpty
                              ? _name.text[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                TextButton.icon(
                  onPressed: _saving ? null : _pickAvatar,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.profileEditChangePhoto),
                ),
              ],
            ),
          ),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.onboardingNameLabel,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bio,
            decoration: InputDecoration(
              labelText: l10n.profileEditBioLabel,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            decoration: InputDecoration(
              labelText: l10n.onboardingCityLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileEditInterestsHint,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (_catalogError != null) ...[
            Text(
              _catalogError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _saving ? null : _load,
              child: Text(l10n.commonRetry),
            ),
          ] else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _catalog.map((item) {
                final selected = _selectedInterestIds.contains(item.id);
                return FilterChip(
                  label: Text(item.name),
                  selected: selected,
                  onSelected: _saving
                      ? null
                      : (v) {
                          setState(() {
                            if (v) {
                              _selectedInterestIds.add(item.id);
                            } else {
                              _selectedInterestIds.remove(item.id);
                            }
                          });
                        },
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _hobbies,
            decoration: InputDecoration(
              labelText: l10n.onboardingHobbiesLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _linkedin,
            decoration: InputDecoration(
              labelText: l10n.profileLinkedIn,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _facebook,
            decoration: InputDecoration(
              labelText: l10n.profileFacebook,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.profileEditSave),
          ),
        ],
      ),
    );
  }
}
