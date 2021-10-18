function writeR(filenm,amplitude,stepsize)
% This function creates an noise file (.R) for SNNAP


if ~strcmp(filenm(end-1:end),'.R')
    filenm = [filenm, '.R'];
end

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: R		>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

head2 =['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
		'R:  > 	 distributions	                                       >\n',...
		'    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n'];    
sbr  =  '>--------------------------->--------------------------------->\n';
spc  =  '>                           >                                 >\n';
opt1 =  '>  1		                > R=0.0                (1)        >\n';
opt2 =  '   2		                >                      (2)        >\n';
amp  =  '   %.0f       >percent<       > R = Gaussian(g, percent x g/3)  >\n';
desc =  '            >               In (g-g*percent, g+g*percent)      >\n';
step =  '   %.0f      >step size<     >  In how many steps is R renewed >\n';
spu  =  '                            >                                 >\n';

txt = [head,head2,sbr,spc,opt1,spc,sbr,spu,opt2,spu,amp,desc,spu,step,sbr,'END\n'];

fid = fopen(filenm,'w');
fprintf(fid,txt,[amplitude,stepsize]);
fclose(fid);


end