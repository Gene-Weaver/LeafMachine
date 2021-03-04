function n = find_Min_Max(INFO,minmax)
    if minmax == "min"
        T = INFO;
        [TTT, ~] = find(cellfun(@(s) isequal(s, ''), T));
        T(TTT, :) = [];
        T = cell2mat(T);
        T(isnan(T)) = [];
        T2 = find(T<1500);
        T(T2, :) = [];
        n = min(T);
    elseif minmax == "max"
        T = INFO;
        [TTT, ~] = find(cellfun(@(s) isequal(s, ''), T));
        T(TTT, :) = [];
        T = cell2mat(T);
        T(isnan(T)) = [];
        T2 = find(T<1500);
        T(T2, :) = [];
        n = max(T);
    end
end