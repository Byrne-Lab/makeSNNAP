function var = makevar(str)
% Converts a string into SNNAP variable syntax
% The syntax of str input:
% conductance = variable.conductance.neuron
% neuron      = variable.neuron
% chemical synapse = variable.pre.post.type
% electrical synapse = variable.pre.post

parts = split(str,'.');
if str(1)=='d'
    ends = '/dt<{tvr}';
else
    ends = '<{ivr}';
end

if strcmp(str,'time')
    var = 'time<{ivr}';
elseif length(parts)==4
    if contains(parts{1},'fBR','IgnoreCase',true) 
        var = [parts{1} '[' parts{3} '.' parts{2} '.' parts{4} '..]' ends];
    else
        var = [parts{1} '[' parts{3} '.>----.' parts{2} '.' parts{4} '.]' ends];
    end
elseif length(parts)==3
    var = [parts{1} '[' parts{2} '.' parts{3} '...]' ends];
    if contains(parts{1},'Ies')
        var = [parts{1} '[' parts{3} '.-^v^v^-.' parts{2} '..]' ends];
    end
else
    var = [parts{1} '[' parts{2} '....]' ends];
end





