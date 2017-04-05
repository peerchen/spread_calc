function[datelst]=getDateList(startdate,enddate)
%'参数必须为yyyymmdd类型
%提取 startdate--endate 间所有交割日,以及交割日前一日（换月日）
%包含startdate, 包含enddate
w=windmatlab;
if datenum(startdate,'yyyymmdd')>datenum(enddate,'yyyymmdd')
    display('ERROR:startdate greater than enddate!!!');
end

delivlst=getDelivList(startdate,enddate); %提取到期日，若没有则为空{}
lendeliv=length(delivlst);

if lendeliv==0
    datelst={startdate,enddate};
else
    if datenum(startdate,'yyyymmdd')==datenum(enddate,'yyyymmdd') %起始为同一日
        datelst={startdate,enddate};
    else %起始不为同一日
        datelst=cell(1,2*lendeliv);
        for dumi=1:lendeliv %提取交割日及交割日前一日
            datelst{2*dumi-1}=datestr(w.tdaysoffset(-1,delivlst{dumi}),'yyyymmdd');
            datelst{2*dumi}=delivlst{dumi};
        end
        if datenum(startdate,'yyyymmdd')>datenum(datelst{1},'yyyymmdd') %startdate 为交割日
            datelst={startdate};        
        elseif datenum(startdate,'yyyymmdd')<datenum(datelst{1},'yyyymmdd') %补上开始日
            datelst=[startdate datelst];
        end
        if datenum(enddate,'yyyymmdd')>datenum(datelst{end},'yyyymmdd') %补上结束日
            datelst{end+1}=enddate;
        end
    end
end


