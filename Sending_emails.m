function[]=Sending_emails(currentdate)
%% �����ʼ������¼�����
MailAddress = 'wangjp@baiquaninvest.com';   % ���������˺�
password = 'Wqxl7309';                              % ������������
setpref('Internet','E_mail',MailAddress);
setpref('Internet','SMTP_Server','smtp.qiye.163.com');
setpref('Internet','SMTP_Username',MailAddress);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.port', '465');
%%
ToAddress = {'wangjp@baiquaninvest.com'};     % �ռ��˵�ַ
Subject = strcat(currentdate,' �ֻ���ʱ��ƽ���������ݸ���');            % ����
Content = '����������Matlab�Զ����ͣ�';                                 % �ʼ�����
Attatchments={'�ֻ���ʱ��ƽ������\IC_XHZS.txt','�ֻ���ʱ��ƽ������2\IC_XHZS.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

ToAddress = {'wangjp@baiquaninvest.com'};     % �ռ��˵�ַ
Subject = strcat(currentdate,' �ڻ����¿�ƽ���������ݸ���');            % ����
Content = '����������Matlab�Զ����ͣ�';                                 % �ʼ�����
Attatchments={  '�ڻ����¿�ƽ������\IF_KPCTHK.txt',...
                '�ڻ����¿�ƽ������\IC_KPCTHK.txt',...
                '�ڻ����¿�ƽ������\IH_KPCTHK.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

ToAddress = {'wangjp@baiquaninvest.com'};     % �ռ��˵�ַ
Subject = strcat(currentdate,' �ڻ�Զ�¿�ƽ���������ݸ���');            % ����
Content = '����������Matlab�Զ����ͣ�';                                 % �ʼ�����
Attatchments={  '�ڻ�Զ�¿�ƽ������\IF_KPCTHK.txt',...
                '�ڻ�Զ�¿�ƽ������\IC_KPCTHK.txt',...
                '�ڻ�Զ�¿�ƽ������\IH_KPCTHK.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

%%
ToAddress = {'wangjp@baiquaninvest.com','chenhf@baiquaninvest.com','zhouh@baiquaninvest.com'};     % �ռ��˵�ַ
Subject = strcat(currentdate,' �ڻ���ƽ���������ݸ���');            % ����
Content = '����������Matlab�Զ����ͣ�';                                 % �ʼ�����
Attatchments={['KPCTHK_history\KPCTHK_' currentdate '_WJP.csv']}; 
sendmail(ToAddress,Subject,Content,Attatchments);

display('Emails sent!');



