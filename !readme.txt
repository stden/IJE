1. Порядок событий при тестировании:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TestingInfo
CompileStarted
CompilerOutput
TestResult
(
 TestingStarted
 (
  TestingStatus *
  TestResult
 )* // сколько есть тестов
 (
  EvalStarted
  TestResult *
 )? // не выполняется, если нет evaluator'а
)? //не выполняется, если CE
TestingFinished

2. Вся память мериется в байтах и хранится в integer; //не скоро ml достигнет гигов, наверное
   время --- в сек. и в double