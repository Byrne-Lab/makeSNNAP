function writentw(OS,filenm,neurons,cs,es)
% This function creates an noise file (.ntw) for SNNAP
% INPUT:
% filenm =  name of network file
% neurons = list of neurons as nx2 or nx3 array of strings
%           [name,fname,color]. Color column optional.
% cs     =  array of connections fs=fast excitatory, fi=fast inhibitory,
%           se=slow excitatory, si=slow inhibitory
% EXAMPLE:
% fname = 'C:\Users\cneveu\Desktop\modeling\toy\ntw\play';
% writentw(fname,["N1" "../N1/N1.neu";"N2" "../N2/N2.neu"],["" "fe"; "fi" ""],logical([0 1 ;0 0]))
% cs = ["N1" "../N1/N1.neu";"N2" "../N2/N2.neu";"N3" "../N3/N3.neu"];
% writentw(fname,cs,["" "fe" "fe"; "fi" "" "";"fi" "" ""],logical([0 1 0;0 0 0;0 1 0]))

comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

if ~strcmp(filenm(end-3:end),'.ntw')
    filenm = [filenm, '.ntw'];
end

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: ntw		    >>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];
  
sbr  =  '>--------------------------->--------------------------------->\n';
sbd  =  '>...........................>.................................>\n';
edd  =  '    END                     >                                 >\n';
net  =  '  LIST_NEURONS:		        >       List of Neurons           >\n';
nnm  =  '   %-6s                   >  Neuron''s name                  >\n';
fnm  =  '   %-24s >  File Name                      >\n';
clr  =  '   %-6s                   >  Color name                     >\n';
cst  =  '  CHEMSYN:                  >  Chemical synapse          >\n';
pos  =  '   %-6s                   >  Name of postsynaptic neuron    >\n';
pre  =  '   %-6s                   >  Name of presynaptic neuron     >\n';
typ  =  '   %-5s                    >  type of synapse                >\n';
est  =  '  ELCTRCPL:                 >       Electrical coupling       >\n';

nstr = [sbd,nnm,fnm,clr];
cstr = [sbd,pos,pre,typ,fnm,clr];
estr = [sbd,pos,pre,fnm,clr];

txt = [head,sbr,net];
nn = size(neurons,1);
for n=1:nn
    if size(neurons,2)==3
        txt = sprintf([txt,nstr],neurons(n,:));
    else
        txt = sprintf([txt,nstr],[neurons(n,:),"green"]);
    end
end
txt = sprintf([txt,sbd,edd,sbr]);

if nargin>3 && ~isempty(cs)
    txt = sprintf([txt,'\n',sbr,cst]);
    cs(cs=='fe') = "f_exc";
    cs(cs=='fi') = "f_inh";
    cs(cs=='se') = "s_exc";
    cs(cs=='si') = "s_inh";
    color = ["red"     ,"cyan";
              "magenta","blue"];
    choos = ["f_exc", "f_inh";
             "s_exc", "s_inh"];
    for p=1:nn
        for o=1:nn
            for i=1:size(cs,3)
                if cs(p,o,i)~=""
                    cnm = [comp 'cs/' , neurons{p,1} , '_2_' , neurons{o,1} ,'_', cs{p,o,i} , '.cs'];
                    txt = sprintf([txt,cstr], neurons{o,1}, neurons{p,1}, cs{p,o,i}, cnm, color{choos==cs{p,o,i}});
                end
            end
        end
    end
    txt = sprintf([txt,sbd,edd,sbr]);
end

if nargin>4 && ~isempty(es)
    txt = sprintf([txt,'\n',sbr,est]);
    for p=1:nn
        for o=1:nn
            if es(p,o) && p<o
                enm = [comp 'es/' , neurons{p,1} , '_2_' , neurons{o,1} , '.es'];
                txt = sprintf([txt,estr], neurons{o,1}, neurons{p,1}, enm, 'white');
            end
        end
    end
    txt = sprintf([txt,sbd,edd,sbr]);
end
txt = sprintf([txt,'END\n']);

fid = fopen(filenm,'w');
fprintf(fid,'%s',txt);
fclose(fid);


end