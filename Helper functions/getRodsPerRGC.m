function rodsPerRGC = getRodsPerRGC(sigma, rodDensity, lim)

  dr = 0.005;                                       % Resolution in standard deviations for the numerical integration
  rVals = (0:dr:lim)*sigma;                         % Radii to integrate over
  gaussianWeights = exp(-(rVals).^2 /2/sigma^2);    % Gaussian weighting factor at each radius
  
  % Integrate numerically as long as there is at least one nonzero radius
  if numel(rVals) > 1
    circleAreas = rVals.^2*pi;
    annuliAreas = diff(circleAreas);
    annuliWeigths = conv(gaussianWeights, 0.5*[1, 1], 'valid');
    rodsPerRGC = annuliWeigths*annuliAreas' * rodDensity;
  else
    rodsPerRGC = 0;
  end

end