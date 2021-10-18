function writeneu(OS,filenm,init,cm,ch,ion,ch2ion,ion2ch,sm,sm2ch,tr)
% This function writes a neu file for SNNAP  
%
% INPUT: 
% filenm = name and path to save file. Include .neu in name
% init   = initial voltage of cell 
% cm     = cell capacitance (not sure right now what units) prob uF 
% ch     = string vector of conductances name. Don't include extension or 
%          path.  The assumed file path is ../neuron/neuron_channel.vdg
% ion    = string vector of ion pools, assumed name
%           ../neuron/neuron_ion.ion
% ch2ion = current to ion pool, Nx2 string array [channel,ion;channel,ion]
% ion2ch = ion regulation of current. Nx2 string array
%          [ion,channel;ion,channel]
% sm     = string vector of second messengers
% sm2ch  = Nx2 string array [sm, channel; sm, channel]
% 
%
% EXAMPLE:
% three channels
% writeneu('C:\Users\cneveu\Desktop\modeling\toy\N1\toy.neu',-70,0.0001,["Na","K","Leak"])
%
% Na and K channels feed a Na and K pools.  The Na pool regulates K and K
% regulates Na
% writeneu('C:\Users\cneveu\Desktop\modeling\toy\N1\toy.neu',-70,0.0001,...
%   ["Na","K","Leak"],["Na","K"],["Na","Na";"K","K"],["Na","K";"K","Na"])
%
% Transmitter regulates both Na and K channels
% writeneu('C:\Users\cneveu\Desktop\modeling\toy\N1\toy.neu',-70,0.0001,...
%   ["Na","K","Leak"],[],[],[],["TR"],["TR","Na";"TR","K"])

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: neu		>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

sbr  = '>---------------------------->------------------------------->\n';
hd   =[sbr,'   THRESHOLD:	  0          > Threshold for transmitter release	>\n',sbr,...
       '   SPIKDUR:	  0.003		     > Spike duration. If equal 0 then >\n',...
       '				             >  actual time when presynaptic   >\n',...
       '				             > neuronis above threshold will   >\n',...
       '				             > be measured                     >\n',sbr,...   
       '   VMINIT:	  %.1f          > Initial value of membrane potential. >\n',sbr,...
       '   CM:		    %.4f	     > Membrane capacitance.         >\n',sbr];
% ----------------------------------------------------------------------   
ttl  = '   CONDUCTANCES:             >   List of Conductances        >\n';
nam  = '    %-6s                   >  Name of Conductance          >\n';
fnm  = ' %-26s  >  File Name                    >\n';
clr  = '   %-8s                  >  Color name                   >\n';
% --------------------------------------------------------------------------
lin  = '  LIST_ION:                  >   List of Ion pools           >\n';
inm  = '	%-3s                      >  Name of Ion                  >\n';
% --------------------------------------------------------------------------
lsm  = '  LIST_SM:			   >	List of Second Messengers	        >\n';
sml  = '  %-6s                 >   Name of SM                          >\n';
% -------------------------------------------------------------------------
c2i  =['  CURRENT_TO_ION:            > List of current contributing  >\n',...
	   '                             > to ion pools                  >\n'];
% -------------------------------------------------------------------------
i2c  =['  COND_BY_ION:               >   Regulation of V-dep         >\n',...
	   '                             >   conductances by ion pools   >\n'];
% -------------------------------------------------------------------------
s2i  =['  COND_BY_SM:                >   Regulation of V-dep         >\n',...
	   '                             >   conductances by Second      >\n',...		
	   '                             >    messangers                 >\n'];
% ------------------------------------------------------------------------ 
trm  = '  TRNSMTR:                   >   Dynamics of transmitter     >\n';
tnm  = '    %-15s          >  Name of transmitter          >\n';
i2t  =['  TRNSMTR_BY_ION:            >   Regulation of transmitter   >\n',...
	   '                             >   by ion pools                >\n'];

sec  =  '        END                  >                               >\n';

[~,name] = fileparts(filenm);

txt = sprintf([head,hd,'\n\n'],init,cm);

