function plotFig3Panels(visible)

  if nargin < 1
    visible = true;
  end
  fprintf('Plotting Fig 3 panels...\n')

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
  xLim = [0.5, 15];
  xLimPsycho = [0.5, 40];
  xLim2AFC = [0.5, 100];
  xLimWide = [0.5, 100];
  yLim = [0.5, 50];
  yLim2AFC = [45, 105];
  yLimWide = [0.5, 100];
  yLimSummary = [0.5, 40];
  logTicks = [0.1, 1, 10, 100];
  afcTicks = [50, 75, 100];
  markers = 'os^vd';
  subject = 'S1';
  pedIdx = 3;
  letters = 'abcdefghij';

  onSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'ON', xLim);
  offSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'OFF', xLim);
  psychoSummary = getDataSummary(psychoResultsDir, {''}, [], xLimPsycho);

  xVals = onSummary.discrimination.pedestalsInterp;
  thTheory = getPoissonDiscriminationLimitVec(xVals, 0.75, 0) - xVals;
  xValsRetina = logspace(log10(xLim(1)), log10(25), 101);
  xValsWide = logspace(log10(xLimWide(1)), log10(xLimWide(2)), 101);
  thTheoryWide = getPoissonDiscriminationLimitVec(xValsWide, 0.75, 0) - xValsWide;
  xValsPsycho = psychoSummary.discrimination.pedestalsInterp;
  thTheoryPsycho = getPoissonDiscriminationLimitVec(xValsPsycho, 0.75, 0) - xValsPsycho;
  thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, 0);

  %% 2AFC
  
  load(fullfile(psychoResultsDir, [subject, '.mat']), 'out');
  marker = markers(contains(psychoSummary.tags, subject));

  % Get figure window and axes
  [fh, ahLeft, ahRight] = getSplitLogAxes(xLim2AFC, yLim2AFC, logTicks, afcTicks, 'log', 'linear', 1, 1, visible);

  ahThreshold = axes('Position', [x0, y0, xw, yh]);
  set(fh, 'CurrentAxes', ahThreshold)
  plot([0, 1], [75, 75], '-.', 'Color', config.Color.Theory, 'LineWidth', 0.5)
  set(gca, 'YLim', yLim2AFC, 'XLim', [0, 1], 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none', 'Color', 'none')

  set(fh, 'CurrentAxes', ahLeft)
  set(gca, 'XTickLabel', 0)
  subjectIdx = find(contains(psychoSummary.tags, subject));
  text(0, 92, ['O', num2str(subjectIdx)], 'HorizontalAlignment', 'Left')
  text(0, 100, sprintf('I_{ref} = %1.1f R*', psychoSummary.discrimination.pedestals{subjectIdx}(pedIdx)), 'Color', config.Color.Disc, 'HorizontalAlignment', 'left')
  plot(0, out.twoAFC.detection.fractionCorrect(1)*1e2, marker, 'Color', config.Color.Det+(1-config.Color.Det)*config.Color.Fading);
  plot(0, out.twoAFC.discrimination.fractionCorrect{pedIdx}(1)*1e2, marker, 'Color', config.Color.Disc+(1-config.Color.Disc)*config.Color.Fading);
  ylabel('Percent correct')
  set(gca, 'Color', 'none')

  set(fh, 'CurrentAxes', ahRight)
  plot(out.twoAFC.detection.fit.x, out.twoAFC.detection.fit.y*1e2, '-', 'Color', config.Color.Det);
  plot(out.twoAFC.discrimination.fit.x, out.twoAFC.discrimination.fit.y{pedIdx}*1e2, '-', 'Color', config.Color.Disc);
  plot(out.twoAFC.detection.intensities(2:end), out.twoAFC.detection.fractionCorrect(2:end)*1e2, marker, 'Color', config.Color.Det+(1-config.Color.Det)*config.Color.Fading);
  plot(out.twoAFC.discrimination.intensityDifference{pedIdx}(2:end), out.twoAFC.discrimination.fractionCorrect{pedIdx}(2:end)*1e2, marker, 'Color', config.Color.Disc+(1-config.Color.Disc)*config.Color.Fading);
  xlabel('\DeltaI (R*)')
  set(gca, 'Color', 'none')

  % For saving data to an excel sheet
  tableLabels2AFC = {{'DeltaI_fit', 'Det_fit', 'Disc_fit'}, {'DeltaI_det', 'Det'}, {'DeltaI_disc', 'Disc'}};
  tableData2AFC = {{[], [], []}, {[], []}, {[], []}};
  % Fitted functions
  tableData2AFC{1}{1} = out.twoAFC.detection.fit.x;
  tableData2AFC{1}{2} = out.twoAFC.detection.fit.y*1e2;
  tableData2AFC{1}{3} = out.twoAFC.discrimination.fit.y{pedIdx}*1e2;
  % Detection data points
  tableData2AFC{2}{1} = out.twoAFC.detection.intensities(1:end);
  tableData2AFC{2}{2} = out.twoAFC.detection.fractionCorrect(1:end)*1e2;
  % Discrimination data points
  tableData2AFC{3}{1} = out.twoAFC.discrimination.intensityDifference{pedIdx}(1:end);
  tableData2AFC{3}{2} = out.twoAFC.discrimination.fractionCorrect{pedIdx}(1:end)*1e2;

  saveFigure(['Figure Panels', filesep, 'Fig3_Psycho2AFC'])
  try
    writeArraysToExcel(['Figure data', filesep, 'Fig3', letters(2),'.xlsx'], 'data', tableLabels2AFC, tableData2AFC)
  catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
  end
    
  %% Psychophysics dipper

  % For saving data to an excel sheet
  tableLabelsJND = {{'I_ref', 'Theor. lim'}};
  tableDataJND = {{[0, xValsWide], [thTheory0, thTheoryWide]}};

  [fh, ahLeft, ahRight] = getSplitLogAxes(xLimWide, yLimWide, logTicks, logTicks, 'log', 'log', 1, 1, visible);

  set(fh, 'CurrentAxes', ahLeft)
  plot(0, thTheory0, '.', 'Color', config.Color.Theory);
  set(fh, 'CurrentAxes', ahRight)
  plot(xValsWide, thTheoryWide, ':', 'Color', config.Color.Theory)

  phs = [];
  for i = 1:numel(psychoSummary.detection.ths)
    set(fh, 'CurrentAxes', ahLeft)
    plot(0, psychoSummary.detection.ths(i), markers(i), 'Color', config.Color.Det + (1-config.Color.Det)*config.Color.Fading);

    set(fh, 'CurrentAxes', ahRight)
    plot([xLim(1), psychoSummary.discrimination.pedestals{i}], [psychoSummary.detection.ths(i), psychoSummary.discrimination.ths{i}], '-', 'Color', config.Color.Disc + (1-config.Color.Disc)*config.Color.Fading);
    phs(end+1) = plot(psychoSummary.discrimination.pedestals{i}, psychoSummary.discrimination.ths{i}, ['-', markers(i)], 'Color', config.Color.Disc + (1-config.Color.Disc)*config.Color.Fading, 'Display', ['O', num2str(i)]);
    if i == find(contains(psychoSummary.tags, subject))
      plot([xLim(1), psychoSummary.discrimination.pedestals{i}], [psychoSummary.detection.ths(i), psychoSummary.discrimination.ths{i}], ':', 'Color', config.Color.Disc);
      plot(psychoSummary.discrimination.pedestals{i}(pedIdx), psychoSummary.discrimination.ths{i}(pedIdx), markers(i), 'Color', config.Color.Disc);
    end

    tableLabelsJND{end+1} = {['I_ref_', psychoSummary.tags{i}(1:2)], ['JND_', psychoSummary.tags{i}(1:2)]};
    tableDataJND{end+1} = {[0, psychoSummary.discrimination.pedestals{i}], [psychoSummary.detection.ths(i), psychoSummary.discrimination.ths{i}]};

  end

  tableLabelsJND{end+1} = {'I_ref_mean', 'JND_mean'};
  tableDataJND{end+1} = {[0, psychoSummary.discrimination.pedestalsInterp], [psychoSummary.detection.mean, psychoSummary.discrimination.mean]};

  set(fh, 'CurrentAxes', ahLeft)
  plot(0, psychoSummary.detection.mean, '.', 'Color', config.Color.Det);
  ylabel('\DeltaI (R*)')
  set(gca, 'Color', 'none')
  set(fh, 'CurrentAxes', ahRight)
  plot(psychoSummary.discrimination.pedestalsInterp, psychoSummary.discrimination.mean, '-', 'Color', config.Color.Disc);
  xlabel('I_{ref} (R*)')
  set(gca, 'Color', 'none')

  [lgh, icons] = legend(phs, 'Orientation', 'horizontal');
  lgh.Box = 'off';
  lgh.Position(1:2) = [0.2, 0.8];
  fixLegendIcons(icons, -0.1, true)
  
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
  lgh.Position(1:2) = [0.6, 0.26];
  fixLegendIcons(icons, -0.27, false)

  [minSep, minIdx] = min(psychoSummary.discrimination.mean ./ thTheoryPsycho);
  fprintf('Psychophysics, detection distance to theory: %1.1f fold\n', psychoSummary.detection.mean / thTheory0)
  fprintf('Psychophysics, discrimination min. distance to theory: %1.1f fold at %1.1f R*\n', minSep, xValsPsycho(minIdx))

  saveFigure(['Figure Panels', filesep, 'Fig3_PsychoDippers'])
  try
    writeArraysToExcel(['Figure data', filesep, 'Fig3', letters(3),'.xlsx'], 'data', tableLabelsJND, tableDataJND)
  catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
  end
  
  %% Dipper summary

  dataSummaries = [psychoSummary, offSummary, onSummary];
  colors = [config.Color.Psycho; config.Color.Off; config.Color.On];
  displayNames = {'Psychop.', 'OFF RGC', 'ON RGC'};
  tableLabelsSummary = {...
    {'I_ref', 'Theor. lim'},...
    {'I_ref_psycho', 'JND_psycho_mean', 'JND_psycho_se'},...
    {'I_ref_off', 'JND_off_mean', 'JND_off_se'},...
    {'I_ref_on', 'JND_on_mean', 'JND_on_se'}...
    };
  tableDataSummary = {{[0, xValsWide], [thTheory0, thTheoryWide]}, {}, {}, {}};

  [fh, ahLeft, ahRight] = getSplitLogAxes(xLimPsycho, yLimSummary, logTicks, logTicks, 'log', 'log', 1, 1., visible);

  % Add theoretical limit
  phs = [];
  set(fh, 'CurrentAxes', ahLeft)
  ylh = ylabel('\DeltaI_{JND} (R*)');
  ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
  plot(0, thTheory0, '.', 'Color', config.Color.Theory);
  set(gca, 'Color', 'none')
  set(fh, 'CurrentAxes', ahRight)
  xlabel('I_{ref} (R*)')
  phs(end+1) = plot(xValsWide, thTheoryWide, ':', 'Color', config.Color.Theory, 'Display', 'Theor. lim.');


  for i = 1:numel( dataSummaries)

    set(fh, 'CurrentAxes', ahLeft)
    errorbar(0, dataSummaries(i).detection.mean, dataSummaries(i).detection.se, '-', 'Color', colors(i, :)+(1-colors(i, :))*config.Color.Fading)
    plot(0, dataSummaries(i).detection.mean, '.', 'Color', colors(i, :), 'MarkerSize', 5);

    set(fh, 'CurrentAxes', ahRight)
    xVals = dataSummaries(i).discrimination.pedestalsInterp;
    mask = ~isnan(dataSummaries(i).discrimination.mean);
  %   fill([xVals(mask), flip(xVals(mask))], [dataSummaries(i).discrimination.mean(mask)+dataSummaries(i).discrimination.se(mask), flip(dataSummaries(i).discrimination.mean(mask)-dataSummaries(i).discrimination.se(mask))], colors(i, :)+(1-colors(i, :))*config.Color.Fading, 'EdgeColor', 'none')
    fill([xVals(mask), flip(xVals(mask))], [dataSummaries(i).discrimination.mean(mask)+dataSummaries(i).discrimination.se(mask), flip(dataSummaries(i).discrimination.mean(mask)-dataSummaries(i).discrimination.se(mask))], colors(i, :), 'FaceAlpha', 1-config.Color.Fading, 'EdgeColor', 'none')
    plot(xVals, dataSummaries(i).discrimination.mean, '-', 'LineWidth', 1, 'Color', colors(i, :), 'Display', displayNames{i});

    tableDataSummary{i+1} = {...
      [0, xVals], ...
      [dataSummaries(i).detection.mean, dataSummaries(i).discrimination.mean], ...
      [dataSummaries(i).detection.se, dataSummaries(i).discrimination.se]
      };
  end

  % Fix the legend
  [lgh, icons] = legend(phs, 'Orientation', 'vertical');
  lgh.Box = 'off';
  lgh.Position(1:2) = [0.6, 0.26];
  fixLegendIcons(icons, -0.27, false)
  set(gca, 'Color', 'none')

  saveFigure(['Figure Panels', filesep, 'Fig3_PsychoRGCDipper'], 'png')
  try
    writeArraysToExcel(['Figure data', filesep, 'Fig3', letters(4),'.xlsx'], 'data', tableLabelsSummary, tableDataSummary)
  catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
  end
    
  %% Dipper summary with model

  dataSummaries = [psychoSummary, onSummary];
  colors = [config.Color.Psycho; config.Color.On];
  displayNames = {'Psychop.', 'ON RGC'};
  tableLabelsModels = {...
    {'I_ref', 'Theor. lim'},...
    {'I_ref_psycho', 'JND_psycho_mean', 'JND_psycho_se'},...
    {'I_ref_on', 'JND_on_mean', 'JND_on_se'},...
    {'I_ref_M1_n3', 'JND_M1_n3', 'JND_M1_n6', 'JND_M2_n6'}
    };  
  tableDataModels = {{[0, xValsWide], [thTheory0, thTheoryWide]}, {}, {}, {}};

  [fh, ahLeft, ahRight] = getSplitLogAxes(xLimPsycho, yLimSummary, logTicks, logTicks, 'log', 'log', 1, 1., visible);

  % Add theoretical limit
  phs = [];
  set(fh, 'CurrentAxes', ahLeft)
  ylh = ylabel('\DeltaI_{JND} (R*)');
  ylh.Position(1) = ylh.Position(1) + abs(ylh.Position(1) * 0.1);
  plot(0, thTheory0, '.', 'Color', config.Color.Theory);
  set(gca, 'Color', 'none')
  set(fh, 'CurrentAxes', ahRight)
  xlabel('I_{ref} (R*)')
  phs(end+1) = plot(xValsWide, thTheoryWide, ':', 'Color', config.Color.Theory, 'Display', 'Theor. lim.');

  % Model parameters
  noise = 0.055;
  alphaRgc = 0.364;
  alphaPsycho = 0.333;
  firstTh = 2;
  secondTh = 2;
  nSubunitsRgc = 3;
  nSubunitsPsycho = 6;
  onParams = [firstTh, 0, alphaRgc, 0, nSubunitsRgc];
  retinaParams = [firstTh, 0, alphaRgc, 0, nSubunitsPsycho];
  psychoParams = [firstTh, secondTh, alphaPsycho, 0, nSubunitsPsycho];

  % Get model performance
  xValsModels = logspace(log10(xValsPsycho(1)), log10(xValsPsycho(end)), 36);
  onModelTh = onParams(5)*getPoissonDiscriminationLimitVec(noise, 0.75, onParams) - onParams(5)*noise;
  onModelDipper = onParams(5)*getPoissonDiscriminationLimitVec(xValsModels/onParams(5)+noise, 0.75, onParams) - onParams(5)*noise - xValsModels;
  retinaModelTh = retinaParams(5)*getPoissonDiscriminationLimitVec(noise, 0.75, retinaParams) - retinaParams(5)*noise;
  retinaModelDipper = retinaParams(5)*getPoissonDiscriminationLimitVec(xValsModels/retinaParams(5)+noise, 0.75, retinaParams) - retinaParams(5)*noise - xValsModels;
  psychoModelTh = psychoParams(5)*getPoissonDiscriminationLimitVec(noise, 0.75, psychoParams) - psychoParams(5)*noise;
  psychoModelDipper = psychoParams(5)*getPoissonDiscriminationLimitVec(xValsModels/psychoParams(5)+noise, 0.75, psychoParams) - psychoParams(5)*noise - xValsModels;

  % Add ON RGC and psychophysics data to the table
  for i = 1:numel(dataSummaries)
    xVals = dataSummaries(i).discrimination.pedestalsInterp;
    tableDataModels{i+1} = {...
      [0, xVals], ...
      [dataSummaries(i).detection.mean, dataSummaries(i).discrimination.mean], ...
      [dataSummaries(i).detection.se, dataSummaries(i).discrimination.se]
      };
  end

  % Add model performance to the table
  tableDataModels{4} = {...
    [0, xValsModels],...
    [onModelTh, onModelDipper],...
    [retinaModelTh, retinaModelDipper],...
    [psychoModelTh, psychoModelDipper]...
    };

  % Detection performance
  set(fh, 'CurrentAxes', ahLeft)
  for i = 1:numel(dataSummaries)
    errorbar(0, dataSummaries(i).detection.mean, dataSummaries(i).detection.se, '-', 'Color', colors(i, :)+(1-colors(i, :))*config.Color.Fading)
    plot(0, dataSummaries(i).detection.mean, '.', 'Color', colors(i, :), 'MarkerSize', 5);
    
  end
  for th = [onModelTh, retinaModelTh, psychoModelTh]
    plot(0, th, 'k.', 'MarkerSize', 5);
  end
  plot(0, thTheory0, '.', 'Color', config.Color.Theory);
  set(gca, 'Color', 'none')

  % ON RGC and psychophysics discrimination mean and se
  set(fh, 'CurrentAxes', ahRight)
  for i = 1:numel(dataSummaries)
    xVals = dataSummaries(i).discrimination.pedestalsInterp;
    mask = ~isnan(dataSummaries(i).discrimination.mean);
  %   fill([xVals(mask), flip(xVals(mask))], [dataSummaries(i).discrimination.mean(mask)+dataSummaries(i).discrimination.se(mask), flip(dataSummaries(i).discrimination.mean(mask)-dataSummaries(i).discrimination.se(mask))], colors(i, :)+(1-colors(i, :))*config.Color.Fading, 'EdgeColor', 'none')
    fill([xVals(mask), flip(xVals(mask))], [dataSummaries(i).discrimination.mean(mask)+dataSummaries(i).discrimination.se(mask), flip(dataSummaries(i).discrimination.mean(mask)-dataSummaries(i).discrimination.se(mask))], colors(i, :), 'FaceAlpha', 1-config.Color.Fading, 'EdgeColor', 'none')
    plot(xVals, dataSummaries(i).discrimination.mean, '-', 'LineWidth', 1, 'Color', colors(i, :), 'Display', displayNames{i});
  end

  % Model discrimination performance
  % Special way of plotting a dashed line so that one can adjust the 
  % length of the dashed elements
  xText = 0.5;
  yScale = 1.1;
  xValsModels2 = reshape(xValsModels, 2, numel(xValsModels)/2);
  onModelDipper2 = reshape(onModelDipper, 2, numel(xValsModels)/2);
  retinaModelDipper2 = reshape(retinaModelDipper, 2, numel(xValsModels)/2);
  psychoModelDipper2 = reshape(psychoModelDipper, 2, numel(xValsModels)/2);

  maxIdxOn = find(xVals(end) > xValsModels2(2,:), 1, 'last');
  maxIdxRetina = find(xValsRetina(end) > xValsModels2(2,:), 1, 'last');
  maxIdxPsycho = find(xValsPsycho(end) > xValsModels2(2,:), 1, 'last');

  % plot(xVals, onModelDipper, 'k-', 'LineWidth', 1)
  plot(xValsModels2(:, 1:maxIdxOn), onModelDipper2(:, 1:maxIdxOn), '-', 'Color', config.Color.Model, 'LineWidth', 1.5)
  % text(xText, onModelDipper(1)/yScale, 'I:', 'VerticalAlignment', 'top', 'Interpreter', 'latex', 'FontSize', 6)
  text(xText*1., onModelDipper(1)/yScale, sprintf('M1, n=%i', onParams(5)), 'VerticalAlignment', 'top', 'FontSize', 6)
  % plot(xValsRetina, retinaModelDipper, 'k-', 'LineWidth', 1)
  plot(xValsModels2(:, 1:maxIdxRetina), retinaModelDipper2(:, 1:maxIdxRetina), '-', 'Color', config.Color.Model, 'LineWidth', 1.5)
  % text(xText, retinaModelDipper(1)*yScale, 'II', 'VerticalAlignment', 'bottom', 'Interpreter', 'latex', 'FontSize', 6)
  text(xText, retinaModelDipper(1)*yScale, sprintf('M1, n=%i', retinaParams(5)), 'VerticalAlignment', 'bottom', 'FontSize', 6)
  % plot(xValsPsycho, psychoModelDipper, 'k-', 'LineWidth', 1)
  plot(xValsModels2(:, 1:maxIdxPsycho), psychoModelDipper2(:, 1:maxIdxPsycho), '-', 'Color', config.Color.Model, 'LineWidth', 1.5)
  % text(xText, psychoModelDipper(1)*yScale, 'III', 'VerticalAlignment', 'bottom', 'Interpreter', 'latex', 'FontSize', 6)
  text(xText, psychoModelDipper(1)*yScale, sprintf('M2, n=%i', psychoParams(5)), 'VerticalAlignment', 'bottom', 'FontSize', 6)

  % Arrows
  yScale = 1.1;
  arrow([2, yScale*interp1(xValsModels, onModelDipper, 2)], [2.5, interp1(xValsModels, retinaModelDipper, 2.5)/yScale], 4)
  arrow([3, yScale*interp1(xValsModels, retinaModelDipper, 3)], [5.2, interp1(xValsModels, psychoModelDipper, 5.2)/yScale], 4)

  % Fix the legend
  [lgh, icons] = legend(phs, 'Orientation', 'vertical');
  lgh.Box = 'off';
  lgh.Position(1:2) = [0.6, 0.26];
  fixLegendIcons(icons, -0.27, false)
  set(gca, 'Color', 'none')

  saveFigure(['Figure Panels', filesep, 'Fig3_PsychoRGCDipperModel'], 'png')
  try
    writeArraysToExcel(['Figure data', filesep, 'Fig3', letters(5),'.xlsx'], 'data', tableLabelsModels, tableDataModels)
  catch
      fprintf('Problem with writing figure data to an excel file, your Matlab version might be too old.\n')
  end
    
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
