function writext(filenm,tau,tr)
% Writes a Xt SNNAP file.  Tau is a matrix containing the depression time
% constant and the recovery time constant.  Tr is whether you want
% neurotransmitter modification (optional logical).  Psm is whether you want
% postsynaptic depression (optional, logical).

if ~strcmp(filenm(end-2:end),'.Xt')
    filenm = [filenm, '.Xt'];
end

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: Xt		    >>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

sbr  =  '>------------------------------->--------------------------------------->\n';
brk	 =  '>                               >                                       >\n';
tt1	 =  '>    1    >  Xt=1          pre is spiking      (1)                      >\n';
tt2	 =  '>    2    >  Xt=TR         pre is spiking      (2)                      >\n';
tt3	 =  '>    3    >  Xt=PSM        pre is spiking      (3)                      >\n';
tt4	 =  '>    4    >  Xt=TR x PSM   pre is spiking      (4)                      >\n';
tto	 =  '>         >      0         pre is not spiking                           >\n';

head2 =['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
		'PSM:>    Postsynaptic depression                              >\n',...
		'    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n'];
    
psm  = ['>  1     >               +--                                  >\n',...
        '>  %.3f  >ud< 	>		  | -PSM/ud	         pre is 	       >\n',...
        '>  %.3f  >ur<	>		  |		             spiking	       >\n',...
        '>        >     dPSM/dt= <            (1)                      >\n',...
        '>        >               |                                    >\n',...
        '>        >               | (1 - PSM)/ur     pre is            >\n',...
        '>        >               +--                not spiking       >\n']; 

if nargin==1 || (nargin==2 && isempty(tau)) || (nargin==3 && isempty(tau) && ~tr)
    choose = 1;
    tt1(1) = ' ';
elseif nargin==2 || (nargin==3 && (~tr || isnan(tr) || isempty(tr)))
    if isscalar(tau)
        error('Tau must have length of 2')
    end
    choose = 3;
    tt3(1) = ' ';
    psm(1) = ' ';
    psm = replace(psm,'\n>','\n ');
elseif nargin==3 && isempty(tau) && tr
    choose = 2;
    tt2(1) = ' ';
else
    if isscalar(tau)
        error('Tau must have length of 2')
    end
    choose = 4;
    tt4(1) = ' ';
    psm(1) = ' ';
    psm = replace(psm,'\n>','\n ');
end   

txt = [head,'Xt:\n\n',sbr,tt1,tto,brk,...
                      sbr,tt2,tto,brk,...
                      sbr,tt3,tto,brk,...
                      sbr,tt4,tto,brk,...
                      sbr,'\n',head2,sbr,psm,sbr,'END:\n'];

fid = fopen(filenm,'w');
if choose==1 || choose==2
    fprintf(fid,txt,nan,nan);
else
    fprintf(fid,txt,tau);
end
fclose(fid);

end