checkit(["ion" "conductance"],name,ion2ch(:,1),ion,1)
checkit(["ion" "conductance"],name,ion2ch(:,2),ch,2)
checkit(["conductance" "ion"],name,ch2ion(:,1),ch,1)
checkit(["conductance" "ion"],name,ch2ion(:,2),ion,2)

comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

color = ["white","red","orange","cyan"];
colors = ["magenta","blue"];

if nargin>10 && ~isempty(tr)
    txt = sprintf([txt,sbr,trm,sbr]);
    txt = [txt, sprintf([tnm,fnm,clr],tr{2}, [comp 'cs/' name '.tr'],colors{1})];%'../'
    txt = [txt, sprintf([sbr,'\n\n'])];
end

txt = sprintf([txt,sbr,ttl,sbr]);

for c=1:length(ch)
    txt = [txt,sprintf([nam,fnm,clr,sbr],ch{c},[ comp name '/' name '_' ch{c} '.vdg'],'green')];%'../'
end
txt = [txt, sprintf([sec,sbr,'\n\n'])];


if nargin>5 && ~isempty(ion)
    txt = sprintf([txt,sbr,lin,sbr]);
    for i=1:length(ion)
        txt = [txt, sprintf([inm,fnm,clr,sbr],ion{i},[ comp name '/' name '_' ion{i} '.ion'],color{i})];%'../'
    end
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end

if nargin>6 && ~isempty(ch2ion)
    txt = sprintf([txt,sbr,c2i,sbr]);
    for i=1:size(ch2ion,1)
        txt = [txt, sprintf([nam,inm,clr,sbr],ch2ion{i,1},ch2ion{i,2},color{i})];
    end
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end

if nargin>7 && ~isempty(ion2ch)
    txt = sprintf([txt,sbr,i2c,sbr]);
    for i=1:size(ion2ch,1)
        if ~contains(txt,[comp name '/' ion2ch{i,1},'_2_',ion2ch{i,2} '.fBR'])%'../'
            txt = [txt, sprintf([nam,inm,fnm,clr,sbr],ion2ch{i,2},ion2ch{i,1},...
                  [comp name '/' ion2ch{i,1},'_2_',ion2ch{i,2} '.fBR'],color{i})];%'../'
        else
            txt = [txt, sprintf([nam,inm,fnm,clr,sbr],ion2ch{i,2},ion2ch{i,1},...
                  [comp name '/' ion2ch{i,1},'_2_',ion2ch{i,2} '2.fBR'],color{i})];%'../'
        end
    end
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end

if nargin>8 && ~isempty(sm)
    txt = sprintf([txt,sbr,lsm,sbr]);
    for s=1:size(sm,1)
        txt = [txt, sprintf([sml,fnm,clr,sbr],sm{s},[comp name '/' name '_' sm{s} '.sm'],colors{s})];%'../'
    end
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end

if nargin>9 && ~isempty(sm2ch)
    txt = sprintf([txt,sbr,s2i,sbr]);
    for s=1:size(sm2ch,1)
        txt = [txt, sprintf([sml,nam,fnm,clr,sbr],sm2ch{s,2},sm2ch{s,1},...
              [comp name '/' sm2ch{s,1},'_2_',sm2ch{s,2}],colors{s})];%'../'
    end
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end


if nargin>10 && ~isempty(tr)
    txt = sprintf([txt,sbr,i2t,sbr]);
    txt = [txt, sprintf([inm,fnm,clr,sbr],tr{1}, [comp name '/' name '_TR.fBR'],colors{1})];%'../'
    txt = [txt, sprintf([sec,sbr,'\n\n'])];
end

txt = [txt,sprintf('\nEND')];

fid = fopen(filenm,'w');
fprintf(fid,'%s',txt);
fclose(fid);
end

function checkit(parmn,name,item,listn,idx)
checkpool = arrayfun(@(x) ~any(listn==x),item);
errstr = strings(sum(checkpool),1);
if any(checkpool)
    cnt = 1;
    for c=1:length(checkpool)
        if checkpool(c)
            errstr{cnt} =[ 'For the ' parmn{1} '->' parmn{2} ' (in Neu tab) for neuron ' name ' the ' parmn{idx} ' ' item{c} ' was not found in ' parmn{idx} 's'];
            cnt = cnt+1;
        end
    end
    error(join(errstr,newline))
end
end