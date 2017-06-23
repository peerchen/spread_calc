function[processeddata]=OpenNdata_extract_min(startdate,starttime,enddate,endtime,contract,isxx)
w=windmatlab;
startdatetime=strcat(startdate,32,starttime);
enddatetime=strcat(enddate,32,endtime);
[data,~,~,times,~,~]=w.wsi(contract,'open,high,low,close,volume,amt',startdatetime,enddatetime);

years=year(times);
months=month(times);
days=day(times);
date=years*10000+months*100+days;

hours=hour(times);
minutes=minute(times)+1;
minidx=(minutes==60);
minutes(minidx)=0;
hours(minidx)=hours(minidx)+1;
time=hours*10000+minutes*100;

bf2016=(date<=20151231);
if isxx
    idx=(time>93000) & (time<=150000);
    sn=repmat((1:240)',sum(idx)/240,1);
else
    idx=((time>91500) & (time<=151500) & bf2016) |((time>93000) & (time<=150000) & ~bf2016);
    sn=[repmat((1:270)',sum(idx&bf2016)/270,1); repmat((1:240)',sum(idx&~bf2016)/240,1) ];
end

flags=flagfill(data);
startmarks=[1;days(1:(end-1))~=days(2:end)];
filled_data=datafill(data,flags,startmarks);
processeddata=[date(idx) time(idx) filled_data(idx,:) sn flags(idx)];
