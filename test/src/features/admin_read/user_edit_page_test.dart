import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooapp_dashboard/src/core/network/api_client.dart';
import 'package:tooapp_dashboard/src/core/session/admin_session.dart';
import 'package:tooapp_dashboard/src/features/admin_read/data/admin_read_repository.dart';
import 'package:tooapp_dashboard/src/features/admin_read/models/admin_read_models.dart';
import 'package:tooapp_dashboard/src/features/admin_read/presentation/user_edit_page.dart';

class _Users extends AdminReadRepository {
  _Users()
    : super(ApiClient(baseUrl: 'https://api.invalid', session: AdminSession()));

  Map<String, Object?>? updated;

  @override
  Future<Map<String, Object?>> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    required String? email,
    required String phone,
    required String? avatarUrl,
  }) async {
    updated = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
    return updated!;
  }
}

void main() {
  testWidgets('edits only the approved user profile fields', (tester) async {
    final repository = _Users();
    final user = AdminUser(
      id: 'user-1',
      firstName: 'Ana',
      lastName: 'Pérez',
      email: 'ana@example.com',
      isAccountActive: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      locality: null,
      phone: '5551234',
      avatarUrl: null,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AdminUserEditPage(repository: repository, user: user),
                ),
              ),
              child: const Text('Editar'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ana María');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repository.updated, containsPair('firstName', 'Ana María'));
    expect(repository.updated, containsPair('phone', '5551234'));
    expect(
      repository.updated!.keys,
      containsAll([
        'firstName',
        'lastName',
        'email',
        'phone',
        'avatarUrl',
        'id',
      ]),
    );
    expect(repository.updated!.keys, isNot(contains('dni')));
  });
}
