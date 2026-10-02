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
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  Object? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
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
    final theme = Theme.of(context);
    final appName = ref.watch(brandProvider).appName;
    final error = switch (_error) {
      null => null,
      UnauthorizedException() => l10n.errorInvalidCredentials,
      final e => l10n.errorMessage(e),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(ds.spacing.s6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.loginTitle(appName),
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (!Env.hasBackend) ...[
                        SizedBox(height: ds.spacing.s1),
                        Text(
                          l10n.loginDemoHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ds.colors.text2,
                          ),
                        ),
                      ],
                      SizedBox(height: ds.spacing.s6),
                      TextFormField(
                        key: const Key('login.email'),
                        controller: _email,
                        enabled: !_submitting,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(labelText: l10n.loginEmail),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.loginEmailRequired
                            : null,
                      ),
                      SizedBox(height: ds.spacing.s4),
                      TextFormField(
                        key: const Key('login.password'),
                        controller: _password,
                        enabled: !_submitting,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.loginPasswordRequired
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (error != null) ...[
                        SizedBox(height: ds.spacing.s4),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            error,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
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
      ),
    );
  }
}
