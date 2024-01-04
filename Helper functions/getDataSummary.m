function all = getDataSummary(resultsDir, dataSets, dataType, pedestalRange)

pedestals = {};
thDiscrimination = {};
thDiscriminationInterp = [];
thDetection = [];
stimIntensities = {};
fanoFactors = {};
fanoFactorsInterp = [];
spontaneousRates = [];
tags = {};
pedestalsInterp = logspace(log10(pedestalRange(1)), log10(pedestalRange(2)), 101);
stimInterp = logspace(log10(1e-4), log10(50), 101);

for dataSet = dataSets
  
  if isempty(dataType)
    % Psychophysics data
    template = fullfile(resultsDir, '*.mat');
  else
    % RGC data
    template = fullfile(resultsDir, dataSet{1}, dataType, '*.mat');
  end
  
  % Loop over all mat files (RGCs or human observers)
  files = dir(template);
  for i = 1:length(files)

    % Load file
    load(fullfile(files(i).folder, files(i).name), 'out')
    if sum(~isnan(out.twoAFC.discrimination.th75Fit)) < 2
      continue
    end
    
    % Extract data
    tags{end+1} = files(i).name;
    thDetection(end+1) = out.twoAFC.detection.th75Fit;
    
    nPedestals = numel(out.twoAFC.discrimination.th75Fit);
    pedestals{end+1} = out.twoAFC.discrimination.pedestal(1:nPedestals);
    pedestalsTmp = [pedestalRange(1), pedestals{end}];
    
    thDiscrimination{end+1} = out.twoAFC.discrimination.th75Fit;
    thsTmp = [out.twoAFC.detection.th75Fit,  thDiscrimination{end}];
    thDiscriminationInterp(end+1, :) = interp1(pedestalsTmp(~isnan(thsTmp)), thsTmp(~isnan(thsTmp)), pedestalsInterp);
    
    % Fano factors and spontaneous rates for RGCs
    if ~isempty(dataType)
      fanoFactors{end+1} = [
        nanmean(out.spcPre.variance ./ out.spcPre.mean), ...
        out.spcPost.variance ./ out.spcPost.mean
        ];
      stimIntensities{end+1} = [1e-4, out.rStarPerRGCPerFlash];
      mask = ~isnan(fanoFactors{end});
      fanoFactorsInterp(end+1, :) = interp1(stimIntensities{end}(mask), fanoFactors{end}(mask), stimInterp, 'linear', 'extrap');
      spontaneousRates(end+1) = mean(out.spontaneousRates);
    end
    
  end
end

all.tags = tags;
all.detection.ths = thDetection;
all.detection.mean = nanmean(thDetection);
all.detection.se = nanstd(thDetection) ./ sqrt(sum(~isnan(thDetection)));
all.discrimination.ths = thDiscrimination;
all.discrimination.pedestals = pedestals;
all.discrimination.thsInterp = thDiscriminationInterp;
all.discrimination.pedestalsInterp = pedestalsInterp;
all.discrimination.mean = nanmean(thDiscriminationInterp);
all.discrimination.se = nanstd(thDiscriminationInterp) ./ sqrt(sum(~isnan(thDiscriminationInterp)));
% Spontaneous rates for RGCs
all.spontaneous.rates = spontaneousRates;
all.spontaneous.mean = nanmean(spontaneousRates);
all.spontaneous.se = nanstd(spontaneousRates) ./ sqrt(sum(~isnan(spontaneousRates)));
% Fano factors for RGCs
all.fanofactors.stimIntensities = stimIntensities;
all.fanofactors.stimIntensitiesInterp = stimInterp;
all.fanofactors.fanoFactors = fanoFactors;
all.fanofactors.fanoFactorsInterp = fanoFactorsInterp;
all.fanofactors.mean = nanmean(fanoFactorsInterp);
all.fanofactors.std = nanstd(fanoFactorsInterp);
all.fanofactors.se = nanstd(fanoFactorsInterp) ./ sqrt(sum(~isnan(fanoFactorsInterp)));

