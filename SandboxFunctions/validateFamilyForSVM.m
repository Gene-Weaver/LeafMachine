function validFamily = validateFamilyForSVM(family,allFamilies)
    validFamily = 'NaN';
    for i = 1:length(family)
        if ismember(lower(family{i}),allFamilies.allPlantFamilies.family)
            validFamily = lower(family{i});
        end
    end
end