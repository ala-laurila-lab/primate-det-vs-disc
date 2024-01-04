close all; clear; clc;

% Load configuration
config = getConfiguration();
cd(config.rootPath)
resultsDir = config.PsychophysicsResultsPath;

% Set up the figure window
fh = figure();
set(fh, 'DefaultAxesFontSize', 15, 'DefaultTextFontSize', 15)
yLim = [0.5, 100];
xLim = [0.5, 100];
xLimPsycho = [0.5, 40];

% Left and right axes
ahLeft = axes('Position', [0.13, 0.15, 0.03, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim, 'YScale', 'log'); hold on;
ylabel('\DeltaI_{JND} (R*)')
text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
ahRight = axes('Position', [0.19, 0.15, 0.75, 0.75], 'YLim', yLim, 'YScale', 'log', 'YTick', [], 'XLim', xLim, 'XScale', 'log', 'XTick', [1, 10, 100], 'YColor', 'none'); hold on;
xlabel('I_{ref} (R*)')
text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)


% Get a summary for all RGC data
psychoSummary = getDataSummary(resultsDir, {''}, [], xLimPsycho);

% Plot the data
plotData(fh, [ahLeft, ahRight], 'Psychophysics', psychoSummary, config)

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
