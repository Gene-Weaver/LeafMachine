function n = countUniqItemsInTable(INFO)
    T = cell2table(INFO);
    TTT = ismember(T{:,1}, {'','NaN'});
    T(TTT, :) = [];
    n = height(unique(T,'rows'));
end