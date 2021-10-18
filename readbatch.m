function [values, params] = readbatch(fname)
% this function reads a batch file and returns the information
% INPUT:
% fname = pathstring of file
%
% OUTPUT:
% values = float array of values of each parameter, row = iteration,
%          column = parameter
% params = string array of parameters first colum is the file of each
%          parameter, second column is keyword, third is parameter index, fourth is the
%          parameter unit e.g., g, E, A...  not tested for batch for .A or
%          .B or .fBR files.



fid = fopen(fname);

values = zeros(0,1);
params = strings(0,4);
parn = ["Ivd","Ics","Ies";...
        "gE" ,"gE" ,"gg"];
pnum = 0;
while 1==1
    tline = fgets(fid);
    if tline==-1;break;end
    
    if contains(tline,'PARAMETER')
        pnum = pnum + 1;
        cnt = 1;
    elseif contains(tline,'One value')
        values(cnt,pnum) = double(string(regexp(tline,'[0-9.]+','match')));
        cnt = cnt+1;
    elseif contains(tline,'File containing')
        out = string(regexp(tline,'\S+','match'));
        out = out(contains(out,'/') & contains(out,'.'));
        params(pnum,1) = out;
    elseif contains(tline,'keyword in formula')
        params(pnum,2) = string(regexp(tline,'(Ivd|Ics|Ies)','match'));
    elseif contains(tline,'which parameter')
        params(pnum,3) = string(regexp(tline,'[0-9.]+','match'));
        keyw = parn{2,contains(parn(1,:),params(pnum,2))};
        params(pnum,4) = keyw(double(params(pnum,3))+1);
    end
end

fclose(fid);
end