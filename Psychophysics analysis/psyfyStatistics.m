function out = psyfyStatistics(out)

% t-test for checking the difference in the c50 parameter for detection and
% discrimination tasks

% Degrees of freedom
df_det = numel(out.twoAFC.detection.intensities) - ...
         size(out.twoAFC.detection.params, 2);
df_disc = cellfun(@(s) numel(s), out.twoAFC.discrimination.intensityDifference) - ...
          size(out.twoAFC.discrimination.params, 2);

% Standard errors for the parameters
SEdet = out.twoAFC.detection.SE(:,1);
SEdisc = out.twoAFC.discrimination.SE(:,1);
% Parameter values
params_det = out.twoAFC.detection.params(:,1);
params_disc = out.twoAFC.discrimination.params(:,1);
% t-test score
tScore = (params_det - params_disc)./sqrt(SEdet.^2 + SEdisc.^2);
% p-vaue for two sided test
pVal = 2 * (1 - tcdf(abs(tScore), df_det+df_disc'));

% Effect size using Cohen's d
SDdet = SEdet*sqrt(7);
SDdisc = SEdisc*sqrt(7);
SDpooled = sqrt((SDdet.^2+SDdisc.^2)./2);
cohensd = (params_det-params_disc)./SDpooled;

% Store results
out.twoAFC.discrimination.pVal = pVal;
out.twoAFC.discrimination.tScore = tScore;
out.twoAFC.discrimination.cohensd = cohensd;

end

