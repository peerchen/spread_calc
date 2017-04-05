function[flags]=flagfill(data)
% 0 for missing value flag and 1 for non-missing
[m,n]=size(data);
idx=isnan(data);
flags=zeros(m,1);
for dumi=1:n
    flags=flags | idx(:,dumi);
end
flags=~flags;