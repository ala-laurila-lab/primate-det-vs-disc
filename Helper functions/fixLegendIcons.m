function fixLegendIcons(icons, shift, horizontal)

  lineCnt = 1;
  markCnt = 1;
  textCnt = 1;
  config = getConfiguration();

  for icon = icons'
    
    if strcmp(icon.Type, 'hggroup')
      chs = get(icon, 'Children');
      for ch = chs'
        if contains(ch.Type, 'group')
          chs2 = get(get(icon, 'Children'), 'Children');
          for icon2 = chs2'
            icon2.XData = icon2.XData + shift/2;
          end
        else
          if strcmp(ch.Type, 'patch')
            ch.XData = ch.XData + lineCnt*shift*0.5;
            ch.MarkerSize = ch.MarkerSize*0.5;
          else
            ch.FaceAlpha = 0.4;
            ch.XData(3:4) = ch.XData(3:4) + lineCnt*shift;
          end
        end
      end
      if horizontal
        lineCnt = lineCnt + 1;
      end
    end
    
    if strcmp(icon.Type, 'text')
      icon.Position = icon.Position + [textCnt*shift, icon.Position(2)*0.05, 0];
      icon.FontSize = config.Axes.FontSize;
      if horizontal
        textCnt = textCnt + 1;
      end
    end

    if strcmp(icon.Type, 'line') && any(strcmp({'-', '--', ':', '-.'}, icon.LineStyle))
      icon.XData = icon.XData + [(lineCnt-1)*shift, lineCnt*shift];
      if horizontal
        lineCnt = lineCnt + 1;
      end
    elseif strcmp(icon.Type, 'line') && ~strcmp(icon.Marker, 'none')
      icon.XData = icon.XData + (markCnt-0.5)*shift;
      if horizontal
        markCnt = markCnt + 1;
      end
    end
    
    if strcmp(icon.Type, 'patch')
      icon.XData(1:2) = icon.XData(1:2) + (lineCnt-1)*shift;
      icon.XData(3:4) = icon.XData(3:4) + lineCnt*shift;
      if horizontal
%         symCnt = symCnt + 1;
      end
    end
    
  end
  
end