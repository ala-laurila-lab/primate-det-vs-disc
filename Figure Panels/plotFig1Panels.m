function plotFig1Panels(visible)

  if nargin < 1
    visible = true;
  end

  fprintf('Plotting Fig 1 panels...\n')

  config = getConfiguration();
  cd(config.rootPath)

  % Parameters
  global width height x0 y0 xw yh dx dy
  width = 6;      % panel width, cm
  height = 4;      % panel height, cm
  x0 = 0.2;
  y0 = 0.26;
  xw = 0.70;
  yh = 0.65;
  dx = 0.02;
  dy = 0.15;
  xLim = [0.3, 40];
  xLim2AFC = [0.3, 40];
  yLim = [0.5, 10];
  yLim2AFC = [45, 105];
  logTicks = [0.1, 1, 10, 100];
  afcTicks = [50, 75, 100];
  marker = 'o';
  letters = 'abcdefghij';


  xVals = logspace(log10(xLim(1)), log10(xLim(2)), 101);
  thTheory = getPoissonDiscriminationLimitVec(xVals, 0.75, 0) - xVals;
  thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, 0);

  % Parameters for four example 2AFC curves
  noise = 2;
  pedestal = 4;
  thresholds = [0, 6];
  thAFC = 0.75;

  %% Isomerization distributions
  signalMeans = [0, 4, 8, 12];
  dr = 0.025;
  rMax = 22;

  rVals = 0:dr:rMax;
  rIntIdxs = mod(rVals, 1) == 0;

  rValsWide = (-0.5+dr):dr:(rMax+0.5);
  rValsNoise = (-0.5+dr):dr:(0.5);
  pNoise = ones(1, numel(rValsNoise));

  % colors = colormap(gray(6));
  colors = [linspace(0, 0.6, 4)', linspace(0, 0.6, 4)', linspace(0, 0.6, 4)'];
  labels = {'N', 'N+S_1', 'N+S_2', 'N+S_3'};
  % colors = get(gca,'colororder');

  xStretch = 1;
  yStretch = 1.2;
  fprintf('Tikz ys: %1.5f\n', (1-y0/yStretch-yh)*height*yStretch);
  fprintf('Tikz yh: %1.5f\n', (yh-dy)*0.325*height*yStretch);
  for i = 1:numel(thresholds)

    % For saving data to an excel sheet
    tableLabelsRStar = {[{'R*'}, labels]};
    tableDataRStar = {{0:rMax}};

    [fh, ahBottom, ahTop] = getSplitVerticalAxes([-0.5, rMax+0.5], [0, 1.05], 0:5:20, [], xStretch, yStretch, visible);

    % Distributions below
    set(fh, 'CurrentAxes', ahBottom)
    for j = 1:numel(signalMeans)
      pSignal = zeros(1, numel(rVals));
      pSignal(rIntIdxs) = poisspdf(0:rMax, signalMeans(j)+noise);
      pSignalAndNoise = conv(pSignal, pNoise);
      pSignalAndNoise = pSignalAndNoise / max(poisspdf(0:rMax, noise));
      tableDataRStar{1}{j+1} = pSignal(rIntIdxs);

      if thresholds(i) == 0
        rTh = -1;
      else
        rTh = thresholds(i)+0.5;
      end
      maskBelow = rValsWide < rTh;
      idxTh = find(maskBelow == 0, 1);
      fill([rValsWide(1), rValsWide(maskBelow), rValsWide(idxTh)], [0, pSignalAndNoise(maskBelow), 0], colors(j, :), 'FaceAlpha', 0.05, 'EdgeColor', 'none');
      plot([rValsWide(1), rValsWide(maskBelow), rValsWide(idxTh)], [0, pSignalAndNoise(maskBelow), 0], '-', 'Color', [colors(j, :), 0.15], 'LineWidth', 1);
      fill([rValsWide(idxTh), rValsWide(~maskBelow), rValsWide(end)], [0, pSignalAndNoise(~maskBelow), 0], colors(j, :), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
      plot([rValsWide(idxTh), rValsWide(~maskBelow), rValsWide(end)], [0, pSignalAndNoise(~maskBelow), 0], '-', 'Color', colors(j, :), 'LineWidth', 1);
      if thresholds(i) > 0
        plot([rTh, rTh], [0, 0.7], 'k-')
      end
      text(noise*1.1+signalMeans(j)-0.5, 0.85, labels{j}, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 6, 'Color', colors(j, :))
    end
    xlabel('R*')
    ylabel('Probability')
    set(gca, 'Color', 'none')
    set(gca, 'Layer', 'top')

    % Stimulus magnitudes on top
    set(fh, 'CurrentAxes', ahTop)
    ds = 0.15;
    for j = 1:numel(signalMeans)
      plot([-1, -ds, -ds, ds, ds, 1]+noise+signalMeans(j)-0.5, [0, 0, 1, 1, 0, 0]*signalMeans(j), 'Color', colors(j, :), 'LineWidth', 1);
    end
    set(gca, 'YLim', [0, max(signalMeans)], 'Color', 'none')

    saveFigure(['Figure Panels', filesep, 'Fig1_', 'Distributions_th', num2str(thresholds(i)>0)], 'png')
    try
      writeArraysToExcel(['Figure data', filesep, 'Fig1', letters(i+2),'.xlsx'], 'data', tableLabelsRStar, tableDataRStar)
    catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
    end

  end

  %% 2AFC

  for i = 1:numel(thresholds)

    % Get performance
    det2AFC = 100*getPerformancePoissonVec(noise, xVals+noise, thresholds(i));
    disc2AFC = 100*getPerformancePoissonVec(pedestal+noise, pedestal+xVals+noise, thresholds(i));
    det2AFC_ex = 100*getPerformancePoissonVec(noise, signalMeans(2:end)+noise, thresholds(i));
    disc2AFC_ex = 100*getPerformancePoissonVec(signalMeans(2)+noise, signalMeans(3:end)+noise, thresholds(i));

    % For saving data to an excel sheet
    tableLabels2AFC = {{'DeltaI', 'Dark', 'S1'}, {'DeltaI_ex', 'Dark_ex', 'S1_ex'}};
    tableData2AFC = {{[0, xVals], [], []}, {[], [], []}};

    % Fill the data table
    tableData2AFC{1}{2} = [50, det2AFC];
    tableData2AFC{1}{3} = [50, disc2AFC];
    % Example points
    tableData2AFC{2}{1} = signalMeans(2:end);
    tableData2AFC{2}{2} = det2AFC_ex;
    tableData2AFC{2}{3} = [disc2AFC_ex, nan];

    % Get figure window and axes
    [fh, ahLeft, ahRight] = getSplitLogAxes(xLim2AFC, yLim2AFC, logTicks, afcTicks, 'log', 'linear', 1, 1, visible);

    % Background axes for continous 75 % line
    ahThreshold = axes('Position', [x0, y0, xw, yh]);
    phs = [];
    set(fh, 'CurrentAxes', ahThreshold)
    plot([0, 1], [75, 75], '-.', 'Color', config.Color.Theory, 'LineWidth', 0.5)
    set(gca, 'YLim', yLim2AFC, 'XLim', [0, 1], 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none', 'Color', 'none')

    % left axes, Delta I = 0
    set(fh, 'CurrentAxes', ahLeft)
    set(gca, 'XTickLabel', 0)
    text(0.5, 0.9, sprintf('I_{ref}=Dark'), 'Color', config.Color.Det, 'Units', 'normalized', 'HorizontalAlignment', 'left')
    text(0.5, 0.725, sprintf('I_{ref}=S_1'), 'Color', config.Color.Disc, 'Units', 'normalized', 'HorizontalAlignment', 'left')
    plot(0, 50, '.', 'Color', config.Color.Disc);
    ylabel('Percent correct')
    set(gca, 'Color', 'none')

    % right axes, Delta I > 0
    set(fh, 'CurrentAxes', ahRight)

    % Interpolate to find thresholds
    thDet = interp1(det2AFC, xVals, 75);
    thDisc = interp1(disc2AFC, xVals, 75);
    arrow([thDet, 75], [thDet, yLim2AFC(1)], 4, 'Color', config.Color.Det+(1-config.Color.Det)*config.Color.Fading)
    arrow([thDisc, 75], [thDisc, yLim2AFC(1)], 4, 'Color', config.Color.Disc+(1-config.Color.Disc)*config.Color.Fading)

    phs(end+1) = plot(xVals, det2AFC, '-', 'Color', config.Color.Det);
    plot(signalMeans(2:end), det2AFC_ex, marker, 'Color', config.Color.Det);
    phs(end+1) = plot(xVals, disc2AFC, '-', 'Color', config.Color.Disc);
    plot(signalMeans(3:end)-signalMeans(2), disc2AFC_ex, marker, 'Color', config.Color.Disc);
    set(gca, 'XTickLabel', [])
    xlh = xlabel('\DeltaI (R*)');
    xlh.Position(2) = xlh.Position(2) - abs(xlh.Position(2) * 0.15);
    set(gca, 'Color', 'none')
    uistack(ahRight)

    textSep = 2;
    if thresholds(i) == 0
      text(signalMeans(2:end), det2AFC_ex+textSep, {'I', 'II', 'III'}, 'Color', config.Color.Det, 'Interpreter', 'LaTex', 'FontSize', 6, 'VerticalAlignment', 'Bottom', 'HorizontalAlignment', 'center')
      text(signalMeans(3:end)-signalMeans(2), disc2AFC_ex-textSep, {'I', 'II'}, 'Color', config.Color.Disc, 'Interpreter', 'LaTex', 'FontSize', 6, 'VerticalAlignment', 'Top', 'HorizontalAlignment', 'center')
      text(thDet, yLim2AFC(1), '\DeltaI_{JND}', 'Color', config.Color.Det, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Top', 'FontSize', 6)
      text(thDisc, yLim2AFC(1), '\Delta I_{JND}', 'Color', config.Color.Disc, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'Top', 'FontSize', 6)
    else
      text(signalMeans(2:end), det2AFC_ex-textSep, {'I', 'II', 'III'}, 'Color', config.Color.Det, 'Interpreter', 'LaTex', 'FontSize', 6, 'VerticalAlignment', 'Top', 'HorizontalAlignment', 'center')
      text(signalMeans(3:end)-signalMeans(2), disc2AFC_ex+textSep, {'I', 'II'}, 'Color', config.Color.Disc, 'Interpreter', 'LaTex', 'FontSize', 6, 'VerticalAlignment', 'Bottom', 'HorizontalAlignment', 'center')
      text(thDet, yLim2AFC(1), '\DeltaI_{JND}', 'Color', config.Color.Det, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'Top', 'FontSize', 6)
      text(thDisc, yLim2AFC(1), '\DeltaI_{JND}', 'Color', config.Color.Disc, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Top', 'FontSize', 6)
    end

    saveFigure(['Figure Panels', filesep, 'Fig1_', '2AFC_th', num2str(thresholds(i)>0)])
    try
      writeArraysToExcel(['Figure data', filesep, 'Fig1', letters(i+4),'.xlsx'], 'data', tableLabels2AFC, tableData2AFC)
    catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
    end
    
  end

  %% Dippers

  for i = 1:numel(thresholds)

    % Get the 
    disc2AFC = 100*getPerformancePoissonVec(pedestal+noise, pedestal+xVals+noise, thresholds(i));
    thDisc = interp1(disc2AFC, xVals, 75);

    % Just noticable difference
    darkJND = getPoissonDiscriminationLimitVec(noise, thAFC, thresholds(i))-noise;
    bgJND = getPoissonDiscriminationLimitVec(xVals+noise, thAFC, thresholds(i))-noise-xVals;

    % For saving data to an excel sheet
    tableLabelsJND = {{'I_ref', 'Theor. lim', 'Delta I JND'}};
    tableDataJND = {{[0, xVals], [thTheory0, thTheory], [darkJND, bgJND]}};

    [fh, ahLeft, ahRight] = getSplitLogAxes(xLim, yLim, logTicks, logTicks, 'log', 'log', 1, 1, visible);

    % Left, darkness
    phs = [];
    set(fh, 'CurrentAxes', ahLeft)
    plot(0, thTheory0, '.', 'Color', config.Color.Theory);
    phs(end+1) = plot(0, darkJND, marker, 'Color', config.Color.Det, 'Display', sprintf('I_{ref}=Dark'));
    ylh = ylabel('\DeltaI_{JND} (R*)');
    ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
    set(gca, 'Color', 'none')

    % Right, background
    set(fh, 'CurrentAxes', ahRight)
    plot(xVals, bgJND, '-', 'Color', config.Color.Disc);
    phs(end+1) = plot(pedestal, thDisc, marker, 'Color', config.Color.Disc, 'Display', sprintf('I_{ref}=S_1', pedestal));
    phs(end+1) = plot(xVals, thTheory, ':', 'Color', config.Color.Theory, 'Display', 'Theor. lim.');
    xlh = xlabel('I_{ref} (R*)');
    xlh.Position(2) = xlh.Position(2) + abs(xlh.Position(2) * 0.1);

    [lgh, icons] = legend(phs, 'Orientation', 'vertical');
    lgh.Box = 'off';
    lgh.Position(1:2) = [0.6, 0.26];
    fixLegendIcons(icons, -0.27, false)
    set(gca, 'Color', 'none')

    saveFigure(['Figure Panels', filesep, 'Fig1_', 'Dippers_th', num2str(thresholds(i)>0)])
    try
      writeArraysToExcel(['Figure data', filesep, 'Fig1', letters(i+6),'.xlsx'], 'data', tableLabelsJND, tableDataJND)
    catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
    end
    
  end
  
  fprintf('Done\n')
  
end

%% Function definitions

function [fh, ahLeft, ahRight] = getSplitLogAxes(xLim, yLim, xTicks, yTicks, xScale, yScale, xStretch, yStretch, visible)

  global width height x0 y0 xw yh dx

  [fh, ahLeft] = getFigureWindow(1, 1, [width*xStretch, height*yStretch, x0/xStretch, y0/yStretch, 2*dx/xStretch, yh + (yStretch-1)*(1-yh)/yStretch, 0, 0], true, visible);
  set(ahLeft, 'XLim', [-1, 1], 'XTick', 0, 'XTickLabel', 'Dark', 'YLim', yLim, 'YTick', yTicks, 'YTickLabel', yTicks, 'YScale', yScale); hold on;
  text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', get(gca, 'XColor'))
  tmpPos = get(gca, 'Position');
  tmpPos(1) = (x0 + 4*dx)/xStretch;
  tmpPos(3) = xw - 4*dx/xStretch + (xStretch-1)*(x0)/xStretch + (xStretch-1)*(1-x0-xw)/xStretch;
  ahRight = axes('Position', tmpPos, 'YLim', yLim, 'YScale', yScale, 'YTick', [], 'XLim', xLim, 'XScale', xScale, 'XTick', xTicks, 'XTickLabel', xTicks, 'YColor', 'none'); hold on;
  text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', get(gca, 'XColor'))
  
end

function [fh, ahBottom, ahTop] = getSplitVerticalAxes(xLim, yLim, xTicks, yTicks, xStretch, yStretch, visible)

  global width height x0 y0 xw yh dy

  [fh, ahBottom] = getFigureWindow(1, 1, [width*xStretch, height*yStretch, x0/xStretch, y0/yStretch, xw + (xStretch-1)*(1-xw)/xStretch, 0.675*(yh-dy), 0, 0], true, visible);
  set(ahBottom, 'XLim', xLim, 'XTick', xTicks, 'YLim', yLim, 'YTick', yTicks, 'YTickLabel', yTicks); hold on;
  tmpPos = get(gca, 'Position');
  tmpPos(2) = tmpPos(2)+tmpPos(4)+dy;
  tmpPos(4) = 0.325*(yh-dy);
  ahTop = axes('Position', tmpPos, 'YLim', [0, 1], 'YTick', [], 'XLim', xLim, 'XTick', xTicks, 'XTickLabel', [], 'XColor', 'none', 'YColor', 'none'); hold on;
  
end
