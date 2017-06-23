%% load the historical data in .mat
clear;
clc;
tic
%% data reset
data_reset;
%%
load; %提取存储的mat数据

spreadplace='';
openNplace='open_N 数据\';
momentumplace='';

%% 数据更新
update_openN=1;
update_momentum=1;

w=windmatlab;
startdate=datestr(w.tdaysoffset(1,last_update),'yyyymmdd');
current=now();
if hour(current)*10000+minute(current)*100<151500
    display('date not ready for today, taking previous day as enddate! ');
    enddate=datestr(w.tdaysoffset(-1,datestr(today,'yyyymmdd')),'yyyymmdd');
else
    enddate=datestr(today,'yyyymmdd');
end

if last_update==enddate
    display('Already updated today!');
    exit;
end
starttime='09:00:00';
endtime='15:30:00';

logid=fopen('log.txt','a+');
% update the log
fprintf(logid,'\r\n');
fprintf(logid,'%s\r\n',strcat('*************** Update date:',enddate,' ********************'));

% 非交易日检查
notholiday=w.tdayscount(enddate,enddate);
if ~notholiday
    display(strcat('Today:',enddate,'is a holiday, no trade!'));
    % update the log
    fprintf(logid,'%s\r\n','Holiday today.');
    fclose(logid);
    exit;
end
clear('notholiday','current');


%% 现货更新
indices={'IF','IC','IH'};
ix=[1:8 10]; % column sn is not needed!

contract_IF='000300.SH';
contract_IC='000905.SH';
contract_IH='000016.SH';

new_underlying_IF=OpenNdata_extract_min(startdate,starttime,enddate,endtime,contract_IF,1);
new_underlying_IC=OpenNdata_extract_min(startdate,starttime,enddate,endtime,contract_IC,1);
new_underlying_IH=OpenNdata_extract_min(startdate,starttime,enddate,endtime,contract_IH,1);

errorIF=check_error(underlying_IF,new_underlying_IF(:,ix),1);
errorIC=check_error(underlying_IC,new_underlying_IC(:,ix),1);
errorIH=check_error(underlying_IH,new_underlying_IH(:,ix),1);


