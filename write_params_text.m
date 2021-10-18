function makebatch(fname)



parLabel = 'B4_gleak'; % Descriptive label to be included in file name.

range = [1 15];

params = [0.1*logspace(-1,1,15)'];% (0.15:-0.01:0.05)' (0.15:-0.01:0.05)'];
targets = params;

parList = {'/B4/B4_leak.vgd'};
parNum = [1];%2 3];
IvdNumList = [0];%0 0]; % Parameter to be changed for each iteration. Should be 0 for leak conductances and first coupling conductances (first value) and 1 for second coupling conductances (second value). This is because the second coupling conductance is just changing the second value on the same .es file. .es files have coupling conductances for both directions, which are being changed simultaneously here.
paramsBatchOut = [];
targetsBatchOut = [];

    str = ['        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' newline...
        '        >>   Batch job file: *.bch      >>' newline...
        '        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' newline newline newline];
for C = 1:numel(parNum)
    
    itr = 0;
    parCount = 0;
    
    str = [str '>----------------------->------------------------------->' newline...
        '	PARAMETER:	>	One Parameter		>' newline];
    str = [str '>----------------------->------------------------------->' newline...
        parList{parNum(C)} '	>  File containing the param	>' newline...
'>----------------------->------------------------------->' newline...
'	FMU		>  File type is formula		>' newline...
'>----------------------->------------------------------->' newline...
'	Ivd:		> keyword in formula file	>' newline...
'	' num2str(IvdNumList(C)) '		> which parameter under keyword	>' newline...
'>----------------------->------------------------------->' newline...
'	0		>	Manual=0, Auto=1	>' newline...
'>----------------------->------------------------------->' newline...
'	PARNUMREPLACE		>   number of parameter values	>' newline];
    for A = 1:size(params,1)
        for B = 1:size(params,3)
            if isnan(params(A,parNum(C),B))
                continue
            else
                itr = itr + 1;
                if ~((itr < range(1)) || (itr > range(2)))
                str = [str ['>----------------------->------------------------------->' newline...
                    num2str(params(A,parNum(C),B),15) '	>	One value		>' newline...
                    ]];
                paramsBatchOut = [paramsBatchOut params(A,parNum(C),B)]; % Just for sanity check.
                targetsBatchOut = [targetsBatchOut targets(A,parNum(C),B)];
                parCount = parCount + 1;
                end                
            end
        end
    end
    
    str = [str '>----------------------->------------------------------->' newline...
        newline newline];
    str = strrep(str,'PARNUMREPLACE',num2str(parCount));
    disp([parList{parNum(C)} ' has ' num2str(parCount) ' parameters.'])
end
fid=fopen(fname,'w');
fprintf(a,str);

fclose(fid)
end