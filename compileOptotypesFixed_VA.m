% This script takes individual optotype images (PNG) and combines them into
% lines of N optotypes. Images should be in folders separated according to
% size. These optotypes correspond to standard ETDRS charts lines. Letters
% are dropped from the largest optotypes to fit in the screen.

sourceFolder = '/Users/experimentalmode/Documents/MATLAB/Optometric/Optotypes_VA';
destinationFolder = '/Users/experimentalmode/Documents/MATLAB/Optometric/Stimuli_VA';
labelFolder = '/Users/experimentalmode/Documents/MATLAB/Optometric/Labels_VA';
stimVersions = {'Mini', 'Std'};
optoTypes = {'C', 'D', 'H', 'K', 'N', 'O', 'R', 'S', 'V', 'Z'};
acuityVals = 1.0:-0.1:-0.3;
optotypesPerRow = 5;
maxWidth = 2048;
outputPrefix = '2_';
nCopies = 1;

optoOrders = {'NCKZO RHSDK DOVHR CZRHS ONHRC DKSNV ZSOKN CKDNR SRZKD HZOVC NVDOK VHCNO SVHCZ OZDVK',...
    'DSRKN CKZOH ONRKD KZVDC VSHZO HDKCR CSRHN SVZDK NCVOZ RHSDV SNROH ODHKR ZKCSN CRHDV',...
    'ZRKDC DNCHV CDHNR RVZOS OSDVZ NOZCD RDNSK OKSVZ KSNHO HOVSN VCSZH CZDRV SHRZC DNOKR',...
    'HVZDS NCVKD CZSHN ONVSR KDNRO ZKCSV DVOHC OHVCK HZCKO NCKHD ZHCSR SZRDN HCDRO RDCSH'};

cd(sourceFolder);
folders = dir;
folderNames = {folders.name};
isFolder = [folders.isdir];
isFolder(strncmp(folderNames,'.',1)) = 0;
folderNames = folderNames(isFolder);
nFolders = numel(folderNames);
nVersions = numel(stimVersions);
nTypes = numel(optoTypes);

nOrders = length(optoOrders);

% Sort folder names
[~,sortOrder] = sort(cellfun(@str2num,folderNames));
folderNames = folderNames(sortOrder);

for thisFolder = 1:nFolders
    
    for thisVersion = 1:nVersions
        
        % Open the label folder
        cd(labelFolder);
        
        % Load the first label
        thisLabel = imread(strcat('Label_',folderNames{thisFolder},'_',stimVersions{thisVersion},'.png'), 'png');
        labelSize = size(thisLabel);
        
        % Open source folder
        cd(strcat(sourceFolder,'/',folderNames{thisFolder}));
        
        % Load the first optotype
        firstOpto = imread(strcat(optoTypes{1},'_',stimVersions{thisVersion},'.png'), 'png');
        optoSize = size(firstOpto);
        allOpto = 255*ones([nTypes optoSize]);
        allOpto(1,:,:,:) = firstOpto;
        
        % Load the remaining optotypes
        for thisOpto = 2:nTypes
            imOpto = imread(strcat(optoTypes{thisOpto},'_',stimVersions{thisVersion},'.png'), 'png');
            allOpto(thisOpto,:,:,:) = imOpto;
        end
        
        % Check how many will fit
        maxN = min([optotypesPerRow floor((maxWidth-(2*labelSize(2)))/optoSize(2))]);
        
        for thisOrder = 1:nOrders
            
            % Create destination folder
            dFolder = strcat(destinationFolder,'/',stimVersions{thisVersion},'/Chart',num2str(thisOrder),'/',folderNames{thisFolder});

            if ~exist(dFolder,'dir')
                mkdir(dFolder);
            end

            cd(dFolder);
            
            % Concatenate optotypes
            imOrder = optoOrders{thisOrder};
            allSpaces = strfind(imOrder,' ');
            allSpaces = [allSpaces allSpaces(end)+optotypesPerRow+1]; %#ok<AGROW>
            thisEnd = allSpaces(nFolders-thisFolder+1)-1;
            thisStart = thisEnd-optotypesPerRow+1;
            theseLetters = imOrder(thisStart:thisEnd);
            
            thisOpto = find(strcmp(optoTypes, theseLetters(1)));
            newIm = allOpto(thisOpto,:,:,:);
            
            for thisCol = 2:maxN
                thisOpto = find(strcmp(optoTypes, theseLetters(thisCol)));
                newIm = cat(3,newIm,allOpto(thisOpto,:,:,:));
            end
            
            newIm = uint8(squeeze(newIm));
            
            % Grow columns if necessary
            if size(newIm,2) < maxWidth
                growCols = maxWidth-size(newIm,2);
                startAdd = ceil(growCols/2);
                newIm = cat(2,255*ones(size(newIm,1),startAdd,3),newIm,...
                    255*ones(size(newIm,1),growCols-startAdd,3));
            end
                
            % Grow rows if necessary
            if size(newIm,1) < labelSize(1)
                growRows = labelSize(1)-size(newIm,1);
                startAdd = ceil(growRows/2);
                newIm = cat(1,255*ones(startAdd,size(newIm,2),3),newIm,...
                    255*ones(growRows-startAdd,size(newIm,2),3));
            end
            
            % Add label
            blankRows = size(newIm,1)-labelSize(1);
            firstRow = floor(blankRows/2) + 1;
            firstCol = maxWidth-labelSize(2) + 1;
            newIm(firstRow:firstRow+labelSize(1)-1, firstCol:end,:) = thisLabel;
            
            % Save to destination folder         
            for thisCopy = 1:nCopies
                thisName = strcat(outputPrefix,num2str(thisCopy,'%03d'),'.png');
                imwrite(newIm, thisName, 'png');
            end
            
        end
        
    end
    
end