function fanoFactor = getFanoFactorVec(mu, param)

  fanoFactor = zeros(1, numel(mu));
  for i = 1:numel(mu)
    fanoFactor(i) = getFanoFactor(mu(i), param);
  end
  
end

function fanoFactor = getFanoFactor(mu, param)

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
  maxLim = ceil(max([firstTh+10, mu+10*sqrt(mu)]));

  % Increment/decrement selection
  x = 0:maxLim;
  logxFactorial = [0, cumsum(log(1:maxLim))];
  if mu == 0
    pSingle = zeros(1, numel(x));
    pSingle(1) = 1;
  else
    pSingle = exp(x.*log(mu) - mu - logxFactorial(x+1));
  end
%   pSingle = poisspdf(x, mu1);

  % First threshold
  x = x - firstTh;
  belowTh = x < 0;
  pBelow = sum(pSingle(belowTh));
  pSingle(x == 0) = pSingle(x == 0) + pBelow;
  pSingle(belowTh) = [];
  x(belowTh) = [];
  
  % Subunit pooling
  pPool = pSingle;
  for n = 1:(nSubUnits-1)
    pPool = conv2(pPool, pSingle);
    % Remove not occurring counts
    lastIdx = max(find(pPool>1e-14, 1, 'last'));
    pPool = pPool(1:lastIdx);
  end
  x = 0:(numel(pPool)-1);
  
  % Multiplicative noise
  if firstAlpha > 0
    maxSpikes = ceil(firstAlpha*x(end)+10*sqrt(firstAlpha*x(end)));
    xSpikes = 0:maxSpikes;
    logFactorial = [0, cumsum(log(xSpikes(2:end)))];
    pPoisson = exp(log(firstAlpha*x')*xSpikes - firstAlpha*x' - logFactorial(xSpikes+1));
    pPoisson(1, 1) = 1;
    pPool = pPool*pPoisson;
    x = xSpikes;
  end
  
  % Second threshold
  x = x - secondTh;
  belowTh = x < 0;
  pBelow = sum(pPool(belowTh));
  pPool(x == 0) = pPool(x == 0) + pBelow;
  pPool(belowTh) = [];
  x(belowTh) = [];
  
   %Second  Multiplicative noise
  if secondAlpha > 0
    maxSpikes = ceil(secondAlpha*x(end)+5*sqrt(secondAlpha*x(end)));
    xSpikes = 0:maxSpikes;
    logFactorial = [0, cumsum(log(xSpikes(2:end)))];
    pPoisson = exp(log(secondAlpha*x')*xSpikes - secondAlpha*x' - logFactorial(xSpikes+1));
    pPoisson(1, 1) = 1;
    pPool = pPool*pPoisson;
    x = xSpikes;
  end
  
  % Fano factor
  pMu = pPool*x';
  pVar = pPool*(x.^2)' - (pPool*x')^2;
  fanoFactor = pVar / pMu;
  
end