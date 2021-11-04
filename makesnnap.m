function makesnnap(OS,fname)
% This is the main function for creating SNNAP files from windows Excel
% spreadsheet.
% INPUT:
% OS    = the operating system that will run the SNNAP simulation 'win' or 'mac'
% fname = the path of the spreadsheet that contains the network
% EXAMPLE:
% makesnnap('win','C:\Users\cneveu\Desktop\modeling\toy\11neuron.xlsx')

if nargin<2
    [fnm,folder] = uigetfile('*.xlsx','Select Excel network file', 'MultiSelect', 'off');
    if ~ischar(fnm)
        disp('Must select file or provide file name')
        return
    end
    fname = fullfile(folder,fnm);
    [~,fnm,~] = fileparts(fnm);
else
    [folder,fnm] = fileparts(fname);
end

loc = fileparts(which('makesnnap')); % location of the makesnnap function

comp = '';
if nargin==0 || isempty(OS)
    OS = 'win';
end

if strcmpi(OS,'win')
    comp = '../';
end


tinfo = dir(fname);
if exist(fullfile(folder,[fnm '.mat']),'file')
    load(fullfile(folder,[fnm '.mat']),'ftinfo')
    
%     if (datetime(tinfo.date) - datetime(ftinfo.date))==0
%         fprintf('\n\tSNNAP files already include most recent modifications to excel spreadsheet.\n')
%         fprintf('\tConfirm spreadsheet is saved\n\n')
%         out = input('Continue(y/n)?','s');
%         if strcmpi(out,'n')            
%             return
%         end
%     end
end

ftinfo = tinfo;

fdir = dir(folder);
for f=3:length(fdir)
    if fdir(f).isdir && ~strcmpi('ous',fdir(f).name)
        sf = fullfile(folder,fdir(f).name);
        if ~contains(sf,'.git')
            try
                rmdir(sf)
            catch
                sfdir = dir(sf);
                for s=3:length(sfdir)
                    delete(fullfile(sf,sfdir(s).name))
                end
                try
                    rmdir(sf)
                catch
                    fclose all;
                    try
                        rmdir(sf)
                    catch
                        disp(['Could not remove directory: ' sf])
                        disp('Try closing out SNNAP java program then reopen')
                    end
                end
            end
        end
    elseif fdir(f).isdir && strcmpi('ous',fdir(f).name)
        sdir = dir(fullfile(folder,fdir(f).name));
        for s=3:length(sdir)
            if contains(sdir(s).name,'.mne')
                delete(fullfile(sdir(s).folder,sdir(s).name))
            end
        end
    end
end



% get network information
[~,~,neu] = xlsread(fname,'Neu');
sidx = cellfun(@(x) ~any(isnan(x)),neu(4:end,2));
idx = [false;false; sidx];
sidx = false(size(idx,1)-1,1);
sidx(3:2:sum(idx)*2+1) = true;
nname = string(neu([false;idx],2));
tempn = string(neu([false;idx],3));

[~,~,csgp] = xlsread(fname,'cs_g');
csg = strings(sum(idx),sum(idx),2);
csg(:,:,1) = csgp([sidx;false],idx);
csg(:,:,2) = csgp([false;sidx],idx);
csg = double(csg);

[~,~,csep] = xlsread(fname,'cs_E');
cse = strings(sum(idx),sum(idx),2);
cse(:,:,1) = csep([sidx;false],idx);
cse(:,:,2) = csep([false;sidx],idx);
cse = double(cse);

[~,~,cstp] = xlsread(fname,'cs_FAT');
cst = strings(sum(idx),sum(idx),2);
cst(:,:,1) = cstp([sidx;false],idx);
cst(:,:,2) = cstp([false;sidx],idx);
cst = double(cst);

mis = cat(4, isnan(csg) & ~isnan(cse) & ~isnan(cst),...
            ~isnan(csg) &  isnan(cse) & ~isnan(cst),...
            ~isnan(csg) & ~isnan(cse) &  isnan(cst),...
            ~isnan(csg) &  isnan(cse) &  isnan(cst),...
             isnan(csg) & ~isnan(cse) &  isnan(cst),...
             isnan(csg) &  isnan(cse) & ~isnan(cst));
   
    
