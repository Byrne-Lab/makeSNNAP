function makeRs(folder,amplitude,stepsize,jitter, displayo)
% This goes through folder and makes a corresponding R file for each VDG,
% ES, and CS file. 
%
% INPUT:
% folder = directory
% amplitude = amount of noise
% stepsize = number of samples random number updates
% jitter   = amount of jitter in stepsize
% displayo = print channels to commandline (optional)
%
% EXAMPLE:
% makeRs('C:\Users\cneveu\Desktop\modeling\DI_cpg_old\cs',20,400,10)

if nargin<4
    jitter = 10;
end


files = dir(folder);

dest = fullfile(fileparts(folder),'R');
crope = [3,2,2];
for f=1:length(files)
    step = round(stepsize*(1+randn(1)/100*jitter));
    ft = [contains(files(f).name,'vdg'), contains(files(f).name,'.es'), contains(files(f).name,'.cs')];
    
    if contains(files(f).name,'vdg') || contains(files(f).name,'.es') || contains(files(f).name,'.cs')
        if displayo; disp(files(f).name);end
        writeR(fullfile(dest, [files(f).name(1:end-crope(ft)),'R']),amplitude,step)
        fnm = fullfile(files(f).folder,files(f).name);
        txt = fileread(fnm);
%         txt = replace(txt,'/R/R_VDG',['/R/' files(f).name(1:end-crope(ft)-1)]);
%         txt = replace(txt,'/R/R_CS',['/R/' files(f).name(1:end-crope(ft)-1)]);
%         txt = replace(txt,'/R/R_ES',['/R/' files(f).name(1:end-crope(ft)-1)]);
        txt = regexprep(txt,'/R/\S+',['/R/' files(f).name(1:end-crope(ft)-1) '.R']);
        fid = fopen(fnm,'w');
        fprintf(fid,'%s',txt);
        fclose(fid);
    end
end

