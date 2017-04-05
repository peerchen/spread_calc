function[delivlst]=getDelivList(startdate,enddate)
%'��������Ϊyyyymmdd����
%��ȡ startdate--endate �����н�����
%���startdate �ǽ����������
%���enddate �ǽ����������
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
