function[delivery]=makeDelivery(contract)
w=windmatlab;
tempdate=w.wss(contract,'lasttrade_date');
if strcmp(tempdate,'0:00:00')
    display(strcat('Contract ',contract,' does NOT exist yet!'));
    delivery='NaN';
else
    tempdate=tempdate{1};
    delivery=datestr(tempdate,'yyyymmdd');
end
