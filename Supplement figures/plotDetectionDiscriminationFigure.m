function plotDetectionDiscriminationFigure(visible)

  if nargin < 1
    visible = true;
  end
  fprintf('Plotting detection discrimination... ')
  
  config = getConfiguration();           % Set default plot settings

  %%
  % onExample = '20190502c8.mat';
  % onExample = '083110Ec10.mat';
  onExample = '092011Ec1.mat';
  onPedestals = [1, 2, 3, 4];
  offExample = '261119c2.mat';
  offPedestals = [1, 3, 5, 7];
  psychoExample = 'S1';
  psychoPedestals = [1, 2, 4, 5];
  names = {'Psychop.', 'OFF RGC', 'ON RGC'};
  labels = {'c', 'b', 'a'};
  pedestals = [psychoPedestals; offPedestals; onPedestals];

  config = getConfiguration();
  resultsDirs = {fullfile(config.PsychophysicsResultsPath, psychoExample), ...
                 fullfile('RGC Results', 'new', 'OFF', offExample), ...
                 fullfile('RGC Results', 'old', 'ON', onExample)};

  [fh, ahs] = getFigureWindow(3, 4, [17, 13, 0.125, 0.09, 0.85, 0.82, 0.08, 0.14], true, visible);

  xMin = 0.5;
  xMax = 60;
  yLim = [45, 105];
  for i = 1:numel(resultsDirs)
    load(resultsDirs{i}, 'out')
    for j = 1:4
      set(fh, 'CurrentAxes', ahs(j+(i-1)*4))
      hold on
      k = pedestals(i, j);
    %   plot(out.twoAFC.detection.intensities, out.twoAFC.detection.fractionCorrect, 'o', 'Color', config.Color.Det, 'MarkerFaceColor', config.Color.Det)
      ph1 = plot(out.twoAFC.detection.fit.x, out.twoAFC.detection.fit.y*100, '-', 'Color', config.Color.Det, 'Display', 'Detection');
      plot(out.twoAFC.discrimination.intensityDifference{k}, out.twoAFC.discrimination.fractionCorrect{k}*100, 'o', 'Color', config.Color.Disc, 'MarkerFaceColor', config.Color.Disc)
      if isfield(out.twoAFC.discrimination, 'fractionCorrectInterp')
        plot(out.twoAFC.discrimination.intensityDifferenceInterp{k}, out.twoAFC.discrimination.fractionCorrectInterp{k}*100, 'o', 'LineWidth', 1, 'Color', config.Color.Disc)
      end
      ph2 = plot(out.twoAFC.discrimination.fit.x, out.twoAFC.discrimination.fit.y{k}*100, '-', 'Color', config.Color.Disc, 'Display', 'Discrimination');
      text(xMin, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', get(gca, 'XColor'))
      hold off
      set(gca, 'XScale', 'log', 'YLim', yLim, 'XLim', [xMin, xMax], 'XTick', [1, 10], 'XTickLabel', [1, 10], 'YTick', [], 'Color', 'none', 'YColor', 'none')
      if (i == 1)
        xlabel('\DeltaI (R*)')
        title(sprintf('I_b: %1.1f R*', out.twoAFC.discrimination.pedestal(k)));
      elseif (i > 1)
        if i == 2
          xlabel('\DeltaI (R*/RGC)')
        end
        title(sprintf('I_b: %1.1f R*/RGC', out.twoAFC.discrimination.pedestal(k)));
      end


      ahPos = get(gca, 'Position');
      ahPos(1) = ahPos(1) - 0.025;
      ahPos(3) = 0.02;
      ahTmp = axes('Position', ahPos);
      plot(0, 50, 'ro', 'MarkerFaceColor', 'r')
      text(1, yLim(1), '/', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', get(gca, 'XColor'))
      set(gca, 'XLim', [-1, 1], 'YLim', yLim, 'YTick', [50, 75, 100], 'XTick', 0, 'Color', 'none', 'box','off')
      if (j > 1)
        set(gca, 'YTickLabel', [])
      else
        text(-4.5, 1.4, labels{i}, 'Units', 'Normalized', 'FontSize', 12, 'FontWeight', 'bold')
  %       text(-4, 1.1, names{i}, 'Units', 'Normalized', 'FontSize', 9)
        ylabel('Percent correct')
      end
      if (i == 2) && (j == 1)
        [lgh, icons] = legend([ph1, ph2], 'Orientation', 'Horizontal');
  %     lgh = legend([ph1, ph2], 'Orientation', 'Horizontal');
        lgh.Box = 'off';
        lgh.Position(1:2) = [0.7, 0.65];
        lgh.FontSize = 14;
        fixLegendIcons(icons, -0.14, true)
      end
    end
  end

  saveFigure(['Supplement figures', filesep, 'SupplementDetectionDiscrimination'])
%   export_fig(['Supplement figures', filesep, 'SupplementDetectionDiscrimination'], '-pdf', '-transparent', '-painters', '-nocrop')
  
  fprintf('Done\n')
  
end
