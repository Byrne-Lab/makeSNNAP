function writeous(filenm,vgraph,vout)
% This function writes a ous file for SNNAP from scratch based on a string array.
%
% INPUT:
% filenm = name and path to save file. Include .ous in name
% vgraph = the parameters for the graph as a string array.  Each row is a 
%          graph.  Additional variables to be plotted on the same graph
%          should be added along the 2nd dimension.
%                 X axis                     Y-axis #1->
%          [gain, #Xticks, minX, maxX, color, var name, #Yticks, minY,
%                        Y-axis #2
%          maxY, color,  var name, #Yticks, minY,maxY, color]
% vout   = names of the variables to be saved to file. Time is automatically included.  
% 
%
% EXAMPLE:
% Below creates a series of 200ms pulses to measure excitability in B51s.
% istim = [repelem("B51s",5)', string([(1:5)', (1:5)'+0.2, (1:5)'])];
% writetrt('C:\Users\cneveu\Desktop\DI_cpg\trt\B51exc.trt',istim,[])

% personal notes
% folder = 'C:\Users\cneveu\Desktop\modeling\DI_cpg\trt\';



vtg   =['   VAR_TO_GRAPH: 		>	List of current contributing				>\n',...
        '						>	to ion pools								>\n'];
vtf   =['	VAR_TO_FILE: 		>	List of current contributing				>\n',...
        '						>	to ion pools								>\n'];
sbr   = '>------------------------------->--------------------------------------->\n';
gax=[sbr,'	GRPH_CHNL:			>	Graph channel								>\n',sbr];
gain  = '		%-1.f				>	GAIN of Channel								>\n';
tln   = ' %-22s >	Var Name for X-axis							>\n';
minx  = '		%-3.2f        		>	 Min Value of X								>\n';
maxx  = replace(minx,'Min','Max');
name  = ' %-22s >	Var Name for Y-axis							>\n';
ntick = '		%-2.f          	>	 Number of Tic Marks						>\n';
minv  = '		%-3.3f     		>	 Min Value of Y								>\n';
maxv  = replace(minv,'Min','Max');
gclr  = '		%-6s        	>	 Color of Range								>\n';
vtfi  = ' %-26s >	VAR name                            >\n';
endg=[sbr,'	END:						>										>\n',sbr];

% Check validity of variable
param = ["V","sIex","sIlight","slightOn","sIvd_reg","sIld","sIcs","sIes",...
         "sIrs","spk","spknow","tfin_spk","Ivd","pGBI","pGBS","Gvd","A","B",...
         "ssA","tA","tB","R","IVDxREG","dA","dB","dCion","dfbr","dV","fbr",...
         "Cion","Ies","Ics","R1","R2","tfin_spk"];
regex = join(['(',join(param,'|') ')[[a-zA-Z._>\-^0-9]+\](/dt)*<{(ivr|tvr|svr)}'],'');

if exist([filenm '.mnu'],'file')
    mnutxt = fileread([filenm '.mnu']);
    mnu = true;
else
    disp('No mnu file found to verify variable existance.  Proceeding anyway.')
    mnu = false;
end

idx = 7;
while idx<=size(vgraph)
    for g=1:size(vgraph,1)
        if vgraph(g,idx)~='' || strcmp(vgraph{g,idx},'time<{ivr}')
            loc = ['Variable ' vgraph{g,idx}, ' in vgraph{' num2str(g),',',num2str(idx),'}'];

            fmt = isempty(regexp(vgraph{g,idx},regex,'once'));
            if fmt;error([loc, ' does not have proper format']);end

            per = length(strfind(vgraph{g,idx},'.'))~=4;
            if per;error([loc, ' does not have 4 periods']);end

            par = length(regexp(vgraph{g,idx},'(\[|\])'))~=2;
            if par;error([loc, ' does not two square brackets']);end

            if mnu && ~contains(mnutxt,vgraph{g,idx})
                warning([loc ' not found in mnu file'])
            end
        end
    end
    idx = idx+5;
end



txt = [sbr,vtg];

vgraph = vgraph';

for g=1:size(vgraph,2)
    nv = sum(vgraph(:,g)~='');
    gsec =     [gax, gain, tln, ntick, minx, maxx, gclr, ...
        repmat([name,ntick,minv,maxv,gclr],1,(nv-1)/5 - 1)];
    txt = [txt,gsec]; %#ok<AGROW>
end
txt = [txt,endg,'\n'];

tvar = sprintf(vtfi,'time<{ivr}');
txt = [txt,sbr,vtf,sbr,tvar,repmat(vtfi,1,length(vout)),endg,'\n','END:'];

vgraph = vgraph(vgraph(:)~='');

fid = fopen(filenm,'w');
fprintf(fid,txt,[vgraph(:)',vout]);
fclose(fid);
end
