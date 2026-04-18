import 'dart:convert';

import 'package:app/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogScreen extends StatelessWidget {
  static const routeName = '/logs';

  const LogScreen({Key? key}) : super(key: key);

  Future<void> _copyAll(BuildContext context) async {
    final list = LogService.instance.entries
        .map((e) => {
              'timestamp': e.timestamp.toIso8601String(),
              'screen': e.screen,
              'message': e.message,
              'stackTrace': e.stackTrace,
              'extras': e.extras,
            })
        .toList();
    final text = const JsonEncoder.withIndent('  ').convert(list);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LogService.instance,
      builder: (context, _) {
        final entries = LogService.instance.entries;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Logs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_all_outlined),
                tooltip: 'Copy all',
                onPressed: () => _copyAll(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear',
                onPressed: () => LogService.instance.clear(),
              ),
            ],
          ),
          body: entries.isEmpty
              ? const Center(child: Text('No logs yet'))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        title: Text(
                          e.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_formatTime(e.timestamp)} · ${e.screen}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: [
                          if (e.extras.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: SelectableText(
                                  const JsonEncoder.withIndent('  ')
                                      .convert(e.extras),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          if (e.stackTrace != null && e.stackTrace!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: SelectableText(
                                e.stackTrace!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}:'
        '${l.second.toString().padLeft(2, '0')}';
  }
}
