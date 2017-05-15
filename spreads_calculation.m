  %% 提取对应参数
clear;
clc;

spreadplace = '';
openNplace = 'open_N 数据\';

parameters = csvread('model_parameters.txt');

% parameter positions in the para matrix
% columns
K1 = 1;
K2 = 2;
c = 3;
%rows
zsIC1 = 1;
jyIF = 2;
alIC1 = 3;
jyIH = 4;
yyIF = 5;
yyIC = 6;
yyIH = 7;
xhzs2 = 8;
zsIC3 = 9;
alIC3 = 10;
zsIC5 = 11;
zsIC10 = 12;
alIC7 = 13;
alIC8 = 14;
alIC6 = 15;

lag = 3;
weight = 0.5;

w = windmatlab;

%% 提取当前日期 及 上一次更新日期
current = now();
if hour(current)*10000+minute(current)*100<151500
    currentdate = datestr(w.tdaysoffset(-1,datestr(today,'yyyymmdd')),'yyyymmdd');
else
    currentdate = datestr(today,'yyyymmdd');
end

load('lastupdt_calculation.mat');
last_updt = datestr(w.tdaysoffset(-1,last_updt),'yyyymmdd');
dayslen = w.tdayscount(last_updt,currentdate);  % 上次更新日期距今天数

