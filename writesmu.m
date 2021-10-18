function writesmu(filenm,dur,step,graph,store,method,ntw,ous,trt)
% This function writes a smu file for SNNAP.
%
% INPUT:
% filenm = name and path to save file. 
% dur    = duration of the simulation (s)
% step   = stepsize (i think in seconds)
% graph  = logical whether to display graph
% store  = store results of simulation in smu.out
% method = method of integration for the simulation, typically 1.
%          1 = Euler, 2 = RK, 3 = RKQC
% ntw    = name and path of (.ntw) network
% ous    = name and path of (.ous) output file
% trt    = name and path of treatment (.trt) file
%
% EXAMPLE:
% fn = 'C:\Users\cneveu\Desktop\modeling\toy\smu\play.smu';
% writesmu(fn,10,0.0001,1,1,1,'../ntw/play.ntw','../ous/play.ous','../trt/play.trt')


head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: smu		>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

sbr = '>-------------------------->------------------------------->\n';
sbd = '>..........................>...............................>\n';
lgg = ' LOGICAL_NAME:             >   Name of Network             >\n';
nmn = ' network                   > The name of the network       >\n';
tmn = '  TIMING:                  > Timing information in seconds >\n';
tm0 = '    0.0                    > What value to assign to the   >\n';
vmt = '                           > variable "time" at time=0     >\n';
drr = '   %.1f                    > When to stop the simulation   >\n';
stp = '   %.5f                 > Step-size (h)                 >\n';
onl = ' ON_LINE_GRAPH:            > On-line graph                 >\n';
yno = '      %u                    > 1 for yes, 0 for no           >\n';
str = '  STORE_RESULTS:		   >  Store results                >\n';
int = '  INT_METHOD:              > Integration method            >\n';
chs =['     %u                     > 1 for Euler method            >\n',...
      '                           > 2 for RK                      >\n',...
      '                           > 3 for RKQC                    >\n'];
ntt = '  NETWORK:                 > structure of network          >\n';
nts = '  %-24s > the name of the file    >\n';
ott = '  OUTPUT_SETUP:            > list of variables for output  >\n';
ttt = '  TREATMENTS:              > External treatments           >\n';

txt = [head, sbr,lgg,sbd,nmn,sbr,'\n',...
       sbr,tmn,sbd,tm0,vmt,sbd,drr,sbd,stp,sbr,'\n',...
       sbr,onl,sbd,yno,sbr,'\n',...
       sbr,str,sbd,yno,sbr,'\n',...
       sbr,int,sbd,chs,sbr,'\n',...
       sbr,ntt,sbd,nts,sbr,'\n',...
       sbr,ott,sbd,nts,sbr,'\n',...
       sbr,ttt,sbd,nts,sbr,'\n'];

fid = fopen(filenm,'w');
fprintf(fid,txt,dur,step,graph,store,method,ntw,ous,trt);
fclose(fid);
end