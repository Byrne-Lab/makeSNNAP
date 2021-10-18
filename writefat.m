function writefat(OS,filenm,tau,xt,A)
% Writes a fAt SNNAP file.  Tau can be a scalar or a 2x1 vector for the u1
% and u2 parameters. xt is optional file name for Xt file.  Default is an
% Xt file with same name as filenm in the cs folder.
% INPUT:
% OS =      operating system (win or mac)
% filenm =  full name and path of file. Extension recommended but not required.
% tau =     the time constant of synapse. Either scalar or vector with length
%           of two.
% xt =      Name and path of XT file.  Optional.
% A =       Voltage-dependence. Only add if fAvt.


comp = '';
if strcmpi(OS,'win')
    comp = '../';
end

ext = '.fAt';
if nargin==5 && ~isempty(A) && A || strcmpi(filenm(end-length(ext)+1:end),'.fAvt')
    ext = '.fAvt';  
    A = true;
end

if ~strcmpi(filenm(end-length(ext)+1:end),ext)
    filenm = [filenm, ext];
end

if strcmp(filenm(end-length(ext)+1:end),lower(ext)) %#ok<STCI>
    filenm = [filenm(1:end-4), ext];
end

[~,name] = fileparts(filenm);

if ~exist(['template' ext],'file')
    error(['Template ' ext ' file not found in cs folder'])
end

fid = fopen(['template' ext]);
fline = strings(0,1);
option = length(tau)+2;
cnt = inf;
while 1==1
    tline = fgets(fid);
    if tline==-1;break;end
    
    if contains(tline,['option' num2str(option)])
        cnt = 1;
    end
    
    if strcmp(ext,'.fAvt')
        if isstring(A)
            tline = replace(tline,'atip', A{1});
        elseif ischar(A)
            tline = replace(tline,'atip', A);
        else
            tline = replace(tline,'atip',[comp 'cs/' name '.A']);
        end
    end
    
    
    if cnt<=option
        tline(1) = ' ';
        if nargin<4 || isempty(xt)
            tline = replace(tline,'xtip',[comp 'cs/' name '.Xt']);
        else
            tline = replace(tline,'xtip',xt);
        end
        tline = replace(tline,'u1ip',num2str(tau(1)));
        if option==4
            tline = replace(tline,'u2ip',num2str(tau(2)));
        end
    end
    cnt = cnt+1;
    
    fline = [fline ; string(tline)]; %#ok<AGROW>
end
fclose(fid);

fid = fopen(filenm,'w');
fprintf(fid,'%s',fline);
fclose(fid);



end