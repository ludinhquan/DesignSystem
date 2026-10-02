import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/brand.dart';
import '../../../config/env.dart';
import '../../../core/http.dart';
import '../../../l10n/l10n.dart';
import '../data/session_controller.dart';

/// Email + password form. Navigation after login is the router's job: the
/// session changes and the redirect sends the user back to `from`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;
  Object? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Validates on submit, not on every keystroke.
  bool _validate() {
    final l10n = context.l10n;
    setState(() {
      _emailError = _email.text.trim().isEmpty ? l10n.loginEmailRequired : null;
      _passwordError = _password.text.isEmpty
          ? l10n.loginPasswordRequired
          : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_validate()) {
      DsHaptics.error(context);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ds = context.ds;
    final c = ds.colors;
    final appName = ref.watch(brandProvider).appName;
    final error = switch (_error) {
      null => null,
      UnauthorizedException() => l10n.errorInvalidCredentials,
      final e => l10n.errorMessage(e),
    };
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: gutter,
              vertical: ds.spacing.s6,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // No logo yet: the brand name in the display face.
                    Text(
                      appName,
                      style: ds.text.titleScreen.copyWith(color: c.text1),
                    ),
                    SizedBox(height: ds.spacing.s1),
                    Text(
                      l10n.loginTitle(appName),
                      style: ds.text.subhead.copyWith(color: c.text2),
                    ),
                    if (!Env.hasBackend) ...[
                      SizedBox(height: ds.spacing.s1),
                      Text(
                        l10n.loginDemoHint,
                        style: ds.text.footnote.copyWith(color: c.text2),
                      ),
                    ],
                    SizedBox(height: ds.spacing.s8),
                    DsTextField(
                      inputKey: const Key('login.email'),
                      label: l10n.loginEmail,
                      placeholder: l10n.loginEmailPlaceholder,
                      controller: _email,
                      enabled: !_submitting,
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    SizedBox(height: ds.spacing.s4),
                    DsTextField(
                      inputKey: const Key('login.password'),
                      label: l10n.loginPassword,
                      controller: _password,
                      enabled: !_submitting,
                      error: _passwordError,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                    ),
                    if (error != null) ...[
                      SizedBox(height: ds.spacing.s4),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          children: [
                            DsGlyph(
                              ds.icons.warning,
                              weight: DsGlyphWeight.fill,
                              size: 16,
                              color: c.negative,
                            ),
                            SizedBox(width: ds.spacing.s2),
                            Expanded(
                              child: Text(
                                error,
                                style: ds.text.footnote.copyWith(
                                  color: c.negative,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: ds.spacing.s6),
                    DsButton(
                      key: const Key('login.submit'),
                      label: l10n.loginSubmit,
                      loading: _submitting,
                      variant: DsButtonVariant.prominent,
                      size: DsButtonSize.lg,
                      block: true,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