%% checking for potential errors in the synapse parameters
erm = {'g ','E ','fAt ','E and fAt ', 'g and fAt ','g and E '};
stopf = false;
errstr = strings(0,1);
for m=1:6
    for i=1:2
        [mrow,mcol] = find(mis(:,:,i,m));
        for s=1:length(mrow)
            errstr = [errstr ;string(['Synapse ' num2str(i) ' of ' nname{mrow(s)} '->' nname{mcol(s)} ' is missing ' erm{m}])];%#ok<AGROW>
            stopf = true;
        end
    end
end

fats = string(cstp(:,find(string(cstp(1,:))=="taus")-1));
fats = fats(~ismissing(fats) & fats~="");
fats = str2double(fats);
saidx = find(sidx,1,'first'):find(sidx,1,'last');
% sfats = string(cstp(saidx,idx));


nidx = find(idx);
for p=saidx
    for o=nidx'
        synidx = cstp{p,o};
        if isnan(synidx);continue;end
        nnidx = 0;
        addstr = '1st';
        if mod(p,2)==0
            nnidx = 1;
            addstr = '2nd';
        end
        pneu = cstp{p-nnidx,2}; 
        tauidx = string(cstp(1,:))=="taus";
        if ~any(fats==synidx)
            stopf = true;
            errstr = [errstr ;string(['In cs_FAT tab, the ' addstr ' ' pneu '->'  cstp{2,o}...
                      ' synapse contains an index (' num2str(synidx)...
                      ') not present in the FAT parameter table (on right)'])]; %#ok<AGROW>
        elseif isnan(cstp{synidx+2,tauidx})
            stopf = true;
            errstr = [errstr ;string(['In cs_FAT tab, the ' addstr ' ' pneu '->'  cstp{2,o}...
                      ' synapse contains an index (' num2str(synidx)...
                      ') that doesn''t have u1 specified in the FAT parameter table (on right)'])];%#ok<AGROW>
        end 
    end
end

if stopf
    error(join(errstr,newline))
end
%%

[~,~,esg] = xlsread(fname,'es');
esg = cell2mat(esg(idx,idx));

idxf =  find(cellfun(@(x) strcmpi('taus',x) | strcmpi('facilitation',x) ,cstp(1,:)));%'taus'
idxt = ~cellfun(@isempty, cstp(:,idxf(1)-1));
idxt(1:2) = false;
csp = cstp( idxt, idxf(1):idxf(2)+1 );
ionf = string(cstp(3:end,idxf(2)));
csp(:,9) = mat2cell(nan(size(csp,1),1),ones(size(csp,1),1));
csp = cell2mat(csp);


%% write neuron files
nn = length(nname);
vfiles = string(neu(1:2,:));
vdgn = vfiles(:,5:end);
vdg = find(~ismissing(vdgn(1,:)) & vdgn(1,:)~='File');

[irow,~] = find(string(neu)=='Ion pools');
iidx = find(~ismissing(string(neu(irow,:))));
ion = string(neu(irow+2:end,iidx(1)+1:iidx(2)-2));
c2i = string(neu(irow+2:end,iidx(2)+1:iidx(3)-3));
i2c = string(neu(irow+2:end,iidx(3)+1:iidx(4)-2));
vinit = string(neu(irow+2:end,iidx(4)+1));

