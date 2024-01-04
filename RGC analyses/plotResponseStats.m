function plotResponseStats(out, saveDir)

  if ishandle(2)
    figure(2)
    clf;
  else
    [fh, ahs] = getFigureWindow(1, 1, [30, 15, 0.15, 0.3, 0.8, 0.6, 0, 0], false);
    clf;
  end
  
  epsilon = 1e-2;
  % Fields to plot
  fields = {'spcPre', 'spcPost', 'discPost'};
  xLim = [0.5*min(out.rStarPerRGCPerFlash), 2*max(out.rStarPerRGCPerFlash)];
  for i = 1:numel(fields)
    subplot(3, 3, i)
    yDiff = max(max(out.(fields{i}).mean) - min(out.(fields{i}).mean), epsilon);
    yLim = [min(out.(fields{i}).mean) - 0.25*yDiff, max(out.(fields{i}).mean) + 0.25*yDiff];
    plot(out.rStarPerRGCPerFlash, out.(fields{i}).mean, 'ko', out.(fields{i}).meanFit.x, out.(fields{i}).meanFit.y, 'r-'); 
    set(gca, 'XScale', 'log', 'XLim', xLim, 'YLim', yLim, 'XTick', [1, 10])
    title(fields{i})
    if i == 1
      ylabel('Mean', 'FontWeight', 'bold')
    end
  end

  for i = 1:numel(fields)
    subplot(3, 3, i+3)
    yDiff = max(max(out.(fields{i}).variance) - min(out.(fields{i}).variance), epsilon);
    yLim = [min(out.(fields{i}).variance) - 0.25*yDiff, max(out.(fields{i}).variance) + 0.25*yDiff];
    plot(out.rStarPerRGCPerFlash, out.(fields{i}).variance, 'ko', out.(fields{i}).varFit.x, out.(fields{i}).varFit.y, 'r-'); 
    set(gca, 'XScale', 'log', 'XLim', xLim, 'YLim', yLim, 'XTick', [1, 10])
    xlabel('Intensity (R*/RGC)')
    if i == 1
      ylabel('Variance', 'FontWeight', 'bold')
    end
  end
  
  for i = 1:numel(fields)
    subplot(3, 3, i+6)
    yDiff = max(out.(fields{i}).variance./out.(fields{i}).mean) - min(out.(fields{i}).variance./out.(fields{i}).mean);
    yLim = [min(out.(fields{i}).variance./out.(fields{i}).mean) - 0.25*yDiff, max(out.(fields{i}).variance./out.(fields{i}).mean) + 0.25*yDiff];
    if isnan(yDiff)
      yLim = epsilon*[-1, 1];
    elseif yDiff == 0
      yLim = epsilon*[-1, 1] + yLim(1);
    end
    plot(out.rStarPerRGCPerFlash, out.(fields{i}).variance./out.(fields{i}).mean, 'ko', out.(fields{i}).varFit.x, out.(fields{i}).varFit.y ./ out.(fields{i}).meanFit.y, 'r-'); 
    set(gca, 'XScale', 'log', 'XLim', xLim, 'YLim', yLim, 'XTick', [1, 10])
    xlabel('Intensity (R*/RGC)')
    if i == 1
      ylabel('Fano factor', 'FontWeight', 'bold')
    end
  end
  
  if nargin == 2
    saveName = fullfile(saveDir, [out.cellName, '_response_stats']);
    saveas(gcf, saveName, 'png')
  %   export_fig(save_name, '-png', '-transparent', '-nocrop', '-r100')
  end

end