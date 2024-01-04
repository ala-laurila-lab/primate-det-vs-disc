close all; clear; clc;

set(0, 'DefaultAxesFontSize', 17)
set(0, 'DefaultLineLineWidth', 2);

config = getConfiguration();
rgcResultsDir = config.RGCResultsPath;
psychoResultsDir = config.PsychophysicsResultsPath;

xLim = [0.5, 15];
yLim = [0.5, 20];
xVals = logspace(log10(xLim(1)), log10(xLim(2)), 21);

% Get RGC data
onSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'ON', xLim);
offSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'OFF', xLim);
onDipper = interp1(onSummary.discrimination.pedestalsInterp, onSummary.discrimination.mean, xVals);
offDipper = interp1(offSummary.discrimination.pedestalsInterp, offSummary.discrimination.mean, xVals);
% Get the theoretical limit
thTheory = getPoissonDiscriminationLimitVec(xVals, 0.75, [0, 0, 0, 0, 1]) - xVals;
thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, [0, 0, 0, 0, 1]);

% Loop over threshoolds and number of subunits while optimizing the noise
mse = [];
foundParams = [];
firstThs = [1, 2, 3];
nSubunitVals = [2, 3, 4];
options = optimset('Display', 'iter');
for i = 1:numel(firstThs)
  for j = 1:numel(nSubunitVals)
    lossFun = @(w) meanSquarredError([w(1), firstThs(i), w(2), 0, 0, nSubunitVals(j)], xVals, onDipper);
    [paramsTmp, lossTmp] = fminsearch(lossFun, [1, 1], options);
    foundParams(i, j, :) = paramsTmp;
    mse(i, j) = lossTmp;
  end
end
% Select the parameter combination that yielded the best fit
[argVal, argMin] = min(mse(:));
[argRow, argCol] = ind2sub(size(mse), argMin);
firstThFit = firstThs(argRow);
nSubUnitsFit = nSubunitVals(argCol);
noiseFit = foundParams(argRow, argCol, 1);
alphaFit = foundParams(argRow, argCol, 2);

% Calculate the dipper for the best model
bestDipper = nSubUnitsFit*getPoissonDiscriminationLimitVec(xVals/nSubUnitsFit+noiseFit, 0.75, [firstThFit, 0, alphaFit, 0, nSubUnitsFit]) - nSubUnitsFit*noiseFit - xVals;

% Plot the dipper together with the data and the theoretical limit
figure()
hold on
plot(xVals, onDipper, '-', 'LineWidth', 4, 'Color', config.Color.On)
% plot(xVals, offDipper, '-', 'LineWidth', 4, 'Color', config.Color.Off)
plot(xVals, bestDipper, 'b:', 'LineWidth', 3)
plot(xVals, thTheory, 'k:', 'LineWidth', 3)
set(gca, 'XLim', xLim, 'XScale', 'log', 'YLim', yLim, 'YScale', 'log')

%%

% Initialize
xLimPsycho = [0.1, 30];
yLimPsycho = [0.5, 100];
xValsPsycho = logspace(log10(xLimPsycho(1)), log10(xLimPsycho(2)), 21);
nSubUnitsPsycho = 2*nSubUnitsFit; % The psychophysics stimulus covers roughly twice as many subunits as a single RGC.
% nSubUnitsPsycho = 5; % The psychophysics stimulus covers roughly twice as many subunits as a single RGC.

% Get psychophysics data
psychoSummary = getDataSummary(psychoResultsDir, {''}, [], xLimPsycho);
psychoDipper = interp1(psychoSummary.discrimination.pedestalsInterp, psychoSummary.discrimination.mean, xValsPsycho);

% Determine how much the dipper moves from just adding subuunits (comparison purposes) 
modelRGCDipper = nSubUnitsPsycho*getPoissonDiscriminationLimitVec(xValsPsycho/nSubUnitsPsycho+noiseFit, 0.75, [firstThFit, 0, alphaFit, 0, nSubUnitsPsycho]) - nSubUnitsPsycho*noiseFit - xValsPsycho;

% Loop over secondary thresholds while optimizing the multiplicative noise
mse = [];
alphas = [];
secondThs = [1, 2, 3];
for i = 1:numel(secondThs)
  lossFun = @(alpha) meanSquarredError([noiseFit, firstThFit, alpha, secondThs(i) 0, nSubUnitsPsycho], xValsPsycho, psychoDipper);
  [alphas(end+1), mse(end+1)] = fminsearch(lossFun, alphaFit, options);
end

% Select the parameter combination that yielded the best fit
[~, bestIdx] = min(mse);
alphaPsychoFit = alphas(bestIdx);
secondThFit = secondThs(bestIdx);

% Calculate the dipper for the best model and the theoretical line
modelPsychoDipper = nSubUnitsPsycho*getPoissonDiscriminationLimitVec(xValsPsycho/nSubUnitsPsycho+noiseFit, 0.75, [firstThFit, secondThFit, alphaPsychoFit, 0, nSubUnitsPsycho]) - nSubUnitsPsycho*noiseFit - xValsPsycho;
thTheoryPsycho = getPoissonDiscriminationLimitVec(xValsPsycho, 0.75, [0, 0, 0, 0, 1]) - xValsPsycho;

figure();
hold on
plot(xVals, onDipper, '-', 'LineWidth', 4, 'Color', config.Color.On)
% plot(xVals, offDipper, '-', 'LineWidth', 4, 'Color', config.Color.Off)
plot(xVals, bestDipper, 'b:', 'LineWidth', 3)
plot(xValsPsycho, modelRGCDipper, 'b:', 'LineWidth', 3)
plot(xValsPsycho, psychoDipper, 'k-', 'LineWidth', 4, 'Color', config.Color.Psycho)
plot(xValsPsycho, modelPsychoDipper, 'b:', 'LineWidth', 3)
% plot(xValsPsycho, modelPsychoDipper2, 'b:', 'LineWidth', 3)
plot(xValsPsycho, thTheoryPsycho, 'k:', 'LineWidth', 3)
set(gca, 'XLim', xLimPsycho, 'XScale', 'log', 'YLim', yLimPsycho, 'YScale', 'log')

fprintf("RGC model\n")
fprintf("Additive noise (fitted): %1.3f\n", noiseFit)
fprintf("Multiplicative noise (fitted): %1.3f\n", alphaFit)
fprintf("First threshold (fitted): %1i\n", firstThFit)
fprintf("N sub-units (fitted): %1i\n", nSubUnitsFit)

fprintf("\nPsychophysics model\n")
fprintf("Additive noise (fixed): %1.3f\n", noiseFit)
fprintf("Multiplicative noise (fitted): %1.3f\n", alphaPsychoFit)
fprintf("First threshold (fixed): %1i\n", firstThFit)
fprintf("Second threshold (fitted): %1i\n", secondThFit)
fprintf("N sub-units (fixed): %1i\n", nSubUnitsPsycho)

%% Function definitions

function mse = meanSquarredError(w, xVals, targetDipper)

  noise = w(1);
  firstTh = w(2);
  firstAlpha = w(3);
  secondTh = w(4);
  secondAlpha = w(5);
  nSubUnits = w(6);
  
  if noise < 0 || firstAlpha < 0
    mse = 1e3;
  elseif noise > 4 || firstAlpha > 2
    mse = 1e3;
  else
    mse = mean((targetDipper - (nSubUnits*getPoissonDiscriminationLimitVec(xVals/nSubUnits+noise, 0.75, [firstTh, secondTh, firstAlpha, secondAlpha, nSubUnits]) - nSubUnits*noise - xVals)).^2);
  end
  
end