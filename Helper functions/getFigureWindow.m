function [fh, ahs] = getFigureWindow(nRows, nCols, params, ms, visible)

% Parse parameters
figWidth = params(1);
figHeight = params(2);
x0 = params(3);
y0 = params(4);
width = params(5);
height = params(6);
xSpace = params(7);
ySpace = params(8);

config = getConfiguration();

% Default settings for ms and other figures
if ms
  set(0, 'DefaultAxesFontSize', config.Axes.FontSize)
  set(0, 'DefaultTextFontSize', config.Text.FontSize)
  set(0, 'DefaultLegendFontSize', config.Axes.FontSize)  % Not working, set in fixLegendIcons.m instead
  set(0, 'DefaultAxesLabelFontSizeMultiplier', 1)
  set(0, 'DefaultAxesTitleFontSizeMultiplier', 1)
  set(0, 'DefaultLineLineWidth', 1);
  set(0, 'DefaultLineMarkerSize', 4);
else
  set(0, 'DefaultAxesFontSize', 15)
  set(0, 'DefaultTextFontSize', 15)
  set(0, 'DefaultLegendFontSize', 15)
  set(0, 'DefaultLineLineWidth', 3);
  set(0, 'DefaultLineMarkerSize', 7);
end

% Assume that the figure should be visible by default
if nargin < 5 || visible
  visible = 'on';
else
  visible = 'off';
end

% Create figure
fh = figure('Visible', visible, 'units', 'centimeters', 'Position', [0, 0, figWidth, figHeight], 'PaperUnits', 'centimeters', 'PaperSize', [figWidth, figHeight]);

% Create axes array with the following index notation
%| 7 8 9 |
%| 4 5 6 |
%| 1 2 3 |
axWidth = (width - (nCols-1)*xSpace) / nCols;
axHeigt = (height - (nRows-1)*ySpace) / nRows;
ahs = [];
for i = 1:nRows
  for j= 1:nCols
    ahs(end+1) = axes('Position', [x0 + (j-1)*(axWidth+xSpace), y0 + (i-1)*(axHeigt+ySpace), axWidth, axHeigt]);
  end
end

