function writees(OS,filenm,g,r)
% writes a .es synapse file for SNNAP.
% INPUT:
% filenm = file name
% g      = the conductance, scalar or 1x2 
%
% EXAMPLE:
% writecs('C:\Users\cneveu\Desktop\modeling\toy\cs\A_2_B.es',0.01)



if ~strcmp(filenm(end-2:end),'.es')
    filenm = [filenm, '.es'];
end

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: es		>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

head2 =['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
		'Ies:>     Current due to electrical synapse                   >\n',...
		'    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n'];  

sbr  =  '>-------------------------->-------------------------------------------->\n';
brk	 =  '                           >                                            >\n';
ttl	 =  '     1                     >                           (1)              >\n';
rf1  =  '  %-24s >R1<    >  random fluctuations fo G1         >\n';
rf2  =  '  %-24s >R2<    >  random fluctuations fo G2         >\n';
ge1  =  '  %.4f                    >G1<         >  Ies(1) = (G1+R1) x (V1 -V2)  >\n';
ge2  =  '  %.4f                    >G2<         >  Ies(2) = (G2+R2) x (V2 -V1)  >\n';

comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

txt = [head,head2,sbr,ttl,rf1,rf2,ge1,ge2,brk,sbr,'END\n'];

fid = fopen(filenm,'w');

if nargin<4
    [~,name] = fileparts(filenm);
    rnm = [comp 'R/' name, '.R'];%'../'
else
    rnm = r;
end

if length(g)==2
    fprintf(fid,txt,rnm,rnm,g(1),g(2));
else
    fprintf(fid,txt,rnm,rnm,g,g);
end
fclose(fid);


end