function[]=Sending_emails(currentdate)
%% 发送邮件及更新计算结果
MailAddress = 'wangjp@baiquaninvest.com';   % 发件邮箱账号
password = 'Wqxl7309';                              % 发件邮箱密码
setpref('Internet','E_mail',MailAddress);
setpref('Internet','SMTP_Server','smtp.qiye.163.com');
setpref('Internet','SMTP_Username',MailAddress);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.port', '465');
%%
ToAddress = {'wangjp@baiquaninvest.com'};     % 收件人地址
Subject = strcat(currentdate,' 现货择时开平仓门限数据更新');            % 标题
Content = '以下数据由Matlab自动发送：';                                 % 邮件内容
Attatchments={'现货择时开平仓门限\IC_XHZS.txt','现货择时开平仓门限2\IC_XHZS.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

ToAddress = {'wangjp@baiquaninvest.com'};     % 收件人地址
Subject = strcat(currentdate,' 期货近月开平仓门限数据更新');            % 标题
Content = '以下数据由Matlab自动发送：';                                 % 邮件内容
Attatchments={  '期货近月开平仓门限\IF_KPCTHK.txt',...
                '期货近月开平仓门限\IC_KPCTHK.txt',...
                '期货近月开平仓门限\IH_KPCTHK.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

ToAddress = {'wangjp@baiquaninvest.com'};     % 收件人地址
Subject = strcat(currentdate,' 期货远月开平仓门限数据更新');            % 标题
Content = '以下数据由Matlab自动发送：';                                 % 邮件内容
Attatchments={  '期货远月开平仓门限\IF_KPCTHK.txt',...
                '期货远月开平仓门限\IC_KPCTHK.txt',...
                '期货远月开平仓门限\IH_KPCTHK.txt'}; 
sendmail(ToAddress,Subject,Content,Attatchments);

%%
ToAddress = {'wangjp@baiquaninvest.com','chenhf@baiquaninvest.com','zhouh@baiquaninvest.com'};     % 收件人地址
Subject = strcat(currentdate,' 期货开平仓门限数据更新');            % 标题
Content = '以下数据由Matlab自动发送：';                                 % 邮件内容
Attatchments={['KPCTHK_history\KPCTHK_' currentdate '_WJP.csv']}; 
sendmail(ToAddress,Subject,Content,Attatchments);

display('Emails sent!');



