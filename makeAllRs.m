function makeAllRs(amplitude,stepsize,jitter)
mfolder = 'C:\Users\cneveu\Desktop\modeling\CPG_Yuto';

fdir = dir(mfolder);

% amplitude = 0;%5
% stepsize = 50;
% jitter = 10;
for f=1:length(fdir)
    if contains(fdir(f).name,'es') || contains(fdir(f).name,'cs') || contains(fdir(f).name,'B')
        makeRs(fullfile(mfolder,fdir(f).name),amplitude,stepsize,jitter,false)
    end
end
