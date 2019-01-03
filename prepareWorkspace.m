function prepareWorkspace(level)
% PREPAREWORKSPACE A function to run every time before working on the
% project. 
% ATTENTION: Always make sure that che current directory is the base 
%               directory of the project.
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

% Check if the current directory is right.
if ~isdir('./src') || ~isdir('./src/Level 1') || ~isdir('./data')
    error('Change the current directory to the one at the root of the project.');
end

% If the execution reaches here. The current directory is probably the
% right one.

% Remove all the levels from the path to avoid conflicts.
% Suppress 'MATLAB:rmpath:DirNotFound' warning that rmpath might throw.
warning('off', 'MATLAB:rmpath:DirNotFound');

rmpath('src/Level 1');
rmpath('src/Level 2');
rmpath('src/Level 3');

% Turn 'MATLAB:rmpath:DirNotFound' warning on again.
warning('on', 'MATLAB:rmpath:DirNotFound');

% Prepare path for each case:
addpath('data');
addpath('src');

if level == 1
    addpath('src/Level 1');
elseif level == 2
    addpath('src/Level 2');
elseif level == 3
    addpath('src/huffman');
    addpath('src/Level 3');
end

end