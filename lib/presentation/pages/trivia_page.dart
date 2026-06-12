import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/domain/entities/trivia_question.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage>
    with SingleTickerProviderStateMixin {
  late List<TriviaQuestion> _questions;
  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _showResult = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _questions = List.from(triviaQuestions)..shuffle(Random());
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _answer(int index) {
    if (_selected != null) return;
    setState(() {
      _selected = index;
      if (index == _questions[_current].correctIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_current >= _questions.length - 1) {
      _showResult = true;
      setState(() {});
      return;
    }
    _animCtrl.reset();
    setState(() {
      _current++;
      _selected = null;
    });
    _animCtrl.forward();
  }

  void _restart() {
    setState(() {
      _questions.shuffle(Random());
      _current = 0;
      _selected = null;
      _score = 0;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult();

    final q = _questions[_current];
    final isCorrect = _selected == q.correctIndex;
    final total = _questions.length;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_current + 1) / total,
              color: AppColors.secondary,
              backgroundColor: Colors.grey[800],
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${context.tr("Question", "Pregunta")} ${_current + 1}/$total',
                    style: const TextStyle(color: AppColors.textMuted)),
                Text('${context.tr("Score:", "Puntaje:")} $_score',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 24),
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                q.question,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                    height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            Expanded(
              child: ListView.separated(
                itemCount: q.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  Color bg;
                  Color txt = Colors.white;
                  IconData? icon;

                  if (_selected != null) {
                    if (i == q.correctIndex) {
                      bg = Colors.green.withOpacity(0.3);
                      icon = Icons.check_circle_rounded;
                      txt = Colors.green;
                    } else if (i == _selected) {
                      bg = Colors.red.withOpacity(0.3);
                      icon = Icons.cancel_rounded;
                      txt = Colors.red;
                    } else {
                      bg = Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]!
                          : Colors.grey[100]!;
                      txt = AppColors.textMuted;
                    }
                  } else {
                    bg = Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]!
                        : Colors.grey[100]!;
                  }

                  return Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _answer(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(q.options[i],
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: txt)),
                            ),
                            if (icon != null)
                              Icon(icon, color: txt, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Fact + Next button
            if (_selected != null) ...[
              if (q.fact != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.emoji_events_rounded
                            : Icons.lightbulb_outline_rounded,
                        color: isCorrect ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(q.fact!,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _current >= total - 1 ? context.tr("See Results", "Ver Resultados") : context.tr("Next Question", "Siguiente Pregunta"),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_score / _questions.length * 100).round();
    String grade;
    if (pct >= 90) {
      grade = context.tr("World Cup Winner!", "¡Ganador de la Copa!");
    } else if (pct >= 70) {
      grade = context.tr("Semifinalist!", "¡Semifinalista!");
    } else if (pct >= 50) {
      grade = context.tr("Group Stage", "Fase de Grupos");
    } else {
      grade = context.tr("Need more practice", "Necesitas más práctica");
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text('$pct%',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 20),
          Text('$_score / ${_questions.length} ${context.tr("correct", "correctas")}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(grade,
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr("Play Again", "Jugar de Nuevo")),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
