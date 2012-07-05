<?php
// Define constants needed, taken from
// Visual Studio/Tools/Winapi/WIN32API.txt
define("MB_OK", 0);

// Load the extension in
dl("php_w32api.dll");

// Register the GetTickCount function from kernel32.dll
w32api_register_function("kernel32.dll", 
                        "GetTickCount",
                        "long");
                        
// Register the MessageBoxA function from User32.dll
w32api_register_function("User32.dll",
                        "MessageBoxA",
                        "long");

// Get uptime information
$ticks = GetTickCount();

// Convert it to a nicely displayable text
$secs  = floor($ticks / 1000);
$mins  = floor($secs / 60);
$hours = floor($mins / 60);

$str = sprintf("You have been using your computer for:" .
               "\r\n %d Milliseconds, or \r\n %d Seconds" .
               "or \r\n %d mins or\r\n %d hours %d mins.",
               $ticks,
               $secs,
               $mins,
               $hours,
               $mins - ($hours*60));

// Display a message box with only an OK button and the uptime text
MessageBoxA(NULL, 
           $str, 
           "Uptime Information", 
           MB_OK);
?>