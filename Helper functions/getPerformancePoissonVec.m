function pCorrect = getPerformancePoissonVec(mu1, mu2, param)

  pCorrect = zeros(1, numel(mu2));
  for i = 1:numel(mu2)
    pCorrect(i) = getPerformancePoisson(mu1, mu2(i), param);
  end
  
end

function pCorrect = getPerformancePoisson(mu1, mu2, param)

  % Parse parameters
  if numel(param) > 0
    firstTh = param(1);
  else
    firstTh = 0;
  end
  if numel(param) > 1
    secondTh = param(2);
  else
    secondTh = 0;
  end
  if numel(param) > 2
    firstAlpha = param(3);
  else
    firstAlpha = 0;
  end
  if numel(param) > 3
    secondAlpha = param(4);
  else
    secondAlpha = 0;
  end
  if numel(param) > 4
    nSubUnits = param(5);
  else
    nSubUnits = 1;
  end

  % Find limits for possible outcomes
  maxLim = ceil(max([firstTh+10, mu1+5*sqrt(mu1), mu2+5*sqrt(mu2)]));

  % Increment/decrement selection
  x = 0:maxLim;
  logxFactorial = [0, cumsum(log(1:maxLim))];
  if mu1 == 0
    p1Single = zeros(1, numel(x));
    p1Single(1) = 1;
  else
    p1Single = exp(x.*log(mu1) - mu1 - logxFactorial(x+1));
  end
  p2Single = exp(x.*log(mu2) - mu2 - logxFactorial(x+1));
%   p1Single = poisspdf(x, mu1);
%   p2Single = poisspdf(x, mu2);

  % First threshold
  x = x - firstTh;
  belowTh = x < 0;
  p1Below = sum(p1Single(belowTh));
  p1Single(x == 0) = p1Single(x == 0) + p1Below;
  p2Below = sum(p2Single(belowTh));
  p2Single(x == 0) = p2Single(x == 0) + p2Below;
  p1Single(belowTh) = [];
  p2Single(belowTh) = [];
  x(belowTh) = [];
  
  % Subunit pooling
  p1Pool = p1Single;
  p2Pool = p2Single;
  for n = 1:(nSubUnits-1)
    p1Pool = conv2(p1Pool, p1Single);
    p2Pool = conv2(p2Pool, p2Single);
    % Remove not occurring counts
    lastIdx = max([find(p1Pool>1e-6, 1, 'last'), find(p2Pool>1e-6, 1, 'last')]);
    p1Pool = p1Pool(1:lastIdx);
    p2Pool = p2Pool(1:lastIdx);
  end
  x = 0:(numel(p1Pool)-1);
  
  % Multiplicative noise
  if firstAlpha > 0
    maxSpikes = ceil(firstAlpha*x(end)+5*sqrt(firstAlpha*x(end)));
    xSpikes = 0:maxSpikes;
    logFactorial = [0, cumsum(log(xSpikes(2:end)))];
    pPoisson = exp(log(firstAlpha*x')*xSpikes - firstAlpha*x' - logFactorial(xSpikes+1));
    pPoisson(1, 1) = 1;
    p1Pool = p1Pool*pPoisson;
    p2Pool = p2Pool*pPoisson;
    x = xSpikes;
  end
  
  % Second threshold
  x = x - secondTh;
  belowTh = x < 0;
  p1Below = sum(p1Pool(belowTh));
  p1Pool(x == 0) = p1Pool(x == 0) + p1Below;
  p2Below = sum(p2Pool(belowTh));
  p2Pool(x == 0) = p2Pool(x == 0) + p2Below;
  p1Pool(belowTh) = [];
  p2Pool(belowTh) = [];
  x(belowTh) = [];
  
   %Second  Multiplicative noise
  if secondAlpha > 0
    maxSpikes = ceil(secondAlpha*x(end)+5*sqrt(secondAlpha*x(end)));
    xSpikes = 0:maxSpikes;
    logFactorial = [0, cumsum(log(xSpikes(2:end)))];
    pPoisson = exp(log(secondAlpha*x')*xSpikes - secondAlpha*x' - logFactorial(xSpikes+1));
    pPoisson(1, 1) = 1;
    p1Pool = p1Pool*pPoisson;
    p2Pool = p2Pool*pPoisson;
    x = xSpikes;
  end
  
  % 2AFC performance
  pCorrect = sum(p1Pool.*(1-cumsum(p2Pool))) + 0.5*sum(p1Pool.*p2Pool);
  
end