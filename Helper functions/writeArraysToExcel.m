function writeArraysToExcel(filepath, sheetName, columnLabels, data)

    % Example column labels
    % columnLabels = {
    %   {'Column1', 'Column2'}, 
    %   {'Column3', 'Column4', 'Column5'}, 
    %   {'Column6'}
    % };

    % Example data that matches the column label structure
    % data = {
    %   {[1, 2, 3], [4, 5, 6]}, 
    %   {[7, 8, 9], [10, 11, 12], [13, 14, 15]},
    %   {[16, 17, 18, 99, 100]}
    % };

    % Number of groups
    numGroups = length(data);

    % Find the length of the arrays within each group
    groupLengths = cellfun(@(group) numel(group{1}), data);

    % Find the maximum length among all arrays
    maxLength = max(groupLengths);

    % Initialize an empty cell array of the appropriate size
    % Include extra empty columns between groups
    numColumns = sum(cellfun(@(group) length(group), data));
    dataInColumns = cell(maxLength, numColumns + numGroups - 1); 
    fullColumnLabels = cell(1, numColumns + numGroups - 1);
    % Start column index
    startColumn = 1;

    for i = 1:numGroups
        % Number of arrays in this group
        numArrays = length(data{i});

        for j = 1:numArrays
            % Fill in the new cell array with your data, put each array in its own column
            dataInColumns(1:groupLengths(i), startColumn + j - 1) = num2cell(data{i}{j});
            % Add the column label
            fullColumnLabels{startColumn + j - 1} = columnLabels{i}{j};
        end

        % Label for the empty column
        if i < numGroups
          % fullColumnLabels{startColumn + numArrays} = ['empty', num2str(i)];
          fullColumnLabels{startColumn + numArrays} = repmat(' ', 1, i);
        end
        
        % Leave the next column empty to separate groups
        startColumn = startColumn + numArrays + 1;
    end

    % Convert to table
    T = cell2table(dataInColumns, 'VariableNames', fullColumnLabels);
    
    % Delete the existing file before writing new data
    if exist(filepath, 'file')
        delete(filepath);
    end

    % Write to Excel
    writetable(T, filepath, 'Sheet', sheetName);
end