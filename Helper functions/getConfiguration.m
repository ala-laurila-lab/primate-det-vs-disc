function config = getConfiguration()

  % find root folder
  config.rootPath = fileparts(fileparts(mfilename('fullpath')));
  
  % RGC
  config.RGCSpatialRFDataPath = 'RGC Data RF';
  config.RGCspikeTimeDataPath = 'RGC Data';
  config.RGCResultsPath = 'RGC Results';
  
  % Psychophysics
  config.PsychophysicsDataPath = 'Psychophysics Data';
  config.PsychophysicsResultsPath = 'Psychophysics Results';
  
  % Default figure settings
  config.Axes.FontSize = 8;
  config.Text.FontSize = 8;
  
  % Default colors
  config.Color.Det =        [40, 40, 200] ./ 255;
  config.Color.Disc =       [255, 0, 0] ./ 255;
  config.Color.SpatialRF =  [213, 94, 0] ./ 255;
  config.Color.Morphology = [10, 150, 150] ./ 255;
  config.Color.On =         [94, 213, 0] ./ 255;
  config.Color.Off =        [213, 30, 213] ./ 255;
  config.Color.Psycho =     [255, 164, 5] ./ 255;
  % config.Color.Psycho =     [100, 100, 100] ./ 255;
  config.Color.Theory =     [0, 0, 0] ./ 255;
  config.Color.Model =      [0, 0, 0] ./ 255;
  config.Color.Fading = 0.6;

end