function[numcell]=roundall(dataarray,digit)
% len=length(dataarray);
% numcell={len,1};
% for dumi=1:len
%     numcell{dumi}=round(dataarray(dumi),digit);    
% end
temp=round(dataarray,digit,'significant');
numcell=num2cell(temp);