for dumi=1:length(indices)
    errcode=evalin('base',strcat('error',indices{dumi}));
    if errcode
        display(['Error in',indices{dumi},'underlying, errorcode=', num2str(errcode),' data NOT updated']);
        % update the log
        timenow=getTimeNow();
        fprintf(logid,'%s\r\n',[timenow,' Error in',indices{dumi},'ErrCode=',num2str(errcode),' underlying, data NOT updated']);
    else        
        % update the .mat file
         new_underlying=evalin('base',strcat('new_underlying_',indices{dumi}));
         underlying=[evalin('base',strcat('underlying_',indices{dumi}));new_underlying(:,ix)];
         assignin('base',strcat('underlying_',indices{dumi}),underlying);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if update_openN
            % update openN spot data
            % minute data
            xxfid_min=fopen(strcat(openNplace,'concatenated_data\现货数据\',indices{dumi},'xx_min.csv'),'a');
            for row=1:length(new_underlying)
                fprintf(xxfid_min,'%d,%d,%f,%f,%f,%f,%f,%f,%d\r\n',new_underlying(row,ix));
            end
            fclose(xxfid_min);          
            display('openN min underlying data updated');
            fprintf(logid,'%s\r\n',strcat('openN min underlying data updated for',indices{dumi}));
            
            % daily data
%             day_underlying=OpenNdata_extract_day(startdate,enddate,evalin('base',strcat('contract_',indices{dumi})));
%             xxfid_day=fopen(strcat(openNplace,'concatenated_data\现货数据\',indices{dumi},'xx_day.csv'),'a');
%             [m,n]=size(day_underlying);
%             for row=1:m
%                 fprintf(xxfid_day,'%d,%f,%f,%f,%f\n',day_underlying(row,:));
%             end
%             fclose(xxfid_day);
%             display('openN daily underlying data updated');
%             fprintf(logid,'%s\r\n',strcat('openN daily underlying data updated for',indices{dumi}));
            
            % update the log
            timenow=getTimeNow();
            display(strcat(indices{dumi},'underlying data updated for openN'));
            fprintf(logid,'%s\r\n',strcat(timenow,32,indices{dumi},' underlying data updated for openN'));            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % update the log
        timenow=getTimeNow();
        display(strcat(indices{dumi},'underlying data updated'));
        fprintf(logid,'%s\r\n',strcat(timenow,32,indices{dumi},' underlying all data updated'));
    end
end

%% 更新日期提取
datelist=getDateList(last_update,enddate);
lendates=length(datelist);

%% 期货更新
for enddt=2:length(datelist)
    startdate=datestr(w.tdaysoffset(1,datelist{enddt-1}),'yyyymmdd');
    enddate=datelist{enddt};
    
    [contracts,deliveries]=getContracts(enddate);
    % no parameter is given, then take the contract based on the current date
    
    fut_contracts_IF=contracts.IF;
    fut_contracts_IC=contracts.IC;
    fut_contracts_IH=contracts.IH;
    
    nearby1=fut_contracts_IF{1};
    nearby2=fut_contracts_IF{2};
    back1=fut_contracts_IF{3};
    back2=fut_contracts_IF{4};
    
    outfiles_IF={
        strcat(spreadplace,'tempdata\k_if',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_if',back2(3:6),'.csv'),...
        };
    
    outfiles_IC={
        strcat(spreadplace,'tempdata\k_ic',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ic',back2(3:6),'.csv'),...
        };
    
    outfiles_IH={
        strcat(spreadplace,'tempdata\k_ih',nearby1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',nearby2(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back1(3:6),'.csv'),...
        strcat(spreadplace,'tempdata\k_ih',back2(3:6),'.csv'),...
        };
    
    % fill the data in files
    
    for dumj=1:length(indices)
        
        index=indices{dumj};
        outfile=evalin('base',strcat('outfiles_',index));
        fut_contracts=evalin('base',strcat('fut_contracts_',index));
        new_underly_temp=evalin('base',strcat('new_underlying_',index));        
        
        %%%%%%%
        underdate=new_underly_temp(:,1);
        underidx=(underdate>=str2double(startdate) & underdate<=str2double(enddate));
        new_undlydata=new_underly_temp(underidx,1:6);
        %%%%%%%
        
        if evalin('base',strcat('error',index))
            display(strcat('Error in ',index,' underlying, corresponding futures data will NOT be updatedd'));
            continue;
        end
        
        allvars=who;
        for dumi=1:length(outfile)
            delivery=deliveries{dumi};
            fut_contract=fut_contracts{dumi};
            
            % check the existence of data
            if ismember(fut_contract(1:6),allvars);
                var_exist=1;
                old_fulldata=evalin('base',fut_contract(1:6));
            else
                var_exist=0;
                old_fulldata=[];
                % create new file with names
                names={'date','time','o_x','h_x','l_x','c_x','o_q','h_q','l_q','c_q','delta','sn','flag'};
                newfid=fopen(strcat(spreadplace,'tempdata\k_',lower(fut_contract(1:6)),'.csv'),'a');
                fprintf(newfid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\r\n',names{:});
                fclose(newfid);
            end
            
            % extract the data
            new_futdata=winddata_extract(startdate,starttime,enddate,endtime,fut_contract,0);  % new_futdata has column amt and vol here !
            new_fulldata=table2array(combine_data(new_futdata,delivery,new_undlydata));
            
            % error check if data exist
            if var_exist
                error_full=check_error(old_fulldata,new_fulldata,1);
            else
                error_full=0;
            end
            
            if error_full
                display(strcat('Error in contract:',fut_contract,', data NOT updated'));
                % update the log
                timenow=getTimeNow();
                fprintf(logid,'%s\r\n',strcat(timenow,' Error in contract:',fut_contract,',errorcode=',num2str(error_full),',data NOT updated'));
            else
                % update the spread data
                fid = fopen(outfile{dumi}, 'a');
                for row=1:length(new_fulldata)
                    fprintf(fid,'%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%d\r\n',new_fulldata(row,:));
                end
                fclose(fid);
                
                % update the .mat file
                fulldata=[old_fulldata;new_fulldata];
                assignin('base',fut_contract(1:6),fulldata);
                
                delta=w.tdayscount(enddate,deliveries{1});
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if update_momentum && (delta==2 && dumi==2) %周四更新，提取当时的次月合约
                    % update momentum data
                    % minute data
                    qhfid_min=fopen(strcat(momentumplace,'momentum data\predeliv',indices{dumj},'_min.csv'),'a');
                    for row=1:length(new_futdata)
                        % need delta\flag but NOT sn !
                        fprintf(qhfid_min,'%d,%d,%f,%f,%f,%f,%f,%f,%d,%d\n',[new_futdata(row,1:8) new_fulldata(row,(end-2)) new_futdata(row,end) ]);
                    end
                    fclose(qhfid_min);
                    display(strcat('momentum min futures data updated with contract:',fut_contract));
                    fprintf(logid,'%s\r\n',strcat('momentum min futures data updated with contract:',fut_contract));
                    
                    % daily data
%                     day_futures=OpenNdata_extract_day(startdate,enddate,fut_contract);
%                     qhfid_day=fopen(strcat(momentumplace,'momentum data\predeliv',indices{dumj},'_day.csv'),'a');
%                     [m,n]=size(day_futures);
%                     for row=1:m
%                         fprintf(qhfid_day,'%d,%f,%f,%f,%f\n',day_futures(row,:));
%                     end
%                     fclose(qhfid_day);
%                     display(strcat('momentum daily futures data updated with contract:',fut_contract));
%                     fprintf(logid,'%s\r\n',strcat('momentum daily futures data updated with contract:',fut_contract));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if update_openN
                    % update openN
                    if (dumi==1) || (delta==1 && dumi==2)
                        
                        if (delta>=2 && dumi==1) || (delta==1 && dumi==2)
                            fileplace='主力数据\';
                        elseif (delta==1 && dumi==1)
                            fileplace='交割日剩余数据\T0_';
                        else
                            display('wrong logic, break here!!!');
                            break;
                        end
                        
                        % minute data
                        qhfid_min=fopen(strcat(openNplace,'concatenated_data\',fileplace,indices{dumj},'_min.csv'),'a');
                        for row=1:length(new_futdata)
                            % need delta\flag but NOT sn !
                            fprintf(qhfid_min,'%d,%d,%f,%f,%f,%f,%f,%f,%d,%d\n',[new_futdata(row,1:8) new_fulldata(row,(end-2)) new_futdata(row,end) ]);
                        end
                        fclose(qhfid_min);
                        display(strcat('openN min futures data updated with contract:',fut_contract));
                        fprintf(logid,'%s\r\n',strcat('openN min futures data updated with contract:',fut_contract));
                        
                        % daily data
%                         day_futures=OpenNdata_extract_day(startdate,enddate,fut_contract);
%                         qhfid_day=fopen(strcat(openNplace,'concatenated_data\',fileplace,indices{dumj},'_day.csv'),'a');
%                         [m,n]=size(day_futures);
%                         for row=1:m
%                             fprintf(qhfid_day,'%d,%f,%f,%f,%f\n',day_futures(row,:));
%                         end
%                         fclose(qhfid_day);
%                         display(strcat('openN daily futures data updated with contract:',fut_contract));
%                         fprintf(logid,'%s\r\n',strcat('openN daily futures data updated with contract:',fut_contract));
                        
                        % update the log
                        timenow=getTimeNow();
                        display(strcat(indices{dumi},'underlying data updated for openN'));
                        fprintf(logid,'%s\r\n',strcat(timenow,32,indices{dumi},' underlying data updated for openN'));
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % update the log
                timenow=getTimeNow();
                display(strcat(fut_contract,', data updated'));
                fprintf(logid,'%s\r\n',strcat(timenow,32,fut_contract,' futures data updated'));
            end
        end
    end    
end
%%
last_update=enddate;
fprintf(logid,'\r\n');
fclose(logid);

% make copy for the log
!copy log.txt "tempdata\matdata and log\" /Y
display('log copied');

clearvars back1 back2 contract_IF contract_IC contract_IH contracts...
    day_futures day_underlying deliveries delivery delta dumi dumj...
    startdate enddate errcode error_full errorIF errorIC errorIH...
    old_fulldata new_fulldata fulldata fut_contract fut_contracts fut_contracts_IF...
    fut_contracts_IC fut_contracts_IH index fid logid m n nearby1 nearby2...
    new_futdata new_underlying new_underlying_IF new_underlying_IC new_underlying_IH...
    outfile outfiles_IF outfiles_IC outfiles_IH qhfid_day qhfid_min row underlying...
    update_openN w xxfid_day xxfid_min ix new_underly_temp new_undlydata timenow underidx underdate...
    

save; % save the work space

% make copy for the .mat data 
!copy matlab.mat "tempdata\matdata and log\" /Y
display('mat file copied');

display('Data update is finished');
toc

%%
spreads_calculation;


