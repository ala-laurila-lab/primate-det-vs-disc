function plot2AFCResults(out, saveDir)

  if ishandle(3)
    figure(3)
    clf;
  else
    [fh, ahs] = getFigureWindow(1, 1, [40, 25, 0.15, 0.3, 0.8, 0.6, 0, 0], false);
    clf
  end
  
  xLim = [min(out.twoAFC.detection.fit.x)/2, max(out.twoAFC.detection.fit.x)*2];
  yLim = [0.45, 1.05];
  xTicks = 10.^(ceil(log10(xLim(1))):floor(log10(xLim(2))));

  % Loop over and plot all pedestals
  nPedestals = sum(cellfun(@(p) sum(p>0.6), out.twoAFC.discrimination.fractionCorrect) > 0);
  nCols = ceil(nPedestals / 2);
  for i = 1:nPedestals

    subplot(2, nCols, i)
    hold on

    % Detection
    plot(out.twoAFC.detection.intensities, out.twoAFC.detection.fractionCorrect, 'ko', 'MarkerFaceColor', 'k')
    ph1 = plot(out.twoAFC.detection.fit.x, out.twoAFC.detection.fit.y, 'k-', 'Display', 'Detection');
    plot(out.twoAFC.detection.th75, 0.75, 'kx')

    % Discrimination
    plot(out.twoAFC.discrimination.intensityDifference{i}, out.twoAFC.discrimination.fractionCorrect{i}, 'ro', 'MarkerFaceColor', 'r')
    if isfield(out.twoAFC.discrimination, 'intensityDifferenceInterp')
      plot(out.twoAFC.discrimination.intensityDifferenceInterp{i}, out.twoAFC.discrimination.fractionCorrectInterp{i}, 'ro')
    end
    ph2 = plot(out.twoAFC.discrimination.fit.x, out.twoAFC.discrimination.fit.y{i}, 'r-', 'Display', 'Discrimination');
    plot(out.twoAFC.discrimination.th75(i), 0.75, 'rx')

    hold off

%     set(gca, 'XScale', 'log', 'YLim', [0.45, 1.05], 'XLim', [0.5*xMin, 2*xMax], 'XTick', [1, 4, 16, 64], 'XTickLabels', 2.5*[1, 4, 16, 64])
    set(gca, 'XScale', 'log', 'YLim', yLim, 'XLim', xLim, 'XTick', xTicks)
    if i == nCols+1
      xlabel('\DeltaI (R*/RGC)')
      ylabel('Percent correct')
      lh = legend([ph1, ph2], 'Location', 'SouthEast');
      lh.Box = 'off';
    end
    
    % Corneal photons for psychophysics
    if isfield(out.twoAFC.detection, 'cornealPhotons')
      scaling = out.twoAFC.detection.cornealPhotons(2) ./ out.twoAFC.detection.intensities(2);
      xLimScaled = xLim*scaling;
      xTicksScaled = 10.^(ceil(log10(xLimScaled(1))):floor(log10(xLimScaled(2))));
      ahTop = axes('Position', get(gca, 'Position'), 'XLim', xLimScaled, 'XTick', xTicksScaled, 'YLim', yLim, 'XAxisLocation', 'top', 'XScale', 'log');
    end
    set(gca, 'Color', 'none')

    % Add plot title
    title(sprintf('Pedestal: %2.1f R*/RGC', out.twoAFC.discrimination.pedestal(i)), 'FontWeight', 'normal')

  end
  
  
  if nargin == 2
    if isfield(out, 'cellName')
      saveName = fullfile(saveDir, [out.cellName, '_2AFC_results']);
    else
      saveName = fullfile(saveDir, [out.subject, '_2AFC_results']);
    end
    saveas(gcf, saveName, 'png')
  %   export_fig(saveName, '-png', '-transparent', '-nocrop', '-r100')
  end

end