function saveFigure(name, format)

  config = getConfiguration();

  % set(0, 'DefaultAxesFontSize', fontSize) does not appear to work for
  % font sizes below 10pt in Matlab 2018b so we try to fix it here before
  % saving the figure panesl.
  handles = findall(gcf,'-property','FontSize');
  for i = 1:numel(handles)
    if strcmp(handles(i).Type, 'axes')
      handles(i).FontSize = config.Axes.FontSize;
    end
  end

  % Save as pdf if export_fig is found
  if exist('export_fig', 'file')
    if nargin == 1
      try
        export_fig(name, '-pdf', '-transparent', '-painters', '-nocrop')
      % Save as a png in case export_fig runs into problems
      catch
        export_fig(name, '-png', '-r600', '-transparent', '-painters', '-nocrop')
        fprintf('\nWarning: figure saved as png instead of pdf\n')
      end
    else
      export_fig(name, ['-', format], '-r600', '-transparent', '-painters', '-nocrop')
    end
  % Otherwise save as a png or any other requested format
  else
    if nargin == 1
      format = 'png';
    end
    print(name, ['-d', format], '-r600')
  end
end
