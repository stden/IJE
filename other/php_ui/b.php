<?php
dl ("php_ffi.dll");
$windows = new ffi ("[lib='user32.dll'] int MessageBoxA( int handle, char *text, char *caption, int type );" );
echo $windows->MessageBoxA(0, "Message For You", "Hello World", 1);
?>
