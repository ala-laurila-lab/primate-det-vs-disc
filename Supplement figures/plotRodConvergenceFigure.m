function plotRodConvergenceFigure(visible)

  if nargin < 1
    visible = true;
  end
  warning('off','all')
  fprintf('Plotting rod convergence...\n')
  
  config = getConfiguration();           % Set default plot settings

  % Parameters
  exampleCellIdx = 3;   % This is the cell whos image is shown in b
  dx = 0.12;
  fit = getArborAndRFSize(config);

  % Set up figure window and get data
  [fh, ahs] = getFigureWindow(1, 3, [17, 6, 0.08, 0.22, 0.8, 0.6, dx, 0], true, visible);

  % Spatial RF fit
  set(fh, 'CurrentAxes', ahs(1))
  xDense = linspace(0, 1, 101);
  yHat = responseFun(xDense/2, fit.Params(exampleCellIdx, :));
  yFullRF = interp1(xDense/2, yHat, 2*fit.Params(exampleCellIdx, 1));

  hold on
  ph1 = plot(fit.SpotSizes{exampleCellIdx}*1e3/2, fit.Responses{exampleCellIdx}/max(yHat), 'ko', 'Display', 'Data');
  ph2 = plot(xDense*1e3/2, yHat/max(yHat), '-', 'Color', config.Color.SpatialRF, 'Display', 'Fit');
  plot(2*fit.Sigmas(exampleCellIdx)*[1, 1], [0, yFullRF/max(yHat)], ':', 'Color', config.Color.SpatialRF)
  hold off
  xlabel('Spot radius (μm)')
  ylabel('Response (a.u.)')
  [lgh, icons] = legend([ph1, ph2]);
  lgh.Box = 'off';
  % lgh.Position(1:2) = [0.15, 0.23];
  lgh.Position(1:2) = [0.19, 0.23];
  fixLegendIcons(icons, -0.35, false)
  title('Spatial RF')
  set(gca, 'Color', 'none', 'XLim', [-20, 520], 'XTick', [0, 2*round(fit.Sigmas(exampleCellIdx)), 500], 'XTickLabel', {'0', '2\sigma', '500'}, 'YLim', [-0.1, 1.1], 'YTick', [0, 1])
  text(-0.25, 1.2, 'a', 'Units', 'Normalized', 'FontSize', 12, 'FontWeight', 'bold')

  % Outline of dendritic tree and spatial RF
  set(fh, 'CurrentAxes', ahs(2))
  I = (255-double(imread('110519c4.jpg'))) / 255;
  pixelToUm = 500 / mean(size(I));
  center = [100, 100];
  rExample = 60.5;
  objFun = @(w) rfPixelSum(I, w, rExample);
  sigmaExample = fit.Sigmas(exampleCellIdx);
  w = fminsearch(objFun, center);

  hold on
  imagesc(I, [0, 0.5]);
  colormap('gray')
  fill([175, 250, 250, 175], [0, 0, 210, 210], 'k')
  theta = linspace(0, 2*pi, 101);
  ph1 = plot(sin(theta)*rExample+w(2), cos(theta)*rExample+w(1), '-', 'Color', config.Color.Morphology, 'Display', '');
  plot([w(2), w(2)+rExample], [w(1), w(1)], '-', 'Color', config.Color.Morphology);
  text(w(2)+rExample/2, w(1), 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', config.Color.Morphology, 'FontSize', 8.1);
  [lgh, icons] = legend(ph1);
  lgh.Box = 'off';
  lgh.Position(1:2) = [0.39, 0.23];
  fixLegendIcons(icons, -0.35, false)
  text(0.23, 0.1, sprintf('r: %3d μm', round(pixelToUm*rExample)), 'Units', 'Normalized', 'Color', [1, 1, 1], 'FontSize', 8.1);
  hold off
  axis equal
  set(gca, 'XLim', [-50, 250], 'XTick', [16.2, 100, 184.8], 'YTick', [16.2, 100, 184.8])
  set(gca,'XTickLabel', round(pixelToUm*[-84.8, 0, 84.8]), 'YTickLabel', round(pixelToUm*[-84.8, 0, 84.8]))
  xlabel('X (μm)')
  ylabel('Y (μm)')
  title('Morphological size')
  set(gca, 'Color', 'k')
  ahTmp = gca;
  ah1 = get(gca);

  axes('Position', get(ahTmp, 'Position'))
  ph2 = plot(sin(theta)*2*sigmaExample/pixelToUm+w(2), cos(theta)*2*sigmaExample/pixelToUm+w(1), ':', 'Color', config.Color.SpatialRF, 'Display', '');
  [lgh, icons] = legend(ph2);
  lgh.Box = 'off';
  lgh.Position(1:2) = [0.39, 0.73];
  fixLegendIcons(icons, -0.35, false)
  text(0.23, 0.92, sprintf('2\\sigma: %3d μm', round(2*sigmaExample)), 'Units', 'Normalized', 'Color', [1, 1, 1], 'FontSize', 8.1);
  hold off
  axis equal
  set(gca, 'XLim', [-50, 250], 'XTick', [], 'YTick', [], 'Color', 'none', 'YLim', get(ahTmp, 'YLim'))
  text(-0.25, 1.2, 'b', 'Units', 'Normalized', 'FontSize', 12, 'FontWeight', 'bold')

  % Arbor and spatial RF size, population data
  set(fh, 'CurrentAxes', ahs(3))
  axTmp = get(gca, 'Position');
  axTmp(1) = axTmp(1) - dx/5;
  set(gca, 'Position', axTmp.*[1, 1, 0.5, 1])
  hold on
  bar(1, 2*mean(fit.Sigmas), 0.6, 'FaceColor', config.Color.SpatialRF + (1-config.Color.SpatialRF)*config.Color.Fading, 'EdgeColor', 'none')
  bar(2, nanmean(fit.Radiuses), 0.6, 'FaceColor', config.Color.Morphology + (1-config.Color.Morphology)*config.Color.Fading, 'EdgeColor', 'none')
  for i = 1:numel(fit.Sigmas)
    plot([1, 2], [2*fit.Sigmas(i), fit.Radiuses(i)], 'k-')
  end
  plot(1*ones(1, numel(fit.Sigmas)), 2*fit.Sigmas, 'o', 'Color', config.Color.SpatialRF)
  plot(2*ones(1, numel(fit.Radiuses)), fit.Radiuses, 'o', 'Color', config.Color.Morphology)
  hold off
  set(gca, 'YLim', [0, 350], 'XLim', [0.5, 2.5], 'YTick', [0, 100, 200, 300], 'XTick', [1, 2], 'XTickLabel', {'2\sigma', 'r'}, 'Layer', 'top')
  ylabel('Radius (μm)')
  title({'RF size vs.', 'morphology'})
  set(gca, 'Color', 'none')
  text(-0.5, 1.2, 'c', 'Units', 'Normalized', 'FontSize', 12, 'FontWeight', 'bold')

  % Scaling factor for On and OFF RGCs, population data
  axPosTmp = get(gca, 'Position');
  axPosTmp(1) = axPosTmp(1) + axPosTmp(3) + dx*4/5;
  ah4 = axes('Position', axPosTmp);
  hold on
  onCells = contains(fit.Tags, 'On');
  bar(1, 2*nanmean(fit.Sigmas(onCells==1)./fit.Radiuses(onCells==1)), 0.6, 'FaceColor', config.Color.On + (1-config.Color.On)*config.Color.Fading, 'EdgeColor', 'none')
  bar(2, 2*nanmean(fit.Sigmas(onCells==0)./fit.Radiuses(onCells==0)), 0.6, 'FaceColor', config.Color.Off + (1-config.Color.Off)*config.Color.Fading, 'EdgeColor', 'none')
  plot(1*ones(1, sum(onCells==1)), 2*fit.Sigmas(onCells==1)./fit.Radiuses(onCells==1), 'o', 'Color', config.Color.On)
  plot(2*ones(1, sum(onCells==0)), 2*fit.Sigmas(onCells==0)./fit.Radiuses(onCells==0), 'o', 'Color', config.Color.Off)
  hold off
  set(gca, 'YLim', [0, 2.75], 'XLim', [0.5, 2.5], 'YTick', [0, 1, 2], 'XTick', [1, 2], 'XTickLabel', {'ON', 'OFF'}, 'Layer', 'top', 'Color', 'none')
  title({'Scaling', 'factor'})
  ylabel('2\sigma/r')
  text(-0.5, 1.2, 'd', 'Units', 'Normalized', 'FontSize', 12, 'FontWeight', 'bold')

  % Statistics
  ratioOn = 2*fit.Sigmas(onCells==1)./fit.Radiuses(onCells==1);
  ratioOn = ratioOn(~isnan(ratioOn));
  ratioOnNorm = (ratioOn-mean(ratioOn)) ./ std(ratioOn);
  ratioOff = 2*fit.Sigmas(onCells==0)./fit.Radiuses(onCells==0);
  ratioOff = ratioOff(~isnan(ratioOff));
  ratioOffNorm = (ratioOff-mean(ratioOff)) ./ std(ratioOff);
  [H_ks_on, p_ks_on] = kstest(ratioOnNorm);
  fprintf('KS-test for ON ratios: p=%1.2f\n', p_ks_on)
  [H_ks_off, p_ks_off] = kstest(ratioOffNorm);
  fprintf('KS-test for OFF ratios: p=%1.2f\n', p_ks_off)
  [H, p, ~, stats] = ttest2(ratioOff, ratioOn, 'Vartype','unequal');
  fprintf('t-test for equal ratios: p=%1.2f\n', p)
  stdPooled = sqrt( ( (numel(ratioOn)-1)*nanvar(ratioOn) + (numel(ratioOff)-1)*nanvar(ratioOff) ) / (numel(ratioOn)+numel(ratioOff)-2) );
  cohensd = (nanmean(ratioOff)-nanmean(ratioOn)) / stdPooled; 
  fprintf('Cohen''s d for equal ratios: d=%1.2f\n', cohensd)
  
  saveFigure(['Supplement figures', filesep, 'SupplementRodConvergence'])
%   export_fig(['Supplement figures', filesep, 'SupplementRodConvergence'], '-pdf', '-transparent', '-painters', '-nocrop')

  fprintf('Done\n')
  warning('on','all')
  
end

%% Function definitions

function yHat = responseFun(x, param)

  yHat = zeros(1, numel(x));
  for i = 1:numel(x)
    yHat(i) = getRodsPerRGC(param(1), param(2), x(i)/param(1));
  end

end

function pixelSum = rfPixelSum(I, w, radius)

  [nRows, nCols] = size(I);
  [X1, X2] = meshgrid(1:nRows, 1:nCols);
  radii = sqrt((X1-w(1)).^2 + (X2-w(2)).^2);
  mask = radii' < radius;
  pixelSum = -sum(sum(I(mask)));
  
end