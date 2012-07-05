<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: lang_english.php 202 2008-04-19 11:24:40Z *KAP* $ */

$lang["name"]="ENG";

$lang["NoContestsRunning"]="No contests running";
$lang["StatusUnknown"]="Status unknown";
$lang["TimeOfTime"]="%d of %d";
$lang["NotLoggedIn"]="Not logged in";
$lang["LogIn"]="Log in";
$lang["ChangeContest"]="Change contest";
$lang["ChangeContestSuccessfull"]="Change contest successfull";
$lang["LoggedAsSbToSth"]="Logged as %s to %s";
$lang["LogOut"]="Log out";
$lang["ThisIs..."]='This is IJEml:http version %s (IJE %s) running on %s<br/>';
$lang["PageGeneratedAtTime"]="Page generated at %s";
$lang["LoginError"]="Login error";
$lang["Error"]="Error";
$lang["UnknownTeamName"]="Unknown team name";
$lang["UnknownContest"]="Unknown contest";
$lang["TryToDo"]="Try to %s";
$lang["relogin"]='relogin';
$lang['WrongLoginPassword']='Wrong login password';
$lang["SthRequiredToAccess..."]="%s required to access this page";
$lang["LoginForReq"]="Login";
$lang["Login"]="Login";
$lang["Home"]="Home";
$lang["ContestName"]="Contest name";
$lang["ContestFormat"]="Contest format";
$lang["MonitorMessagesTime"]="Monitor&messages time";
$lang["ContestLength"]="Contest length";
$lang["ContestStatus"]="Contest status";
$lang["NumberOfProblems"]="Number of problems";
$lang["NumberOfTeams"]="Number of teams";
$lang["NumberOfAllowedLanguages"]="Number of allowed languages";
$lang["StrangeMonitorTime..."]="Strange monitor time: probably, IJE is not running";
$lang["monitorStatus"]="monitor status";
$lang["Contest"]="Contest";
$lang["LoginSuccessfull"]="Login successfull";
$lang['LoginRejected']="Login rejected";
$lang["Password"]="Password";
$lang["LogOut"]="Log out";
$lang["LogoutSuccessfull"]="Logout successfull";

$lang['MessageDetails']='Message details';
$lang['Messages']='Messages';
$lang["ClickOnMessageTime..."]="Click on message time to see detailed information about message";
$lang["SortBy"]="Sort by";
$lang["time"]="time";
$lang["problem"]="problem";
$lang["Time"]="Time";
$lang["Problem"]="Problem";
$lang["NoSubmissions"]="No submissions";

$lang["Standings"]="Standings";
$lang["CurrentStandings"]='Current standings';
$lang["HideSuccessTimes"]="Hide success times";
$lang["ShowSuccessTimes"]="Show success times";
$lang["Id"]="Id";
$lang["Party"]="Party";

$lang["SelectTheProblemFirst"]="Select the problem first";
$lang["SelectTheLanguageFirst"]="Select the language first";
$lang["Submit"]="Submit";
$lang["ErrorUploadedFile..."]="An error occured while moving uploaded file";
$lang["SubmitFailed"]="Submit failed";
$lang["NoResponseFromIJE"]='No response from IJE';
$lang["SubmitSuccessfull"]="Submit successfull";
$lang["YourSolutionHasBeen..."]="Your solution has been successfully submitted for evaluation. Good luck!";
$lang["YouCanSee..."]="You can see the results of your submission on the %s page";

$lang['AnErrorOccured']='An error occured';
$lang["SelectTheProblem"]="Select the problem";
$lang["Language"]="Language";
$lang["SelectTheLanguage"]="Select the language";
$lang["ProgramText"]="Program text";
$lang["OR"]="OR";
$lang['FileWithSolution']='File with solution';


$ltext=array(
'OK'=>'Accepted',
'WA'=>'Wrong answer',
'PE'=>'Presentation error',
'TL'=>'Time limit exceeded',
'ML'=>'Memory limit exceeded',
'OL'=>'Output limit exceeded',
'IL'=>'Idleness limit exceeded',
'RE'=>'Runtime error',
'CR'=>'Crash', 
'SV'=>'Security violation',
'NC'=>'Accepted, but not counted',
'CE'=>'Compilation error',
'NS'=>"Problem wasn't submitted",
'CP'=>"Compiled, but wasn't tested",
'FL'=>'Tester failed',
'NT'=>'Not tested');
for ($i=1;$i<=10;$i++){
    $ltext["PC$i"]="Partial correct ($i)";
}

?>