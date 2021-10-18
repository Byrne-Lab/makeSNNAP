function writevdg(OS,filenm,opt,g,E,p,nfilenm)
% writes a vdg file for SNNAP.
% INPUT:
% OS      = specify either 'win' or 'mac'.
% filenm  = file name, assumes that the corresponding .A and .B files have
%          same name and are located in the same folder as filenm
% opt     = the type of channel
% g       = the maximum conductance of the synapse
% e       = the reversal potential of the synapse
% nfilenm = new file name (optional), if not included this function will
%           write over existing file
% EXAMPLE:
% writevdg('C:\Users\cneveu\Desktop\modeling\toy\N1\N1_Kca.vdg',1,1,-70)

comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

if ~strcmp(filenm(end-3:end),'.vdg')
    filenm = [filenm, '.vdg'];
end

if exist('template.vdg','file')
    txt = fileread('template.vdg');
else
    error('could not find template.vdg')
end

[~,name] = fileparts(filenm);
parts = split(name,'_');

txt = replace(txt,[num2str(opt) 'R'],[comp 'R/' name '.R']);%'../'
txt = replace(txt,[num2str(opt) 'G'],num2str(g));
txt = replace(txt,[num2str(opt) 'E'],num2str(E));
if nargin==6 && ~isnan(p) && ~isempty(p)
    txt = replace(txt,[num2str(opt) 'P'],num2str(p));
else
    txt = replace(txt,[num2str(opt) 'P'],num2str(1));
end

txt = replace(txt,[num2str(opt) 'A'],[comp parts{1} '/' name '.A']);%'../'
txt = replace(txt,[num2str(opt) 'B'],[comp parts{1} '/' name '.B']);%'../'
txt = replace(txt,[num2str(opt) 'M'],[comp parts{1} '/' name '.m']);%'../'
txt = replace(txt,[num2str(opt) 'H'],[comp parts{1} '/' name '.h']);%'../'

for o=1:5
    if o==opt
        txt = replace(txt,['>' num2str(o)],'');
    else
        txt = replace(txt,['>' num2str(o)],'>');
    end
end

if nargin<7
    fid = fopen(filenm,'w');
else
    fid = fopen(nfilenm,'w');
end
fprintf(fid,'%s',txt);
fclose(fid);
end