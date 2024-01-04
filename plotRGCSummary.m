close all; clear; clc;

% Load configuration
config = getConfiguration();
cd(config.rootPath)
resultsDir = config.RGCResultsPath;

% Set up the figure window
fh = figure();
set(fh, 'Position', get(fh, 'Position').*[0.55, 1, 1.5, 1], 'DefaultAxesFontSize', 15, 'DefaultTextFontSize', 15)
yLim = [0.5, 100];
xLim = [0.5, 100];
xLimOn = [0.5, 30];
xLimOff = [0.5, 15];

% ON axes
ahOnLeft = axes('Position', [0.1, 0.15, 0.02, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI_{JND} (R*/RGC)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOnRight = axes('Position', [0.13, 0.15, 0.35, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I_{ref} (R*/RGC)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)

% OFF axes
ahOffLeft = axes('Position', [0.6, 0.15, 0.02, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI_{JND} (R*/RGC)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahOffRight = axes('Position', [0.63, 0.15, 0.35, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I_{ref} (R*/RGC)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)

% Get a summary for all RGC data
onSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'ON', xLimOn);
offSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'OFF', xLimOff);

% Plot the data
plotData(fh, [ahOnLeft, ahOnRight], 'ON Parasols', onSummary, config)
plotData(fh, [ahOffLeft, ahOffRight], 'OFF Parasols', offSummary, config)

function plotData(fh, ahs, name, dataSummary, config)

  % Theoretical limit
  xLim = ahs(2).XLim;
  xVals = logspace(log10(xLim(1)), log10(xLim(2)), 101);
  thTheory = getPoissonDiscriminationLimitVec(xVals, 0.75, 0) - xVals;
  thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, 0);

  % Theoretical limit
  set(fh, 'CurrentAxes', ahs(1))
  plot(0, thTheory0, '.', 'LineWidth', 2, 'Color', config.Color.Theory);
  set(fh, 'CurrentAxes', ahs(2))
  plot(xVals, thTheory, ':', 'LineWidth', 2, 'Color', config.Color.Theory)

  % Individual traces
  for j = 1:numel(dataSummary.detection.ths)
    set(fh, 'CurrentAxes', ahs(1))
    plot(0, dataSummary.detection.ths(j), 'o', 'Color', config.Color.Det+config.Color.Fading*(1-config.Color.Det));

    set(fh, 'CurrentAxes', ahs(2))
    xTmp = [xLim(1), dataSummary.discrimination.pedestals{j}];
    yTmp = [dataSummary.detection.ths(j), dataSummary.discrimination.ths{j}];
    plot(xTmp(~isnan(yTmp)), yTmp(~isnan(yTmp)), 'Color', config.Color.Disc+config.Color.Fading*(1-config.Color.Disc));
  end

  % Mean values
  set(fh, 'CurrentAxes', ahs(1))
  plot(0, dataSummary.detection.mean, 'o', 'LineWidth', 3, 'Color', config.Color.Det);
  set(fh, 'CurrentAxes', ahs(2))
  plot(dataSummary.discrimination.pedestalsInterp, dataSummary.discrimination.mean, '-', 'LineWidth', 3, 'Color', config.Color.Disc)

  title(sprintf('%s (N=%d)', name, numel(dataSummary.detection.ths)))
  
end