function n = countItemsInTable(INFO,special,nImg)
    if special == "year"
        T = INFO;
        [TTT, ~] = find(cellfun(@(s) isequal(s, ''), T));
        T(TTT, :) = [];
        
        T = cell2mat(T);
        T(isnan(T)) = [];
        T2 = find(T>1500);
        n = length(T2)/nImg;
    elseif special == "number"
        T = INFO;
        [TTT, ~] = find(cellfun(@(s) isequal(s, ''), T));
        T(TTT, :) = [];
        T = cell2mat(T);
        T(isnan(T)) = [];
        n = length(T)/nImg;
    else 
        T = cell2table(INFO);
        try
            TTT = ismember(T{:,1}, {'','NaN'});
            T(TTT, :) = [];
            n = height(T)/nImg;
        catch
            TT = table2array(T);
            emptyCells = cellfun(@isempty,TT);
            %# remove empty cells
            TT(emptyCells) = [];
            n = length(TT)/nImg;
        end
        
    end
end