uses ijeconsts,xmlije;
var a:tSettings;
begin
LoadSettings('xmltest.xml',a);
SaveSettings('xmltest.2.xml',a);
end.