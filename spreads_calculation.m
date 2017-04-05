  %% 提取对应参数
clear;
clc;

spreadplace='';
openNplace='open_N 数据\';

parameters=csvread('model_parameters.txt');

% parameter positions in the para matrix
% columns
K1=1;
K2=2;
c=3;
%rows
xhzs=1;
jyIF=2;
jyIC=3;
jyIH=4;
yyIF=5;
yyIC=6;
yyIH=7;
xhzs2=8;
zsIC3=9;
alIC3=10;
zsIC5=11;

lag=3;
weight=0.5;

w=windmatlab;

%% 提取当前日期 及 上一次更新日期
current=now();
if hour(current)*10000+minute(current)*100<151500
    currentdate=datestr(w.tdaysoffset(-1,datestr(today,'yyyymmdd')),'yyyymmdd');
else
    currentdate=datestr(today,'yyyymmdd');
end

load('lastupdt_calculation.mat');
last_updt=datestr(w.tdaysoffset(-1,last_updt),'yyyymmdd');
dayslen=w.tdayscount(last_updt,currentdate);

%% 合约生成及相应设置
logid=fopen('log.txt','a');
for currdt=1:(dayslen-1)
    currentdate=datestr(w.tdaysoffset(1,last_updt),'yyyymmdd');
    
    notholiday=w.tdayscount(currentdate,currentdate);
    if ~notholiday
        display(strcat('Today:',enddate,'is a holiday, no trade!'));
        %update the log
        fprintf(logid,'%s\n','Holiday today, need not calculation.');
        exit;
    end
    
    [contracts,deliveries]=getContracts(currentdate);
    
    fut_contracts_IF=contracts.IF;
    fut_contracts_IC=contracts.IC;
    fut_contracts_IH=contracts.IH;
    
    % 合约换月计算
    nearby1=fut_contracts_IF{1};
    nearby2=fut_contracts_IF{2};
    back1=fut_contracts_IF{3};
    back2=fut_contracts_IF{4};
    delta=w.tdayscount(currentdate,deliveries{1});
    ctnear1=1;
    ctnear2=2;
    ctback1=3;
    ctback2=4;
    
    if delta<=2
        nearby1=nearby2;
        ctnear1=ctnear2;
        delta=w.tdayscount(currentdate,deliveries{2}); % update delta with new contract
        if ismember(str2double(nearby2(5:6)),[2,5,8,11])
            ctnear2=ctback1;
            nearby2=back1;
            back1=back2;
        end
    end
    
    if ismember(str2double(nearby1(5:6)),[2,5,8,11])
        back2=back1;
        ctback2=ctback1;
    end
    
    datafiles_IF={
        strcat(spreadplace,'tempdata\k_if',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back2(3:6),'.csv'),...
        };
    
    datafiles_IC={
        strcat(spreadplace,'tempdata\k_ic',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back2(3:6),'.csv'),...
        };
    
    datafiles_IH={
        strcat(spreadplace,'tempdata\k_ih',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back2(3:6),'.csv'),...
        };
    
    %% 提取数据
    dataIF_near1=csvread(datafiles_IF{1},1,0);
    dataIC_near1=csvread(datafiles_IC{1},1,0);
    dataIH_near1=csvread(datafiles_IH{1},1,0);
    
    dataIF_near2=csvread(datafiles_IF{2},1,0);
    dataIC_near2=csvread(datafiles_IC{2},1,0);
    dataIH_near2=csvread(datafiles_IH{2},1,0);
    
    dataIF_back2=csvread(datafiles_IF{4},1,0);
    dataIC_back2=csvread(datafiles_IC{4},1,0);
    dataIH_back2=csvread(datafiles_IH{4},1,0);
    
    %% 检查数据
    tmp1={'IF','IC','IH'};
    tmp2={'near1','near2','back2'};
    for dumi=1:length(tmp1)
       for dumj=1:length(tmp2)
           if datacheck(evalin('base',['data' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))]))
               error(['Data error in ' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))]);
           else
               display(['Data correct in ' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))])
           end
       end
    end     
    
    currentmk=str2double(currentdate);
    
    idxIF_near1=dataIF_near1(:,1)<=currentmk;
    idxIC_near1=dataIC_near1(:,1)<=currentmk;
    idxIH_near1=dataIH_near1(:,1)<=currentmk;
    
    idxIF_near2=dataIF_near2(:,1)<=currentmk;
    idxIC_near2=dataIC_near2(:,1)<=currentmk;
    idxIH_near2=dataIH_near2(:,1)<=currentmk;
    
    idxIF_back2=dataIF_back2(:,1)<=currentmk;
    idxIC_back2=dataIC_back2(:,1)<=currentmk;
    idxIH_back2=dataIH_back2(:,1)<=currentmk;
    
    %% 开平仓门限计算
    % 择时近月1档
    [xz_O,xz_C,xz_mu,xz_s1,xz_s2,xz_t,xz_w]       =calc_KPC(dataIC_near1(idxIC_near1,:),parameters(xhzs,K1),parameters(xhzs,K2),lag,weight,parameters(xhzs,c), 1); 
    [xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t,xz2_w]=calc_KPC(dataIC_near1(idxIC_near1,:),parameters(xhzs2,K1),parameters(xhzs2,K2),lag,weight,parameters(xhzs2,c), 1);
    % 对冲近月1档
    [jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t,jf_w]=calc_KPC(dataIF_near1(idxIF_near1,:),parameters(jyIF,K1),parameters(jyIF,K2),lag,weight,parameters(jyIF,c), 1);
    [jc_O,jc_C,jc_mu,jc_s1,jc_s2,jc_t,jc_w]=calc_KPC(dataIC_near1(idxIC_near1,:),parameters(jyIC,K1),parameters(jyIC,K2),lag,weight,parameters(jyIC,c), 1);
    [jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t,jh_w]=calc_KPC(dataIH_near1(idxIH_near1,:),parameters(jyIH,K1),parameters(jyIH,K2),lag,weight,parameters(jyIH,c), 1);
    % 对冲远月1档
    [yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t,yf_w]=calc_KPC(dataIF_back2(idxIF_back2,:),parameters(yyIF,K1),parameters(yyIF,K2),lag,weight,parameters(yyIF,c), 0);
    [yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t,yc_w]=calc_KPC(dataIC_back2(idxIC_back2,:),parameters(yyIC,K1),parameters(yyIC,K2),lag,weight,parameters(yyIC,c), 0);
    [yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t,yh_w]=calc_KPC(dataIH_back2(idxIH_back2,:),parameters(yyIH,K1),parameters(yyIH,K2),lag,weight,parameters(yyIH,c), 0);
    % 对冲近月1档，择时近月3和5档
    [al3_O,al3_C,al3_mu,al3_s1,al3_s2,al3_t,al3_w]=calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC3,K1),parameters(alIC3,K2),lag,weight,parameters(alIC3,c), 1);
    [zs3_O,zs3_C,zs3_mu,zs3_s1,zs3_s2,zs3_t,zs3_w]=calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC3,K1),parameters(zsIC3,K2),lag,weight,parameters(zsIC3,c), 1);
    [zs5_O,zs5_C,zs5_mu,zs5_s1,zs5_s2,zs5_t,zs5_w]=calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC5,K1),parameters(zsIC5,K2),lag,weight,parameters(zsIC5,c), 1);
    
    if delta<=12 % 计算次近月，采用与近月相同的参数
        [xc_O,xc_C,xc_mu,xc_s1,xc_s2,xc_t,xc_w]       =calc_KPC(dataIC_near2(idxIC_near2,:),parameters(xhzs, K1),parameters(xhzs, K2),lag,weight,parameters(xhzs, c), 1);
        [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t,xc2_w]=calc_KPC(dataIC_near2(idxIC_near2,:),parameters(xhzs2,K1),parameters(xhzs2,K2),lag,weight,parameters(xhzs2,c), 1);
        [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t,mf_w]       =calc_KPC(dataIF_near2(idxIF_near2,:),parameters(jyIF,K1),parameters(jyIF,K2),lag,weight,parameters(jyIF,c), 1);
        [mc_O,mc_C,mc_mu,mc_s1,mc_s2,mc_t,mc_w]       =calc_KPC(dataIC_near2(idxIC_near2,:),parameters(jyIC,K1),parameters(jyIC,K2),lag,weight,parameters(jyIC,c), 1);
        [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t,mh_w]       =calc_KPC(dataIH_near2(idxIH_near2,:),parameters(jyIH,K1),parameters(jyIH,K2),lag,weight,parameters(jyIH,c), 1);            
        [alc3_O,alc3_C,alc3_mu,alc3_s1,alc3_s2,alc3_t,alc3_w]=calc_KPC(dataIC_near1(idxIC_near2,:),parameters(alIC3,K1),parameters(alIC3,K2),lag,weight,parameters(alIC3,c), 1);
        [zsc3_O,zsc3_C,zsc3_mu,zsc3_s1,zsc3_s2,zsc3_t,zsc3_w]=calc_KPC(dataIC_near1(idxIC_near2,:),parameters(zsIC3,K1),parameters(zsIC3,K2),lag,weight,parameters(zsIC3,c), 1);
        [zsc5_O,zsc5_C,zsc5_mu,zsc5_s1,zsc5_s2,zsc5_t,zsc5_w]=calc_KPC(dataIC_near1(idxIC_near2,:),parameters(zsIC5,K1),parameters(zsIC5,K2),lag,weight,parameters(zsIC5,c), 1);
    else
        [xc_O,xc_C,xc_mu,xc_s1,xc_s2,xc_t,xc_w]=deal(0);
        [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t,xc2_w]=deal(0);
        [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t,mf_w]=deal(0);
        [mc_O,mc_C,mc_mu,mc_s1,mc_s2,mc_t,mc_w]=deal(0);
        [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t,mh_w]=deal(0);
        [alc3_O,alc3_C,alc3_mu,alc3_s1,alc3_s2,alc3_t,alc3_w]=deal(0);
        [zsc3_O,zsc3_C,zsc3_mu,zsc3_s1,zsc3_s2,zsc3_t,zsc3_w]=deal(0);
        [zsc5_O,zsc5_C,zsc5_mu,zsc5_s1,zsc5_s2,zsc5_t,zsc5_w]=deal(0);
    end
    
    %% 输出数值位数设置
    digit=6;
    
    temp1=roundall([xz_O,xz_C,xz_mu,xz_s1,xz_s2,xz_t],digit);
    temp2=roundall([xc_O,xc_C,xc_mu,xc_s1,xc_s2,xc_t],digit);    
    temp3=roundall([jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t],digit);
    temp4=roundall([jc_O,jc_C,jc_mu,jc_s1,jc_s2,jc_t],digit);
    temp5=roundall([jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t],digit);
    temp6=roundall([mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t],digit);
    temp7=roundall([mc_O,mc_C,mc_mu,mc_s1,mc_s2,mc_t],digit);
    temp8=roundall([mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t],digit);    
    temp9=roundall([yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t],digit);
    temp10=roundall([yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t],digit);
    temp11=roundall([yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t],digit);    
    temp12=roundall([xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t],digit);
    temp13=roundall([xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t],digit);   
    temp14=roundall([al3_O,al3_C,al3_mu,al3_s1,al3_s2,al3_t],digit);
    temp15=roundall([zs3_O,zs3_C,zs3_mu,zs3_s1,zs3_s2,zs3_t],digit);
    temp16=roundall([zs5_O,zs5_C,zs5_mu,zs5_s1,zs5_s2,zs5_t],digit);
    temp17=roundall([alc3_O,alc3_C,alc3_mu,alc3_s1,alc3_s2,alc3_t],digit);
    temp18=roundall([zsc3_O,zsc3_C,zsc3_mu,zsc3_s1,zsc3_s2,zsc3_t],digit);
    temp19=roundall([zsc5_O,zsc5_C,zsc5_mu,zsc5_s1,zsc5_s2,zsc5_t],digit);
    
    [xz_O,xz_C,xz_mu,xz_s1,xz_s2,xz_t]=temp1{:};
    [xc_O,xc_C,xc_mu,xc_s1,xc_s2,xc_t]=temp2{:};
    [jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t]=temp3{:};
    [jc_O,jc_C,jc_mu,jc_s1,jc_s2,jc_t]=temp4{:};
    [jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t]=temp5{:};
    [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t]=temp6{:};
    [mc_O,mc_C,mc_mu,mc_s1,mc_s2,mc_t]=temp7{:};
    [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t]=temp8{:};
    [yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t]=temp9{:};
    [yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t]=temp10{:};
    [yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t]=temp11{:};
    [xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t]=temp12{:};
    [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t]=temp13{:};
    [al3_O,al3_C,al3_mu,al3_s1,al3_s2,al3_t]=temp14{:};
    [zs3_O,zs3_C,zs3_mu,zs3_s1,zs3_s2,zs3_t]=temp15{:};
    [zs5_O,zs5_C,zs5_mu,zs5_s1,zs5_s2,zs5_t]=temp16{:};
    [alc3_O,alc3_C,alc3_mu,alc3_s1,alc3_s2,alc3_t]=temp17{:};
    [zsc3_O,zsc3_C,zsc3_mu,zsc3_s1,zsc3_s2,zsc3_t]=temp18{:};
    [zsc5_O,zsc5_C,zsc5_mu,zsc5_s1,zsc5_s2,zsc5_t]=temp19{:};
    
   
    %% 按需要格式组合并输出到显示器
    % 提取合约代码
    near1IF=cell2mat(fut_contracts_IF(ctnear1));
    near1IC=cell2mat(fut_contracts_IC(ctnear1));
    near1IH=cell2mat(fut_contracts_IH(ctnear1));
    near2IF=cell2mat(fut_contracts_IF(ctnear2));
    near2IC=cell2mat(fut_contracts_IC(ctnear2));
    near2IH=cell2mat(fut_contracts_IH(ctnear2));
    back1IF=cell2mat(fut_contracts_IF(ctback2));
    back1IC=cell2mat(fut_contracts_IC(ctback2));
    back1IH=cell2mat(fut_contracts_IH(ctback2));
    
    near1_deliv=datestr(w.tdaysoffset(-1,deliveries{ctnear1}),'yyyymmdd');
    back2_deliv=datestr(w.tdaysoffset(-1,deliveries{ctback2}),'yyyymmdd');
    back_chgdt=datestr(w.tdaysoffset(-1,makeDelivery_premon(back1)),'yyyymmdd');
    
    dig=6;
    names={'opn','cls','dt','ct','chgdt','mu','s1','s2','delta','p1','p2','p3','nxtct','nxtopn','nxtcls','nxtmu'};
    
    % 处理次月合约参数
    nextctxc=0;nextOxc=0;nextCxc=0;nextmuxc=0;   
    nextctxc2=0;nextOxc2=0;nextCxc2=0;nextmuxc2=0;     
    nextctIF=0;nextOIF=0;nextCIF=0;nextmuIF=0; 
    nextctIC=0;nextOIC=0;nextCIC=0;nextmuIC=0;   
    nextctIH=0;nextOIH=0;nextCIH=0;nextmuIH=0;
    
    nextctalc3=0;nextOalc3=0;nextCalc3=0;nextmualc3=0;
    nextctzsc3=0;nextOzsc3=0;nextCzsc3=0;nextmuzsc3=0;
    nextctzsc5=0;nextOzsc5=0;nextCzsc5=0;nextmuzsc5=0;
    
    if delta<=12;
        nextctxc={near2IC(1:6)};nextOxc=xc_O;nextCxc=xc_C;nextmuxc=xc_mu;       
        nextctxc2={near2IC(1:6)};nextOxc2=xc2_O;nextCxc2=xc2_C;nextmuxc2=xc2_mu;    
        nextctIF={near2IF(1:6)};nextOIF=mf_O;nextCIF=mf_C;nextmuIF=mf_mu;   
        nextctIC={near2IC(1:6)};nextOIC=mc_O;nextCIC=mc_C;nextmuIC=mc_mu;       
        nextctIH={near2IH(1:6)};nextOIH=mh_O;nextCIH=mh_C;nextmuIH=mh_mu;
        nextctalc3={near2IC(1:6)};nextOalc3=alc3_O;nextCalc3=alc3_C;nextmualc3=alc3_mu;
        nextctzsc3={near2IC(1:6)};nextOzsc3=zsc3_O;nextCzsc3=zsc3_C;nextmuzsc3=zsc3_mu;
        nextctzsc5={near2IC(1:6)};nextOzsc5=zsc5_O;nextCzsc5=zsc5_C;nextmuzsc5=zsc5_mu;
    end
    
    tommorrow=datestr(w.tdaysoffset(1,currentdate),'yyyymmdd');
    
    display('现货开平仓');
    KPCTHKxh=table(xz_O,xz_C,{tommorrow},{near1IC(1:6)},{near1_deliv},xz_mu,xz_s1,xz_s2,xz_t,parameters(xhzs,K1),parameters(xhzs,K2),xz_w,nextctxc,nextOxc,nextCxc,nextmuxc,'VariableNames',names);
    
    display('现货开平仓2');
    KPCTHKxh2=table(xz2_O,xz2_C,{tommorrow},{near1IC(1:6)},{near1_deliv},xz2_mu,xz2_s1,xz2_s2,xz2_t,parameters(xhzs2,K1),parameters(xhzs2,K2),xz2_w,nextctxc2,nextOxc2,nextCxc2,nextmuxc2,'VariableNames',names);
    
    display('近月开平仓');
    KPCTHKjyif=table(jf_O,jf_C,{tommorrow},{near1IF(1:6)},{near1_deliv},jf_mu,jf_s1,jf_s2,jf_t,parameters(jyIF,K1),parameters(jyIF,K2),jf_w,nextctIF,nextOIF,nextCIF,nextmuIF,'VariableNames',names);
    KPCTHKjyic=table(jc_O,jc_C,{tommorrow},{near1IC(1:6)},{near1_deliv},jc_mu,jc_s1,jc_s2,jc_t,parameters(jyIC,K1),parameters(jyIC,K2),jc_w,nextctIC,nextOIC,nextCIC,nextmuIC,'VariableNames',names);
    KPCTHKjyih=table(jh_O,jh_C,{tommorrow},{near1IH(1:6)},{near1_deliv},jh_mu,jh_s1,jh_s2,jh_t,parameters(jyIH,K1),parameters(jyIH,K2),jf_w,nextctIH,nextOIH,nextCIH,nextmuIH,'VariableNames',names);
    
    display('远月开平仓');
    KPCTHKyyif=table(yf_O,yf_C,{tommorrow},{back1IF(1:6)},{back_chgdt},yf_mu,yf_s1,yf_s2,yf_t,parameters(yyIF,K1),parameters(yyIF,K2),yf_w,0,0,0,0,'VariableNames',names);
    KPCTHKyyic=table(yc_O,yc_C,{tommorrow},{back1IC(1:6)},{back_chgdt},yc_mu,yc_s1,yc_s2,yc_t,parameters(yyIC,K1),parameters(yyIC,K2),yc_w,0,0,0,0,'VariableNames',names);
    KPCTHKyyih=table(yh_O,yh_C,{tommorrow},{back1IH(1:6)},{back_chgdt},yh_mu,yh_s1,yh_s2,yh_t,parameters(yyIH,K1),parameters(yyIH,K2),yh_w,0,0,0,0,'VariableNames',names);
    
    display('multilevel');
    KPCTHKal3=table(al3_O,al3_C,{tommorrow},{near1IC(1:6)},{near1_deliv},al3_mu,al3_s1,al3_s2,al3_t,parameters(alIC3,K1),parameters(alIC3,K2),al3_w,nextctalc3,nextOalc3,nextCalc3,nextmualc3,'VariableNames',names);
    KPCTHKzs3=table(zs3_O,zs3_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zs3_mu,zs3_s1,zs3_s2,zs3_t,parameters(zsIC3,K1),parameters(zsIC3,K2),zs3_w,nextctzsc3,nextOzsc3,nextCzsc3,nextmuzsc3,'VariableNames',names);
    KPCTHKzs5=table(zs5_O,zs5_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zs5_mu,zs5_s1,zs5_s2,zs5_t,parameters(zsIC5,K1),parameters(zsIC5,K2),zs5_w,nextctzsc5,nextOzsc5,nextCzsc5,nextmuzsc5,'VariableNames',names);
    
    KPCTHK=[KPCTHKxh;KPCTHKxh2;KPCTHKjyif;KPCTHKjyic;KPCTHKjyih;KPCTHKyyif;KPCTHKyyic;KPCTHKyyih;KPCTHKal3;KPCTHKzs3;KPCTHKzs5];
    
    if (dayslen>=3 && currdt>1) || (dayslen==2 && currdt==1) % 避免输出已经计算过的结果
        display(KPCTHK);
    end
    
    %% 写入到txt
    
    writetable(KPCTHKxh,'现货择时开平仓门限\IC_XHZS.txt','WriteVariableNames',0);
    writetable(KPCTHKxh2,'现货择时开平仓门限2\IC_XHZS.txt','WriteVariableNames',0);
    writetable(KPCTHKjyif,'期货近月开平仓门限\IF_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKjyic,'期货近月开平仓门限\IC_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKjyih,'期货近月开平仓门限\IH_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyif,'期货远月开平仓门限\IF_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyic,'期货远月开平仓门限\IC_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyih,'期货远月开平仓门限\IH_KPCTHK.txt','WriteVariableNames',0);
    
    writetable(KPCTHKxh ,'产品推送开平仓门限\BQ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs3,'产品推送开平仓门限\BQ2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs3,'产品推送开平仓门限\JQ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs3,'产品推送开平仓门限\HJ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs3,'产品推送开平仓门限\GD2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs5,'产品推送开平仓门限\HJ1ICLongTest_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzs3,'产品推送开平仓门限\XD9ICLong_KPCMX.txt','WriteVariableNames',0);
    
    writetable(KPCTHKjyic,'产品推送开平仓门限\BQ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKal3 ,'产品推送开平仓门限\BQ2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKal3 ,'产品推送开平仓门限\JQ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKal3 ,'产品推送开平仓门限\HJ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKal3 ,'产品推送开平仓门限\GD2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKal3 ,'产品推送开平仓门限\HJ1ICHedgeTest_KPCMX.txt','WriteVariableNames',0);
    %%
    writetable(KPCTHK,['KPCTHK_history\KPCTHK_' tommorrow '_WJP.csv'],'WriteVariableNames',1);
    
    last_updt=currentdate;
end
%%
display('All calculations finished!');
save('lastupdt_calculation','last_updt');
fclose(logid);

%% make copies of data 
!xcopy "tempdata" "tempdata_copies\" /Y/S
!xcopy "open_N 数据\concatenated_data" "open_N 数据\concatenated_data_copy" /Y/S

!xcopy "tempdata" "\\JIAPENG-PC\tempdata\" /Y/S
!xcopy "open_N 数据\concatenated_data" "\\JIAPENG-PC\concatenated_data2\" /Y/S
!xcopy "momentum data" "\\JIAPENG-PC\momentum_data\" /Y/S
display('Data copies made!');

%% update the trading system
push_KPCMX()
display('Trading system & monitor parameters updated !');
%%
Sending_emails(tommorrow);

