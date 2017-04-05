function[contracts,deliveries]=getContracts(date)
% contract may be incorrect if the date given is so early that no valid
% contract exist yet!
if nargin==0
    currentdate=datestr(today,'yyyymmdd');
else
    currentdate=date;
end
season_mons=[3,6,9,12];

current_mon=str2double(currentdate(5:6));
current_year=str2double(currentdate(1:4));
checkcontract=strcat('IF',currentdate(3:4),currentdate(5:6),'.CFE');
checkdate=makeDelivery(checkcontract);
delta=(str2double(currentdate)>str2double(checkdate));

if delta
    nearby_mon1=(current_mon==12)+(current_mon~=12)*(current_mon+1);
    nearby_year1=(current_mon==12)*(current_year+1)+(current_mon~=12)*current_year;
else
    nearby_mon1=current_mon;
    nearby_year1=current_year;
end
nearby_mon2=(nearby_mon1==12)+(nearby_mon1~=12)*(nearby_mon1+1);
nearby_year2=(nearby_mon1==12)*(nearby_year1+1)+(nearby_mon1~=12)*nearby_year1;

if nearby_mon2==12
    back_mon1=3;
    back_mon2=6;
    back_year1=nearby_year2+1;
    back_year2=back_year1;
else
    back_mon1=season_mons(find(season_mons>nearby_mon2,1));
    back_year1=nearby_year2;
    if back_mon1==12
        back_mon2=3;
        back_year2=back_year1+1;
    else
        back_mon2=season_mons(find(season_mons>back_mon1,1));
        back_year2=back_year1;
    end
end

contIF={{makeContract('IF',nearby_mon1,nearby_year1),...
        makeContract('IF',nearby_mon2,nearby_year2),...
        makeContract('IF',back_mon1,back_year1),...
        makeContract('IF',back_mon2,back_year2)}};
    
contIC={{makeContract('IC',nearby_mon1,nearby_year1),...
        makeContract('IC',nearby_mon2,nearby_year2),...
        makeContract('IC',back_mon1,back_year1),...
        makeContract('IC',back_mon2,back_year2)}};
    
contIH={{makeContract('IH',nearby_mon1,nearby_year1),...
        makeContract('IH',nearby_mon2,nearby_year2),...
        makeContract('IH',back_mon1,back_year1),...
        makeContract('IH',back_mon2,back_year2)}};
    
contracts=struct('IF',contIF,'IC',contIC,'IH',contIH);
conts=contIF{1};
deliveries={makeDelivery(conts{1}),...
            makeDelivery(conts{2}),...
            makeDelivery(conts{3}),...
            makeDelivery(conts{4})};
