import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/domain/entities/head_to_head.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';

class HeadToHeadPage extends StatefulWidget {
  const HeadToHeadPage({super.key});

  @override
  State<HeadToHeadPage> createState() => _HeadToHeadPageState();
}

class _HeadToHeadPageState extends State<HeadToHeadPage> {
  String? _team1;
  String? _team2;

  final _teams = [
    'Argentina', 'Brazil', 'England', 'France', 'Germany',
    'Italy', 'Mexico', 'Netherlands', 'Portugal', 'Spain', 'USA',
  ];

  HeadToHead? _result;

  void _compare() {
    if (_team1 == null || _team2 == null) return;
    final key1 = '$_team1-$_team2';
    final key2 = '$_team2-$_team1';
    final data = headToHeadData[key1] ?? headToHeadData[key2];
    setState(() {
      if (data != null) {
        if (data.team1 == _team2) {
          _result = HeadToHead(
            team1: _team2!,
            team2: _team1!,
            team1Wins: data.team2Wins,
            team2Wins: data.team1Wins,
            draws: data.draws,
            team1Goals: data.team2Goals,
            team2Goals: data.team1Goals,
            lastMeeting: data.lastMeeting,
            lastScore: data.lastScore,
          );
        } else {
          _result = data;
        }
      } else {
        _result = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('No head-to-head data available', 'No hay datos cara a cara disponibles'))),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.sports_kabaddi_rounded,
                    size: 40, color: AppColors.secondary),
                const SizedBox(height: 8),
                Text(context.tr('Head to Head', 'Cara a Cara'),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text(context.tr('Compare two teams', 'Compara dos equipos'),
                    style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _teamDropdown(context.tr('Team A', 'Equipo A'), _team1, (v) {
                  setState(() => _team1 = v);
                }),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(context.tr('VS', 'VS'),
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900,
                        color: AppColors.secondary)),
              ),
              Expanded(
                child: _teamDropdown(context.tr('Team B', 'Equipo B'), _team2, (v) {
                  setState(() => _team2 = v);
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_team1 != null && _team2 != null && _team1 != _team2)
                  ? _compare
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.tr('Compare', 'Comparar'),
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _buildResult(isDark),
          ],
        ],
      ),
    );
  }

  Widget _teamDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _teams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResult(bool isDark) {
    final h = _result!;
    final total = h.team1Wins + h.team2Wins + h.draws;
    final t1Pct = total > 0 ? (h.team1Wins / total * 100) : 0.0;
    final t2Pct = total > 0 ? (h.team2Wins / total * 100) : 0.0;
    final drawPct = total > 0 ? (h.draws / total * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('$total ${context.tr("meetings", "encuentros")}',
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            // Win bars
            _statBar(h.team1, h.team1Wins, t1Pct, AppColors.secondary),
            const SizedBox(height: 12),
            _statBar(context.tr('Draws', 'Empates'), h.draws, drawPct, Colors.grey),
            const SizedBox(height: 12),
            _statBar(h.team2, h.team2Wins, t2Pct, AppColors.primary),
            const SizedBox(height: 20),
            const Divider(),
            // Goals
            _infoRow(context.tr('Goals', 'Goles'), '${h.team1Goals} - ${h.team2Goals}'),
            const SizedBox(height: 6),
            _infoRow(context.tr('Last meeting', 'Último encuentro'), h.lastMeeting),
            _infoRow(context.tr('Score', 'Marcador'), h.lastScore),
          ],
        ),
      ),
    );
  }

  Widget _statBar(String label, int wins, num pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${context.tr("$label", "$label")}: $wins ${context.tr("wins", "victorias")}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (pct / 100).toDouble(),
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
