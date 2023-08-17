function writebatch(fname,parList,keyword,paridx,values)
% This function writes a batch file for snnap
%
% INPUT:
% fname = name of the batch file you are creating.
% parList = character or string array of the file contianing the parameter to be modified
% keyword = the part of the equation including the parameter. Must be same length as parList, options:
%           Ivd, Ics, Ies, ssA,tA, ssB, tB use empty strings as
%           placeholders for treatment files.
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
%           if writing a batch file for treatmens, the paridx should be 3xN
%           matrix.  The first row is type of treamtent 0 = current
%           injection, 1 = modulatory tr, 2 = vclamp, 3 = current clamp.
%           2nd row is which injection in the treatment file (e.g., 1st,
%           2nd, 3rd).  Third row is whether to modify the start=0, stop=1,
%           magnitude=2.  
% values  = vector, 2d array with nan placeholders or cell array, each row idicates iteration, each column
%           coresponds to parameter.  For cell array, each cell corresponds
%           to each parameter.  Trailing nan placeholders are not necessary for cell
%           arrays.
%
% EXAMPLES:
% writebatch('C:\Users\cneveu\Documents\MATLAB\makeSNNAP\test.bch','../B51/B51a_Na.vdg',3,1:3)
% writebatch('C:\Users\cneveu\Documents\MATLAB\makeSNNAP\test.bch',["../B51/B51a_Na.vdg","../cs/B4_2_B51s_f_inh.cs"],["Ivd","Ics"],[3 2],{1:3,0.5:0.125:1})
% idx for these parameters
% ppnm = ["An","h","s","p",  "tmx","tmin","th1","ts1","tp1","th2","ts2","tp2"];
% ppidx =[ 0  , 1,  2 , 3 ,   0,     1   ,  2  ,  3  ,  4   , 5  ,  6  ,  7  ];


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

fext = [".vdg", ".cs", ".es" ,".A",".B",".trt"];
for C = 1:length(parList)
    keyidx = contains(fext(1,:),regexp(parList{C},'[.]\w+','match'));
    if ~any(keyidx)
        error(['parList(' num2str(C) ') has an invalid or nonexistent file extension'])
    end
%     key = keyops{2,keyidx};
    itr = 0;
    parCount = 0;
    
    str = [str '>----------------------->------------------------------->' newline...
               '	PARAMETER:	>	One Parameter		>' newline];
    str = [str '>----------------------->------------------------------->' newline...
        parList{C} '	>  File containing the param	>' newline...
                '>----------------------->------------------------------->' newline];
            
            
    if contains(parList{C},'.trt')
    str = [str                  '	TRT		>  File type is treatment		>' newline...
                '>----------------------->------------------------------->' newline...
                '	' num2str(paridx(1,C)) '		> cinj=0,minj=1,vclmp=2,iclmp=3	>' newline...
                '	' num2str(paridx(2,C)) '		> which inject start from 0	>' newline...
                '	' num2str(paridx(3,C)) '		> start=0, stop=1, magn=2	>' newline];
    else
    str = [str                  '	FMU		>  File type is formula		>' newline...
                '>----------------------->------------------------------->' newline...
                '	' keyword{1,C} ':		> keyword in formula file	>' newline...
                '	' num2str(paridx(1,C)) '		> which parameter under keyword	>' newline];
    end
    
    
    str = [str  '>----------------------->------------------------------->' newline...
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