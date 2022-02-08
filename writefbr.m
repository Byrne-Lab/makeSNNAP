function writefbr(filenm,opt1,opt2,param,beta)
% writes a fBR file for SNNAP.
% INPUT:
% filenm = file name, assumes that the corresponding .A and .B files have
%          same name and are located in the same folder as filenm
% opt1   = 1:    fBR = BR 
%          2:    fBR = 1 + BR, 
%          3:    fBR = 1/(1 + beta*BR)
% opt2   = 1: dBR/dt = (ion - BR)/param(1)   initial value = param(2)
%          2:     BR = ion/(param(1) + ion)
%          3:     BR = ion/(param(1) + ion) + 1
%          4:     BR = 1/(1 + param(1)*ion)
%          5:     BR = exp((param(1) + ion)/param(2))
% param  = input parameters for opt2
% beta   = only needed for opt1==3
%
% EXAMPLE:
% writevdg('C:\Users\cneveu\Desktop\modeling\toy\N1\N1_Kca.vdg',1,1,-70)

if ~strcmp(filenm(end-3:end),'.fBR')
    filenm = [filenm, '.fBR'];
end

if exist('template.fBR','file')
    txt = fileread('template.fBR');
else
    error('could not find template.fBR')
end

txt = replace(txt,'AA',num2str(param(1)));

if opt2==5
    if sum(~isnan(param))==2 
        txt = replace(txt,'UU',num2str(param(2)));
    else
        error(['In creating ', filenm , ', param needs to have length of 2 if opt2==5'])
    end
elseif opt2==1
    if sum(~isnan(param))==2
       txt = replace(txt,'CC',num2str(param(2)));
    else
       txt = replace(txt,'CC','0');
       warning(['In creating ', filenm , ', Initial value not given. iC set to 0.'])
    end
end


if nargin==5 && ~isnan(beta)
    txt = replace(txt,'bb',num2str(beta));
end

for o=1:5
    if o==opt2
        txt = replace(txt,['>' num2str(o) 'a'],'');
    else
        txt = replace(txt,['>' num2str(o) 'a'],'>');
    end
    
    if o==opt1
        txt = replace(txt,['>' num2str(o)],'');
    else
        txt = replace(txt,['>' num2str(o)],'>');
    end
end

fid = fopen(filenm,'w');
fprintf(fid,'%s',txt);
fclose(fid);
end