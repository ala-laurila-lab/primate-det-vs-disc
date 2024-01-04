function updateAllFigurePanels(visible)

  if nargin < 1
    visible = true;
  end
  
  % Main figure panels
  plotFig1Panels(visible)
  plotFig2Panels(visible)
  plotFig3Panels(visible)
  
  % Supplementary figures
  plotRodConvergenceFigure(visible)
  plotDetectionDiscriminationFigure(visible)
  plotModelParameters(visible)
  plotModelRobustness(visible)
    
end