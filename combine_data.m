function[fulldata]=combine_data(pfuturesdata,delivery,underlying)
delta=calc_delta(pfuturesdata(:,1),delivery);
flags=pfuturesdata(:,end);
startmarks=[1;underlying(1:(end-1),1)~=underlying(2:end,1)];
underlying_filled=datafill(underlying(:,3:6),flags,startmarks);

futstart=find(underlying(:,1)==pfuturesdata(1,1),1);

fdata=[underlying(futstart:end,1:2) underlying_filled(futstart:end,:) pfuturesdata(:,3:6)...
    delta pfuturesdata(:,(end-1):end)];
names={'date','time','o_x','h_x','l_x','c_x','o_q','h_q','l_q','c_q','delta','sn','flag'};
fulldata=array2table(fdata,'VariableNames',names);
