<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: lang_russian.php 202 2008-04-19 11:24:40Z *KAP* $ */

$lang["name"]="RUS";

$lang["NoContestsRunning"]="Контестов нет";
$lang["StatusUnknown"]="Состояние неизвестно";
$lang["TimeOfTime"]="%d из %d";
$lang["NotLoggedIn"]="Вы не вошли";
$lang["LogIn"]="Войти";
$lang["ChangeContest"]="Сменить контест";
$lang["ChangeContestSuccessfull"]="Смена контеста удачна";
$lang["LoggedAsSbToSth"]="Вы вошли как %s в %s";
$lang["LogOut"]="Log out";
$lang["ThisIs..."]='This is IJEml:http version %s (IJE %s) running on %s<br/>';
$lang["PageGeneratedAtTime"]="Page generated at %s";
$lang["LoginError"]="Ошибка входа в систему";
$lang["Error"]="Ошибка";
$lang["UnknownTeamName"]="Неизвестное название команды";
$lang["UnknownContest"]="Неизвестный контест";
$lang["TryToDo"]="Попробуйте %s";
$lang["relogin"]='заново войти в систему';
$lang['WrongLoginPassword']='Неверный пароль для входа в систему';
$lang["SthRequiredToAccess..."]="Чтобы просмотреть эту страницу, необходимо %s";
$lang["LoginForReq"]="войти в систему";
$lang["Login"]="Имя";
$lang["Home"]="Инфо";
$lang["ContestName"]="Название контеста";
$lang["ContestFormat"]="Формат контеста";
$lang["MonitorMessagesTime"]="Время монитора и сообщений";
$lang["ContestLength"]="Длительность контеста";
$lang["ContestStatus"]="Состояние контеста";
$lang["NumberOfProblems"]="Количество задач";
$lang["NumberOfTeams"]="Количество команд";
$lang["NumberOfAllowedLanguages"]="Количество разрешенных языков программирования";
$lang["StrangeMonitorTime..."]="Странное время монитора; возможно, IJE не запущена";
$lang["monitorStatus"]="состояние контеста из монитора";
$lang["Contest"]="Контест";
$lang["LoginSuccessfull"]="Вход в систему успешно выполнен";
$lang['LoginRejected']="Вход в систему отклонен";
$lang["Password"]="Пароль";
$lang["LogOut"]="Выйти";
$lang["LogoutSuccessfull"]="Выход из системы успешно завершен";

$lang['MessageDetails']='Подробности сообщения';
$lang['Messages']='Сообщения';
$lang["ClickOnMessageTime..."]="Щелкните на времени сообщения, чтобы просмотреть его подробности";
$lang["SortBy"]="Сортировать по";
$lang["time"]="времени";
$lang["problem"]="задаче";
$lang["Time"]="Время";
$lang["Problem"]="Задача";
$lang["NoSubmissions"]="Нет попыток";

$lang["Standings"]="Результаты";
$lang["CurrentStandings"]='Текущие результаты';
$lang["HideSuccessTimes"]="Спрятать время успешных сдач";
$lang["ShowSuccessTimes"]="Показать время успешных сдач";
$lang["Id"]="Id";
$lang["Party"]="Команда/участник";

$lang["SelectTheProblemFirst"]="Выберите задачу";
$lang["SelectTheLanguageFirst"]="Выберите язык";
$lang["Submit"]="Сдать решение";
$lang["ErrorUploadedFile..."]="An error occured while moving uploaded file";
$lang["SubmitFailed"]="Не удалось послать решение на проверку";
$lang["NoResponseFromIJE"]='IJE не отвечает';
$lang["SubmitSuccessfull"]="Решение успешно сдано";
$lang["YourSolutionHasBeen..."]="Ваше решение было успешно послано на проверку. Удачи!";
$lang["YouCanSee..."]="Вы сможете просмотреть результаты тестирования на странице \"%s\"";

$lang['AnErrorOccured']='Ошибка';
$lang["SelectTheProblem"]="Выберите задачу";
$lang["Language"]="Язык программирования";
$lang["SelectTheLanguage"]="Выберите язык";
$lang["ProgramText"]="Текст программы";
$lang["OR"]="ИЛИ";
$lang['FileWithSolution']='Файл с решением';


$ltext=array(
'OK'=>'Зачтено',
'WA'=>'Неверный ответ',
'PE'=>'Нарушен формат выходных данных',
'TL'=>'Превышен предел времени исполнения',
'ML'=>'Превышен предел памяти',
'OL'=>'Превышен предел размера выходного файла',
'IL'=>'Превышен предел времени простоя',
'RE'=>'Ненулевой код возврата',
'CR'=>'Недопустимая операция', 
'SV'=>'Нарушение правил',
'NC'=>'Верно, но не зачтено',
'CE'=>'Ошибка компиляции',
'NS'=>"Задача не сдавалась",
'CP'=>"Скомпилировано",
'FL'=>'Ошибка тестирующей системы',
'NT'=>'Не тестировано');
for ($i=1;$i<=10;$i++){
    $ltext["PC$i"]="Частично верно ($i)";
}

?>