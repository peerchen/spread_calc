function[delivdate]=makeDelivery_premon(contract)
w=windmatlab;
year=2000+str2double(contract(3:4));
month=str2double(contract(5:6))-1;
if month==0
    year=year-1;
    month=12;
end
thirdfriday= datestr(nweekdate(3,6,year,month),30);
thirdfriday=thirdfriday(1:8);
if w.tdayscount(thirdfriday,thirdfriday)==0
    delivdate=datestr(w.tdaysoffset(1,thirdfriday),'yyyymmdd');
else
    delivdate=thirdfriday;
end