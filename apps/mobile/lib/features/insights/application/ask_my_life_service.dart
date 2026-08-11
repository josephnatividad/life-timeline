import 'package:life_timeline/features/insights/domain/life_query_models.dart';

final class AskMyLifeService {
  const AskMyLifeService(this._interpreter, this._executor);

  final LifeQueryExecutor _executor;
  final LifeQueryInterpreter _interpreter;

  Future<LifeQueryResult> ask(String question, {required DateTime now}) async {
    final interpretation = _interpreter.interpret(question, now: now);
    final intent = interpretation.intent;
    if (!interpretation.supported || intent == null) {
      return LifeQueryResult.unsupported();
    }
    return _executor.execute(intent, now: now);
  }
}
