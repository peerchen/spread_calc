function[data]=gmwsd(code,valstr,startdate,enddate)

if startdate>enddate
    error('startdate must <= enddate');
end

init = gm.Init('18201141877','Wqxl7309');
if init ~=0
    error('Loging failed')
end

todaydatenum = datenum(today);
thedate = datestr(todaydatenum,'yyyy-mm-dd');
if length(startdate)==8
    startdatenum = datenum(startdate,'yyyymmdd');
else
    startdatenum = datenum(startdate,'yyyy-mm-dd');
end
if length(enddate)==8
    enddatenum = datenum(enddate,'yyyymmdd');
else
    enddatenum = datenum(enddate,'yyyy-mm-dd');
end
if isempty(strfind(valstr,'strtime'))
    valstr = ['strtime,',valstr];
end
if enddatenum>=todaydatenum %����ȡ��������
    nowtime = clock;
    if nowtime(4)*100+nowtime(5)>1500  % ���̺����������ݣ�����tick���ݹ���     
        starttime = '15:00:00';
        endtime = '16:00:00';
        head = [thedate ' ' starttime];
        tail = [thedate ' ' endtime];
        tickvalstr = strrep(valstr,'close','last_price');
        tickvalstr = strrep(tickvalstr,'amount','cum_amount');
        tickvalstr = strrep(tickvalstr,'volume','cum_volume');
        todaydata = gm.GetTicks(code,head,tail);
        todaydata = cell2table(table2cell(todaydata(end,strsplit(tickvalstr,','))),'VariableNames',strsplit(valstr,','));
    else                    %����ǰ���������ݣ�������ǰһ�ս��
        todaydata = gm.GetLastNDailyBars(code,1,thedate);
        todaydata = todaydata(:,strsplit(valstr,','));
    end
    if startdatenum==enddatenum  % ����Ҫ����ȡ����������
        data = todaydata;
        return
    else
        enddatenum = enddatenum-1; 
    end
else
   todaydata = []; 
end
startdate = datestr(startdatenum,'yyyy-mm-dd');
enddate = datestr(enddatenum,'yyyy-mm-dd');
predata = gm.GetDailyBars(code,startdate,enddate);
predata = predata(:,strsplit(valstr,','));
data = [predata;todaydata];