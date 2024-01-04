function plotRasters(out, saveDir)

  % Hardcoded x-ticks 
  xTicks = [1, 251, 501];
  xTickLabels = [-500, 0, 500];
  
  % Combine all rasters into one
  raster = cell2mat(out.rasters');
  
  % Check how many epochs there is for each intensity
  nEpocs = cellfun(@(raster) size(raster, 1), out.rasters);
  cumEpochs = cumsum(nEpocs);
  
  % Determine where the counting window should be placed
  xUnits = out.param.countBinWidth / out.param.rasterBinWidth;
  spikeWinSize = numel(out.spikeCountWin)*xUnits;
  preSize = out.preTime / out.param.rasterBinWidth;

  % Padding so that pcolor don't remove any epochs
  raster = [raster; zeros(1, size(raster, 2))];
  raster = [raster, zeros(size(raster, 1), 1)];

  % Set up the figure
%   figure(1)
  fhs = findobj('Type', 'figure');
  if any(arrayfun(@(fh) fh.Number == 1, fhs))
    figure(1);
    clf;
  else
    [fh, ahs] = getFigureWindow(1, 1, [20, 15, 0.15, 0.3, 0.8, 0.6, 0, 0], false);
    clf;
  end
  ahRaster = axes('Position', [0.15, 0.30, 0.8, 0.6]);
  hold on
  colormap([1, 1, 1; 0, 0, 0])
  
  % plot raster
  ph = pcolor(raster);
  ph.EdgeColor = 'none';
  % mark the counting window
  bar((xUnits/2:xUnits:spikeWinSize), out.spikeCountWin*size(raster, 1), 1, 'EdgeColor', 'none', 'FaceColor', [0.5, 0.5, 1], 'FaceAlpha', 0.15)
  bar((xUnits/2:xUnits:spikeWinSize)+spikeWinSize, out.spikeCountWin*size(raster, 1), 1, 'EdgeColor', 'none', 'FaceColor', [0.5, 0.5, 1], 'FaceAlpha', 0.15)
  plot([spikeWinSize, spikeWinSize], [0, size(raster, 1)], 'k:', 'LineWidth', 1)
  text(spikeWinSize/2, size(raster, 1), 'Pre', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 15)
  text(spikeWinSize/2+spikeWinSize, size(raster, 1), 'Post', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 15)
  % Mark which epochs that below to each flash intensity
  text(-50, 0, 'R*/RGC', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15)
  for i = 1:(numel(nEpocs))
    plot([0, size(raster, 2)], (cumEpochs(i)+1)*[1, 1], '-', 'Color', 0.5*ones(1, 3))
    text(-50, cumEpochs(i), sprintf('%2.1f', out.rStarPerRGCPerFlash(i)), ....
      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
      'FontSize', 15)
  end
  hold off
  % Set axis properties
  set(gca, 'XLim', [0, size(raster, 2)], 'YLim', [1, size(raster, 1)])
  set(gca, 'XTick', [], 'YDir', 'rev', 'YTick', [], 'CLim', [0, 1])

  title(out.cellName)
  
  time = (-500+out.param.countBinWidth/2):out.param.countBinWidth:(520-out.param.countBinWidth/2);
  ahSpc = axes('Position', [0.15, 0.20, 0.8, 0.05]);
  hold on
  plot(time, [out.spikeCountWin, out.spikeCountWin], 'k-')
  plot([10, 10], [0, 1], 'k:', 'LineWidth', 1)
  set(gca, 'XLim', [-500, 520], 'XTick', [], 'YTick', [], 'YLim', [-1, 1.], 'box','off')
  text(-500 -50*out.param.rasterBinWidth, 0, 'Sp. count', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15)
  
  ahDisc = axes('Position', [0.15, 0.125, 0.8, 0.05]);
  hold on
  plot(time, [out.discriminator, out.discriminator], 'k-')
  plot([10, 10], [0, max(out.discriminator)], 'k:', 'LineWidth', 1)
  set(gca, 'XLim', [-500, 520], 'XTick', [-500, 0, 500], 'YTick', [], 'YLim', [-max(abs(out.discriminator)), max(abs(out.discriminator))], 'box','off')
  text(-500 -50*out.param.rasterBinWidth, 0, 'Sp. disc.', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15)
  xlabel('Time (ms)')

  % Save the figure
  if nargin == 2
    saveName = fullfile(saveDir, [out.cellName, '_raster']);
    saveas(gcf, saveName, 'png')
  %   export_fig(save_name, '-png', '-transparent', '-nocrop', '-r100')
  end
  
end
