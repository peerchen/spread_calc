function[paranames]=parameters_decoder(parameters)
[row,~] = size(parameters);

ctmon = 1; % ½ü£º0 Ô¶£º1
cttype = 2; % IF£º0 IC£º1 IH£º2
strategy = 3; % zs 0, alpha 1
levels = 4;

mon = {'Near1','Near2','Back1','Back2'};
ctype = {'IF','IC','IH'};
strat = {'Long','Hedge'};

paranames = cell(row,1);
counts = zeros(row,1);
counts_out = cell(row,1);

for dumr=1:row
    monpos = parameters(dumr,ctmon)+1;
    ctypepos = parameters(dumr,cttype)+1;
    stratpos = parameters(dumr,strategy)+1;
    level = parameters(dumr,levels);
    paranames{dumr} = strcat(mon{monpos},'_',ctype{ctypepos},'_',strat{stratpos},'_Levels',num2str(level));
    
    if dumr==1
        counts(dumr,1) = 1;
        counts_out{dumr,1} = '01';
    else
        repeated = false;
        for dumi=1:(dumr-1)
            if strcmp(paranames{dumr},paranames{dumi})
                counts(dumi,1) = counts(dumi,1)+1;
                if counts(dumi,1)<10
                    counts_out{dumr,1} = strcat('0',num2str(counts(dumi,1)));
                else
                    counts_out{dumr,1} = num2str(counts(dumi,1));
                end
                repeated = true;
            end
        end
        if ~repeated
            counts(dumr,1) = 1;
            counts_out{dumr,1} = '01';
        end
    end
end

for dumr=1:row
    paranames{dumr} = strcat(paranames{dumr},'_',counts_out{dumr});
end