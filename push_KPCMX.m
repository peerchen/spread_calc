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

%count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICHedge_KPCMX.txt','\\Zfz-pc\ic\ ')];
%count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICLong_KPCMX.txt','\\Zhoufz-pc\ic')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\JQ1ICLong_KPCMX.txt','\\BAIQUAN-PC\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICLong_KPCMX.txt','\\Huijin2\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICLong_KPCMX.txt','\\Trading4\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICHedge_KPCMX.txt','\\Trading5\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICLong_KPCMX.txt','\\Baiquan2trd1\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ2ICHedge_KPCMX.txt','\\Baiquan2trd2\ic\')];
% count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICLongTest_KPCMX.txt','\\Huijin1\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\XD9ICLong_KPCMX.txt','\\Xincheng1\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICLong_KPCMX.txt','\\Bqls1_trading1\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\LS1ICHedge_KPCMX.txt','\\Bqls1_trading2\IC\')];
% to vm machine
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICHedge_KPCMX.txt','\\Bq1_ichedge\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\BQ1ICLong_KPCMX.txt','\\BQ1_IClong\IC\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\JQ1ICLong_KPCMX.txt','\\JQ1_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\GD2ICLong_KPCMX.txt','\\GD2_ICLong\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\XY7ICHedge_KPCMX.txt','\\XY7_ICHEDGE\cwstate\IC\')];
% 
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICLongTest_KPCMX.txt','\\Zhouhu\ic\')];
count=[count make_copy('��Ʒ���Ϳ�ƽ������\HJ1ICHedgeTest_KPCMX.txt','\\Zhouhu\ic\')];

% make_copy('�ֻ���ʱ��ƽ������\IC_XHZS.txt','\\Zhouhu\ts����\kpcthk(N��)_zeshi\IC\')
% make_copy('�ڻ����¿�ƽ������\*KPCTHK.txt','\\Zhouhu\ts����\kpcthk(N��)_alpha\IC\')

suc = sum(count);
tot = length(count);

display(['Total ' num2str(tot) ' copies made, with:']);
display([ num2str(suc) ' success']);
display([ num2str(tot-suc) ' fails']);

