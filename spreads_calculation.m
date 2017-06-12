  %% 提取对应参数
clear;
clc;

%%
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

%%
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
alIC4 = 16;
alBQ3 = 17;

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
    tommorrow = datestr(w.tdaysoffset(1,currentdate),'yyyymmdd');
    
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
    
    ctnear1 = 1;
    ctnear2 = 2;
    ctback1 = 3;
    ctback2 = 4;
    
    delta = w.tdayscount(currentdate,deliveries{1});
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
    
    %% 提取合约代码
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
    % 处理次月合约代码
    next_needed = delta<= 12; 
    nextctIF = ifelse(next_needed,{near2IF(1:6)},0);
    nextctIH = ifelse(next_needed,{near2IH(1:6)},0);
    nextctIC = ifelse(next_needed,{near2IC(1:6)},0);
    
    %% 数据位置
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
    digit = 6;
    
    KPCTHKxh2 = general_calculation(xhzs2,'IC',1,'IC_Long_1',digit);
    KPCTHKjyif = general_calculation(jyIF,'IF',1,'IF_Hedge_1',digit);
    KPCTHKjyih = general_calculation(jyIH,'IH',1,'IH_Hedge_1',digit);
    % 对冲远月 1 挡
    KPCTHKyyif = general_calculation(yyIF,'IF',0,'IFy_Hedge_1',digit);
    KPCTHKyyic = general_calculation(yyIC,'IC',0,'ICy_Hedge_1',digit);
    KPCTHKyyih = general_calculation(yyIH,'IH',0,'IHy_Hedge_1',digit);
    % 对冲近月 IC 1\3\4\6\7\8\档
    KPCTHKalIC1 = general_calculation(alIC1,'IC',1,'IC_Hedge_1',digit);
    KPCTHKalIC3 = general_calculation(alIC3,'IC',1,'IC_Hedge_3',digit);
    KPCTHKalIC4 = general_calculation(alIC4,'IC',1,'IC_Hedge_4',digit);
    KPCTHKalIC6 = general_calculation(alIC6,'IC',1,'IC_Hedge_6',digit);
    KPCTHKalIC7 = general_calculation(alIC7,'IC',1,'IC_Hedge_7',digit);
    KPCTHKalIC8 = general_calculation(alIC8,'IC',1,'IC_Hedge_8',digit);
    % 择时近月 IC 1\3\5\10档
    KPCTHKzsIC1 = general_calculation(zsIC1,'IC',1,'IC_Long_1',digit);
    KPCTHKzsIC3 = general_calculation(zsIC3,'IC',1,'IC_Long_3',digit);
    KPCTHKzsIC5 = general_calculation(zsIC5,'IC',1,'IC_Long_5',digit);
    KPCTHKzsIC10 = general_calculation(zsIC10,'IC',1,'IC_Long_10',digit);
    %  bq3 alpha temp
    KPCTHKalBQ3 = general_calculation(alBQ3,'IC',1,'IC_Hedge_1_temp',digit);
    
    KPCTHK = [KPCTHKalIC1;KPCTHKalIC3;KPCTHKalIC4;KPCTHKalIC6;KPCTHKalIC7;KPCTHKalIC8;...
              KPCTHKzsIC1;KPCTHKzsIC3;KPCTHKzsIC5;KPCTHKzsIC10;...
              KPCTHKxh2;KPCTHKjyif;KPCTHKjyih;KPCTHKyyif;KPCTHKyyic;KPCTHKyyih;KPCTHKalBQ3];
    
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
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\BQ2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\JQ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\HJ1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\GD2ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC5,'产品推送开平仓门限\HJ1ICLongTest_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\LS1ICLong_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKzsIC10,'产品推送开平仓门限\BQ3ICLong_KPCMX.txt','WriteVariableNames',0);
    
    writetable(KPCTHKalIC1,'产品推送开平仓门限\BQ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC4 ,'产品推送开平仓门限\BQ2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\HJ1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC3 ,'产品推送开平仓门限\HJ1ICHedgeTest_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC4 ,'产品推送开平仓门限\GD2ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC6,'产品推送开平仓门限\XY7ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC8,'产品推送开平仓门限\LS1ICHedge_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalIC8,'产品推送开平仓门限\XD9ICCommon_KPCMX.txt','WriteVariableNames',0);
    writetable(KPCTHKalBQ3 ,'产品推送开平仓门限\BQ3ICHedge_KPCMX.txt','WriteVariableNames',0);
    
    writetable(KPCTHK,['KPCTHK_history\KPCTHK_' tommorrow '_WJP.csv'],'WriteVariableNames',1);
    
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


