function[suc,tot]=push_KPCMX()
% %% update the trading system
count=[];
count=[count make_copy('�ڻ����¿�ƽ������\*KPCTHK.txt','\\Acerpc\ʵʱ���\jy')];
count=[count make_copy('�ڻ�Զ�¿�ƽ������\*KPCTHK.txt','\\Acerpc\ʵʱ���\yy')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\*.txt','\\Acerpc\ʵʱ���\plot')];

% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Zhoufz-pc\ic\')
% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\BAIQUAN-PC\ic\')
% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Huijin2\ic\')
% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Trading4\ic\')
% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Baiquan2trd1\ic\')
% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Xincheng1\ic\')
% make_copy('�ڻ����¿�ƽ������\IC_KPCTHK.txt','\\Zfz-pc\ic\')
% make_copy('�ڻ����¿�ƽ������\IC_KPCTHK.txt','\\Trading5\ic\')
% make_copy('�ڻ����¿�ƽ������\IC_KPCTHK.txt','\\Baiquan2trd2\ic\')
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICHedge_KPCMX.txt','\\Zfz-pc\ic\ ')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICLong_KPCMX.txt','\\Zhoufz-pc\ic')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\JQ1ICLong_KPCMX.txt','\\BAIQUAN-PC\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICLong_KPCMX.txt','\\Trading4\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICLong_KPCMX.txt','\\Baiquan2trd1\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICHedge_KPCMX.txt','\\Baiquan2trd2\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\XD9ICCommon_KPCMX.txt','\\Xincheng1\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICLong_KPCMX.txt','\\Bqls1_trading1\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICHedge_KPCMX.txt','\\Bqls1_trading2\IC\')];

% to vm machine
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICLong_KPCMX.txt','\\BQ1_ICLong\ic\')];
%count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICLong_KPCMX.txt','\\BQ2_ICLONG\cwstate\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\JQ1ICLong_KPCMX.txt','\\JQ1_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICLong_KPCMX.txt','\\HJ1_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICLong_KPCMX.txt','\\GD2_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ3ICLong_KPCMX.txt','\\BQ3_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICLong_KPCMX.txt','\\ls1_iclong\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\MS1ICLong_KPCMX.txt','\\MS1_ICLONG\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\JQ1IFLong_KPCMX.txt','\\JQ1_IFLONG\IF\')];

count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICHedge_KPCMX.txt','\\BQ1_ICHedge\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICHedge_KPCMX.txt','\\BQ2_ICHEDGE\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICHedge_KPCMX.txt','\\GD2_ICHedge\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\XY7ICHedge_KPCMX.txt','\\XY7_ICHEDGE\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ3ICHedge_KPCMX.txt','\\BQ3_ICHEDGE\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICHedge_KPCMX.txt','\\ls1_ichedge\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2yyICHedge_KPCMX.txt','\\GD2_YYICHEDGE\IC\')];

% 
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICLongTest_KPCMX.txt','\\Zhouhu\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICHedgeTest_KPCMX.txt','\\Zhouhu\ic\')];

suc = sum(count);
tot = length(count);

display(['Total ' num2str(tot) ' copies made, with:']);
display([ num2str(suc) ' success']);
display([ num2str(tot-suc) ' fails']);

