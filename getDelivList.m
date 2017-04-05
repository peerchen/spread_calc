function[delivlst]=getDelivList(startdate,enddate)
%'参数必须为yyyymmdd类型
%提取 startdate--endate 间所有交割日
%如果startdate 是交割日则包含
%如果enddate 是交割日则包含
w=windmatlab;

[~,deliveries]=getContracts(startdate);

delivlst={};
count=1;

while datenum(deliveries{1},'yyyymmdd')<datenum(enddate,'yyyymmdd')
    delivlst{count}=deliveries{1};
    tempdt=datestr(w.tdaysoffset(1,deliveries{1}),'yyyymmdd');
    [~,deliveries]=getContracts(tempdt);
    count=count+1;
end
if datenum(enddate,'yyyymmdd')==datenum(deliveries{1},'yyyymmdd')
    delivlst{count}=deliveries{1};
end
