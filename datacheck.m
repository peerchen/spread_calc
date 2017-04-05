function[error]=datacheck(data)
daysleft=data(:,11);
error=~(length(daysleft)/240==(daysleft(1)-daysleft(end)+1));