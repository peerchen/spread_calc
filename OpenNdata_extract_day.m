function[pointdata]=OpenNdata_extract_day(startdate,enddate,contract)
w=windmatlab;
[data,~,~,times,~,~]=w.wsd(contract,'open,high,low,close',startdate,enddate);
date=datestr(times,30);
date=str2num(date(:,1:8));
pointdata=[date data];