vfiles = fillmissing(vfiles,'previous',2);
vfiles = join(vfiles,'.',1);
vfiles = vfiles(5:end);
param = cell2mat(neu([false;idx],5:end));
evdg = ~isnan(param(:,vdg));
pnm = string(neu(3,5:end));
cm = cell2mat(neu([false;idx],4));
for n=1:nn
    disp(nname{n})
    fnname = fullfile(folder,nname{n});
    if exist(fnname,'dir')
        rmdir(fnname,'s');
    end
    if ismissing(tempn(n))     
        mkdir(fnname)
        lion = sum(find(~ismissing(ion(n,:)),1,'last'));
        lc2i = sum(find(~ismissing(c2i(n,:)),1,'last'));
        li2c = sum(find(~ismissing(i2c(n,:)),1,'last'));
        
        nionf = ionf(cst(n,~isnan(cst(n,:,:))));
        nionf(ismissing(nionf)) = [];
        nionf = unique(nionf);
        if ~isempty(nionf)
            ions = ion(n,1:3:size(ion,2));
            ions(ismissing(ions)) = [];
            ionthere = arrayfun(@(x) any(ions==x),nionf);
            if any(~ionthere)
                error([ nname{n} ' does not contain the ion/messenger specified in cs_FAT sheet for one of its synapses.'])
            end
        end
        
        
        if length(nionf)>1
            error(['Only one pool can regulate synapses for each neuron.  ' nname{n} ' has more than one.  Change in cs_FAT sheet.'])
        elseif isscalar(nionf)
            tr = [nionf "tr"];
        else
            tr = [];
        end
        
        writeneu(OS,fullfile(fnname,[nname{n} '.neu']),str2double(vinit{n}),cm(n), vdgn(1,vdg(evdg(n,:))),...
                  ion(n,1:3:lion),[c2i(n,1:2:lc2i)' c2i(n,2:2:lc2i)'],...
                  [i2c(n,1:7:li2c)'  i2c(n,2:7:li2c)'],[],[],tr);
        % make ion pool    
        for i=1:3:lion
            txt = fileread(fullfile(loc,'template.ion'));
            txt = replace(txt,'aK1',ion{n,i+1});
            txt = replace(txt,'aK2',ion{n,i+2});
            fid = fopen(fullfile(fnname,[nname{n} '_' ion{n,i} '.ion']),'w');
            fprintf(fid,'%s',txt);
            fclose(fid);
        end
        % make fBR file
        for i=1:7:li2c
            fnmm = fullfile(fnname,[i2c{n,i} '_2_' i2c{n,i+1}]);
            if ~exist([fnmm '.fBR'],'file')
                writefbr([fnmm '.fBR'],double(i2c(n,i+2)),...
                    double(i2c(n,i+3)), double(i2c(n,i+4:i+5)), double(i2c(n,i+6)))
            else
                writefbr([fnmm '2.fBR'],double(i2c(n,i+2)),...
                    double(i2c(n,i+3)), double(i2c(n,i+4:i+5)), double(i2c(n,i+6)))
            end
        end
        
        for v=vdg   
            if ~isnan(param(n,v))
                newname = fullfile(fnname, [nname{n} '_' vdgn{1,v} '.']);
                if strcmpi(vdgn{1,v},'leak')
                    writevdg(OS,[newname 'vdg'],5,param(n,v),param(n,v+1))
                else
                    if ~isnan(param(n,v+16)) && ~isnan(param(n,v+3))
                        writeAB([newname 'A'],param(n,v+(3:14)))
                        bvals = param(n,v+(15:26));
                        if isnan(bvals(1));bvals(1) = 0;end
%                         if contains(newname,'B31rs_Ka');keyboard;end
                        writeAB([newname 'B'],bvals)
                        writevdg(OS,[newname 'vdg'],1,param(n,v),param(n,v+2),param(n,v+1))
                    elseif ~isnan(param(n,v+3))
                        writeAB([newname 'A'],param(n,v+(3:14)))
                        writevdg(OS,[newname 'vdg'],3,param(n,v),param(n,v+2),param(n,v+1))
                    else
                        writevdg(OS,[newname 'vdg'],5,param(n,v),param(n,v+2))
                    end
                end
            end
        end  
    else
        newneuron(fnname,fullfile(folder, tempn{n}))
        midx = find(~isnan(param(n,:)));
        for p=midx
            newname = fullfile(fnname, [nname{n} '_' vfiles{p}]);
            txt = fileread(newname);
            rstr = ['[-]*\d*[.]*\d+(?=\s+>\s*\S*\s*' pnm{p} '\s*<)'];
            txt = regexprep(txt,rstr,num2str(param(n,p)));
            fid = fopen(newname,'w');
            fprintf(fid,'%s',txt);
            fclose(fid);
        end
    end
