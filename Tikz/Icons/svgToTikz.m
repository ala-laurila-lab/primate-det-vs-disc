clear; clc;

% Human head
% svgPaths{1} = 

tikzPaths = {};
for i = 1:numel(svgPaths)
  
  j = 1;
  pStart = [0, 0];
  pStop = [0, 0];
  action = '';
  tikzPath = [];
  parts = strsplit(svgPaths{i}, ' ');
  while j < numel(parts)

    if numel(parts{j}) == 1
      action = parts{j};
      j = j+1;
    else

      pStart = pStop;

      switch action

        case 'm'
          pStop = cellfun(@str2num, strsplit(parts{j}, ','));
          tikzPath = [tikzPath, '(', num2str(pStop(1)), ',', num2str(pStop(2)), ')'];
          j = j+1;
        case 'c'
          coordinates = cell2mat(cellfun(@(s) cellfun(@str2num, strsplit(s, ',')), parts(j:j+2), 'UniformOutput', false));
          p1 = coordinates(1:2) + pStart;
          p2 = coordinates(3:4) + pStart;
          pStop = coordinates(5:6) + pStart;
          tikzPath = [tikzPath, ' .. controls (', num2str(p1(1)), ',', num2str(p1(2)), ') and (', num2str(p2(1)), ',', num2str(p2(2)), ') .. (', num2str(pStop(1)), ',', num2str(pStop(2)), ')'  ];
          j = j + 3;
        case 'C'
          coordinates = cell2mat(cellfun(@(s) cellfun(@str2num, strsplit(s, ',')), parts(j:j+2), 'UniformOutput', false));
          p1 = coordinates(1:2);
          p2 = coordinates(3:4);
          pStop = coordinates(5:6);
          tikzPath = [tikzPath, ' .. controls (', num2str(p1(1)), ',', num2str(p1(2)), ') and (', num2str(p2(1)), ',', num2str(p2(2)), ') .. (', num2str(pStop(1)), ',', num2str(pStop(2)), ')'  ];
          j = j + 3;
        case 'l'
          pStop = cellfun(@str2num, strsplit(parts{j}, ','));
          pStop = pStop + pStart;
          tikzPath = [tikzPath, ' -- (', num2str(pStop(1)), ',', num2str(pStop(2)), ')'];
          j = j + 1;
        case 'L'
          pStop = cellfun(@str2num, strsplit(parts{j}, ','));
          tikzPath = [tikzPath, ' -- (', num2str(pStop(1)), ',', num2str(pStop(2)), ')'];
          j = j + 1;
        case 'v'
          yShift = str2num(parts{j});
          pStop = pStart + [0, yShift];
          j = j+1;
        otherwise
          tikzPath = [tikzPath, ' x'];
          j = j+1;
      end

    end
  
  end
  
  tikzPath = [tikzPath, ' -- cycle'];
  tikzPaths{end+1} = tikzPath;
  
end
