function[timenow]=getTimeNow()
Now=now;
Date=num2str(year(Now)*10000+month(Now)*100+day(Now));
Hour=num2str(hour(Now));
Minute=num2str(minute(Now));
Second=num2str(floor(second(Now)));
if length(Hour)==1
    Hour=strcat('0',Hour);
end
if length(Minute)==1
    Hour=strcat('0',Minute);
end
if length(Second)==1
    Hour=strcat('0',Second);
end
timenow=strcat(Date,32,Hour,':',Minute,':',Second);
