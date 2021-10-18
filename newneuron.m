function newneuron(destination,template)
% creates a new neuron folder at the specified directory using the files
% designated in the template folder.  The last item in the pathstring is
% the new neuron name.  This function is not compatable with two
% compartment models where both compartments are in the same folder.  Adds
% the corresponding R noise files.
% EXAMPLE:
% newneuron('C:\Users\cneveu\Desktop\modeling\toy\W','X')

if exist(destination,'dir')
    error('Neuron files already exists')
end

[folder, name] = fileparts(destination);
[~,tname] = fileparts(template);


copyfile(fullfile(template,'*'),destination)

files = dir(fullfile(folder,name));
for f=3:length(files)
    newname = replace(fullfile(files(f).folder,files(f).name),[tname '_'],[name '_']);
    if contains(files(f).name,'vdg') || contains(files(f).name,'neu') 
        txt = fileread(fullfile(files(f).folder,files(f).name));
        txt = replace(txt,['/R/' tname],['/R/' name]);
        txt = replace(txt,'/R/R_VDG',['/R/' replace(files(f).name(1:end-4),tname,name)]);
        txt = replace(txt,['/' tname '/' tname],['/' name '/' name]);
        txt = replace(txt,['/' tname '/'],['/' name '/']);
        fid = fopen(newname,'w');
        fprintf(fid,'%s',txt);
        fclose(fid);
        if contains(files(f).name,'neu')
            nname = replace([files(f).folder,'\',files(f).name],tname,name);
            copyfile([files(f).folder,'\',files(f).name],nname)
        end
        delete([files(f).folder,'\',files(f).name])
    elseif ~strcmp([files(f).folder,'\',files(f).name],newname)
        copyfile([files(f).folder,'\',files(f).name],newname)
        delete([files(f).folder,'\',files(f).name])
    end
end

% makeRs([folder,'\', name],10,200,10,false)


end