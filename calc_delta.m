function[delta]=calc_delta(date,delivery)
w=windmatlab;
[len,n]=size(date);
deliverydate=num2str(delivery);
if len==1
    if ~ischar(date)
        date=int2str(date);
    end
    delt=w.tdayscount(date,deliverydate);
    delta=delt-1;
else
    days=find([1;date(1:(end-1))~=date(2:end)]);
    lendays=length(days);
    delta=zeros(len,1);
    for i=1:lendays
        delt=w.tdayscount(int2str(date(days(i))),deliverydate);
        if i==lendays
            End=len;
        else
            End=days(i+1)-1;
        end
        delta(days(i):End)=delt-1;
    end
end