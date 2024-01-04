function plotDipper(out, saveDir)

  if ishandle(4)
    figure(4)
    clf;
  else
    [fh, ahs] = getFigureWindow(1, 1, [20, 15, 0.15, 0.3, 0.8, 0.6, 0, 0], false);
    clf
  end

  % Get x and y limits
  xLim = [0.5, 200];
  yLim = [0.5, 200];
  
  % Get the theoretical limit
  xInterp = logspace(log10(xLim(1)), log10(xLim(2)), 101);
  thTheory = getPoissonDiscriminationLimitVec(xInterp, 0.75, 0);

  % Thin axis for detectipon
  ah = axes('Position', [0.15, 0.15, 0.03, 0.75], 'XLim', [-1, 1], 'XTick', [], 'YLim', yLim);
  hold on
  text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
%   plot(0, out.twoAFC.detection.th75, 'kx')
  plot(0, out.twoAFC.detection.th75Fit, 'bo')
  plot(0, getPoissonDiscriminationLimitVec(0, 0.75, 0), 'kx')
  hold off
  ylabel('Delta I (R*/RGC)')
  set(gca, 'YScale', 'log', 'YLim', yLim)

  % Wider axis for discrimination
  ah = axes('Position', [0.20, 0.15, 0.7, 0.75], 'XLim', xLim);
  hold on
  nPedestals = numel(out.twoAFC.discrimination.th75Fit);
  text(xLim(1), yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 12)
%   plot([xLim(1), out.twoAFC.discrimination.pedestal], [out.twoAFC.detection.th75, out.twoAFC.discrimination.th75], 'r:', 'Display', 'Linear interp.')
%   plot(out.twoAFC.discrimination.pedestal, out.twoAFC.discrimination.th75, 'rx', 'Display', 'Linear interp.')
  xTmp = [xLim(1), out.twoAFC.discrimination.pedestal(1:nPedestals)];
  yTmp = [out.twoAFC.detection.th75Fit, out.twoAFC.discrimination.th75Fit];
  plot(xTmp(~isnan(yTmp)), yTmp(~isnan(yTmp)), 'r-', 'Display', 'Hill fun. fit')
  plot(out.twoAFC.discrimination.pedestal(1:nPedestals), out.twoAFC.discrimination.th75Fit, 'ro', 'Display', 'Hill fun. fit')
  plot(xInterp, thTheory-xInterp, 'k:')
  set(gca, 'XScale', 'log', 'YScale', 'log', 'YTick', [], 'YLim', yLim, 'XLim', xLim, 'YColor', 'none')
  xlabel('I (R*/RGC)')
%   lh = legend('Location', 'SouthEast');
%   lh.Box = 'off';
%   box off
  title('Dipper')
  
  if nargin == 2
    if isfield(out, 'cellName')
      saveName = fullfile(saveDir, [out.cellName, '_dipper']);
    else
      saveName = fullfile(saveDir, [out.subject, '_dipper']);
    end
    saveas(gcf, saveName, 'png')
  %   export_fig(saveName, '-png', '-transparent', '-nocrop', '-r100')
  end

end