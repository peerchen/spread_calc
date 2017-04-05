function[contract]=makeContract(type,month,year)
year2dig=mod(year,100);
yearstr=num2str(year2dig);
monthstr=num2str(month);
if year2dig<10
    yearstr=strcat('0',yearstr);
end
if month<10
   monthstr=strcat('0',monthstr); 
end
contract=strcat(type,yearstr,monthstr,'.CFE');
    