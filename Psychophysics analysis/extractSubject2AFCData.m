function out = extractSubject2AFCData(subject)
  % Pedestal, 0 for detection 1,2,...for discrimination

  % Parameters
  NdfAttenuation = -5.95;     % Interf + ND1 + ND3
  out.subject = subject;

  %% Detection
  
  % Extract data
  dataFolder = fullfile('Psychophysics Data', 'Detection', subject);
  [voltages, pCorrect] = get2AFCPerformance(dataFolder);

  % Convert stimulus intensity to R*/RGC
  nanoWatts = voltageToWatts(voltages, subject);
  nanoWatts(1) = 0; % First value negative instead of zero to ensure that the stimulus was completly dark
  nanoWattsNdf = nanoWatts * 10^NdfAttenuation;
  [rStarPerRetina, ~, cornealPhotons] = wattsToRStarPerRGC(nanoWattsNdf, subject);

  % Fit Hill function
  x = logspace(log10(rStarPerRetina(2)/4), log10(rStarPerRetina(end)*4), 101);
  [fitTmp, SStmp, SEtmp, paramstmp] = fitNakaRushton2(rStarPerRetina, pCorrect);
  hillFunTmp = @(x) fitTmp.offset + (fitTmp.Rmax-fitTmp.offset) * (x.^fitTmp.n) ./ ((x.^fitTmp.n) + fitTmp.c50.^fitTmp.n);

  % Store results
  out.twoAFC.detection.fractionCorrect = pCorrect;
  out.twoAFC.detection.intensities = rStarPerRetina';
  out.twoAFC.detection.th75 = interp1(pCorrect+randn(size(pCorrect))*1e-10, rStarPerRetina, 0.75);
  out.twoAFC.detection.cornealPhotons = cornealPhotons';
  out.twoAFC.detection.fit.x = x;
  out.twoAFC.detection.fit.y = hillFunTmp(x);
  out.twoAFC.detection.th75Fit = interp1(hillFunTmp(x), x, 0.75);
  out.twoAFC.detection.SS = SStmp;
  out.twoAFC.detection.SE = SEtmp';
  out.twoAFC.detection.params = paramstmp;

  
  %% Discrimination
  tmpFolder = fullfile('Psychophysics Data', 'Discrimination', subject);
  pedestalFolders = dir(tmpFolder);

  y = {};
  th75 = [];
  th75Fit = [];
  SS = [];
  SE = [];
  params = [];
  pedestal = [];
  pCorrect = {};
  intensityDifference = {};
  % Loop over all pedestal (reference) intensities
  for i = 3:numel(pedestalFolders)

    if pedestalFolders(i).isdir
      % Extract data
      dataFolder = fullfile(tmpFolder, pedestalFolders(i).name);
      [voltages, pCorrect{end+1}] = get2AFCPerformance(dataFolder);
      
      % Convert stimulus intensity to R*/RGC
      nanoWatts = voltageToWatts(voltages, subject);
      nanoWattsNdf = nanoWatts * 10^NdfAttenuation;
      rStarPerRetina = wattsToRStarPerRGC(nanoWattsNdf, subject)';
      
      % Determine pedestals (reference) intensities and deltaI
      pedestal(end+1) = rStarPerRetina(1);
      intensityDifference{end+1} = rStarPerRetina - pedestal(end);
      th75(end+1) = interp1(pCorrect{end}+randn(size(pCorrect{end}))*1e-10, rStarPerRetina - pedestal(end), 0.75);

      % Fit Hill function
      [fitTmp, SStmp, SEtmp, paramstmp] = fitNakaRushton2(intensityDifference{end}, pCorrect{end});
      hillFunTmp = @(x) fitTmp.offset + (fitTmp.Rmax-fitTmp.offset) * (x.^fitTmp.n) ./ ((x.^fitTmp.n) + fitTmp.c50.^fitTmp.n);
      y{end+1} = hillFunTmp(x);
      th75Fit(end+1) = interp1(hillFunTmp(x), x, 0.75);
      SS(end+1)=SStmp;
      SE(end+1,:)=SEtmp';
      params(end+1,:)=paramstmp;
    end

  end

  % Store results
  [~, order] = sort(pedestal);
  out.twoAFC.discrimination.pedestal = pedestal(order);
  out.twoAFC.discrimination.fractionCorrect = pCorrect(order);
  out.twoAFC.discrimination.intensityDifference = intensityDifference(order);
  out.twoAFC.discrimination.th75 = th75(order);
  out.twoAFC.discrimination.fit.x = x;
  out.twoAFC.discrimination.fit.y = y(order);
  out.twoAFC.discrimination.th75Fit = th75Fit(order);
  out.twoAFC.discrimination.SS = SS(order);
  out.twoAFC.discrimination.SE = SE(order,:);
  out.twoAFC.discrimination.params = params(order,:);

end


%% Local function definitions

function [voltages, pCorrect] = get2AFCPerformance(dataFolder)

  % Extract raw data
  files = dir(dataFolder);
  all_data = [];
  for i = 3:size(files,1)
    if ~strcmp(files(i).name(1:5), 'volts')
      load(fullfile(files(i).folder, files(i).name))
      all_data = [all_data; session_struct.session_matrix];
    end
  end

  % Convert stimulus voltages into R*/RGC
  voltages = unique(all_data(:,2));

  % Calculate percent correct values
  pCorrect = [];
  for i = 1:numel(voltages)
      ind = all_data(:,2)==voltages(i);
      pCorrect(i) = mean(all_data(ind,3)==all_data(ind,4)-48);

      % Used for the bias correction below
      biased_pf(i) = mean(all_data(ind,3)==all_data(ind,4)-48);
      pcorr_1(i) = sum(all_data(ind,4)==49&all_data(ind,3)==1)/sum(all_data(ind,3)==1);
      pcorr_2(i) = sum(all_data(ind,4)==50&all_data(ind,3)==2)/sum(all_data(ind,3)==2);  

  end

  % THIS CORRECTION IS CURRENTLY NOT USED AS IT DOES NOT AFFECT THE RESULTS
  % Tweak p correct = 1 values slightly for d prime calculations
  pcorr_1(pcorr_1==1) = (length(all_data)/length(voltages)-0.5)/(length(all_data)/length(voltages));
  pcorr_2(pcorr_2==1) = (length(all_data)/length(voltages)-0.5)/(length(all_data)/length(voltages));

  % Normal, but wrong way of calulating 2AFC d prime
  biased_d = sqrt(2)*norminv((pcorr_1+pcorr_2)/2);
  % Way suggested by Green & Swets, 1966
  d_prime = sqrt(2)* ((norminv(pcorr_1) + norminv(pcorr_2))/2);

  % Back to p correct
  unbiased_pf = normcdf( d_prime / sqrt(2) );

  bias_ef = d_prime./biased_d;

end
