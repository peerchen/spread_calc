function[code_dict]=getdict(index)
undl_index=2;
firsttrd=3;
lasttrd=4;
codes=readtable(strcat('D:\Works\ÈÕ»ù²î¼ÆËã\index_futures_contract_codes_',index,'.csv'));
undl=table2array(codes(:,undl_index));
len=length(undl);
startdate=zeros(len,1);
enddate=zeros(len,1);
for dumi=1:len
    head=strsplit(cell2mat(table2array(codes(dumi,firsttrd))),'/');
    tail=strsplit(cell2mat(table2array(codes(dumi,lasttrd))),'/');
    startdate(dumi)=str2double(head{1})*10000+str2double(head{2})*100+str2double(head{3});
    enddate(dumi)=str2double(tail{1})*10000+str2double(tail{2})*100+str2double(tail{3});
end
code_dict=[codes(:,1:2) array2table([startdate enddate],'VariableNames',{'firsttrd','lasttrd'})];