function [validFamily,ii] = validateFamilyForSVM(family,allFamilies)
    validFamily = 'NaN';
    ii = "NA";
    for i = 1:length(family)
        if ismember(lower(family{i}),allFamilies.allPlantFamilies.family)
            validFamily = lower(family{i});
            ii = i;
        end
    end
end