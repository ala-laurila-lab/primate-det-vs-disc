function mu2 = getPoissonDiscriminationLimitVec(mu1, thAFC, param)
  % Extract the mean value needed for discriminating between two Poisson
  % distributions with a given 2AFC score
  
  mu2 = zeros(1, numel(mu1));
  for i = 1:numel(mu1)
    mu2(i) = getPoissonDiscriminationLimit(mu1(i), thAFC, param);
  end

end

function mu2 = getPoissonDiscriminationLimit(mu1, thAFC, param)

  % Initialization
  mu2 = max(mu1, 0.1);
  thTmp = 0.5;
  delta = sqrt(mu2);
  direction = 1;
  
  % Check that mu1 is non-zero

  
  % Shift and divide delta until the sought threshold is found
  while abs(thTmp-thAFC) > 0.0000001

    % Take a proposed step
    mu2 = mu2 + direction*delta;
    thTmp = getPerformancePoissonVec(mu1, mu2, param);

    % Return and make the step small if too large
    if thTmp > thAFC
      mu2 = mu2 - direction*delta;
      delta = delta / 2;
    end

    % Avoid negative mean values
    if mu2 + direction*delta < 0
      delta = delta / 2;
    end
  end

end

