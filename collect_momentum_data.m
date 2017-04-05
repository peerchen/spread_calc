clc;
clear;
tic
w=windmatlab;

indices={'IF','IC','IH'};
starttime='09:00:00';
endtime='15:30:00';


for j=1:length(indices)
    index=indices{j};
    dict=getdict(index);
    len=height(dict);
    delivs=table2array(dict(:,4));
    idx=delivs<20160701 & delivs>20130701;
    daytb=[];
    mintb=[];
    for i=1:len
        if idx(i)
            contract=cell2mat(table2array(dict(i,1)));
            delivery=delivs(i);
            predeliv=makeDelivery_premon(contract);
            theday=datestr(w.tdaysoffset(-1,predeliv),'yyyymmdd');
            ddata=OpenNdata_extract_day(theday,theday,contract);
            mdata=OpenNdata_extract_min(theday,starttime,theday,endtime,contract,0);
            daytb=[daytb;ddata];
            delta=calc_delta(theday,delivery);
            mintb=[mintb;[mdata ones(length(mdata),1)*double(delta)]];
        end
    end
    pathday=strcat('\\JIAPENG-PC\momentum data\predeliv',index,'_day.csv');
    pathmin=strcat('\\JIAPENG-PC\momentum data\predeliv',index,'_min.csv');
    tbday=array2table(daytb,'VariableNames',{'date','open','high','low','close'});
    tbmin=array2table([mintb(:,1:8) mintb(:,end) mintb(:,10)],'VariableNames',{'date','time','open','high','low','close','vol','amt','delta','flag'});
    writetable(tbday,pathday);
    writetable(tbmin,pathmin);
end
toc

%%
clear;
clc;
tic;
w=windmatlab;
dict=getdict('IF'); 
delivs=table2array(dict(:,4));
idx=delivs<20130701 & delivs>20100601;
len=sum(idx);
dict=dict(idx,:);
mintb=[];

infile='D:\Works\open_N 数据\旧数据处理\股指数据（包含盘口1数据）\k_if01.csv';
alldata=csvread(infile,1,0);

for i=1:len
    
    contract=cell2mat(table2array(dict(i,1)));
    delivery=table2array(dict(i,4));
    predeliv=makeDelivery_premon(contract);
    theday=datestr(w.tdaysoffset(-1,predeliv),'yyyymmdd');
    delta=double(calc_delta(theday,delivery));
    
    takeidx=(alldata(:,1)==str2double(theday));
    takedata=alldata(takeidx,1:8);
    flags=flagfill(takedata(:,3:8));
    days=takedata(:,1);
    startmarks=[1;days(1:(end-1))~=days(2:end)];
    filled_data=datafill(takedata(:,3:8),flags,startmarks);
    tmidx=takedata(:,2)<=151500 & takedata(:,2)>=91600;    
    finaldata=[takedata(tmidx,1:2) filled_data(tmidx,:) ones(length(takedata(tmidx,:)),1)*delta flags(tmidx)];
    
    mintb=[mintb;finaldata];
end
toc;
 

%%
tbmin=array2table(mintb,'VariableNames',{'date','time','open','high','low','close','vol','amt','delta','flag'});
writetable(tbmin,'tbmin.csv');


%%
clear;
clc;
tic;
w=windmatlab;
dict=getdict('IF'); 
delivs=table2array(dict(:,4));
idx=delivs<20130701 & delivs>20100601;
len=sum(idx);
dict=dict(idx,:);
daytb=[];

for i=1:len
    
    contract=cell2mat(table2array(dict(i,1)));
    delivery=table2array(dict(i,4));
    predeliv=makeDelivery_premon(contract);
    theday=datestr(w.tdaysoffset(-1,predeliv),'yyyymmdd');
    
    ddata=OpenNdata_extract_day(theday,theday,contract);
    daytb=[daytb;ddata];
end
toc;
%%
writetable(array2table(daytb,'VariableNames',{'date','open','high','low','close'}),'tbmin.csv');


