close all; clear; clc;

% Load configuration
config = getConfiguration();
resultsDir = config.PsychophysicsResultsPath;
blue = [0, 0, 1];
red = [1, 0, 0];
fading = 0.75;

%% Set up the figure window
fh = figure();
yLim = [0.35, 100];
xLim = [0.35, 100];
yLimNorm = [0.25, 10];
xLimNorm = [0.05, 20];

% ON axes
ahLeft = axes('Position', [0.13, 0.15, 0.03, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI (R*/RGC)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahRight = axes('Position', [0.19, 0.15, 0.75, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I (R*/RGC)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)

% Theoretical limit
xInterp = logspace(log10(xLim(1)), log10(xLim(2)), 201);
thTheory = getPoissonDiscriminationLimitVec(xInterp, 0.75, []);
xInterpNorm = logspace(log10(xLimNorm(1)), log10(xLimNorm(2)), 201);

%% Psychophysics data

yInterp = [];
yDetection = [];
yInterpNorm = [];
tags = {};

template = fullfile(resultsDir, '*.mat');
files = dir(template);
for i = 1:length(files)

  load(fullfile(files(i).folder, files(i).name), 'out')
  if sum(~isnan(out.twoAFC.discrimination.th75Fit)) < 3
    continue
  end
  tags{end+1} = files(i).name;

  axes(ahLeft)
  plot(0, out.twoAFC.detection.th75Fit, 'o', 'Color', blue+fading*(1-blue))
  yDetection(end+1) = out.twoAFC.detection.th75Fit;

  axes(ahRight)
  nPedestals = numel(out.twoAFC.discrimination.th75Fit);
  pedestalsTmp = out.twoAFC.discrimination.pedestal(1:nPedestals);
  pedestalsTmp = [xLim(1), pedestalsTmp];
  thsTmp = out.twoAFC.discrimination.th75Fit;
  thsTmp = [out.twoAFC.detection.th75Fit,  thsTmp];
  plot(pedestalsTmp, thsTmp, '-', 'Color', red+fading*(1-red))

  yInterp(end+1, :) = interp1(pedestalsTmp, thsTmp, xInterp);
  yInterpNorm(end+1, :) = interp1(pedestalsTmp/out.twoAFC.detection.th75Fit, thsTmp/out.twoAFC.detection.th75Fit, xInterpNorm);

end


%% Averages
axes(ahLeft)
pCorrectMean = nanmean(yDetection);
pCorrectStd = nanstd(yDetection);
pCorrectSe = pCorrectStd ./ sqrt(sum(~isnan(yDetection)));
plot([0, 0], [pCorrectMean-pCorrectSe, pCorrectMean+pCorrectSe], '-', 'LineWidth', 3, 'Color', blue+fading*(1-blue))
plot(0, pCorrectMean, '.', 'LineWidth', 3, 'Color', blue)
plot(0, getPoissonDiscriminationLimitVec(0, 0.75, []), 'x', 'LineWidth', 3, 'Color', 'k')
axes(ahRight)
pCorrectMean = nanmean(yInterp);
pCorrectStd = nanstd(yInterp);
pCorrectSe = pCorrectStd ./ sqrt(sum(~isnan(yInterp)));
mask = ~isnan(pCorrectMean);
fill([xInterp(mask), flip(xInterp(mask))], [pCorrectMean(mask)+pCorrectSe(mask), flip(pCorrectMean(mask)-pCorrectSe(mask))], red+fading*(1-red), 'EdgeColor', 'none')
plot(xInterp, pCorrectMean, '-', 'LineWidth', 3, 'Color', red)
plot(xInterp, thTheory-xInterp, 'k:')
title(sprintf('Psychophysics (N=%d)', numel(yDetection)))

% Check distance to the theoretical limit
[minVal, minIdx] = min(nanmean(yInterp) ./ (thTheory-xInterp));
text(0.05, 0.1, sprintf('%1.1f times th. min. at %1.1f R*/RGC', minVal, xInterp(minIdx)), 'Units', 'Normalized', 'FontSize', 15)
