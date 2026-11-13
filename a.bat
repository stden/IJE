cd %1
svn propdel svn:keywords *.*
for /d %%i in (*.*) do call e:\ije\ije_50_d\a.bat %%i
cd ..