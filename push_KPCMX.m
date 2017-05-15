function[suc,tot]=push_KPCMX()
% %% update the trading system
count=[];
count=[count make_copy('期货近月开平仓门限\*KPCTHK.txt','\\Acerpc\实时监控\jy')];
count=[count make_copy('期货远月开平仓门限\*KPCTHK.txt','\\Acerpc\实时监控\yy')];
count=[count make_copy('产品推送开平仓门限\*.txt','\\Acerpc\实时监控\plot')];

% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Zhoufz-pc\ic\')
% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\BAIQUAN-PC\ic\')
% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Huijin2\ic\')
% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Trading4\ic\')
% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Baiquan2trd1\ic\')
% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Xincheng1\ic\')
% make_copy('期货近月开平仓门限\IC_KPCTHK.txt','\\Zfz-pc\ic\')
% make_copy('期货近月开平仓门限\IC_KPCTHK.txt','\\Trading5\ic\')
% make_copy('期货近月开平仓门限\IC_KPCTHK.txt','\\Baiquan2trd2\ic\')

%count=[count make_copy('产品推送开平仓门限\BQ1ICHedge_KPCMX.txt','\\Zfz-pc\ic\ ')];
%count=[count make_copy('产品推送开平仓门限\BQ1ICLong_KPCMX.txt','\\Zhoufz-pc\ic')];
% count=[count make_copy('产品推送开平仓门限\JQ1ICLong_KPCMX.txt','\\BAIQUAN-PC\ic\')];
count=[count make_copy('产品推送开平仓门限\HJ1ICLong_KPCMX.txt','\\Huijin2\ic\')];
% count=[count make_copy('产品推送开平仓门限\GD2ICLong_KPCMX.txt','\\Trading4\ic\')];
count=[count make_copy('产品推送开平仓门限\GD2ICHedge_KPCMX.txt','\\Trading5\ic\')];
count=[count make_copy('产品推送开平仓门限\BQ2ICLong_KPCMX.txt','\\Baiquan2trd1\ic\')];
count=[count make_copy('产品推送开平仓门限\BQ2ICHedge_KPCMX.txt','\\Baiquan2trd2\ic\')];
% count=[count make_copy('产品推送开平仓门限\HJ1ICLongTest_KPCMX.txt','\\Huijin1\ic\')];
count=[count make_copy('产品推送开平仓门限\XD9ICLong_KPCMX.txt','\\Xincheng1\ic\')];
count=[count make_copy('产品推送开平仓门限\LS1ICLong_KPCMX.txt','\\Bqls1_trading1\ic\')];
count=[count make_copy('产品推送开平仓门限\LS1ICHedge_KPCMX.txt','\\Bqls1_trading2\IC\')];
% to vm machine
count=[count make_copy('产品推送开平仓门限\BQ1ICHedge_KPCMX.txt','\\Bq1_ichedge\ic\')];
count=[count make_copy('产品推送开平仓门限\BQ1ICLong_KPCMX.txt','\\BQ1_IClong\IC\')];
count=[count make_copy('产品推送开平仓门限\JQ1ICLong_KPCMX.txt','\\JQ1_ICLong\ic\')];
count=[count make_copy('产品推送开平仓门限\GD2ICLong_KPCMX.txt','\\GD2_ICLong\ic\')];
count=[count make_copy('产品推送开平仓门限\XY7ICHedge_KPCMX.txt','\\XY7_ICHEDGE\cwstate\IC\')];
% 
count=[count make_copy('产品推送开平仓门限\HJ1ICLongTest_KPCMX.txt','\\Zhouhu\ic\')];
count=[count make_copy('产品推送开平仓门限\HJ1ICHedgeTest_KPCMX.txt','\\Zhouhu\ic\')];

% make_copy('现货择时开平仓门限\IC_XHZS.txt','\\Zhouhu\ts仿真\kpcthk(N档)_zeshi\IC\')
% make_copy('期货近月开平仓门限\*KPCTHK.txt','\\Zhouhu\ts仿真\kpcthk(N档)_alpha\IC\')

suc = sum(count);
tot = length(count);

display(['Total ' num2str(tot) ' copies made, with:']);
display([ num2str(suc) ' success']);
display([ num2str(tot-suc) ' fails']);

