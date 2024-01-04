close all; clear; clc;

set(0, 'DefaultAxesFontSize', 17)
set(0, 'DefaultLineLineWidth', 2);

config = getConfiguration();
rgcResultsDir = config.RGCResultsPath;
psychoResultsDir = config.PsychophysicsResultsPath;

xLimRGC = [0.5, 15];
yLimRGC = [0.5, 20];
xVals = logspace(log10(xLimRGC(1)), log10(xLimRGC(2)), 21);
xLimPsycho = [0.1, 30];
yLimPsycho = [0.5, 100];
xValsPsycho = logspace(log10(xLimPsycho(1)), log10(xLimPsycho(2)), 21);

% Get RGC data
onSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'ON', xLimRGC);
offSummary = getDataSummary(config.RGCResultsPath, {'Old', 'New'}, 'OFF', xLimRGC);
onDipper = interp1(onSummary.discrimination.pedestalsInterp, onSummary.discrimination.mean, xVals);
offDipper = interp1(offSummary.discrimination.pedestalsInterp, offSummary.discrimination.mean, xVals);
% Get psychophysics data
psychoSummary = getDataSummary(psychoResultsDir, {''}, [], xLimPsycho);
psychoDipper = interp1(psychoSummary.discrimination.pedestalsInterp, psychoSummary.discrimination.mean, xValsPsycho);
% Get the theoretical limit
thTheory = getPoissonDiscriminationLimitVec(xValsPsycho, 0.75, [0, 0, 0, 0, 1]) - xValsPsycho;
thTheory0 = getPoissonDiscriminationLimitVec(0, 0.75, [0, 0, 0, 0, 1]);

% Calculate the dipper for the best model
noiseFit = 1.5;
alphaFit = 0.6;
firstThFit = 0;
nSubUnitsFit = 3;
bestDipper = nSubUnitsFit*getPoissonDiscriminationLimitVec(xVals/nSubUnitsFit+noiseFit, 0.75, [firstThFit, 0, alphaFit, 0, nSubUnitsFit]) - nSubUnitsFit*noiseFit - xVals;

% Plot the dipper together with the data and the theoretical limit
figure()
hold on
plot(xVals, onDipper, '-', 'LineWidth', 4, 'Color', config.Color.On)
plot(xVals, offDipper, '-', 'LineWidth', 4, 'Color', config.Color.Off)
plot(xVals, bestDipper, 'b:', 'LineWidth', 3)
plot(xValsPsycho, psychoDipper, 'k-', 'LineWidth', 4, 'Color', config.Color.Psycho)
plot(xValsPsycho, thTheory, 'k:', 'LineWidth', 3)
set(gca, 'XLim', xLimPsycho, 'XScale', 'log', 'YLim', yLimRGC, 'YScale', 'log')

%%

% Initialize
nSubUnitsPsycho = 2*nSubUnitsFit; % The psychophysics stimulus covers roughly twice as many subunits as a single RGC.
% nSubUnitsPsycho = 5; % The psychophysics stimulus covers roughly twice as many subunits as a single RGC.

% Determine how much the dipper moves from just adding subuunits (comparison purposes) 
modelRGCDipper = nSubUnitsPsycho*getPoissonDiscriminationLimitVec(xValsPsycho/nSubUnitsPsycho+noiseFit, 0.75, [firstThFit, 0, alphaFit, 0, nSubUnitsPsycho]) - nSubUnitsPsycho*noiseFit - xValsPsycho;

% Loop over secondary thresholds while optimizing the multiplicative noise
mse = [];
alphas = [];
secondThs = [16, 17, 18, 19, 20];
options = optimset('Display', 'iter');
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

%%
figure();
hold on
plot(xVals, onDipper, '-', 'LineWidth', 4, 'Color', config.Color.On)
plot(xVals, offDipper, '-', 'LineWidth', 4, 'Color', config.Color.Off)
plot(xVals, bestDipper, 'b:', 'LineWidth', 3)
plot(xValsPsycho, modelRGCDipper, 'b:', 'LineWidth', 3)
plot(xValsPsycho, psychoDipper, 'k-', 'LineWidth', 4, 'Color', config.Color.Psycho)
plot(xValsPsycho, modelPsychoDipper, 'b:', 'LineWidth', 3)
% plot(xValsPsycho, modelPsychoDipper2, 'b:', 'LineWidth', 3)
plot(xValsPsycho, thTheoryPsycho, 'k:', 'LineWidth', 3)
set(gca, 'XLim', xLimPsycho, 'XScale', 'log', 'YLim', yLimPsycho, 'YScale', 'log')


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