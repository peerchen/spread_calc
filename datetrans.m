function[newdate]=datetrans(date)
dates=strsplit(date{1},'/');
newdate=num2str(str2double(dates{1})*10000+str2double(dates{2})*100+str2double(dates{3}));