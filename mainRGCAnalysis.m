close all; clear; clc;

% cell type
dataSets = {'old', 'new'};
cellTypes = {'ON', 'OFF'};
param.nEpochsMin = 20;
param.rasterBinWidth = 2;
param.countBinWidth = 10;
param.collectingArea = 1.40;      % 2 um wide and 25 um long; (Baylor et al., 1984)

% Load configuration
config = getConfiguration();
resultsDir = config.RGCResultsPath;
dataDir = config.RGCspikeTimeDataPath;

% Parameters at 30 degree eccentricity
% Rod convergence remains fixed from 30 degrees outwards
scalingFactor = 1.05;                                                     % See our supplement analysis  
rodDensity = 110e3;                                                       % mm^-2; Packer et al. (1989)
degToMmMacaque = @(d) (-4.2 + sqrt(4.2^2-4*0.038*(0.1-d))) / 2 / 0.038;   % Methods in Dacey and Petersen, (1992), real source Perry and Covey, (1985)
dendriticFieldRadius = (51.8 + 20.6*degToMmMacaque(30)) / 2 * 1e-3;       % Watanabe and Rodieck (1989)
rfSigma = scalingFactor* dendriticFieldRadius;
rodConvergence = getRodsPerRGC(rfSigma, rodDensity, 5);
param.rodConvergence = rodConvergence;


%% Load data

for dataSet = dataSets

  for cellType = cellTypes
  
    param.dataSet = dataSet{1};
    param.cellType = cellType{1};
  
    template = fullfile(dataDir, param.dataSet, param.cellType, '*.mat');
%     [files.name, files.folder] = uigetfile(template, 'multiselect', 'on');
    files = dir(template);

    for i = 1:length(files)

      tic

      % 1. Extract RGC responses
      out = extractResponses(fullfile(files(i).folder, files(i).name), param);

      % 2. 2AFC analyses
      out = extract2AFCResults(out);
      out = fit2AFCHillFunctions(out);

      % 3. Plot and save the results
      plotRasters(out, fullfile(resultsDir, param.dataSet, param.cellType))
      plotResponseStats(out, fullfile(resultsDir, param.dataSet, param.cellType))
      plot2AFCResults(out, fullfile(resultsDir, param.dataSet, param.cellType))
      plotDipper(out, fullfile(resultsDir, param.dataSet, param.cellType))
      saveName = fullfile(resultsDir, param.dataSet, param.cellType, [out.cellName, '.mat']);
      save(saveName, 'out');

      toc
      fprintf('%s. Analysis took took %g sec\n', files(i).name, toc);

    end
    
  end
  
end