end
disp('neuron files written')


cstp = cst;
if any(~isnan(cstp(:)))
    cstp(~isnan(cstp)) = csp(cstp(~isnan(cstp)),1);
else
    cstp(:) = 1;
end


css = strings(size(cse));
slow = cstp>0.1;
inh = cse<-60;
css(~slow & inh & ~isnan(cse)) = "f_inh";
css(~slow & ~inh & ~isnan(cse)) = "f_exc";
css(slow & inh & ~isnan(cse)) = "s_inh";
css(slow & ~inh & ~isnan(cse)) = "s_exc";



nstr = [nname, join([repelem(string(comp),nn,1),nname,repelem("/",nn,1),nname,repelem(".neu",nn,1)],'')];

fldr = ["ntw","R","smu","ous","trt","es"];
for f=1:length(fldr)
    if ~exist(fullfile(folder, fldr{f}),'dir')
        mkdir(fullfile(folder,fldr{f}));
    end
end


writentw(OS,fullfile(folder, 'ntw',[fnm '.ntw']),nstr,css,~isnan(esg) & esg~=0);

%% write synapse files
tms = 'fs';
ems = ["exc", "inh"];
mkdir(fullfile(folder,'cs'));
for p=1:nn
    for o=1:nn
        for i=1:2
            if ~isnan(csg(p,o,i))
                iff = csp(cst(p,o,i),1)>0.1;
                exc = cse(p,o,i)<-60;
                name = [nname{p} '_2_' nname{o} '_' tms(iff+1) '_' ems{exc+1} ];
                us = csp(cst(p,o,i),1:2);
                A = csp(cst(p,o,i),5:8);
                writefat(OS,fullfile(folder, 'cs',name),us(~isnan(us)),'',any(~isnan(A)))
                fext = '.fAt';
                if any(~isnan(A))
                    writeAB(fullfile(folder, 'cs', [name '.A']),[0,A])
                    fext = '.fAvt';
                end
                writecs(OS,fullfile(folder, 'cs',[ name '.cs']),csg(p,o,i),cse(p,o,i),...
                           [comp 'cs/' name fext]);

                usd = csp(cst(p,o,i),3:4);
                tr = ionf(cst(p,o,i));
                
                writext(fullfile(folder, 'cs', [name '.Xt']),usd(~isnan(usd)),isstring(tr) && ~ismissing(tr))
                if isstring(tr) && ~ismissing(tr)
                    copyfile(fullfile(loc,'template.tr'),fullfile(folder,'cs',[nname{p} '.tr']));
                    writefbr(fullfile(folder,nname{p},[nname{p} '_TR.fBR']),2,1, csp(cst(p,o,i),10) )
                end
            end
    %         if p==4 && o==8;keyboard;end
            if p<o && all([esg(p,o),esg(o,p)]~=0) && all(~isnan([esg(p,o),esg(o,p)]))
                name = [nname{p} '_2_' nname{o}];
                writees(OS,fullfile(folder, 'es', [name '.es']),[esg(p,o),esg(o,p)])
            end
        end
    end
end
disp('synapse files written')
   
%% write noise(R) files
[noise] = xlsread(fname,'noise');

files = dir(folder);

