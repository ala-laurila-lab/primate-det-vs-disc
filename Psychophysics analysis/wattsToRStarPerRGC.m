function [rStarPerRetina, rStarPerRGC, cornealPhotons] = wattsToRStarPerRGC(nanoWatts, subject)

% Subject specific pupil areas
subjects = {'S1', 'S5', 'S2', 'S4', 'S3'};
pupilsAreas =   [44.6, 49.5, 56.4 53.2, 32.5] ;
acFun = @(r, epsilon, l, gamma) r^2*pi*(1-10^(-epsilon*l))*gamma;
degToMmHuman = @(d) (-3.4 + sqrt(3.4^2-4*0.035*(0.1-d))) / 2 / 0.035;   % Methods in Dacey and Petersen, (1992), real source Drasdo and Fowler, (1974)
mmToDensity = @(mm) (98*mm - 24*mm.^2 + 2.4*mm.^3 - 0.09*mm.^4) * 1e3;  % Fig. 11 Curcio et al., (1993)
mmToRadius = @(mm) (2 + 0.054*mm) / 2;                                  % Fig. 11 Curcio et al., (1993)

% Conversion to watts     
power = nanoWatts * 10^-9;          % W or J/s 

% Rod properties
eccentricityMm = degToMmHuman(18);
rodDensity = mmToDensity(eccentricityMm);           % rods/mm2; (Curcio et al., 1993)
rodFraction = 0.55;                                 % fraction covered by rods (Packer et al., 1989), implies a rod radius of 1.118 um for a rod density of 140 000 rods/mm2
rodLength = 42;                                     % um (Hendrickson and Drucker, 1992)
epsilon = 0.019;                                    % um^-1 (Bowmaker et al., 1978)
gamma = 0.67;                                       % Dartnall et al. (1972)
rodRadius = mmToRadius(eccentricityMm);             % um; (Curcio et al., 1993)

% Stimulus parameters
stimSizeDeg = 1.17;                 % degress, diameter
stimDuration = 0.02;                % seconds
stimRadius = 0.268*stimSizeDeg*0.5; % mm
waveLength = 5 * 10^-7;             % m, stimulus wavelength
h = 6.62607015 * 10.^-34;           % Js, Planck's constant
c = 299792458;                      % m/s, speed of light
photonEnergy = h*c/waveLength;      % J

% Losses
tauMediaFun = @(age, lambda) ...
    (0.446 + 0.000031*age^2) * (400/lambda)^4 ...
    + 14.19 * 10.68 * exp(-(0.057*(lambda-273)^2)) ...
    + (0.998-0.000063*age^2) * 2.13 * exp(-(0.029*(lambda-370)^2)) ...
    + (0.059+0.000186*age^2) * 11.95 * exp(-(0.021*(lambda-325)^2)) ...
    + (0.016+0.000132*age^2) * 1.43 * exp(-(0.008*(lambda-325)^2)) ...
    + 0.111;                        % Eq 8 (van de Kraats and Van Norren, 2007)
tauMedia = 0.45;                    % Ocular media factor (Nelson, 2016)

% Areas
sensorArea = 100;                                                       % mm^2
stimArea= pi*stimRadius.^2;                                             % mm^2
pupilArea = pupilsAreas(strcmp(subjects, subject));                     % mm^2
collectingArea = acFun(rodRadius, epsilon, rodLength, gamma) * 10^-6;   % mm^2

% Rod convergence
scalingFactor = 1.05;                                                   % See our supplement analysis 
dendriticFieldRadius = 70.2*(degToMmHuman(18))^(0.65) / 2 * 1e-3;       % mm; (Dacey and Petersen, 1992; Fig. 2)
rfSigma = scalingFactor*dendriticFieldRadius;
rodConvergence = getRodsPerRGC(rfSigma, rodDensity, stimRadius/rfSigma);

% Isomerization rates
Fcornea = power / photonEnergy / sensorArea;          % Corneal photon flux density
Fretina = Fcornea * tauMedia * pupilArea / stimArea;  % Retinal photon flux density
rStarPerRodPerSec = Fretina * collectingArea;         % R*/rod/sec

% Final intensities
rStarPerRGC = rStarPerRodPerSec * rodConvergence * stimDuration;    % R*/RGC/flash
rStarPerRetina = rStarPerRodPerSec*rodDensity*stimArea*stimDuration; 

% Alternative way to calculate R*/retina from corneal photons
% The slighlty different numerical result derive from the rod radius being
% inferred from the rod fraction and density.
cornealPhotons = Fcornea * pupilArea * stimDuration;
% rStarPerRetina = cornealPhotons*tauMedia*rodFraction*(1-10^(-epsilon*rodLength))*gamma; 

end








 









