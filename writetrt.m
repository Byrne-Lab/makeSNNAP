function writetrt(filenm,istim,vstim)
% This function writes a trt file for SNNAP from scratch based on a string array.
% INPUT:
% filenm = name and path to save file. Include .trt in name
% istim = current stimulus with columns [name,start,stop,intensity]. Each
%         row is a new stimulus.
% vstim = voltage-clamp stimuli with same format as istim.  
% 
% NOTE:  In SNNAP, stimuli located below (higher row index) will
%        temporarily override stimuli above if occuring at same time and
%        neuron. For, example: writetrt(filename, ["B8" "1" "2" "3"], ["B8"
%        "0" "3" "-60"]) will only clamp B8 to -60 mV without injecting
%        3nA, because voltage clamps are written further down the text
%        file.  But, writetrt(filename, ["B8" "0" "3" "-1"; "B8" "1" "2"
%        "3"] ,[]) will inject a -1 nA holding current, deliver a +3nA
%        current injection for 1 sec and then -1nA for the remainder of the
%        simulation.
%
% EXAMPLE:
% Below creates a series of 200ms pulses to measure excitability in B51s.
% istim = [repelem("B51s",5)', string([(1:5)', (1:5)'+0.2, (1:5)'])];
% writetrt('C:\Users\cneveu\Desktop\DI_cpg\trt\B51exc.trt',istim,[])

% personal notes
% folder = 'C:\Users\cneveu\Desktop\modeling\DI_cpg\trt\';

head = ['    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>   modules name: trt		>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n',...
        '    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n'];

curt = '  CURNT_INJ:		    > Timing for currnt injection	>\n';
vct  = '  VCLAMP:               > Timing for V_clamping         >\n';
sbr  = '>----------------------->------------------------------->\n';
br   = '>.......................>...............................>\n';
name = '        %s             >       Name of Neuron          >\n';
tisr  = '        %.3f           >       Start injection         >\n';
tiend = '        %.3f           >       Stop injection          >\n';
tvsr  = '        %.3f           >       Start clamping          >\n';
tvend = '        %.3f           >       Stop clamping           >\n';
mag  =  '        %.3f           >       Magnitude               >\n';
sec  =  '        END             >                              >\n';

if nargin<3
    vstim = [];
end


txt = [head,sbr,curt];

istim = istim';
vstim = vstim';

isec = [br,name,br,tisr,br,tiend,br,mag];
sistim = repmat(isec,1,size(istim,2));
txt = [txt,sistim,sbr,sec,sbr,'\n'];

txt = [txt,sbr,vct];
vsec = [br,name,br,tvsr,br,tvend,br,mag];
svstim = repmat(vsec,1,size(vstim,2));
txt = [txt,svstim,sbr,sec,sbr,'\n','END'];

fid = fopen(filenm,'w');
fprintf(fid,txt,[istim,vstim]);
fclose(fid);
end
