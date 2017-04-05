function[filled_data]=datafill(data,flags,startmarks)
[m,n]=size(data);
filled_data=zeros(m,n);
len=sum(startmarks);
startidx=find(startmarks);
for dumi=1:len
    head=startidx(dumi);
    if dumi==len
        tail=m;
    else
        tail=startidx(dumi+1)-1;
    end
    templen=tail-head+1;
    tempdata=data(head:tail,:);
    tempflag=flags(head:tail);
    firstval=find(tempflag,1); % position of the first non-missing value
    if isempty(firstval)
        error('From function <datafill> : Can not fill with no existing rows in the data!');
    end
    if firstval~=1
        tempdata(1:(firstval-1),:)=ones(firstval-1,1)*tempdata(firstval,:);
    end    
    for dumj=(firstval+1):templen
        if ~tempflag(dumj)
            tempdata(dumj,:)=tempdata(dumj-1,:);
        end
    end
    filled_data(head:tail,:)=tempdata;
end
