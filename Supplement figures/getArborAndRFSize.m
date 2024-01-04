function fit = getArborAndRFSize(config)

  % Data holders
  sigmas = [];
  radiuses = [];
  params = [];
  responses = {};
  spotSizes = {};
  tags = {};

  template = fullfile(config.rootPath, config.RGCSpatialRFDataPath, '*.mat');
  files = dir(template);

  % Extract data
  for rfFile = files'
    load(rfFile.name)
    for i = 1:numel(RF)
      spotSizes{end+1} = RF{i}.results.splitValue / 1e3;
      responses{end+1} = RF{i}.results.respAmp;

      % Least squares objective function
      objFun = @(w) norm(responses{end}-responseFun(spotSizes{end}/2, w));
      % Minimize
      params(end+1, :) = fminsearch(objFun, [0.15, 30]);
      sigmas(end+1) = round(params(end, 1)*1e3);
      if isfield(RF{i}.results, 'dendriticRadius')
        radiuses(end+1) = RF{i}.results.dendriticRadius;
      else
        radiuses(end+1) = nan;
      end
      if isfield(RF{i}.results, 'type')
        if contains(RF{1}.results.type, 'On')
          tags{end+1} = [rfFile.name(1:end-7), '-', num2str(i), '-On'];
        else
          tags{end+1} = [rfFile.name(1:end-7), '-', num2str(i), '-Off'];
        end
        disp(RF{1}.results.type)
      else
        tags{end+1} = [rfFile.name(1:end-7), '-', num2str(i), '-On'];
      end
    end
  end
  
  % Store relevant data to a struct
  fit.Sigmas = sigmas;
  fit.Radiuses = radiuses;
  fit.Params = params;
  fit.Responses = responses;
  fit.SpotSizes = spotSizes;
  fit.Tags = tags;

  % Plot all spatial RF fits
  [fh, ahs] = getFigureWindow(4, 4, [30, 25, 0.1, 0.1, 0.8, 0.85, 0.03, 0.06], false, false);
  xDense = linspace(0, 1, 101);
  for i = 1:numel(sigmas)
    set(fh, 'CurrentAxes', ahs(i))
    yHat = responseFun(xDense/2, params(i, :));
    hold on
    plot(spotSizes{i}*1e3/2, responses{i}/max(yHat), 'ko', 'Display', 'Data')
    plot(xDense*1e3/2, yHat/max(yHat), '-', 'Color', config.Color.SpatialRF)
    hold off
    text(0.5, 0.2, sprintf('\\sigma=%3d um', sigmas(i)), 'Units', 'normalized')
    set(gca, 'XLim', [-10, 510], 'YLim', [-0.1, 1.1], 'XTick', [0, 250, 500], 'YTick', [0, 1])
    title(tags{i})
    if i > 4
      set(gca, 'XTickLabel', [])
    end
    if mod(i-1, 4) > 0 
      set(gca, 'YTickLabel', [])
    end
    if i == 1
      xlabel('Spot radius (um)')
      ylabel('Response (a.u.)')
    end
  end

  % Save the figure for inspection
  figName = fullfile(config.rootPath, config.RGCSpatialRFDataPath, 'FittedRFs.png');
  saveas(fh, figName);

end

%% Function definitions

function yHat = responseFun(x, param)

  yHat = zeros(1, numel(x));
  for i = 1:numel(x)
    yHat(i) = getRodsPerRGC(param(1), param(2), x(i)/param(1));
  end

end