%% 合约生成及相应设置
logid = fopen('log.txt','a');
for currdt = 1:(dayslen-1)
    currentdate = datestr(w.tdaysoffset(1,last_updt),'yyyymmdd');
    
    notholiday = w.tdayscount(currentdate,currentdate);
    if ~notholiday
        display(strcat('Today:',enddate,'is a holiday, no trade!'));
        %update the log
        fprintf(logid,'%s\n','Holiday today, need not calculation.');
        exit;
    end
    
    [contracts,deliveries] = getContracts(currentdate);
    
    fut_contracts_IF = contracts.IF;
    fut_contracts_IC = contracts.IC;
    fut_contracts_IH = contracts.IH;
    
    % 合约换月计算
    nearby1 = fut_contracts_IF{1};
    nearby2 = fut_contracts_IF{2};
    back1 = fut_contracts_IF{3};
    back2 = fut_contracts_IF{4};
    delta = w.tdayscount(currentdate,deliveries{1});
    ctnear1 = 1;
    ctnear2 = 2;
    ctback1 = 3;
    ctback2 = 4;
    
    if delta<= 2
        nearby1 = nearby2;
        ctnear1 = ctnear2;
        delta = w.tdayscount(currentdate,deliveries{2}); % update delta with new contract
        if ismember(str2double(nearby2(5:6)),[2,5,8,11])
            ctnear2 = ctback1;
            nearby2 = back1;
            back1 = back2;
        end
    end
    
    if ismember(str2double(nearby1(5:6)),[2,5,8,11])
        back2 = back1;
        ctback2 = ctback1;
    end
    
    datafiles_IF = {
        strcat(spreadplace,'tempdata\k_if',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back2(3:6),'.csv'),...
        };
    
    datafiles_IC = {
        strcat(spreadplace,'tempdata\k_ic',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back2(3:6),'.csv'),...
        };
    
    datafiles_IH = {
        strcat(spreadplace,'tempdata\k_ih',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back2(3:6),'.csv'),...
        };
    
    %% 提取数据
    dataIF_near1 = csvread(datafiles_IF{1},1,0);
    dataIC_near1 = csvread(datafiles_IC{1},1,0);
    dataIH_near1 = csvread(datafiles_IH{1},1,0);
    
    dataIF_near2 = csvread(datafiles_IF{2},1,0);
    dataIC_near2 = csvread(datafiles_IC{2},1,0);
    dataIH_near2 = csvread(datafiles_IH{2},1,0);
    
    dataIF_back2 = csvread(datafiles_IF{4},1,0);
    dataIC_back2 = csvread(datafiles_IC{4},1,0);
    dataIH_back2 = csvread(datafiles_IH{4},1,0);
    
    %% 检查数据
    tmp1 = {'IF','IC','IH'};
    tmp2 = {'near1','near2','back2'};
    for dumi = 1:length(tmp1)
       for dumj = 1:length(tmp2)
           if datacheck(evalin('base',['data' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))]))
               error(['Data error in ' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))]);
           else
               display(['Data correct in ' cell2mat(tmp1(dumi)) '_' cell2mat(tmp2(dumj))])
           end
       end
    end     
    
    currentmk = str2double(currentdate);
    
    idxIF_near1 = dataIF_near1(:,1)<= currentmk;
    idxIC_near1 = dataIC_near1(:,1)<= currentmk;
    idxIH_near1 = dataIH_near1(:,1)<= currentmk;
    
    idxIF_near2 = dataIF_near2(:,1)<= currentmk;
    idxIC_near2 = dataIC_near2(:,1)<= currentmk;
    idxIH_near2 = dataIH_near2(:,1)<= currentmk;
    
    idxIF_back2 = dataIF_back2(:,1)<= currentmk;
    idxIC_back2 = dataIC_back2(:,1)<= currentmk;
    idxIH_back2 = dataIH_back2(:,1)<= currentmk;
    
    %% 开平仓门限计算
    % 择时近月1档
    [xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t,xz2_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(xhzs2,K1),parameters(xhzs2,K2),lag,weight,parameters(xhzs2,c), 1);
    % 对冲近月1档 IF IH
    [jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t,jf_w] = calc_KPC(dataIF_near1(idxIF_near1,:),parameters(jyIF,K1),parameters(jyIF,K2),lag,weight,parameters(jyIF,c), 1);
    [jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t,jh_w] = calc_KPC(dataIH_near1(idxIH_near1,:),parameters(jyIH,K1),parameters(jyIH,K2),lag,weight,parameters(jyIH,c), 1);
    % 对冲远月1档
    [yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t,yf_w] = calc_KPC(dataIF_back2(idxIF_back2,:),parameters(yyIF,K1),parameters(yyIF,K2),lag,weight,parameters(yyIF,c), 0);
    [yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t,yc_w] = calc_KPC(dataIC_back2(idxIC_back2,:),parameters(yyIC,K1),parameters(yyIC,K2),lag,weight,parameters(yyIC,c), 0);
    [yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t,yh_w] = calc_KPC(dataIH_back2(idxIH_back2,:),parameters(yyIH,K1),parameters(yyIH,K2),lag,weight,parameters(yyIH,c), 0);
    % 择时近月 1\3\5\10 档
    [zsIC1_O,zsIC1_C,zsIC1_mu,zsIC1_s1,zsIC1_s2,zsIC1_t,zsIC1_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC1,K1),parameters(zsIC1,K2),lag,weight,parameters(zsIC1,c), 1); 
    [zsIC3_O,zsIC3_C,zsIC3_mu,zsIC3_s1,zsIC3_s2,zsIC3_t,zsIC3_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC3,K1),parameters(zsIC3,K2),lag,weight,parameters(zsIC3,c), 1);
    [zsIC5_O,zsIC5_C,zsIC5_mu,zsIC5_s1,zsIC5_s2,zsIC5_t,zsIC5_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC5,K1),parameters(zsIC5,K2),lag,weight,parameters(zsIC5,c), 1);
    [zsIC10_O,zsIC10_C,zsIC10_mu,zsIC10_s1,zsIC10_s2,zsIC10_t,zsIC10_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(zsIC10,K1),parameters(zsIC10,K2),lag,weight,parameters(zsIC10,c), 1);
    % 对冲近月 1\3\6\7\8 档
    [alIC1_O,alIC1_C,alIC1_mu,alIC1_s1,alIC1_s2,alIC1_t,alIC1_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC1,K1),parameters(alIC1,K2),lag,weight,parameters(alIC1,c), 1);
    [alIC3_O,alIC3_C,alIC3_mu,alIC3_s1,alIC3_s2,alIC3_t,alIC3_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC3,K1),parameters(alIC3,K2),lag,weight,parameters(alIC3,c), 1);
    [alIC6_O,alIC6_C,alIC6_mu,alIC6_s1,alIC6_s2,alIC6_t,alIC6_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC6,K1),parameters(alIC6,K2),lag,weight,parameters(alIC6,c), 1);
    [alIC7_O,alIC7_C,alIC7_mu,alIC7_s1,alIC7_s2,alIC7_t,alIC7_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC7,K1),parameters(alIC7,K2),lag,weight,parameters(alIC7,c), 1);
    [alIC8_O,alIC8_C,alIC8_mu,alIC8_s1,alIC8_s2,alIC8_t,alIC8_w] = calc_KPC(dataIC_near1(idxIC_near1,:),parameters(alIC8,K1),parameters(alIC8,K2),lag,weight,parameters(alIC8,c), 1);
    
    if delta<= 12 % 计算次近月，采用与近月相同的参数
        [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t,xc2_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(xhzs2,K1),parameters(xhzs2,K2),lag,weight,parameters(xhzs2,c), 1);
        [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t,mf_w]        = calc_KPC(dataIF_near2(idxIF_near2,:),parameters(jyIF,K1),parameters(jyIF,K2),lag,weight,parameters(jyIF,c), 1);
        [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t,mh_w]        = calc_KPC(dataIH_near2(idxIH_near2,:),parameters(jyIH,K1),parameters(jyIH,K2),lag,weight,parameters(jyIH,c), 1);            
        % 择时次月 IC 1\3\5\10档
        [zscIC1_O,zscIC1_C,zscIC1_mu,zscIC1_s1,zscIC1_s2,zscIC1_t,zscIC1_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(zsIC1,K1),parameters(zsIC1,K2),lag,weight,parameters(zsIC1,c), 1);
        [zscIC3_O,zscIC3_C,zscIC3_mu,zscIC3_s1,zscIC3_s2,zscIC3_t,zscIC3_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(zsIC3,K1),parameters(zsIC3,K2),lag,weight,parameters(zsIC3,c), 1);
        [zscIC5_O,zscIC5_C,zscIC5_mu,zscIC5_s1,zscIC5_s2,zscIC5_t,zscIC5_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(zsIC5,K1),parameters(zsIC5,K2),lag,weight,parameters(zsIC5,c), 1);
        [zscIC10_O,zscIC10_C,zscIC10_mu,zscIC10_s1,zscIC10_s2,zscIC10_t,zscIC10_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(zsIC10,K1),parameters(zsIC10,K2),lag,weight,parameters(zsIC10,c), 1);
        % 对冲次月 IC 1\3\6\7\8档
        [alcIC1_O,alcIC1_C,alcIC1_mu,alcIC1_s1,alcIC1_s2,alcIC1_t,alcIC1_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(alIC1,K1),parameters(alIC1,K2),lag,weight,parameters(alIC1,c), 1);
        [alcIC3_O,alcIC3_C,alcIC3_mu,alcIC3_s1,alcIC3_s2,alcIC3_t,alcIC3_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(alIC3,K1),parameters(alIC3,K2),lag,weight,parameters(alIC3,c), 1);
        [alcIC6_O,alcIC6_C,alcIC6_mu,alcIC6_s1,alcIC6_s2,alcIC6_t,alcIC6_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(alIC6,K1),parameters(alIC6,K2),lag,weight,parameters(alIC6,c), 1);
        [alcIC7_O,alcIC7_C,alcIC7_mu,alcIC7_s1,alcIC7_s2,alcIC7_t,alcIC7_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(alIC7,K1),parameters(alIC7,K2),lag,weight,parameters(alIC7,c), 1);
        [alcIC8_O,alcIC8_C,alcIC8_mu,alcIC8_s1,alcIC8_s2,alcIC8_t,alcIC8_w] = calc_KPC(dataIC_near2(idxIC_near2,:),parameters(alIC8,K1),parameters(alIC8,K2),lag,weight,parameters(alIC8,c), 1);
    else
        [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t,xc2_w] = deal(0);
        [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t,mf_w] = deal(0);
        [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t,mh_w] = deal(0);
        % 择时次月 IC 1\3\5\10档
        [zscIC1_O,zscIC1_C,zscIC1_mu,zscIC1_s1,zscIC1_s2,zscIC1_t,zscIC1_w] = deal(0);
        [zscIC3_O,zscIC3_C,zscIC3_mu,zscIC3_s1,zscIC3_s2,zscIC3_t,zscIC3_w] = deal(0);
        [zscIC5_O,zscIC5_C,zscIC5_mu,zscIC5_s1,zscIC5_s2,zscIC5_t,zscIC5_w] = deal(0);
        [zscIC10_O,zscIC10_C,zscIC10_mu,zscIC10_s1,zscIC10_s2,zscIC10_t,zscIC10_w] = deal(0);
        % 对冲次月 IC 1\3\6\7\8档
        [alcIC1_O,alcIC1_C,alcIC1_mu,alcIC1_s1,alcIC1_s2,alcIC1_t,alcIC1_w] = deal(0);
        [alcIC3_O,alcIC3_C,alcIC3_mu,alcIC3_s1,alcIC3_s2,alcIC3_t,alcIC3_w] = deal(0);
        [alcIC6_O,alcIC6_C,alcIC6_mu,alcIC6_s1,alcIC6_s2,alcIC6_t,alcIC6_w] = deal(0);
        [alcIC7_O,alcIC7_C,alcIC7_mu,alcIC7_s1,alcIC7_s2,alcIC7_t,alcIC7_w] = deal(0);
        [alcIC8_O,alcIC8_C,alcIC8_mu,alcIC8_s1,alcIC8_s2,alcIC8_t,alcIC8_w] = deal(0);
    end
    
    %% 输出数值位数设置 
    digit = 6;
    
    temp3 = roundall([jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t],digit);
    temp5 = roundall([jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t],digit);
    temp6 = roundall([mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t],digit);
    temp8 = roundall([mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t],digit);    
    temp9 = roundall([yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t],digit);
    temp10 = roundall([yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t],digit);
    temp11 = roundall([yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t],digit);    
    temp12 = roundall([xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t],digit);
    temp13 = roundall([xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t],digit); 
    % 对冲近月 IC 1\3\6\7\8档
    temp_alIC1 = roundall([alIC1_O,alIC1_C,alIC1_mu,alIC1_s1,alIC1_s2,alIC1_t],digit);
    temp_alIC3 = roundall([alIC3_O,alIC3_C,alIC3_mu,alIC3_s1,alIC3_s2,alIC3_t],digit);
    temp_alIC6 = roundall([alIC6_O,alIC6_C,alIC6_mu,alIC6_s1,alIC6_s2,alIC6_t],digit);
    temp_alIC7 = roundall([alIC7_O,alIC7_C,alIC7_mu,alIC7_s1,alIC7_s2,alIC7_t],digit);
    temp_alIC8 = roundall([alIC8_O,alIC8_C,alIC8_mu,alIC8_s1,alIC8_s2,alIC8_t],digit);
    % 择时近月 IC 3\5\10档
    temp_zsIC1 = roundall([zsIC1_O,zsIC1_C,zsIC1_mu,zsIC1_s1,zsIC1_s2,zsIC1_t],digit);
    temp_zsIC3 = roundall([zsIC3_O,zsIC3_C,zsIC3_mu,zsIC3_s1,zsIC3_s2,zsIC3_t],digit);
    temp_zsIC5 = roundall([zsIC5_O,zsIC5_C,zsIC5_mu,zsIC5_s1,zsIC5_s2,zsIC5_t],digit);
    temp_zsIC10 = roundall([zsIC10_O,zsIC10_C,zsIC10_mu,zsIC10_s1,zsIC10_s2,zsIC10_t],digit);
    % 对冲次月 IC 1\3\6\7\8档
    temp_alcIC1 = roundall([alcIC1_O,alcIC1_C,alcIC1_mu,alcIC1_s1,alcIC1_s2,alcIC1_t],digit);
    temp_alcIC3 = roundall([alcIC3_O,alcIC3_C,alcIC3_mu,alcIC3_s1,alcIC3_s2,alcIC3_t],digit);
    temp_alcIC6 = roundall([alcIC6_O,alcIC6_C,alcIC6_mu,alcIC6_s1,alcIC6_s2,alcIC6_t],digit);
    temp_alcIC7 = roundall([alcIC7_O,alcIC7_C,alcIC7_mu,alcIC7_s1,alcIC7_s2,alcIC7_t],digit);
    temp_alcIC8 = roundall([alcIC8_O,alcIC8_C,alcIC8_mu,alcIC8_s1,alcIC8_s2,alcIC8_t],digit);
    % 择时次月 IC 1\3\5\10档
    temp_zscIC1 = roundall([zscIC1_O,zscIC1_C,zscIC1_mu,zscIC1_s1,zscIC1_s2,zscIC1_t],digit);    
    temp_zscIC3 = roundall([zscIC3_O,zscIC3_C,zscIC3_mu,zscIC3_s1,zscIC3_s2,zscIC3_t],digit);
    temp_zscIC5 = roundall([zscIC5_O,zscIC5_C,zscIC5_mu,zscIC5_s1,zscIC5_s2,zscIC5_t],digit);
    temp_zscIC10 = roundall([zscIC10_O,zscIC10_C,zscIC10_mu,zscIC10_s1,zscIC10_s2,zscIC10_t],digit);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 华丽分割线 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [jf_O,jf_C,jf_mu,jf_s1,jf_s2,jf_t] = temp3{:};
    [jh_O,jh_C,jh_mu,jh_s1,jh_s2,jh_t] = temp5{:};
    [mf_O,mf_C,mf_mu,mf_s1,mf_s2,mf_t] = temp6{:};
    [mh_O,mh_C,mh_mu,mh_s1,mh_s2,mh_t] = temp8{:};
    [yf_O,yf_C,yf_mu,yf_s1,yf_s2,yf_t] = temp9{:};
    [yc_O,yc_C,yc_mu,yc_s1,yc_s2,yc_t] = temp10{:};
    [yh_O,yh_C,yh_mu,yh_s1,yh_s2,yh_t] = temp11{:};
    [xz2_O,xz2_C,xz2_mu,xz2_s1,xz2_s2,xz2_t] = temp12{:};
    [xc2_O,xc2_C,xc2_mu,xc2_s1,xc2_s2,xc2_t] = temp13{:};
    % 对冲近月 IC 1\3\6\7\8档
    [alIC1_O,alIC1_C,alIC1_mu,alIC1_s1,alIC1_s2,alIC1_t] = temp_alIC1{:};
    [alIC3_O,alIC3_C,alIC3_mu,alIC3_s1,alIC3_s2,alIC3_t] = temp_alIC3{:};
    [alIC6_O,alIC6_C,alIC6_mu,alIC6_s1,alIC6_s2,alIC6_t] = temp_alIC6{:};
    [alIC7_O,alIC7_C,alIC7_mu,alIC7_s1,alIC7_s2,alIC7_t] = temp_alIC7{:};
    [alIC8_O,alIC8_C,alIC8_mu,alIC8_s1,alIC8_s2,alIC8_t] = temp_alIC8{:};
    % 择时近月 IC 1\3\5\10档
    [zsIC1_O,zsIC1_C,zsIC1_mu,zsIC1_s1,zsIC1_s2,zsIC1_t] = temp_zsIC1{:};
    [zsIC3_O,zsIC3_C,zsIC3_mu,zsIC3_s1,zsIC3_s2,zsIC3_t] = temp_zsIC3{:};
    [zsIC5_O,zsIC5_C,zsIC5_mu,zsIC5_s1,zsIC5_s2,zsIC5_t] = temp_zsIC5{:};
    [zsIC10_O,zsIC10_C,zsIC10_mu,zsIC10_s1,zsIC10_s2,zsIC10_t] = temp_zsIC10{:};
    % 对冲次月 IC 1\3\6\7\8档
    [alcIC1_O,alcIC1_C,alcIC1_mu,alcIC1_s1,alcIC1_s2,alcIC1_t] = temp_alcIC1{:};
    [alcIC3_O,alcIC3_C,alcIC3_mu,alcIC3_s1,alcIC3_s2,alcIC3_t] = temp_alcIC3{:};
    [alcIC6_O,alcIC6_C,alcIC6_mu,alcIC6_s1,alcIC6_s2,alcIC6_t] = temp_alcIC6{:};
    [alcIC7_O,alcIC7_C,alcIC7_mu,alcIC7_s1,alcIC7_s2,alcIC7_t] = temp_alcIC7{:};
    [alcIC8_O,alcIC8_C,alcIC8_mu,alcIC8_s1,alcIC8_s2,alcIC8_t] = temp_alcIC8{:};
    % 择时次月 IC 1\3\5\10档
    [zscIC1_O,zscIC1_C,zscIC1_mu,zscIC1_s1,zscIC1_s2,zscIC1_t] = temp_zscIC1{:};
    [zscIC3_O,zscIC3_C,zscIC3_mu,zscIC3_s1,zscIC3_s2,zscIC3_t] = temp_zscIC3{:};
    [zscIC5_O,zscIC5_C,zscIC5_mu,zscIC5_s1,zscIC5_s2,zscIC5_t] = temp_zscIC5{:};
    [zscIC10_O,zscIC10_C,zscIC10_mu,zscIC10_s1,zscIC10_s2,zscIC10_t] = temp_zscIC10{:};

   
    %% 按需要格式组合并输出到显示器
    % 提取合约代码
    near1IF = cell2mat(fut_contracts_IF(ctnear1));
    near1IC = cell2mat(fut_contracts_IC(ctnear1));
    near1IH = cell2mat(fut_contracts_IH(ctnear1));
    near2IF = cell2mat(fut_contracts_IF(ctnear2));
    near2IC = cell2mat(fut_contracts_IC(ctnear2));
    near2IH = cell2mat(fut_contracts_IH(ctnear2));
    back1IF = cell2mat(fut_contracts_IF(ctback2));
    back1IC = cell2mat(fut_contracts_IC(ctback2));
    back1IH = cell2mat(fut_contracts_IH(ctback2));
    
    near1_deliv = datestr(w.tdaysoffset(-1,deliveries{ctnear1}),'yyyymmdd');
    back2_deliv = datestr(w.tdaysoffset(-1,deliveries{ctback2}),'yyyymmdd');
    back_chgdt = datestr(w.tdaysoffset(-1,makeDelivery_premon(back1)),'yyyymmdd');
    
    dig = 6;
    names = {'opn','cls','dt','ct','chgdt','mu','s1','s2','delta','p1','p2','p3','nxtct','nxtopn','nxtcls','nxtmu','trdtypes'};
        
    % 处理次月合约代码
    next_needed = delta<= 12; 
    nextctIF = ifelse(next_needed,{near2IF(1:6)},0);
    nextctIH = ifelse(next_needed,{near2IH(1:6)},0);
    ICnext = ifelse(next_needed,{near2IC(1:6)},0);
    nextctxc2 = ICnext;
    % 择时次月 IC 1\3\5\10档
    nextctzscIC1 = ICnext;
    nextctzscIC3 = ICnext;
    nextctzscIC5 = ICnext;
    nextctzscIC10 = ICnext;
    % 对冲次月 IC 1\3\6\7\8档
    nextctalcIC1 = ICnext;
    nextctalcIC3 = ICnext;
    nextctalcIC6 = ICnext;
    nextctalcIC7 = ICnext;
    nextctalcIC8 = ICnext;
    
    tommorrow = datestr(w.tdaysoffset(1,currentdate),'yyyymmdd');
    
    KPCTHKxh2 = table(xz2_O,xz2_C,{tommorrow},{near1IC(1:6)},{near1_deliv},xz2_mu,xz2_s1,xz2_s2,xz2_t,parameters(xhzs2,K1),parameters(xhzs2,K2),xz2_w,nextctxc2,xc2_O,xc2_C,xc2_mu,{'IC_Long_1'},'VariableNames',names);
    KPCTHKjyif = table(jf_O,jf_C,{tommorrow},{near1IF(1:6)},{near1_deliv},jf_mu,jf_s1,jf_s2,jf_t,parameters(jyIF,K1),parameters(jyIF,K2),jf_w,nextctIF,mf_O,mf_C,mf_mu,{'IF_Hedge_1'},'VariableNames',names);
    KPCTHKjyih = table(jh_O,jh_C,{tommorrow},{near1IH(1:6)},{near1_deliv},jh_mu,jh_s1,jh_s2,jh_t,parameters(jyIH,K1),parameters(jyIH,K2),jf_w,nextctIH,mh_O,mh_C,mh_mu,{'IH_Hedge_1'},'VariableNames',names);
    % 对冲远月 1 挡
    KPCTHKyyif = table(yf_O,yf_C,{tommorrow},{back1IF(1:6)},{back_chgdt},yf_mu,yf_s1,yf_s2,yf_t,parameters(yyIF,K1),parameters(yyIF,K2),yf_w,0,0,0,0,{'IFy_Hedge_1'},'VariableNames',names);
    KPCTHKyyic = table(yc_O,yc_C,{tommorrow},{back1IC(1:6)},{back_chgdt},yc_mu,yc_s1,yc_s2,yc_t,parameters(yyIC,K1),parameters(yyIC,K2),yc_w,0,0,0,0,{'ICy_Hedge_1'},'VariableNames',names);
    KPCTHKyyih = table(yh_O,yh_C,{tommorrow},{back1IH(1:6)},{back_chgdt},yh_mu,yh_s1,yh_s2,yh_t,parameters(yyIH,K1),parameters(yyIH,K2),yh_w,0,0,0,0,{'IHy_Hedge_1'},'VariableNames',names);
    % 对冲近月 IC 1\3\6\7\8档
    KPCTHKalIC1 = table(alIC1_O,alIC1_C,{tommorrow},{near1IC(1:6)},{near1_deliv},alIC1_mu,alIC1_s1,alIC1_s2,alIC1_t,parameters(alIC1,K1),parameters(alIC1,K2),alIC1_w,nextctalcIC1,alcIC1_O,alcIC1_C,alcIC1_mu,{'IC_Hedge_1'},'VariableNames',names);
    KPCTHKalIC3 = table(alIC3_O,alIC3_C,{tommorrow},{near1IC(1:6)},{near1_deliv},alIC3_mu,alIC3_s1,alIC3_s2,alIC3_t,parameters(alIC3,K1),parameters(alIC3,K2),alIC3_w,nextctalcIC3,alcIC3_O,alcIC3_C,alcIC3_mu,{'IC_Hedge_3'},'VariableNames',names);
    KPCTHKalIC6 = table(alIC6_O,alIC6_C,{tommorrow},{near1IC(1:6)},{near1_deliv},alIC6_mu,alIC6_s1,alIC6_s2,alIC6_t,parameters(alIC6,K1),parameters(alIC6,K2),alIC6_w,nextctalcIC6,alcIC6_O,alcIC6_C,alcIC6_mu,{'IC_Hedge_6'},'VariableNames',names);
    KPCTHKalIC7 = table(alIC7_O,alIC7_C,{tommorrow},{near1IC(1:6)},{near1_deliv},alIC7_mu,alIC7_s1,alIC7_s2,alIC7_t,parameters(alIC7,K1),parameters(alIC7,K2),alIC7_w,nextctalcIC7,alcIC7_O,alcIC7_C,alcIC7_mu,{'IC_Hedge_7'},'VariableNames',names);
    KPCTHKalIC8 = table(alIC8_O,alIC8_C,{tommorrow},{near1IC(1:6)},{near1_deliv},alIC8_mu,alIC8_s1,alIC8_s2,alIC8_t,parameters(alIC8,K1),parameters(alIC8,K2),alIC8_w,nextctalcIC8,alcIC8_O,alcIC8_C,alcIC8_mu,{'IC_Hedge_8'},'VariableNames',names);
    % 择时近月 IC 1\3\5\10档
    KPCTHKzsIC1 = table(zsIC1_O,zsIC1_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zsIC1_mu,zsIC1_s1,zsIC1_s2,zsIC1_t,parameters(zsIC1,K1),parameters(zsIC1,K2),zsIC1_w,nextctzscIC1,zscIC1_O,zscIC1_C,zscIC1_mu,{'IC_Long_1'},'VariableNames',names);
    KPCTHKzsIC3 = table(zsIC3_O,zsIC3_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zsIC3_mu,zsIC3_s1,zsIC3_s2,zsIC3_t,parameters(zsIC3,K1),parameters(zsIC3,K2),zsIC3_w,nextctzscIC3,zscIC3_O,zscIC3_C,zscIC3_mu,{'IC_Long_3'},'VariableNames',names);
    KPCTHKzsIC5 = table(zsIC5_O,zsIC5_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zsIC5_mu,zsIC5_s1,zsIC5_s2,zsIC5_t,parameters(zsIC5,K1),parameters(zsIC5,K2),zsIC5_w,nextctzscIC5,zscIC5_O,zscIC5_C,zscIC5_mu,{'IC_Long_5'},'VariableNames',names);
    KPCTHKzsIC10 = table(zsIC10_O,zsIC10_C,{tommorrow},{near1IC(1:6)},{near1_deliv},zsIC10_mu,zsIC10_s1,zsIC10_s2,zsIC10_t,parameters(zsIC10,K1),parameters(zsIC10,K2),zsIC10_w,nextctzscIC10,zscIC10_O,zscIC10_C,zscIC10_mu,{'IC_Long_10'},'VariableNames',names);
    
    KPCTHK = [KPCTHKalIC1;KPCTHKalIC3;KPCTHKalIC6;KPCTHKalIC7;KPCTHKalIC8;...
              KPCTHKzsIC1;KPCTHKzsIC3;KPCTHKzsIC5;KPCTHKzsIC10;...
              KPCTHKxh2;KPCTHKjyif;KPCTHKjyih;KPCTHKyyif;KPCTHKyyic;KPCTHKyyih;];
    
    if (dayslen>=3 && currdt>1) || (dayslen==2 && currdt==1) % 避免输出已经计算过的结果
        display(KPCTHK);
    end
    
    %% 写入到txt
    
    writetable(KPCTHKzsIC1,'现货择时开平仓门限\IC_XHZS.txt','WriteVariableNames',0);
    writetable(KPCTHKxh2,'现货择时开平仓门限2\IC_XHZS.txt','WriteVariableNames',0);
    writetable(KPCTHKjyif,'期货近月开平仓门限\IF_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC1,'期货近月开平仓门限\IC_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKjyih,'期货近月开平仓门限\IH_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyif,'期货远月开平仓门限\IF_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyic,'期货远月开平仓门限\IC_KPCTHK.txt','WriteVariableNames',0);
    writetable(KPCTHKyyih,'期货远月开平仓门限\IH_KPCTHK.txt','WriteVariableNames',0);
    
    writetable(KPCTHKzsIC1 ,'产品推送开平仓门限\BQ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC3,'产品推送开平仓门限\BQ2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC3,'产品推送开平仓门限\JQ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC3,'产品推送开平仓门限\HJ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC3,'产品推送开平仓门限\GD2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC5,'产品推送开平仓门限\HJ1ICLongTest_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\LS1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC3,'产品推送开平仓门限\XD9ICLong_KPCMX.txt','WriteVariableNames',0);
    
    writetable(KPCTHKalIC1,'产品推送开平仓门限\BQ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\BQ2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\JQ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\HJ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\GD2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\HJ1ICHedgeTest_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC8,'产品推送开平仓门限\LS1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC6,'产品推送开平仓门限\XY7ICHedge_KPCMX.txt','WriteVariableNames',0);
    
    writetable(KPCTHK,['KPCTHK_history\KPCTHK_' tommorrow '_WJP.csv'],'WriteVariableNames',1);
    
    %%
    last_updt = currentdate;
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
[suc,tot]  =  push_KPCMX();
display('Trading system & monitor parameters updated !');
%%
Sending_emails(tommorrow);

if suc== tot
    exit;
end


