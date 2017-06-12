function[KPCTHK]=general_calculation(name,contract,isnear,strat,digit)

global K1;
global K2;
global c;
global lag;
global weight;
global delta;
global deliveries;
global parameters;
% 数据
global dataIF_near1;
global dataIC_near1;
global dataIH_near1;
global dataIF_near2;
global dataIC_near2;
global dataIH_near2;
global dataIF_back2;
global dataIC_back2;
global dataIH_back2;
% data index
global idxIF_near1;
global idxIC_near1;
global idxIH_near1;
global idxIF_near2;
global idxIC_near2;
global idxIH_near2;
global idxIF_back2;
global idxIC_back2;
global idxIH_back2;
% 合约代码
global near1IF;
global near1IC;
global near1IH;
global near2IF;
global near2IC;
global near2IH;
global back1IF;
global back1IC;
global back1IH;

global near1_deliv;
global back_chgdt;

global nextctIF;
global nextctIC;
global nextctIH;

global tommorrow


if isnear
    idx = eval(['idx',contract,'_near1']);
    data = eval(['data',contract,'_near1']);
    deliv = near1_deliv;
    ct = ['near1',contract];
else
    idx = eval(['idx',contract,'_back2']);
    data = eval(['data',contract,'_back2']);
    deliv = back_chgdt;
    ct = ['back1',contract];
end

[opn,cls,mu,s1,s2,t,w] = calc_KPC(data(idx,:),parameters(name,K1),parameters(name,K2),lag,weight,parameters(name,c), isnear);
temp = roundall([opn,cls,mu,s1,s2,t],digit);
[opn,cls,mu,s1,s2,t] = temp{:};

if isnear  % 只有近月才计算次近月，远月合约不必
    if delta<= 12 % 计算次近月，采用与近月相同的参数
        idx = eval(['idx',contract,'_near2']);
        data = eval(['data',contract,'_near2']);
        [opnc,clsc,muc,s1c,s2c,tc,wc] = calc_KPC(data(idx,:),parameters(name,K1),parameters(name,K2),lag,weight,parameters(name,c), isnear);
    else
        [opnc,clsc,muc,s1c,s2c,tc,wc] = deal(0);
    end
    tempc = roundall([opnc,clsc,muc,s1c,s2c,tc],digit);
    [opnc,clsc,muc,s1c,s2c,tc] = tempc{:};
    nextct = eval(['nextct',contract]);
else
    [opnc,clsc,muc,s1c,s2c,tc]= deal(0);
    nextct = 0;
end

names = {'opn','cls','dt','ct','chgdt','mu','s1','s2','delta','p1','p2','p3','nxtct','nxtopn','nxtcls','nxtmu','trdtypes'};
KPCTHK = table(opn,cls,{tommorrow},{eval([ct,'(1:6)'])},{deliv},mu,s1,s2,t,parameters(name,K1),parameters(name,K2),w,nextct,opnc,clsc,muc,{strat},'VariableNames',names);









