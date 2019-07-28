%%% Generate list of family, dim, id for DwC files for buildSVMdataset

families = readtable('D:\Dropbox\ML_Project\Image_Database\Plant_Families\allPlantFamilies.csv');

files = dir(fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg', '*.jpg'));

headers = {'herbarium','id','family','megapixels','familyQC'};
data = cell(10000,length(headers));
parametersLeaf = cell2table(data);
parametersLeaf.Properties.VariableNames = headers;


       
for p = 1:length(files)
    img = imread(fullfile(files(p).folder,files(p).name));
    
    dim = size(img);
    mp = dim(1)*dim(2)/1000000;
    
    parametersLeaf.megapixels{p} = mp;
    
    fname = files(p).name;
    parsing = strsplit(fname,{'_','.'})
    lp = length(parsing);

    parametersLeaf.herbarium{p} = parsing{1};
    parametersLeaf.id{p} = parsing{2};
    if lp <= 4
        parametersLeaf.family{p} = '';
        parametersLeaf.familyQC{p} = "noFamily";
    else
        if  ismember(lower(parsing{3}),families.family)
            parametersLeaf.family{p} = lower(parsing{3});
            parametersLeaf.familyQC{p} = "valid";
        else
            parametersLeaf.family{p} = '';
            parametersLeaf.familyQC{p} = strjoin(["invalid_" parsing{3}],'');
        end
    end
end

writetable(parametersLeaf,fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category','DwC_10RandImg_SVM_parameters.xlsx'));