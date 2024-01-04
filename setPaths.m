function setPaths()

  % Remove any paths to other repositories which might contain function
  % with identical names
  restoredefaultpath;

  % find root folder
  [rootPath, ~, ~] = fileparts(mfilename('fullpath'));
  cd(rootPath)

  % and add all subdirectories to the search path
  addpath(genpath(cd));

  % Get the configuration
  config = getConfiguration();

  % Create project folders if they don't exist
  % RGC results
  if ~exist(config.RGCResultsPath, 'dir')
    mkdir([config.RGCResultsPath, filesep, 'New', filesep, 'ON']);
    mkdir([config.RGCResultsPath, filesep, 'New', filesep, 'OFF']);
    mkdir([config.RGCResultsPath, filesep, 'Old', filesep, 'ON']);
    mkdir([config.RGCResultsPath, filesep, 'Old', filesep, 'OFF']);
    addpath(genpath(config.RGCResultsPath));
  end
  % Psychophysics results
  if ~exist(config.PsychophysicsResultsPath, 'dir')
    mkdir(config.PsychophysicsResultsPath);
    addpath(genpath(config.PsychophysicsResultsPath));
  end
  % Figure data in excel format
  if ~exist('Figure data', 'dir')
    mkdir('Figure data');
    addpath(genpath('Figure data'));
  end

end