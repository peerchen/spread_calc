function[error]=check_error(olddata,newdata,isxx)
% error is a binary number based on error1,error2,.., thus can be used to
% distinguish the error type if needed
% check error in newdata and olddata is assumed to be correct
[oldrow,oldcol]=size(olddata);
[newrow,newcol]=size(newdata);
knum=240;
% should have same column number
if oldcol==newcol
    error1=0;
else
    error1=1;
end

% should have the correct row number: is times of 240
if mod(newrow,knum)==0
    error2=0;
else
    error2=1;
end

% should have no repetitious rows
if isxx
    lenrow=length(unique([olddata;newdata],'rows'));
    if lenrow==oldrow+newrow
        error3=0;
    else
        error3=1;
    end
else
    firstdelta=olddata(1,(end-2));
    newdelta=newdata(1,(end-2));
    if (oldrow+newrow)/knum==(firstdelta-newdelta+1)
        error3=0;
    else
        error3=1;
    end
end
error=error1+error2*2+error3*2^2;
