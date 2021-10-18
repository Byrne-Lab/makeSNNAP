function writeAB(filenm,param)
% writes a A or B file for SNNAP.
% INPUT:
% filenm = file name, assumes that the corresponding .A and .B files have
%          same name and are located in the same folder as filenm
% param = [mn,h,s,p,tmx,tmn,th1,ts1,tp1,th2,ts2,tp2]
%
% param:
% mn     = the minimum activation/inactivation 
% h      = the half inactivation/activation potential (mV)
% s      = slope of inactivation/activation function, decrease = sharper
% p      = exponential of inactivation/activation function
% tmx    = max time constant (s)
% tmn    = min time constant (s)
% th1    = halfway of time constant (mV) of function 1
% ts1    = slope of time constant (mV) of function 1
% tp1    = exponential of time constant of function 1
% th2    = halfway of time constant (mV) of function 2
% ts2    = slope of time constant (mV) of function 2
% tp2    = exponential of time constant of function 2
% 
% EXAMPLE:
% writeAB('C:\Users\cneveu\Desktop\modeling\toy\N1\N1_Kca.vdg',1,1,-70)

[~,~,ext] = fileparts(filenm);
if ~strcmp(ext,'.A') && ~strcmp(ext,'.B')
    error('please include file extension A or B')
end

if exist(['template' ext],'file')
    txt = fileread(['template' ext]);
else
    error(['could not find template' ext])
end

if nargin==1
    txt = replace(txt,'>a','');
    txt = replace(txt,'>b','>');
    txt = eraseit(txt);
else
    txt = replace(txt,'>c','');
    if sum(~isnan(param))<4
        erstr = ["Bn,","h,","s,","p,"];
        error(join([erstr(isnan(param(1:4))),"is not provided for",filenm],' '))
    elseif sum(~isnan(param))==4
        txt = replace(txt,'>a','');
        txt = replace(txt,'>c','');
        txt = replace(txt,'>b','>');
    else
        txt = replace(txt,'>a','>');
        txt = replace(txt,'>b','');
        txt = replace(txt,'>c','');
        if sum(~isnan(param))<6
            txt = replace(txt,'>1','');
        elseif sum(~isnan(param))<10
            txt = replace(txt,'>2','');
        else
            txt = replace(txt,'>3','');
        end
    end
    txt = eraseit(txt);
    
    tags = ["AN","H0","S0","P0","TX","TN","H1","S1","P1","H2","S2","P2"];
    for t=1:sum(~isnan(param))
        txt = replace(txt,tags{t},num2str(param(t)));
    end
end
    

fid = fopen(filenm,'w');
fprintf(fid,'%s',txt);
fclose(fid);

end

function txt = eraseit(txt)
for o=1:5
    txt = replace(txt,['>' num2str(o)],'>');
end
end




