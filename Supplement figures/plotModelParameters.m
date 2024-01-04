function plotModelParameters(visible)

  if nargin < 1
    visible = true;
  end
  fprintf('Plotting model parameters... ')

  config = getConfiguration();
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
  xLim = [0.5, 100];
  yLim = [0.5, 100];
  xVals = logspace(log10(xLim(1)), log10(xLim(end)), 101);
  logTicks = [0.1, 1, 10, 100];
  nSubunits = 6;
  addNoiseVals = [0.25, 1, 4];
  mulNoiseVals = [1, 0.5, 0.25];
  firstThs = [1, 2, 4];
  secondThs = [1, 2, 4]*3;
  paramNames = {'addNoiseVals', 'mulNoiseVals', 'firstThs', 'secondThs'};
  paramLabels = {'Additive noise (N+)', 'Multiplicative noise (Nx)', 'Retinal threshold (\theta_1)', 'Higher-order threshold (\theta_2)'};
  % levelLabels = {{'Low noise', '', 'High noise'}, {'Low noise', '', 'High noise'}, {'Low th.', '', 'High th.'}, {'Low th.', '', 'High th.'}};
  levelLabels = repmat({{'x ^{1}/_{2}', 'x 1', 'x 2'}}, 1, 4);
  levelLabels{1} = {'x ^{1}/_{4}', 'x 1', 'x 4'};
  legend_scaling = repmat(-0.35, 1, 4);
  legend_xpos = repmat(0.75, 1, 4);
  
  % Baseline parameter values
  modelParams0 = [0, 0, 0, 0]; %[firstTh, secondTh, alpha, alpha, nSubUnits]

  % Colors
  colorsDet = [0.65*config.Color.Det;
               config.Color.Det;
               config.Color.Det+(1-config.Color.Det)*0.35];
  colorsDisc = [0.65*config.Color.Disc;
                config.Color.Disc;
                config.Color.Disc+(1-config.Color.Disc)*0.35];

  % Theoretical lines
  theoryDet = getPoissonDiscriminationLimitVec(0, 0.75, [0, 0, 0, 0, 1]);
  theoryDipper = getPoissonDiscriminationLimitVec(xVals, 0.75, [0, 0, 0, 0, 1]) - xVals;

  for i = 1:numel(paramNames)

    modelParams = modelParams0;
    tmpVals = eval(paramNames{i});

    [fh, ahLeft, ahRight] = getSplitLogAxes(xLim, yLim, logTicks, logTicks, 'log', 'log', 1, 1., visible);
    
    % Left axes (darkness)
    set(fh, 'CurrentAxes', ahLeft)
    ylh = ylabel('\DeltaI_{JND} (R*)');
    ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
    for j = 1:numel(firstThs)
      modelParams(i) = tmpVals(j);
      modelDet = getModelPerformance(0, modelParams, nSubunits);
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
    for j = numel(firstThs):-1:1
      modelParams(i) = tmpVals(j);
      modelDipper = getModelPerformance(xVals, modelParams, nSubunits);
      phs(end+1) = plot(xVals, modelDipper, '-', 'Color', colorsDisc(j, :), 'Display', levelLabels{i}{j});
    end
    plot(xVals, theoryDipper, ':', 'Color', config.Color.Theory)
    
    % Fix the legend
    [lgh, icons] = legend(phs);
    lgh.Box = 'off';
    lgh.Position(1:2) = [legend_xpos(i), 0.26];
    fixLegendIcons(icons, legend_scaling(i), false)
    set(gca, 'Color', 'none')

    saveFigure(['Supplement figures', filesep, 'SupplementModelParameters_', paramNames{i}(1:end-1)])
%     export_fig(['Supplement figures', filesep, 'SupplementModelParameters_', paramNames{i}(1:end-1)], '-pdf', '-transparent', '-painters', '-nocrop')

  end
  
  fprintf('Done\n')
  
end


%% Function definitions

function ths = getModelPerformance(xVals, modelParams, nSubunits)
  
  noise = modelParams(1);
  params = [modelParams(3), modelParams(4), modelParams(2), 0, nSubunits];

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