regex = join(['(' join(nname','|') ')'],'');
for f=1:length(files)
    fn = [files(f).folder '\' files(f).name];
    if files(f).isdir && ~isempty(regexp(files(f).name,regex,'once'))
        disp(['Making Rs for ' files(f).name])
        makeRs(fn,noise(1,1),noise(1,2),noise(1,3),false) 
    elseif files(f).isdir && strcmp(files(f).name,'cs')
        disp(['Making Rs for ' files(f).name])
        makeRs(fn,noise(2,1),noise(2,2),noise(2,3),false) 
    elseif files(f).isdir && strcmp(files(f).name,'es')
        disp(['Making Rs for ' files(f).name])
        makeRs(fn,noise(3,1),noise(3,2),noise(3,3),false) 
    end
end


%% write simulation files
[~,sheets]=xlsfinfo(fname);
sims = find(cellfun(@(x) contains(x,'.smu'),sheets));
for s=1:length(sims)
    disp(['Making ' sheets{sims(s)}])
    [~,~,simi] = xlsread(fname,sheets{sims(s)});
    ssimi = string(simi);
    writesmu(fullfile(folder, 'smu', [simi{2,3} '.smu']),simi{3,3},simi{4,3},simi{2,5},...
              simi{3,5},simi{4,5},[comp 'ntw/' fnm '.ntw'],[comp 'ous/' simi{2,3} '.ous'],[comp 'trt/' simi{2,3} '.trt'])
%     oidx = find(contains(ssimi(:,1),'graph'));
%     vgraph = ssimi(oidx+3:oidx+18,:);%<---fix
    
    vgraph = ssimi(mod(double(ssimi(:,1)),1)==0,:);
    mis = ~ismissing(vgraph);
    vgraph = vgraph(mis(:,1),any(mis,1));
    vgraph(ismissing(vgraph)) = "";
    vout = strings(0,1);
    for g=1:size(vgraph,1)
        for v=2:5:size(vgraph,2)
            if ~ismissing(vgraph(g,v)) && vgraph(g,v)~=""
                vgraph{g,v} = makevar(vgraph{g,v});
                if ~contains(vgraph{g,v},'time')
                    vout = [vout;vgraph{g,v}];
                end
            end
        end
    end
    
    [row,col] = find(contains(ssimi,'output variables'));
    if ~strcmpi(simi{row+1,col},'all')
        vout = string(simi(row+1:end,col));
        vout(ismissing(vout)) = [];
        for o=1:length(vout)
            vout{o} = makevar(vout{o}); 
        end
    end  
    writeous(fullfile(folder, 'ous', [simi{2,3} '.ous']),vgraph,vout')
    
    [irow,icol] = find(contains(ssimi,'Current injection'));
    istim = ssimi(irow+2:end,icol:icol+3);
    [vrow,vcol] = find(contains(ssimi,'Voltage clamp'));
    vstim = ssimi(vrow+2:end,vcol:vcol+3);
    
    istim(ismissing(istim(:,1)),:) = [];
    vstim(ismissing(vstim(:,1)),:) = [];
    
    writetrt(fullfile(folder, 'trt', [simi{2,3} '.trt']),istim,vstim)
end


%% write batch files

ppnm = ["An","h","s","p",  "tmx","tmin","th1","ts1","tp1","th2","ts2","tp2"];
ppidx =[ 0  , 1,  2 , 3 ,   0,     1   ,  2  ,  3  ,  4   , 5  ,  6  ,  7  ];


bchs = find(cellfun(@(x) contains(x,'.bch'),sheets));
for s=1:length(bchs)
    disp(['Making ' sheets{bchs(s)}])
    [~,~,bcht] = xlsread(fname,sheets{bchs(s)});
    ionc = find(string(bcht(:,1))=="Ion Channel Batch Parameters");
    sync = find(string(bcht(:,1))=="Synapse Batch Parameters");
    ionpn = bcht(ionc+2:sync-3,1:4);
    idx = cellfun(@ischar,ionpn(:,1));
    ionpn = ionpn(idx,:);
    ionpp = bcht(ionc+2:sync-3,5:24);
    idx2 = ~cellfun(@isnan,ionpp(1,:));
    ionpp = double(string(ionpp(idx,idx2)));
    ionps = join([repmat({'..'},size(ionpn,1),1), ionpn(:,1:2)],'/');
    ionps = string(join([ionps,ionpn(:,3)],'.')'); % name of the file containing parameters
    idxp = ppidx(cellfun(@(x) find(ppnm==x),ionpn(:,4)));% index of the parameters
    writebatch(fullfile(folder,'smu',sheets{bchs(s)}),ionps, idxp , ionpp')
end


csgi = csg;
csgi(cse<0) = csg(cse<0)*-1;

save(fullfile(folder,replace(fnm,'.xlsx','')),'csg','cse','esg','cst','csp','csgi','param','cm','ion','i2c','c2i','ftinfo')   

% neuron_model;



