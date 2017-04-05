function[datelst]=getDateList(startdate,enddate)
%'��������Ϊyyyymmdd����
%��ȡ startdate--endate �����н�����,�Լ�������ǰһ�գ������գ�
%����startdate, ����enddate
w=windmatlab;
if datenum(startdate,'yyyymmdd')>datenum(enddate,'yyyymmdd')
    display('ERROR:startdate greater than enddate!!!');
end

delivlst=getDelivList(startdate,enddate); %��ȡ�����գ���û����Ϊ��{}
lendeliv=length(delivlst);

if lendeliv==0
    datelst={startdate,enddate};
else
    if datenum(startdate,'yyyymmdd')==datenum(enddate,'yyyymmdd') %��ʼΪͬһ��
        datelst={startdate,enddate};
    else %��ʼ��Ϊͬһ��
        datelst=cell(1,2*lendeliv);
        for dumi=1:lendeliv %��ȡ�����ռ�������ǰһ��
            datelst{2*dumi-1}=datestr(w.tdaysoffset(-1,delivlst{dumi}),'yyyymmdd');
            datelst{2*dumi}=delivlst{dumi};
        end
        if datenum(startdate,'yyyymmdd')>datenum(datelst{1},'yyyymmdd') %startdate Ϊ������
            datelst={startdate};        
        elseif datenum(startdate,'yyyymmdd')<datenum(datelst{1},'yyyymmdd') %���Ͽ�ʼ��
            datelst=[startdate datelst];
        end
        if datenum(enddate,'yyyymmdd')>datenum(datelst{end},'yyyymmdd') %���Ͻ�����
            datelst{end+1}=enddate;
        end
    end
end


