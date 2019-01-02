function prepareWorkspace(level)
% PREPAREWORKSPACE A function to run every time before working on the
% project.
%   Arguments:
%       level: The level to prepare the workspace for.
%              Possible values: 1-3 for 'Level 1', 'Level 2' and 'Level 3'
%              Current Default value: 1
%   Returns nothing.

% Check argument(s):
if ~exist('level', 'var')   ...  % It wasn't provided.
        || ~isscalar(level) ...  % It wasn't a scalar value.
        || floor(level) ~= level % It wasn't an integer
    level = 1;
    disp("Used level's default value: " + level);
end

% Prepare path for each case:
addpath('data');
addpath('src');

if level == 1
    
elseif level == 2
    
elseif level == 3
    
end

end