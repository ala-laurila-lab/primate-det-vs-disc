function out = fit2AFCHillFunctions(out)

  % Set limits along the x-axis (intensity)
  xMin = 0.5*min(out.twoAFC.detection.intensities);
  xMax = 2*max(out.twoAFC.detection.intensities);
  x = logspace(log10(xMin/4), log10(xMax*4), 101);
 
  
  % Detection
  fitTmp = fitNakaRushton(out.twoAFC.detection.intensities, out.twoAFC.detection.fractionCorrect, []);
  funTmp = @(x) fitTmp.offset + (fitTmp.Rmax-fitTmp.offset) * (x.^fitTmp.n) ./ ((x.^fitTmp.n) + fitTmp.c50.^fitTmp.n);
  out.twoAFC.detection.fit.params = fitTmp;
  out.twoAFC.detection.fit.x = x;
  out.twoAFC.detection.fit.y = funTmp(x);
  out.twoAFC.detection.th75Fit = interp1(funTmp(x), x, 0.75);

  % Discrimination
  out.twoAFC.discrimination.fit.x = x;
  out.twoAFC.discrimination.fit.y = {};
  out.twoAFC.discrimination.th75Fit = [];
  out.twoAFC.discrimination.fit.params = {};
  nPedestals = sum(cellfun(@(p) sum(p>0.6), out.twoAFC.discrimination.fractionCorrect) > 0);
  for i = 1:nPedestals
    xTmp = [out.twoAFC.discrimination.intensityDifference{i}, out.twoAFC.discrimination.intensityDifferenceInterp{i}];
    yTmp = [out.twoAFC.discrimination.fractionCorrect{i}, out.twoAFC.discrimination.fractionCorrectInterp{i}];
    fitTmp = fitNakaRushton(xTmp, yTmp, []);
    funTmp = @(x) fitTmp.offset + (fitTmp.Rmax-fitTmp.offset) * (x.^fitTmp.n) ./ ((x.^fitTmp.n) + fitTmp.c50.^fitTmp.n);
    out.twoAFC.discrimination.fit.y{end+1} = funTmp(x);
    if max(out.twoAFC.discrimination.fractionCorrect{i}) < 0.75
      valid = false;
    else
      valid = true;
    end
    if valid
      out.twoAFC.discrimination.th75Fit(end+1) = interp1(funTmp(x)+randn(size(x))*1e-10, x, 0.75);
    else
      out.twoAFC.discrimination.th75Fit(end+1) = nan;
    end
    out.twoAFC.discrimination.fit.params{end+1} = fitTmp;
  end

end