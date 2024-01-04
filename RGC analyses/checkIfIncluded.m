function include = checkIfIncluded(cellName)

  excludedCells = {...
    'Bad RGCs', ...
    '011111Ec3', ...  % OLD OFF: Unstable, few epochs, low sensitivity.
    '062111Fc8', ...  % OLD OFF: Unstable, few epochs, low firing rate, and something messed up in general.
    '022211Bc8', ...  % OLD ON: Outlier in terms of sensitivity and recorded after a point at which the tissue appears to have degraded
    '022211Bc11', ... % OLD ON: Outlier in terms of sensitivity and recorded after a point at which the tissue appears to have degraded
    '261119c3', ...   % NEW OFF: strange response that appears to saturate before dropping to 0 Hz 
    '020519c9' ...    % NEW OFF: unstable baseline that keeps the analysis from reaching the 75 % 2AFC threshold
    };

  if any(contains(excludedCells, cellName))
    include = false;
  else
    include = true;
  end

end