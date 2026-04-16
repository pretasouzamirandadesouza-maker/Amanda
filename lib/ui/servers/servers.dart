// Copyright 2022-2023 Marlon "Eiss" Lorram. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artplay_launcher/bloc/server/server_bloc.dart';
import 'package:artplay_launcher/state/server_state_event.dart';
import 'package:artplay_launcher/ui/colors.dart';
import 'package:artplay_launcher/ui/widgets/server_tile.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Servers extends StatefulWidget {
  const Servers({super.key});

  @override
  State<Servers> createState() => _ServersState();
}

class _ServersState extends State<Servers> {
  final Logger log = Logger('Servers');
  static const MethodChannel platform = MethodChannel('launcher');
  late ServerBloc _serverBloc;

  @override
  void initState() {
    super.initState();
    log.fine('initState() - fetch servers');
    _serverBloc = Provider.of<ServerBloc>(context, listen: false);
    _serverBloc.loadServers(LoadServersEvent());
  }

  void _handleRefresh() {
    log.fine('_handleRefresh');
    _serverBloc.loadServers(RefreshServersEvent());
  }

  Future<void> _connectServer(String address, String? hostname) async {
    try {
      final parts = address.split(':');
      final ip = parts[0];
      final port = int.parse(parts[1]);

      await platform.invokeMethod('connectServer', {
        'ip': ip,
        'port': port,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectando em ${hostname ?? address} ($address)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.background,
                onRefresh: () async {
                  _handleRefresh();
                },
                child: StreamBuilder<ServerState>(
                  initialData: ServerInitial(),
                  stream: _serverBloc.stateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;

                    if (state is ServerInitial) {
                      return const SizedBox.shrink();
                    } else if (state is ServerLoadInProgress) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is ServerLoadFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _handleRefresh,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is ServerLoadSuccess) {
                      final data = state;

                      return ListView.builder(
                        itemCount: data.serverInfos!.length,
                        itemBuilder: (context, index) {
                          final server = data.serverInfos![index];

                          return ServerTile(
                            hostname: server.hostname,
                            address: server.address,
                            gamemode: server.gamemode,
                            players: '${server.players}/${server.maxPlayers}',
                            onTap: () async {
                              await _connectServer(
                                server.address ?? '',
                                server.hostname,
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      extendBody: true,
    );
  }
}
