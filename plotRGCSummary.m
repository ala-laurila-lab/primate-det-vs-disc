close all; clear; clc;

% Load configuration
config = getConfiguration();
resultsDir = config.RGCResultsPath;
blue = [0, 0, 1];
red = [1, 0, 0];
fading = 0.75;

%% Set up the figure window
fh = figure();
set(fh, 'Position', get(fh, 'Position').*[0.55, 1, 1.5, 1])
yLim = [0.35, 50];
xLim = [0.75, 30];
yLimNorm = [0.3, 7];
xLimNorm = [0.2, 6];

% ON axes
ahOnLeft = axes('Position', [0.1, 0.15, 0.02, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI (R*/RGC)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOnRight = axes('Position', [0.13, 0.15, 0.35, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I (R*/RGC)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOnInset = axes('Position', [0.35, 0.21, 0.125, 0.175], 'YLim', yLimNorm, 'YScale', 'log', 'YTick', 1, 'YTickLabel', 1, 'XLim', xLimNorm, 'XScale', 'log', 'XTick', 1, 'XTickLabel', 1); hold on;
title('Normalized', 'FontWeight', 'normal')

% OFF axes
ahOffLeft = axes('Position', [0.6, 0.15, 0.02, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI (R*/RGC)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOffRight = axes('Position', [0.63, 0.15, 0.35, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I (R*/RGC)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOffInset = axes('Position', [0.85, 0.21, 0.125, 0.175], 'YLim', yLimNorm, 'YScale', 'log', 'YTick', 1, 'YTickLabel', 1, 'XLim', xLimNorm, 'XScale', 'log', 'XTick', 1, 'XTickLabel', 1); hold on;
title('Normalized', 'FontWeight', 'normal')

% Theoretical limit
xInterp = logspace(log10(xLim(1)), log10(xLim(2)), 201);
thTheory = getPoissonDiscriminationLimitVec(xInterp, 0.75, []);
xInterpNorm = logspace(log10(xLimNorm(1)), log10(xLimNorm(2)), 201);

%% ON cells

yInterpON = [];
yDetectionON = [];
yInterpNormON = [];
detectionSlopeOn = [];
discriminationSlopeOn = [];
tagsON = {};
for dataSet = {'Old', 'New'}
  template = fullfile(resultsDir, dataSet{1}, 'ON', '*.mat');
  files = dir(template);
  for i = 1:length(files)
  % for i = 1:2

    if ~checkIfIncluded(files(i).name(1:end-4))
      continue
    end

    load(fullfile(files(i).folder, files(i).name), 'out')
    if sum(~isnan(out.twoAFC.discrimination.th75Fit)) < 2
      continue
    end
    tagsON{end+1} = files(i).name;
    detectionSlopeOn(end+1) = out.twoAFC.detection.fit.params.n;
    discriminationSlopeOn(end+1) = mean(cellfun(@(p) p.n, out.twoAFC.discrimination.fit.params));

    axes(ahOnLeft)
    plot(0, out.twoAFC.detection.th75Fit, 'o', 'Color', blue+fading*(1-blue))
    yDetectionON(end+1) = out.twoAFC.detection.th75Fit;

    axes(ahOnRight)
    nPedestals = numel(out.twoAFC.discrimination.th75Fit);
    pedestalsTmp = out.twoAFC.discrimination.pedestal(1:nPedestals);
    pedestalsTmp = [xLim(1), pedestalsTmp];
    thsTmp = out.twoAFC.discrimination.th75Fit;
    thsTmp = [out.twoAFC.detection.th75Fit,  thsTmp];
    plot(pedestalsTmp, thsTmp, '-', 'Color', red+fading*(1-red))

    axes(ahOnInset)
    plot(pedestalsTmp/out.twoAFC.detection.th75Fit, thsTmp/out.twoAFC.detection.th75Fit, '-', 'Color', red+fading*(1-red))

    yInterpON(end+1, :) = interp1(pedestalsTmp, thsTmp, xInterp);
    yInterpNormON(end+1, :) = interp1(pedestalsTmp/out.twoAFC.detection.th75Fit, thsTmp/out.twoAFC.detection.th75Fit, xInterpNorm);

  end
end

%% Averages
axes(ahOnLeft)
pCorrectMean = 10^nanmean(log10(yDetectionON));
pCorrectSe = 10.^(nanstd(log10(yDetectionON))./sqrt(sum(~isnan(yDetectionON))));
errorbar(0, pCorrectMean, pCorrectMean.*(1-1./pCorrectSe), pCorrectMean.*(pCorrectSe-1), '-', 'LineWidth', 2, 'Color', blue+fading*(1-blue))
plot(0, pCorrectMean, '.', 'LineWidth', 3, 'Color', blue)
plot(0, getPoissonDiscriminationLimitVec(0, 0.75, []), 'x', 'LineWidth', 3, 'Color', 'k')

axes(ahOnRight)
pCorrectMean = 10.^nanmean(log10(yInterpON));
pCorrectSe = 10.^(nanstd(log10(yInterpON))./sqrt(sum(~isnan(yInterpON))));
mask = ~isnan(pCorrectMean);
fill([xInterp(mask), flip(xInterp(mask))], [pCorrectMean(mask).*pCorrectSe(mask), flip(pCorrectMean(mask)./pCorrectSe(mask))], red+0.3*(1-red), 'EdgeColor', 'none')
plot(xInterp, pCorrectMean, '-', 'LineWidth', 3, 'Color', red)
plot(xInterp, thTheory-xInterp, 'k:')
title(sprintf('ON Parasols (N=%d)', numel(yDetectionON)))

% Check distance to the theoretical limit
[minVal, minIdx] = min(nanmean(yInterpON) ./ (thTheory-xInterp));
text(0.05, 0.9, sprintf('%1.1f times th. min. at %1.1f R*/RGC', minVal, xInterp(minIdx)), 'Units', 'Normalized', 'FontSize', 15)

axes(ahOnInset)
plot(xInterpNorm, nanmean(yInterpNormON), '-', 'LineWidth', 3, 'Color', red)


%% OFF cells

yInterpOFF = [];
yDetectionOFF = [];
yInterpNormOFF = [];
detectionSlopeOff = [];
discriminationSlopeOff = [];
tagsOff = {};
for dataSet = {'Old', 'New'}
  template = fullfile(resultsDir, dataSet{1}, 'OFF', '*.mat');
  files = dir(template);
  for i = 1:length(files)

    if ~checkIfIncluded(files(i).name(1:end-4))
      continue
    end

    load(fullfile(files(i).folder, files(i).name), 'out')
    if sum(~isnan(out.twoAFC.discrimination.th75Fit)) < 2
      continue
    end
    tagsOff{end+1} = files(i).name;
    detectionSlopeOff(end+1) = out.twoAFC.detection.fit.params.n;
    discriminationSlopeOff(end+1) = mean(cellfun(@(p) p.n, out.twoAFC.discrimination.fit.params));

    axes(ahOffLeft)
    plot(0, out.twoAFC.detection.th75Fit, 'o', 'Color', blue+fading*(1-blue))
    yDetectionOFF(end+1) = out.twoAFC.detection.th75Fit;

    axes(ahOffRight)
    nPedestals = numel(out.twoAFC.discrimination.th75Fit);
    pedestalsTmp = out.twoAFC.discrimination.pedestal(1:nPedestals);
    pedestalsTmp = [xLim(1), pedestalsTmp];
    thsTmp = out.twoAFC.discrimination.th75Fit;
    thsTmp = [out.twoAFC.detection.th75Fit,  thsTmp];
    plot(pedestalsTmp, thsTmp, '-', 'Color', red+fading*(1-red))

    axes(ahOffInset)
    plot(pedestalsTmp/out.twoAFC.detection.th75Fit, thsTmp/out.twoAFC.detection.th75Fit, '-', 'Color', red+fading*(1-red))

    yInterpOFF(end+1, :) = interp1(pedestalsTmp, thsTmp, xInterp);
    yInterpNormOFF(end+1, :) = interp1(pedestalsTmp/out.twoAFC.detection.th75Fit, thsTmp/out.twoAFC.detection.th75Fit, xInterpNorm);

  end
end

%% Averages
axes(ahOffLeft)
pCorrectMean = 10^nanmean(log10(yDetectionOFF));
pCorrectSe = 10.^(nanstd(log10(yDetectionOFF))./sqrt(sum(~isnan(yDetectionOFF))));
errorbar(0, pCorrectMean, pCorrectMean.*(1-1./pCorrectSe), pCorrectMean.*(pCorrectSe-1), '-', 'LineWidth', 2, 'Color', blue+fading*(1-blue))
plot(0, pCorrectMean, '.', 'LineWidth', 3, 'Color', blue)
plot(0, getPoissonDiscriminationLimitVec(0, 0.75, []), 'x', 'LineWidth', 3, 'Color', 'k')

axes(ahOffRight)
pCorrectMean = 10.^nanmean(log10(yInterpOFF));
pCorrectSe = 10.^(nanstd(log10(yInterpOFF))./sqrt(sum(~isnan(yInterpOFF))));
mask = ~isnan(pCorrectMean);
fill([xInterp(mask), flip(xInterp(mask))], [pCorrectMean(mask).*pCorrectSe(mask), flip(pCorrectMean(mask)./pCorrectSe(mask))], red+0.3*(1-red), 'EdgeColor', 'none')
plot(xInterp, pCorrectMean, '-', 'LineWidth', 3, 'Color', red)
plot(xInterp, thTheory-xInterp, 'k:')
title(sprintf('OFF Parasols (N=%d)', numel(yDetectionOFF)))

% Check distance to the theoretical limit
[minVal, minIdx] = min(nanmean(yInterpOFF) ./ (thTheory-xInterp));
text(0.05, 0.9, sprintf('%1.1f times th. min. at %1.1f R*/RGC', minVal, xInterp(minIdx)), 'Units', 'Normalized', 'FontSize', 15)

axes(ahOffInset)
plot(xInterpNorm, nanmean(yInterpNormOFF), '-', 'LineWidth', 3, 'Color', red)