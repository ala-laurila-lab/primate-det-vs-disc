close all; clear; clc;

% Load configuration
config = getConfiguration();
dataDir = config.PsychophysicsDataPath;
resultsDir = config.PsychophysicsResultsPath;

%% Load data
template = fullfile(dataDir, 'Detection');
% [files.name, files.folder] = uigetfile(template, 'multiselect', 'on');
subjects = dir(template);

for i = 3:numel(subjects)
  
  if ~subjects(i).isdir
    continue
  end
  
  % Extract 2ACF performance 
  out = extractSubject2AFCData(subjects(i).name);
  % Compute statistics
  out = psyfyStatistics(out);

  % Print statistics
  edges = [0, 1e-4, 1e-3, 1e-2, 0.05, 1];
  labels = {'****', '*** ', '**  ', '*   ', 'ns  '};
  pedestals = out.twoAFC.discrimination.pedestal;
  nPedestals = numel(pedestals);
  deltaK = out.twoAFC.discrimination.th75Fit - out.twoAFC.detection.th75Fit;
  cohensd = out.twoAFC.discrimination.cohensd;
  tScore = out.twoAFC.discrimination.tScore;
  pVal = out.twoAFC.discrimination.pVal;
  significance = arrayfun(@(p) labels{histcounts(p, edges)==1}, pVal, 'UniformOutput', false);
  fprintf('%s\n', out.subject)
  fprintf(['Pedestal:\t', repmat('%1.1f\t', 1, nPedestals), '\n'], pedestals)
  fprintf(['Delta K:\t', repmat('%1.1f\t', 1, nPedestals), '\n'], deltaK)
  fprintf(['Cohen''s D:\t', repmat('%1.1f\t', 1, nPedestals), '\n'], cohensd)
  fprintf(['t-score:\t', repmat('%1.1f\t', 1, nPedestals), '\n'], tScore)
  fprintf(['p value:\t', repmat('%1.1e\t', 1, nPedestals), '\n'], pVal)
  fprintf('Significance:\t')
  for j = 1:numel(pVal)
    fprintf('%s\t', significance{j})
  end
  fprintf('\n\n')
  
  % Plot the results
  plot2AFCResults(out, resultsDir)
  plotDipper(out, resultsDir)
  
  % Save results
  saveName = fullfile(resultsDir, [out.subject, '.mat']);
  save(saveName, 'out');
  
end