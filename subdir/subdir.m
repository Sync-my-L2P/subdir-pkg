function varargout = subdir(varargin)
%SUBDIR Performs a recursive file search
%
% subdir
% subdir(name)
% files = subdir(...)
%
% This function performs a recursive file search.  The input and output
% format is identical to the dir function.
%
% Input variables:
%
%   name:   pathname or filename for search, can be absolute or relative
%           and wildcards (*) are allowed.  If ommitted, the files in the
%           current working directory and its child folders are returned    
%
% Output variables:
%
%   files:  m x 1 structure with the following fields:
%           name:   full filename
%           date:   modification date timestamp
%           bytes:  number of bytes allocated to the file
%           isdir:  1 if name is a directory; 0 if no
%
% Example:
%
%   >> a = subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
%
%   a = 
%
%   67x1 struct array with fields:
%       name
%       date
%       bytes
%       isdir
%
%   >> a(2)
%
%   ans = 
%
%        name: '/Applications/MATLAB73/toolbox/matlab/audiovideo/chirp.mat'
%        date: '14-Mar-2004 07:31:48'
%       bytes: 25276
%       isdir: 0
%
% See also:
%
%   dir

% Copyright 2006 Kelly Kearney


%---------------------------
% Get folder and filter
%---------------------------

% Check number of input and output arguments
narginchk(0,1);
nargoutchk(0,1);

if nargin == 0
    % List all files if no arguments are passed
    folder = pwd;
    filter = '*';
else
    % Parse given path to folder and filter
    [folder, name, ext] = fileparts(varargin{1});
    
    % Catch case in which no valid input is given
    if isempty(folder) && isempty(name) && isempty(ext)
        varargout{1} = [];
        return
    end
    
    % use pwd is no folder is given
    if isempty(folder)
        folder = pwd;
    end
    
    if isempty(ext)
        % if no ext is present, check if file is a folder
        tmp = fullfile(folder, name);
        if isdir(tmp)
            folder = tmp;
            filter = '*';
        else
            filter = name;
        end
    else
        % use name and extension as filter
        filter = [name ext];
    end
end

%---------------------------
% Search all folders
%---------------------------

% Get all subfolders and separate them
pathstr = genpath(folder);
seplocs = strfind(pathstr, pathsep);

% Catch invalid path
if isempty(seplocs)
   varargout{1} = [];
   return
end

loc1 = [1 seplocs(1:end-1)+1];
loc2 = seplocs(1:end)-1;
pathfolders = arrayfun(@(a,b) pathstr(a:b), loc1, loc2, 'UniformOutput', false);


Files = [];
for ifolder = 1:length(pathfolders)
    NewFiles = dir(fullfile(pathfolders{ifolder}, filter));
    if ~isempty(NewFiles)
        fullnames = cellfun(@(a) fullfile(pathfolders{ifolder}, a), {NewFiles.name}, 'UniformOutput', false); 
        [NewFiles.name] = deal(fullnames{:});
        Files = [Files; NewFiles];
    end
end

if isempty(Files)
    varargout{1} = [];
    return
end

%---------------------------
% Prune . and ..
%---------------------------
[~, ~, tail] = cellfun(@fileparts, {Files(:).name}, 'UniformOutput', false);
dottest = cellfun(@(x) isempty(regexp(x, '\.+(\w+$)', 'once')), tail);
Files(dottest & [Files(:).isdir]) = [];

%---------------------------
% Output
%---------------------------
    
if nargout == 0
    if ~isempty(Files)
        fprintf('\n');
        fprintf('%s\n', Files.name);
        fprintf('\n');
    end
elseif nargout == 1
    varargout{1} = Files;
end
