function out = extract2AFCResults(out)

  % temporary rename
  intensities = out.rStarPerRGCPerFlash;

  % Spike counts
  preCounts = cellfun(@(spc) spc(:, 1:(size(spc, 2)/2)), out.spikeCounts, 'UniformOutput', false);
  postCounts = cellfun(@(spc) spc(:, (size(spc, 2)/2+1):end), out.spikeCounts, 'UniformOutput', false);
  
  % Discriminator filter to smooth out potential peaks due to overfitting
  filterSigma = 2;
  filterRange = 3*filterSigma;
  gFilter = exp(-1/2*(-filterRange:filterRange).^2/filterSigma^2);
  gFilter = gFilter / sum(gFilter);
  
  % Detection task
  preCountsAll = cell2mat(preCounts');
  postCountsAll = cell2mat(postCounts');
  labelsAll = cell2mat(arrayfun(@(i) i*ones(size(preCounts{i}, 1), 1), 1:numel(preCounts), 'UniformOutput', false)');
  detectionCorrect = calculateFosRate(preCountsAll, postCountsAll, labelsAll, gFilter);
  out.twoAFC.detection.intensities = intensities;
  out.twoAFC.detection.fractionCorrect = detectionCorrect;
  out.twoAFC.detection.th75 = getXaxisThreshold(intensities, detectionCorrect, 0.75);
  
  % Discrimination task
  % Here we sample the distributions as we don't have pre|post 
  % pairs as in the detection task.
  rng(1);
  nSamples = 1000;
  discriminationCorrect = {};
  intensityDifferences = {};
  discriminationCorrectInterp = {};
  intensityDifferencesInterp = {};
  for i = 1:(numel(postCounts)-1)
    
    % Baselines
    preMeans = cellfun(@(spc) mean(mean(spc, 1)), preCounts(i:end))';
    meanShifts = preMeans - min(preMeans);
    
    % Mean responses (counts)
    countsTmp = postCounts(i:end);
    nEpochs = cellfun(@(spc) size(spc, 1), countsTmp);
    indices = cell2mat(arrayfun(@(n) randi(n, nSamples, 1), nEpochs, 'UniformOutput', false));
    meanCounts = cellfun(@mean, countsTmp, 'UniformOutput', false);
    
    % Sampling loop
    crossCorrs = [];
    for j = 1:nSamples
      
      % Remove current samples from the means to not bias the discriminator
      meanCountsTmp = cell2mat(arrayfun(@(k) (meanCounts{k} - countsTmp{k}(indices(j, k), :)/nEpochs(k)) * nEpochs(k)/(nEpochs(k)-1), 1:numel(nEpochs), 'UniformOutput', false)');
      % Correct for different baselines when determining the discriminator
      meanCountsTmp = meanCountsTmp - meanShifts;
      meanCountsTmp(meanCountsTmp < 0) = 0;
      
      % Cross-correlate spike counts with the discriminator
      discriminatorTmp = mean(meanCountsTmp(2:end, :)) - meanCountsTmp(1, :);
      discriminatorTmp = filter2(gFilter, discriminatorTmp, 'same');
      crossCorrs(end+1, :) = arrayfun(@(k) countsTmp{k}(indices(j, k), :) * discriminatorTmp', 1:numel(nEpochs));
      
    end
    % Frequency of seeing
    pCorrect = arrayfun(@(k) mean(crossCorrs(:, k) > crossCorrs(:, 1)) + 0.5*mean(crossCorrs(:, k) == crossCorrs(:, 1)), 2:numel(nEpochs));
    discriminationCorrect{end+1} = [0.5, pCorrect];
    intensityDifferences{end+1} = cumsum(diff([intensities(i), intensities(i:end)]));
    
    % Interpolations
    meanCrossCorr = mean(crossCorrs);
    varCrossCorr = var(crossCorrs);
    varCrossCorr(varCrossCorr==1) = 1e-5;
    intensitiesTmp = logspace(log10(intensities(i)), log10(intensities(i+1)), i-numel(intensities)+3+3);
    meansInterp = interp1(intensities(i:end), meanCrossCorr, intensitiesTmp+1e-10);
    varInterp = interp1(intensities(i:end), varCrossCorr, intensitiesTmp+1e-10);
    
    % Sanity check
    md = meanCrossCorr(2:end) - meanCrossCorr(1);
    sd = sqrt(varCrossCorr(1) + varCrossCorr(2:end));
    pCorrectTmp = arrayfun(@(i) 1-normcdf(0, md(i), sd(i)), 1:numel(md));
    pCorrect;
    
    if numel(intensitiesTmp) >= 3
      meanDiff = meansInterp(2:end-1) - meansInterp(1);
      stdDiff = sqrt(varInterp(1) + varInterp(2:end-1));
      discriminationCorrectInterp{i} = arrayfun(@(i) 1-normcdf(0, meanDiff(i), stdDiff(i)), 1:numel(meanDiff));
      intensityDifferencesInterp{i} = cumsum(diff(intensitiesTmp(1:end-1)));
    else
      discriminationCorrectInterp{i} = [];
      intensityDifferencesInterp{i} = []; 
    end
    
  end
  % Get linearly interpolated thresholds
  thresholds = cellfun(@(x, y) getXaxisThreshold(x, y, 0.75), intensityDifferences, discriminationCorrect);
  
  out.twoAFC.discrimination.pedestal = intensities;
  out.twoAFC.discrimination.fractionCorrect = discriminationCorrect;
  out.twoAFC.discrimination.intensityDifference = intensityDifferences;
  out.twoAFC.discrimination.th75 = thresholds;
  
  out.twoAFC.discrimination.fractionCorrectInterp = discriminationCorrectInterp;
  out.twoAFC.discrimination.intensityDifferenceInterp = intensityDifferencesInterp;
  
end

function fosRates = calculateFosRate(preCounts, postCounts, labels, gFilter)

  % Add shifted  versions of pre counts to decrease the 
  % variability in 2AFC of values
  shifts = 0:2:20;
  nRep = numel(shifts);
  
  % Augment in shifted pre counts
  preCountsRep = [];
  for i = 1:nRep
    preCountsRep = [preCountsRep; circshift(preCounts, shifts(i), 2)];
  end
  % Copy post counts
  postCountsRep = repmat(postCounts, nRep, 1);
  labelsRep = repmat(labels, 1, nRep);
  
  % cross-correlate counts with the discriminator
  nSingle = size(preCounts, 1);
  nTot = size(preCountsRep, 1);
  fosChoices = zeros(1, nTot);
  for i = 1:nSingle
    mask = mod(1:nTot, nSingle) ~= mod(i, nSingle);
    discriminatorTmp = mean(postCountsRep(mask, :) - preCountsRep(mask, :));
    discriminatorTmp = filter2(gFilter, discriminatorTmp, 'same');
    preCorr = preCountsRep(~mask, :)*discriminatorTmp';
    postCorr = postCountsRep(~mask, :)*discriminatorTmp';
    fosChoices(~mask) = 1.*(postCorr > preCorr) + 0.5*(postCorr == preCorr); 
  end

  % Determine frequency of seeing rates (2AFC) for each label
  fosRates = [];
  uniqueLabels = sort(unique(labelsRep));
  for i = 1:numel(uniqueLabels)
    fosRates(end+1) = mean(fosChoices(labelsRep==uniqueLabels(i)));
  end
  
end

function [centers, edges] = getBinCenters(values)

  means = cellfun(@mean, values);
  stds = cellfun(@std, values);
  
  minVal = min(means-3*stds);
  maxVal = max(means+3*stds);
  
  centers = linspace(minVal, maxVal, 30);
  delta = diff(centers(1:2));
  edges = [centers(1)-delta/2, centers+delta/2];

end


function xTh = getXaxisThreshold(x, y, yTh)

  UpperIdx = find(y > yTh, 1, 'first');
  lowerIdx = UpperIdx - 1;
  
  if isempty(lowerIdx) || isempty(UpperIdx) || (lowerIdx == 0)
    xTh = nan;
  else
    xTh = interp1(y(lowerIdx:UpperIdx), x(lowerIdx:UpperIdx), yTh);
  end
  
end
