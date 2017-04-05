clear;
clc;

[contracts,deliveries]=getContracts();

fut_contracts_IF=contracts.IF;
fut_contracts_IC=contracts.IC;
fut_contracts_IH=contracts.IH;

nearby1=fut_contracts_IF{1};
nearby2=fut_contracts_IF{2};
back1=fut_contracts_IF{3};
back2=fut_contracts_IF{4};

xxfiles={
    '\\JIAPENG-PC\tempdata\IFxx_min.csv',...
    '\\JIAPENG-PC\tempdata\ICxx_min.csv',...
    '\\JIAPENG-PC\tempdata\IHxx_min.csv',...
    };

datafiles_IF={
    strcat('\\JIAPENG-PC\tempdata\k_if',nearby1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_if',nearby2(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_if',back1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_if',back2(3:6),'.csv'),...
    };

datafiles_IC={
    strcat('\\JIAPENG-PC\tempdata\k_ic',nearby1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ic',nearby2(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ic',back1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ic',back2(3:6),'.csv'),...
    };

datafiles_IH={
    strcat('\\JIAPENG-PC\tempdata\k_ih',nearby1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ih',nearby2(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ih',back1(3:6),'.csv'),...
    strcat('\\JIAPENG-PC\tempdata\k_ih',back2(3:6),'.csv'),...
    };


%% 现货
underlying_IF=csvread(xxfiles{1},1,0);
underlying_IC=csvread(xxfiles{2},1,0);
underlying_IH=csvread(xxfiles{3},1,0);


%% 期货
indices={'IF','IC','IH'};

for dumj=1:length(indices)
    
    index=indices{dumj};
    
    if strcmp(index,'IF')
        outfile=datafiles_IF;
        fut_contracts=fut_contracts_IF;
    elseif strcmp(index,'IC')
        outfile=datafiles_IC;
        fut_contracts=fut_contracts_IC;
    elseif strcmp(index,'IH')
        outfile=datafiles_IH;
        fut_contracts=fut_contracts_IH;
    end
    
    for dumi=1:length(outfile)
        fut_contract=fut_contracts{dumi};
        matdata=csvread(outfile{dumi},1,0);
        assignin('base',fut_contract(1:6),matdata)
    end
    
end