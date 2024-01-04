function out = extractResponses(fullPath, param)

  % Load raw spike time data
  load(fullPath);
  
  % Add basic parameters
  [~, fname] = fileparts(fullPath);
  if strcmp(fname(1:3), 'SPT')
    out.cellName = fname(5:end);
  else
    out.cellName = fname;
  end
  out.param = param;
  out.cellType = param.cellType;
  
  % Spike time data are stored using different formats
  if exist('ResponseParams', 'var')
    % Hardcoded stimulus protocol parameters
    out.preTime = 500;
    out.stimTime = 20;
    out.tailTime = 500;
    out.rStarPerRGCPerFlash = arrayfun(@(r) r.flashStrength, ResponseParams);
    % The data have intensities given in R*/RGC by assuming 4000 rods per RGC or in R*/rod
    % In both cases, the conversion from Watts to R* assumed a collecting
    % area on 1 um2. We thus multiply by the collecting area used here to scale the
    % intensity accordingly.
    if min(out.rStarPerRGCPerFlash) < 1e-2  % intensity given in R*/rod
      out.rStarPerRGCPerFlash = out.rStarPerRGCPerFlash * param.rodConvergence * param.collectingArea;
    else                                    %intensity given in R*/RGC
      out.rStarPerRGCPerFlash = out.rStarPerRGCPerFlash / 4e3 * param.rodConvergence * param.collectingArea;
    end
    % Convert spike time to common format in ms with 0 ms at flash onset
    out.spt = {};
    for i = 1:numel(ResponseParams)
      out.spt{end+1} = cellfun(@(spt) spt/10 - out.preTime, ResponseParams(i).spikeTimes, 'UniformOutput', false);
      % Remove obvious bad epochs
      meanCount = mean(cellfun(@numel, out.spt{end}));
      outliers = cellfun(@numel, out.spt{end}) > (meanCount + 40);
      out.spt{end}(outliers) = [];
    end
  elseif exist('out', 'var')
    % Original intensity in R*/rod/sec assuming a collecting area of 1
    out.rStarPerRGCPerFlash = out.splitValue * out.stimTime / 1e3 * param.rodConvergence * param.collectingArea; 
  end
  
  % Remove intensities with too few epochs
  nEpochs = cellfun(@numel, out.spt);
  removeIdx = find(nEpochs < param.nEpochsMin);
  out.spt(removeIdx) = [];
  out.rStarPerRGCPerFlash(removeIdx) = [];
  
  % Add spike counts and spontaneous firings rates
  out.rasters = {};
  out.spikeCounts = {};
  out.spontaneousRates = [];
  rasterBinEdges = round(-500:param.rasterBinWidth:520);
  countBinEdges = round(-500:param.countBinWidth:520);
  for i = 1:numel(out.spt)
    % First convert spike times to ms and offset by preTime (same format as ON cells)
    out.rasters{end+1} = cell2mat(cellfun(@(s)histcounts(s, rasterBinEdges), out.spt{i}, 'UniformOutput', false));
    out.spikeCounts{end+1} = cell2mat(cellfun(@(s)histcounts(s, countBinEdges), out.spt{i}, 'UniformOutput', false));
    out.spontaneousRates(end+1) = mean(cellfun(@(s)histcounts(s, [-500, 0]), out.spt{i})) / 0.5;
  end
  
  % Extract response window
  shift = round((500-out.preTime) / out.param.countBinWidth);
  nBins = numel(countBinEdges) - 1;
  nHalf = round(nBins/2);
  psth = mean(cell2mat(out.spikeCounts(2:end)'));
  meanNoise = mean(psth((1+shift):nHalf));
  stdNoise = std(psth((1+shift):nHalf));
  response = psth((nHalf+1):end) - meanNoise;
  % Spike count window
  spikeCountWin = response;
  if contains(fullPath, 'ON')
    spikeCountWin(spikeCountWin < 2*stdNoise) = 0;
  else
    spikeCountWin(spikeCountWin > -2*stdNoise) = 0;
  end
  spikeCountWin = conv(spikeCountWin, ones(1, 5), 'same');
  % Keep the largest chunk only
  clusterStarts = find(diff([0, spikeCountWin] > 0) == 1);
  clusterStops = find(diff([0, spikeCountWin] > 0) == -1);
  [~, maxIdx] = max(clusterStops - clusterStarts);
  spikeCountWin(1:clusterStarts(maxIdx)) = 0;
  spikeCountWin(clusterStops(maxIdx):end) = 0;
  out.spikeCountWin = sign(spikeCountWin);
  % Discriminator
  discriminator = response;
  discriminator(abs(discriminator) < 2*stdNoise) = 0;
  discriminator = conv(discriminator, ones(1, 5), 'same');
  discriminator = discriminator / norm(discriminator);
  out.discriminator = discriminator;
  
  % Count spikes and cross-correlations
  out.spcPre.values = cellfun(@(spc) spc(:, 1:nHalf)*out.spikeCountWin', out.spikeCounts, 'UniformOutput', false);
  out.spcPost.values = cellfun(@(spc) spc(:, (nHalf+1):end)*out.spikeCountWin', out.spikeCounts, 'UniformOutput', false);
  out.discPre.values = cellfun(@(spc) spc(:, 1:nHalf)*out.discriminator', out.spikeCounts, 'UniformOutput', false);
  out.discPost.values = cellfun(@(spc) spc(:, (nHalf+1):end)*out.discriminator', out.spikeCounts, 'UniformOutput', false);
  
  % Add spike count stats
  out.spcPre = calcStats(out.spcPre);
  out.spcPost = calcStats(out.spcPost);
  out.discPre = calcStats(out.discPre);
  out.discPost = calcStats(out.discPost);
  
  % Interpolate response means and variances
  fields = {'spcPre', 'spcPost', 'discPost'};
  for i = 1:numel(fields)
    out.(fields{i}).meanFit = interpoalte(out.rStarPerRGCPerFlash, out.(fields{i}).mean);
    out.(fields{i}).varFit = interpoalte(out.rStarPerRGCPerFlash, out.(fields{i}).variance);
  end
  
end

function s = calcStats(s)
  s.mean = cellfun(@mean, s.values);
  s.variance = cellfun(@var, s.values);
  s.skewness = cellfun(@skewness, s.values);
  s.nEpochs = cellfun(@length, s.values);
end

function fit = interpoalte(x, y)

  fit.x = logspace(log10(min(x)), log10(max(x)), 101);
  fit.y = interp1(x, y, fit.x);
 
end
