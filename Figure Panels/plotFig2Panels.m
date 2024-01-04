function plotFig2Panels(visible)

  if nargin < 1
    visible = true;
  end
  fprintf('Plotting Fig 2 panels...\n')

  config = getConfiguration();
  cd(config.rootPath)
  rgcResultsDir = config.RGCResultsPath;

  % Parameters
  global width height x0 y0 xw yh dx
  width = 6;      % panel width, cm
  height = 5;      % panel height, cm
  x0 = 0.2;
  y0 = 0.25;
  xw = 0.74;
  yh = 0.65;
  dx = 0.02;
  xLimOff = [0.5, 15];
  xLimOn = [0.5, 30];
  xLim2AFC = [0.5, 100];
  xLimWide = [0.5, 100];
  yLim = [0.5, 40];
  yLim2AFC = [45, 105];
  yLimWide = [0.5, 100];
  logTicks = [0.1, 1, 10, 100];
  afcTicks = [50, 75, 100];
  onExample = '020519c8';
  offExample = '261119c2';
  onRasters = [1, 3, 5];
  offRasters = [1, 3, 5];
  onPedIdx = 3;
  offPedIdx = 3;
  marker = 'o';
  letters = 'abcdefghij';

  onSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'ON', xLimOn);
  offSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'OFF', xLimOff);

  xValsOn = onSummary.discrimination.pedestalsInterp;
  xValsOff = offSummary.discrimination.pedestalsInterp;
  thTheoryOn = getPoissonDiscriminationLimitVec(xValsOn, 0.75, 0) - xValsOn;
  thTheoryOff = getPoissonDiscriminationLimitVec(xValsOff, 0.75, 0) - xValsOff;
  xValsWide = logspace(log10(xLimWide(1)), log10(xLimWide(2)), 101);
  thTheoryWide = getPoissonDiscriminationLimitVec(xValsWide, 0.75, 0) - xValsWide;
  thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, 0);

  summaryTags = {'ON', 'OFF'};
  xLims = {xLimOn, xLimOff};
  xVals = {xValsOn, xValsOff};
  exampleCells = {onExample, offExample};
  dataSummaries = [onSummary, offSummary];
  thTheories = {thTheoryOn, thTheoryOff};
  pedIdxs = [onPedIdx, offPedIdx];
  rasterIdxs = [onRasters; offRasters];


  %% Raster

  for i = 1:2

    [fh, ahs] = getFigureWindow(1, 3, [width, 2., x0, y0, xw, 0.6, dx, 0], true, visible);

    load(fullfile(rgcResultsDir, 'new', summaryTags{i}, [exampleCells{i}, '.mat']), 'out');

    for j = 1:3

      set(fh, 'CurrentAxes', ahs(j))

      % Padding so that pcolor don't remove any epochs
      raster = out.rasters{rasterIdxs(i, j)};
      % Subsample to get wider pixels
      raster = filter2([1, 1, 1, 1], raster);
      raster = raster(1:50, 1:4:end);
  %     raster = raster(1:100, 1:2:end);
      raster = [raster; zeros(1, size(raster, 2))];
      raster = [raster, zeros(size(raster, 1), 1)];

      colormap([1, 1, 1; 0, 0, 0])
      ph = pcolor(raster > 0);
      ph.EdgeColor = 'none';
      set(gca, 'XTick', [], 'YTick', [], 'CLim', [0, 1])
      text(0, size(raster, 1), sprintf('%1.1f R*/RGC', out.rStarPerRGCPerFlash(rasterIdxs(i, j))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 6);
      text(size(raster, 2)/2, 0, '\uparrow', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 6)
      if j == 1
        text(0, 0, '-0.5 s', 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Top', 'FontSize', 6)
        text(size(raster, 2), 0, '0.5 s', 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top', 'FontSize', 6)
      end

    end

    saveFigure(['Figure Panels', filesep, 'Fig2_', summaryTags{i}, 'Rasters'])

  end

  %% 2AFC

  for i = 1:2

    load(fullfile(rgcResultsDir, 'new', summaryTags{i}, [exampleCells{i}, '.mat']), 'out');

    % Get figure window and axes
    [fh, ahLeft, ahRight] = getSplitLogAxes(xLim2AFC, yLim2AFC, logTicks, afcTicks, 'log', 'linear', 1, 1, visible);

    % Background axes for continous 75 % line
    ahThreshold = axes('Position', [x0, y0, xw, yh]);
    set(fh, 'CurrentAxes', ahThreshold)
    plot([0, 1], [75, 75], '-.', 'Color', config.Color.Theory, 'LineWidth', 0.5)
    set(gca, 'YLim', yLim2AFC, 'XLim', [0, 1], 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none', 'Color', 'none')

    % left axes, Delta I = 0
    set(fh, 'CurrentAxes', ahLeft)
    set(gca, 'XTickLabel', 0)
    text(0.5, 0.9, sprintf('I_{ref} = %1.1f R*/RGC', out.twoAFC.discrimination.pedestal(pedIdxs(i))), 'Color', config.Color.Disc, 'Units', 'normalized', 'HorizontalAlignment', 'left')
    plot(0, out.twoAFC.discrimination.fractionCorrect{pedIdxs(i)}(1)*1e2, marker, 'Color', config.Color.Disc+(1-config.Color.Disc)*config.Color.Fading);
    ylabel('Percent correct')
    set(gca, 'Color', 'none')

    % left axes, Delta I > 0
    phs = [];
    set(fh, 'CurrentAxes', ahRight)
    phs(end+1) = plot(out.twoAFC.detection.fit.x, out.twoAFC.detection.fit.y*1e2, '-', 'Color', config.Color.Det, 'Display', sprintf('I_p=0.0 R*/RGC'));
    phs(end+1) =  plot(out.twoAFC.discrimination.fit.x, out.twoAFC.discrimination.fit.y{pedIdxs(i)}*1e2, '-', 'Color', config.Color.Disc, 'Display', sprintf('I_p=%1.1f R*/RGC', out.twoAFC.discrimination.pedestal(pedIdxs(i))));
    plot(out.twoAFC.detection.intensities(1:end), out.twoAFC.detection.fractionCorrect(1:end)*1e2, marker, 'Color', config.Color.Det+(1-config.Color.Det)*config.Color.Fading);
    plot(out.twoAFC.discrimination.intensityDifference{pedIdxs(i)}(2:end), out.twoAFC.discrimination.fractionCorrect{pedIdxs(i)}(2:end)*1e2, marker, 'Color', config.Color.Disc+(1-config.Color.Disc)*config.Color.Fading);
    xlabel('\DeltaI (R*/RGC)')
    set(gca, 'Color', 'none')
    uistack(ahRight)

    % For saving data to an excel sheet
    tableLabels2AFC = {{'DeltaI_fit', 'Det_fit', 'Disc_fit'}, {'DeltaI_det', 'Det'}, {'DeltaI_disc', 'Disc'}};
    tableData2AFC = {{[], [], []}, {[], []}, {[], []}};
    % Fitted functions
    tableData2AFC{1}{1} = out.twoAFC.detection.fit.x;
    tableData2AFC{1}{2} = out.twoAFC.detection.fit.y*1e2;
    tableData2AFC{1}{3} = out.twoAFC.discrimination.fit.y{pedIdxs(i)}*1e2;
    % Detection data points
    tableData2AFC{2}{1} = out.twoAFC.detection.intensities(1:end);
    tableData2AFC{2}{2} = out.twoAFC.detection.fractionCorrect(1:end)*1e2;
    % Discrimination data points
    tableData2AFC{3}{1} = out.twoAFC.discrimination.intensityDifference{pedIdxs(i)}(2:end);
    tableData2AFC{3}{2} = out.twoAFC.discrimination.fractionCorrect{pedIdxs(i)}(2:end)*1e2;

    saveFigure(['Figure Panels', filesep, 'Fig2_', summaryTags{i}, '2AFC'])
    try
      writeArraysToExcel(['Figure data', filesep, 'Fig2', letters(5-i),'.xlsx'], 'data', tableLabels2AFC, tableData2AFC)
    catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
    end
    
  end

  %% Dippers

  % Detection statistics
  fprintf('t-test for different average detection thresholds\n')
  [~, pEqual] = ttest2(dataSummaries(2).detection.ths, dataSummaries(1).detection.ths);
  [~, pUnequal] = ttest2(dataSummaries(2).detection.ths, dataSummaries(1).detection.ths, 'Vartype','unequal'); 
  fprintf('Equal variances:\tp = %1.2f\n', pEqual)
  fprintf('Unequal variances:\tp = %1.2f\n', pUnequal)
  meanDiff = mean(dataSummaries(2).detection.ths) - mean(dataSummaries(1).detection.ths);
  nOn = numel(dataSummaries(1).detection.ths);
  nOff = numel(dataSummaries(2).detection.ths);
  pooledStd = sqrt( ((nOff-1)*var(dataSummaries(2).detection.ths)+(nOn-1)*var(dataSummaries(1).detection.ths))/(nOn+nOff-2) );
  cohensd = abs(meanDiff / pooledStd);
  fprintf('Effect size (Cohen''s d) for different average detection thresholds\n')
  fprintf('Unequal variances:\td = %1.2f\n', cohensd)

  % kstest to check whether the data could have come from a standard normal distribution
%   [H, p] = kstest((dataSummaries(1).detection.ths-mean(dataSummaries(1).detection.ths))/nanstd(dataSummaries(1).detection.ths))
%   [H, p] = kstest((dataSummaries(2).detection.ths-mean(dataSummaries(2).detection.ths))/nanstd(dataSummaries(2).detection.ths))


  % Discrimination statistics
  fprintf('t-test for different average discrimination thresholds\n')
  allDiscOn = cellfun(@nanmean, dataSummaries(1).discrimination.ths);
  allDiscOff = cellfun(@nanmean, dataSummaries(2).discrimination.ths);
  [~, pUnequalDisc] = ttest2(allDiscOn, allDiscOff, 'Vartype','unequal');
  fprintf('Unequal variances:\tp = %1.5f\n', pUnequalDisc)
  meanDiffDisc = mean(allDiscOn) - mean(allDiscOff);
  nOnDisc = numel(allDiscOn);
  nOffDisc = numel(allDiscOff);
  pooledStd = sqrt( ((nOffDisc-1)*var(allDiscOff)+(nOnDisc-1)*var(allDiscOn))/(nOnDisc+nOffDisc-2) );
  cohensdDisc = abs(meanDiffDisc / pooledStd);
  fprintf('Effect size (Cohen''s d) for different average discrimation thresholds\n')
  fprintf('Unequal variances:\td = %1.2f\n', cohensdDisc)
  
  % kstest to check whether the data could have come from a standard normal distribution
%   [H, p] = kstest((allDiscOn-mean(allDiscOn))/std(allDiscOn))
%   [H, p] = kstest((allDiscOff-mean(allDiscOff))/std(allDiscOff))
  
  for i = 1:2
    
    % For saving data to an excel sheet
    tableLabelsJND = {{'I_ref', 'Theor. lim'}};
    tableDataJND = {{[0, xValsWide], [thTheory0, thTheoryWide]}};

    [fh, ahLeft, ahRight] = getSplitLogAxes(xLimWide, yLimWide, logTicks, logTicks, 'log', 'log', 1, 1, visible);

    set(fh, 'CurrentAxes', ahLeft)
    plot(0, thTheory0, '.', 'Color', config.Color.Theory);
    set(fh, 'CurrentAxes', ahRight)
    plot(xValsWide, thTheoryWide, ':', 'Color', config.Color.Theory)

    phs = [];
    for j = 1:numel(dataSummaries(i).detection.ths)
      set(fh, 'CurrentAxes', ahLeft)
      plot(0, dataSummaries(i).detection.ths(j), '.', 'Color', config.Color.Det + (1-config.Color.Det)*config.Color.Fading);

      set(fh, 'CurrentAxes', ahRight)
      xTmp = [xLims{i}(1), dataSummaries(i).discrimination.pedestals{j}];
      yTmp = [dataSummaries(i).detection.ths(j), dataSummaries(i).discrimination.ths{j}];
      phs(2) = plot(xTmp(~isnan(yTmp)), yTmp(~isnan(yTmp)), '-', 'LineWidth', 0.5, 'Color', config.Color.Disc + (1-config.Color.Disc)*config.Color.Fading, 'Display', 'Single');

      cellNumber = sprintf('cell%i', j);
      tableLabelsJND{end+1} = {['I_ref_', cellNumber], ['JND_', cellNumber]};
      tableDataJND{end+1} = {[0, dataSummaries(i).discrimination.pedestals{j}], [dataSummaries(i).detection.ths(j), dataSummaries(i).discrimination.ths{j}]};
    end
    exampleIdx = find(contains(dataSummaries(i).tags, exampleCells{i}));
    phs(1) = plot([xLims{i}(1), dataSummaries(i).discrimination.pedestals{exampleIdx}], [dataSummaries(i).detection.ths(exampleIdx), dataSummaries(i).discrimination.ths{exampleIdx}], ':', 'LineWidth', 1.5, 'Color', config.Color.Disc, 'Display', 'Example');
    plot(dataSummaries(i).discrimination.pedestals{exampleIdx}(pedIdxs(i)), dataSummaries(i).discrimination.ths{exampleIdx}(pedIdxs(i)), marker, 'Color', config.Color.Disc);

    tableLabelsJND{end+1} = {'I_ref_mean', 'JND_mean'};
    tableDataJND{end+1} = {[0, dataSummaries(i).discrimination.pedestalsInterp], [dataSummaries(i).detection.mean, dataSummaries(i).discrimination.mean]};

    set(fh, 'CurrentAxes', ahLeft)
    errorbar(0, dataSummaries(i).detection.mean, dataSummaries(i).detection.se, '-', 'Color', config.Color.Det)
    plot(0, dataSummaries(i).detection.mean, '.', 'Color', config.Color.Det);
    text(0.5, 0.9, sprintf('n = %d', numel(dataSummaries(i).discrimination.ths)), 'Units', 'normalized', 'HorizontalAlignment', 'left')
    ylh = ylabel('\DeltaI_{JND} (R*/RGC)');
    ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
    set(gca, 'Color', 'none')
    set(fh, 'CurrentAxes', ahRight)
    phs(end+1) = plot(dataSummaries(i).discrimination.pedestalsInterp, dataSummaries(i).discrimination.mean, '-', 'Color', config.Color.Disc, 'Display', 'Mean');
    xlh = xlabel('I_{ref} (R*/RGC)');
  %   xlh.Position(2) = xlh.Position(2) + abs(xlh.Position(2) * 0.05);
    set(gca, 'Color', 'none')

    [lgh, icons] = legend(phs, 'Orientation', 'vertical');
    lgh.Box = 'off';
    lgh.Position(1:2) = [0.66, 0.26];
    fixLegendIcons(icons, -0.3, false)

    % Second invisible axis on top so that we can place a second legend
    ahRightCopy = axes('Position', get(ahRight, 'Position'), 'color', 'none', ...
                       'XScale', 'log', 'XLim', xLimWide, ...
                       'YScale', 'log', 'YLim', yLimWide, ...
                       'XTick', [], 'YTick', [], ...
                       'XColor', 'none', 'YColor', 'none');
    hold on
    phs = plot(nan, nan, ':', 'Color', config.Color.Theory, 'Display', 'Theor. lim.');
    [lgh, icons] = legend(phs, 'Orientation', 'vertical');
    lgh.Box = 'off';
    lgh.Position(1:2) = [0.66, 0.79];
    fixLegendIcons(icons, -0.27, false)
    
    fprintf('%s, Detection mean and SEM: %1.2f +- %1.2f\n', summaryTags{i}, dataSummaries(i).detection.mean, dataSummaries(i).detection.se)
    
    [minSep, minIdx] = min(dataSummaries(i).discrimination.mean ./ thTheories{i});
    fprintf('%s, Detection distance to theory: %1.1f\n', summaryTags{i}, dataSummaries(i).detection.mean / thTheory0)
    fprintf('%s, Min distance to theory: %1.1f at %1.1f R*\n', summaryTags{i}, minSep, xVals{i}(minIdx))

    saveFigure(['Figure Panels', filesep, 'Fig2_', summaryTags{i}, 'Dippers'])
    try
      writeArraysToExcel(['Figure data', filesep, 'Fig2', letters(7-i),'.xlsx'], 'data', tableLabelsJND, tableDataJND)
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
