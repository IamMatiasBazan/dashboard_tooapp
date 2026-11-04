import 'package:flutter/material.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../data/report_repository.dart';
import '../models/admin_report.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({required this.repository, super.key});
  final ReportRepository repository;

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  List<AdminReport>? _reports;
  bool? _resolved;
  AdminReportType? _type;
  bool _loading = true;
  final Set<String> _resolving = {};
  ApiFailure? _failure;
  String? _unexpectedError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
      _unexpectedError = null;
    });
    try {
      final reports = await widget.repository.list(
        isResolved: _resolved,
        type: _type,
      );
      if (mounted) setState(() => _reports = reports);
    } on ApiFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } on Object {
      if (mounted) {
        setState(
          () => _unexpectedError = 'No se pudieron cargar los reportes.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolve(AdminReport report) async {
    final confirmed = await confirmAdminAction(
      context,
      title: 'Marcar reporte como resuelto',
      message:
          'El reporte de tipo ${report.type.apiValue} quedará resuelto. La API no ofrece una acción para deshacer este cambio.',
    );
    if (!confirmed || !mounted || _resolving.contains(report.id)) return;
    setState(() => _resolving.add(report.id));
    try {
      final updated = await widget.repository.resolve(report.id);
      if (!updated.isResolved) {
        throw const ApiFailure(
          ApiFailureKind.invalidResponse,
          'El servidor no confirmó que el reporte quedó resuelto.',
        );
      }
      if (!mounted) return;
      setState(() {
        _reports = [
          for (final item in _reports ?? <AdminReport>[])
            if (item.id == updated.id) updated else item,
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte marcado como resuelto por el servidor.'),
        ),
      );
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _failure = failure);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.statusCode == 404
                ? 'El reporte ya no está disponible.'
                : failure.message,
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se confirmó la resolución. Vuelve a cargar el listado.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _resolving.remove(report.id));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reportes', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            DropdownButton<bool?>(
              value: _resolved,
              hint: const Text('Todos los estados'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos los estados')),
                DropdownMenuItem(value: false, child: Text('Pendientes')),
                DropdownMenuItem(value: true, child: Text('Resueltos')),
              ],
              onChanged: (value) {
                setState(() => _resolved = value);
                _load();
              },
            ),
            DropdownButton<AdminReportType?>(
              value: _type,
              hint: const Text('Todos los tipos'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                for (final type in AdminReportType.values)
                  DropdownMenuItem(value: type, child: Text(type.apiValue)),
              ],
              onChanged: (value) {
                setState(() => _type = value);
                _load();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _stateView()),
      ],
    ),
  );

  Widget _stateView() {
    if (_loading) {
      return const AsyncStateView(
        state: AsyncViewState.loading,
        child: SizedBox.shrink(),
      );
    }
    if (_failure?.kind == ApiFailureKind.forbidden) {
      return const AsyncStateView(
        state: AsyncViewState.forbidden,
        child: SizedBox.shrink(),
      );
    }
    if (_failure?.kind == ApiFailureKind.unauthorized) {
      return AsyncStateView(
        state: AsyncViewState.error,
        message: 'La sesión no está autorizada. Inicia sesión de nuevo.',
        onRetry: _load,
        child: const SizedBox.shrink(),
      );
    }
    if (_failure != null) {
      return AsyncStateView(
        state: AsyncViewState.error,
        message: _failure!.message,
        onRetry: _load,
        child: const SizedBox.shrink(),
      );
    }
    if (_unexpectedError != null) {
      return AsyncStateView(
        state: AsyncViewState.error,
        message: _unexpectedError,
        onRetry: _load,
        child: const SizedBox.shrink(),
      );
    }
    if (_reports == null || _reports!.isEmpty) {
      return const AsyncStateView(
        state: AsyncViewState.empty,
        child: SizedBox.shrink(),
      );
    }
    return _ReportTable(
      reports: _reports!,
      resolving: _resolving,
      onResolve: _resolve,
    );
  }
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({
    required this.reports,
    required this.resolving,
    required this.onResolve,
  });
  final List<AdminReport> reports;
  final Set<String> resolving;
  final ValueChanged<AdminReport> onResolve;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Contenido')),
          DataColumn(label: Text('Autor')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Creado')),
          DataColumn(label: Text('Actualizado')),
          DataColumn(label: Text('Acción')),
        ],
        rows: [
          for (final report in reports)
            DataRow(
              cells: [
                DataCell(Text(report.id)),
                DataCell(Text(report.type.apiValue)),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      report.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    report.author == null
                        ? 'Autor no disponible'
                        : '${report.author!.firstName} ${report.author!.lastName}',
                  ),
                ),
                DataCell(Text(report.isResolved ? 'Resuelto' : 'Pendiente')),
                DataCell(Text(report.createdAt.toLocal().toString())),
                DataCell(Text(report.updatedAt.toLocal().toString())),
                DataCell(
                  report.isResolved
                      ? const Text('—')
                      : FilledButton.tonal(
                          onPressed: resolving.contains(report.id)
                              ? null
                              : () => onResolve(report),
                          child: resolving.contains(report.id)
                              ? const CircularProgressIndicator()
                              : const Text('Resolver'),
                        ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
