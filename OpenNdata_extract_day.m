function[pointdata]=OpenNdata_extract_day(startdate,enddate,contract)
% 使用wind数据
% w=windmatlab;
% [data,~,~,times,~,~]=w.wsd(contract,'open,high,low,close',startdate,enddate);
% date=datestr(times,30);
% date=str2num(date(:,1:8));
% pointdata=[date data];
% 使用掘金数据
ct = strsplit(contract,'.');
if strcmp(ct{2},'CFE')
    contract = ['CFFEX' '.' ct{1}];
else
    contract = [ct{2} 'SE.' ct{1}];
end
data = gmwsd(contract,'open,high,low,close',startdate,enddate);
strdate = cell2mat(table2array(data(:,{'strtime'})));
date = str2num(datestr(datenum(strdate(:,1:10),'yyyy-mm-dd'),'yyyymmdd'));
pointdata = [date double(table2array(data(:,2:end)))];