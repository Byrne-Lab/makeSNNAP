function writecs(OS,filenm,g,e,fat,r)
% writes a .cs synapse file for SNNAP.
% INPUT:
% filenm = file name, assumes that the corresponding .fAt and .R files have
%          same name and are located in the cs and R folders and that the
%          synapse has no voltage dependence (is not a .fAvt extension)
% g      = the maximum conductance of the synapse
% e      = the reversal potential of the synapse
% fat    = time dependent activation file name (optional)
% r      = the location\name of the R file (optional)
% EXAMPLE:
% filenm = 'C:\Users\cneveu\Desktop\modeling\toy\cs\A_2_B_f_exc.cs';
% writecs(filenm,1.2,-80,'../cs/A_2_B_f_exc.fAt','../R/A_2_B_f_exc.R')
% writecs('C:\Users\cneveu\Desktop\modeling\toy\cs\A_2_B_f_exc.cs',1.2,-80)


if ~strcmp(filenm(end-2:end),'.cs')
    filenm = [filenm, '.cs'];
end

head = ['         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '         >>   modules name: cs		>>\n',...
        '         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n'];

head2 =['         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
		'Ics:          >    Current due to a chemical synapse                    >\n',...
		'         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n'];  

sbr  =  '>------------------------------->--------------------------------------->\n';
brk	 =  '>a                                >                                       >\n';
ttl	 =  '>a     1                     >  G= (g+R) x fAt           (1)              >\n';
fln  =  '>a  %-24s >fAt<           >  time-dependent activation >\n';

tt2	 =  '>a     2                     >  G= (g+R) x fAvt           (1)              >\n';
fl2  =  '>a  %-24s >fAvt<           >  time-dependent activation >\n';

rfl  =  '>a  %-24s >R<             >  random fluctuations       >\n';
gln  =  '>a  %.3f                     > g uS<         >                            >\n';
eln  =  '>a  %2.0f                      > E mV<         >  Ics= G x (V -E)           >\n';

comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

if nargin>4 && contains(fat,'.fAvt')
    txt = [head,head2,sbr,replace([brk,ttl,fln,rfl,gln,eln,brk,sbr],'>a','>'),...
                          replace([brk,tt2,fl2,rfl,gln,eln,brk,sbr],'>a',''),'\nEND:\n'];
else
    txt = [head,head2,sbr,replace([brk,ttl,fln,rfl,gln,eln,brk,sbr],'>a',''),...
                          replace([brk,tt2,fl2,rfl,gln,eln,brk,sbr],'>a','>'),'\nEND:\n'];  
end

[~,name] = fileparts(filenm);

fid = fopen(filenm,'w');
if nargin==5
    fprintf(fid,txt,fat,[comp 'R/' name '.R'],g,e,fat,[comp 'R/' name '.R'],g,e);
elseif nargin>5
    fprintf(fid,txt,fat,r,g,e,fat,r,g,e);
else
    fprintf(fid,txt,[comp 'cs/' name '.fAt'],[comp 'R/' name '.R'],g,e,...
                    [comp 'cs/' name '.fAt'],[comp 'R/' name '.R'],g,e);%'../'
end
fclose(fid);


end