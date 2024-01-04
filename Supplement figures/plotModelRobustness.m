function plotModelRobustness(visible)

  if nargin < 1
    visible = true;
  end
  fprintf('Plotting model robustness... ')

% clear; close all; clc;
% visible = true;

  config = getConfiguration();
  psychoResultsDir = config.PsychophysicsResultsPath;

  % Parameters
  global width height x0 y0 xw yh dx
  width = 6;      % panel width, cm
  height = 5;      % panel height, cm
  x0 = 0.2;
  y0 = 0.25;
  xw = 0.74;
  yh = 0.65;
  dx = 0.02;

  % Initialization
  xLim = [0.5, 40];
  yLim = [0.5, 40];
  xVals = logspace(log10(xLim(1)), log10(xLim(end)), 101);
  logTicks = [0.1, 1, 10, 100];
  % Final params used for the psychophysics model fit
  % [nosie, first_th, second_th, alpha_1, n_subunit]
  psychoParams = [0.055, 2, 2, 0.333, 6];  
  paramScalings = [1/2, 1, 2];
  paramNames = {'addNoiseVals', 'firstThs', 'secondThs', 'mulNoiseVals', 'nSubUnits'};
  paramLabels = {'Additive noise (N+)', 'Retinal threshold (\theta_1)', 'Higher-order threshold (\theta_2)', 'Multiplicative noise (Nx)', 'Number of subunits (n)'};
  legend_scaling = repmat(-0.35, 1, 5);
  legend_xpos = repmat(0.75, 1, 5);

  % Colors and line styles
  colorsDet = [config.Color.Det;
               [0, 0, 0];
               config.Color.Det];
  colorsDisc = [config.Color.Disc;
                [0, 0, 0];
                config.Color.Disc];
  lineStyles = {'--', '--', '-.'};

  % Theoretical line and psychophysics data
  theoryDet = getPoissonDiscriminationLimitVec(0, 0.75, [0, 0, 0, 0, 1]);
  theoryDipper = getPoissonDiscriminationLimitVec(xVals, 0.75, [0, 0, 0, 0, 1]) - xVals;
  psychoSummary = getDataSummary(psychoResultsDir, {''}, [], xLim);
  levelLabels = arrayfun(@(s) sprintf('x %1.1g', s), paramScalings, 'UniformOutput', false);
  levelLabels{1} = 'x ^{1}/_{2}';

  for i = 1:numel(paramNames)

    [fh, ahLeft, ahRight] = getSplitLogAxes(xLim, yLim, logTicks, logTicks, 'log', 'log', 1, 1., visible);
        
    % Left axes (darkness)
    set(fh, 'CurrentAxes', ahLeft)
    ylh = ylabel('\DeltaI_{JND} (R*)');
    ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
    for j = 1:numel(paramScalings)
      modelParams = psychoParams;
      modelParams(i) = modelParams(i)*paramScalings(j);
      modelDet = getModelPerformance(0, modelParams);
      plot(0, modelDet, '.', 'Color', colorsDet(j, :))
    end
    plot(0, theoryDet, '.', 'Color', config.Color.Theory);
    set(gca, 'Color', 'none')

    % Right axes (backgrounds)
    phs = [];
    set(fh, 'CurrentAxes', ahRight)
    th = title(paramLabels{i}, 'Units', 'centimeters');
    th.VerticalAlignment = 'top';
    th.Position(2) = yh*height + 0.5;
    xlabel('I_{ref} (R*)')

    xVals = psychoSummary.discrimination.pedestalsInterp;
    mask = ~isnan(psychoSummary.discrimination.mean);
    fill([xVals(mask), flip(xVals(mask))], [psychoSummary.discrimination.mean(mask)+psychoSummary.discrimination.se(mask), flip(psychoSummary.discrimination.mean(mask)-psychoSummary.discrimination.se(mask))], config.Color.Psycho, 'FaceAlpha', 1-config.Color.Fading, 'EdgeColor', 'none')
    plot(xVals, psychoSummary.discrimination.mean, '-', 'LineWidth', 1, 'Color', config.Color.Psycho, 'Display', 'Psychop.');

    for j = 1:numel(paramScalings)
      modelParams = psychoParams;
      modelParams(i) = modelParams(i)*paramScalings(j);
      modelDipper = getModelPerformance(xVals, modelParams);
      phs(end+1) = plot(xVals, modelDipper, lineStyles{j}, 'Color', colorsDisc(j, :), 'Display', levelLabels{j});
    end
    plot(xVals, theoryDipper, ':', 'Color', config.Color.Theory)
    
    % Fix the legend
    [lgh, icons] = legend(flip(phs));
    lgh.Box = 'off';
    lgh.Position(1:2) = [legend_xpos(i), 0.26];
    fixLegendIcons(icons, legend_scaling(i), false)
    set(gca, 'Color', 'none')

    saveFigure(['Supplement figures', filesep, 'SupplementModelRobustness_', paramNames{i}(1:end-1)])

  end

  fprintf('Done\n')
  
end


%% Function definitions

function ths = getModelPerformance(xVals, modelParams)
  
  noise = modelParams(1);
  nSubunits = modelParams(5);
  params = [modelParams(2), modelParams(3), modelParams(4), 0, nSubunits];

  ths = nSubunits*getPoissonDiscriminationLimitVec(xVals/nSubunits+noise, 0.75, params) - nSubunits*noise - xVals;

end


function [fh, ahLeft, ahRight] = getSplitLogAxes(xLim, yLim, xTicks, yTicks, xScale, yScale, xStretch, yStretch, visible)

  global width height x0 y0 xw yh dx

  [fh, ahLeft] = getFigureWindow(1, 1, [width*xStretch, height*yStretch, x0/xStretch, y0/yStretch, 2*dx/xStretch, yh + (yStretch-1)*(1-yh)/yStretch, 0, 0], true, visible);
  set(ahLeft, 'XLim', [-1, 1], 'XTick', 0, 'XTickLabel', 'Dark', 'XTickLabelRotation', 0, 'YLim', yLim, 'YTick', yTicks, 'YTickLabel', yTicks, 'YScale', yScale); hold on;
  text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', get(gca, 'XColor'))
  tmpPos = get(gca, 'Position');
  tmpPos(1) = (x0 + 4*dx)/xStretch;
  tmpPos(3) = xw - 4*dx/xStretch + (xStretch-1)*(x0)/xStretch + (xStretch-1)*(1-x0-xw)/xStretch;
  ahRight = axes('Position', tmpPos, 'YLim', yLim, 'YScale', yScale, 'YTick', [], 'XLim', xLim, 'XScale', xScale, 'XTick', xTicks, 'XTickLabel', xTicks, 'YColor', 'none'); hold on;
  text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', get(gca, 'XColor'))
  
end