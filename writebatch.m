function writebatch(fname,parList,paridx,values)
% This function writes a batch file for snnap
%
% INPUT:
% parList = character or string array of the file contianing the parameter to be modified
% paridx  = the parameter index of the file. Either scalar or vector corresponding to parList 
%           Note: some files may not have R file as paremeter so I think
%           the index should be changed accordingly.
%             Leak vdg:0 = float           , g 
%                      1 = float           , E reversal potential 
%               Na vdg:0 = float           , gmax
%                      1 = positive intiger, p
%                      2 = float           , E reversal potential
%               cs    :0 = float           ,gmax
%                      1 = float           , E reversal potential
%               es    :0 = float           , g1 post -> pre
%                      1 = float           , g2 pre -> post
% values  = vector, 2d array with nan placeholders or cell array, each row idicates iteration, each column
%           coresponds to parameter.  For cell array, each cell corresponds
%           to each parameter.  Trailing nan placeholders are not necessary for cell
%           arrays.
%
% EXAMPLES:
% writebatch('C:\Users\cneveu\Documents\MATLAB\makeSNNAP\test.bch','../B51/B51a_Na.vdg',3,1:3)
% writebatch('C:\Users\cneveu\Documents\MATLAB\makeSNNAP\test.bch',["../B51/B51a_Na.vdg","../cs/B4_2_B51s_f_inh.cs"],[3 2],{1:3,0.5:0.125:1})



if ~strcmp(fname(end-3:end),'.bch') && ~contains(fname,'.')
    fname= [fname, '.bch'];
elseif ~strcmp(fname(end-3:end),'.bch') && contains(fname,'.')
    error('Wrong file extension')
end

    str = ['        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' newline...
        '        >>   Batch job file: *.bch      >>' newline...
        '        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' newline newline newline];
parList = string(parList);
if iscell(values)
    mxlen = max(cellfun(@length,{1:5,1,5:20;1,2,3}),[],'all');
    nval = nan(mxlen,length(parList));
    for c=1:numel(values)
        nval(1:length(values{c}),c) = values{c};
    end
    values = nval;
elseif size(values,1)==1 && size(values,2)>1
    values = values(:);% compress to the 1st dimension if vector along the 2nd
end

keyops = [".vdg", ".cs", ".es" ;...
          "Ivd" ,  "Ics", "Ies"];
for C = 1:length(parList)
    keyidx = contains(keyops(1,:),regexp(parList{C},'[.]\w+','match'));
    if ~any(keyidx)
        error(['parList(' num2str(C) ') has an invalid or nonexistent file extension'])
    end
    key = keyops{2,keyidx};
    itr = 0;
    parCount = 0;
    
    str = [str '>----------------------->------------------------------->' newline...
               '	PARAMETER:	>	One Parameter		>' newline];
    str = [str '>----------------------->------------------------------->' newline...
        parList{C} '	>  File containing the param	>' newline...
                '>----------------------->------------------------------->' newline...
                '	FMU		>  File type is formula		>' newline...
                '>----------------------->------------------------------->' newline...
                '	' key ':		> keyword in formula file	>' newline...
                '	' num2str(paridx(C)) '		> which parameter under keyword	>' newline...
                '>----------------------->------------------------------->' newline...
                '	0		>	Manual=0, Auto=1	>' newline...
                '>----------------------->------------------------------->' newline...
                '	PARNUMREPLACE		>   number of parameter values	>' newline];
    for A = 1:size(values,1)
        for B = 1:size(values,3)
            if isnan(values(A,C,B))
                continue
            else
                itr = itr + 1;
                str = [str ['>----------------------->------------------------------->' newline...
                    '\t' num2str(values(A,C,B),'%.5f') '	>	One value		>' newline...
                    ]];
                parCount = parCount + 1;          
            end
        end
    end
    
    str = [str '>----------------------->------------------------------->' newline...
        newline newline];
    str = strrep(str,'PARNUMREPLACE',num2str(parCount));
    disp([parList{C} ' has ' num2str(parCount) ' parameters.'])
end
fid=fopen(fname,'w');
fprintf(fid,str);
fclose(fid);
end