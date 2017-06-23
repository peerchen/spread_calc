function[ret]=make_copy(file,todir)
try
    [status,msg]=system(['copy ',file,' ',todir]);
catch
    display(['System command failed with ',file,' ',todir]);
end

if status~=0
    display(['Copy failed with ',file,' ',todir]);
    display(['Error : ',msg]);
    ret=0;
else
    display(['Copy successfully with ',file,' ',todir]);
    ret=1;
end