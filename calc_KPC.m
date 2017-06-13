function[open,close,mu,sigma1,outsigma2,calc_delta,width]=calc_KPC(data,k1,k2,lag,weight,c,near)

time=2;
underlying=6;
futures=10;
delta=11;

ttm=data(:,delta);
calc_delta=ttm(end)-1;
dif=data(:,futures)./data(:,underlying)-1;
len=length(dif);

days=find([1;data(1:(end-1),time)>data(2:end,time)]);  % start of days
if length(days)>=lag    %calculate with at least lag number of days
    T=ttm/20;
    mu=mean(dif./T);
    sigma1=std(dif./T);
    res=(dif-mu*T);
    sigma2=sqrt(sum((res(days(end-(lag-1)):end)).^2)/(len-days(end-(lag-1))));
    
    open=(mu+sigma1*weight*k1)*(ttm(end)-1)/20+(1-weight)*k1*sigma2;
    tempclose=(mu+sigma1*weight*k2)*(ttm(end)-1)/20+(1-weight)*k2*sigma2;
    
    if near
        %width=(calc_delta<=20)*(calc_delta*0.002)+(calc_delta>20)*c;
        width=min(calc_delta*0.002,c);
    else
        width=c;
    end
    close=min(tempclose,open-width);
    outsigma2=sigma2/((ttm(end)-1)/20);
else
    open=0;
    close=0;
    mu=0;
    sigma1=0;
    outsigma2=0;
end

