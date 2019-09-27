% leafSnapSegmenter

% Dig into files
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
% baseFolder = fullfile('D:\Will Files\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
subFolders = genpath(baseFolder);
subFolders_0 = subFolders;

listOfFolderNames = {};
while true
	[singleSubFolder, subFolders_0] = strtok(subFolders_0, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames)



% Get info from DwC files
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
    parsing = strsplit(thisFolder,'\');
    lp = length(parsing);
    saveName = parsing{lp};
    
    
    
end