cd %1
svn propset svn:keywords Id *.dpr
svn propset svn:keywords Id *.php
svn propset svn:keywords Id *.pas
for /d %%i in (*.*) do call C:\07_loi\IJE_50_d\_setprop.cmd %%i
cd ..