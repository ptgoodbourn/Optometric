%OPTOMETRIC_DATAENTRY Record optometric measurements.
%
%   Stores optometric measurements entered into pop-up dialogue boxes.
%
%   03/17 PTG wrote it.

close all;

% Set directories
directory.base = '/Users/experimentalmode/Documents/MATLAB/Optometric/';
directory.data = [directory.base 'Data_VA/'];
addpath(genpath(directory.base));                           % Add directories to the MATLAB path

% Open a large figure to cover the background
backgroundFigure = figure('Color','white','DockControls','off','MenuBar','none','NumberTitle','off','ToolBar','none',...
    'Resize','off','SelectionHighlight','off','HitTest','off','OuterPosition',[-100 -100 2000 2000]);

% Get participant details
participant.code = getParticipantCodePopup();                % Get participant code from dialogue box

program.measurementList = {'Sighting Dominance','Cover Test','Uncorrected Acuity (Left)','Uncorrected Acuity (Right)',...
    'Refraction', 'Corrected Acuity', 'Notes'};
program.acuityList = -0.3:0.02:1.1;
program.acuityString = cellstr(num2str(program.acuityList','%+.2f'));
program.powList = -12:0.25:12;
program.zeroPowIndex = 49;
program.powString = cellstr(num2str(program.powList','%+.2f'));
program.eyeString = {'Left','Right'};
program.coverString = {'Heterotropia OS (Single Cover)','Heterotropia OD (Single Cover)',...
    'Heterophoria OS (Cover-Uncover)','Heterophoria OD (Cover-Uncover)','Other'};
program.acuityCriterion = 0.1;
program.nMeasurements = length(program.measurementList);
program.mainDialogSize = [250 100];
program.allDialogSize = [250 30;
                        250 80;
                        250 250;
                        250 250;
                        250 250;
                        250 250;
                        250 250];

% Create or retrieve participant data file
[participant, optometric] = getParticipantDataFile_VA(directory, participant, program);  % Makes a new file or retrieves existing one

inComplete = true;

while inComplete
    
    inparticipant.completeMeasurements = setdiff(1:program.nMeasurements,participant.completeMeasurements);
    firstIncomplete = min(inparticipant.completeMeasurements);
    
    [selectedMeasurement, OK] = listdlg('ListString',participant.currentList,'PromptString','Please select a measurement',...
        'SelectionMode','single','InitialValue',firstIncomplete,'Name','Optometric Data Entry',...
        'OKString','Proceed','CancelString','Quit','ListSize',program.mainDialogSize);
    
        
    if ~OK
        if isempty(inparticipant.completeMeasurements)
            inComplete = 0;
        else
            questCell = ['Are you sure you want to quit?', ' ', 'The following items are incomplete:',...
                ' ', program.measurementList(inparticipant.completeMeasurements)];
           
            buttonName = questdlg(questCell,'Confirmation','Quit','Return','Return');
                    switch buttonName
                        case 'Quit'
                            inComplete = 0;
                            % Save final data
                            save(participant.dataFile, 'directory', 'participant', 'optometric', 'program');
                        case 'Return'
                            inComplete = 1;
                    end
        end
    
    elseif selectedMeasurement==1
        % Sighting dominance
        selectedVal = listdlg('ListString',program.eyeString,'Name','Sighting Dominance',...
            'PromptString','Select preferred eye','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:));
        
        if ~isempty(selectedVal)
            optometric.preferredEye = program.eyeString{selectedVal};
            participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
            participant.currentList(selectedMeasurement) = strcat(program.measurementList{selectedMeasurement},...
                ' [',program.eyeString(selectedVal),']');
            
            if isfield(optometric,'uncorrectedOD')&&isfield(optometric,'uncorrectedOS')
                if ((optometric.uncorrectedOD-optometric.uncorrectedOS) >= 0.09)
                    buttonName = questdlg('OS acuity is at least one line better. Test with the left eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Left';
                        case 'Override'
                            optometric.testedEye = 'Right';
                    end
                    
                elseif ((optometric.uncorrectedOS-optometric.uncorrectedOD) >= 0.09)
                    % If OD is at least one line better, use OD
                    buttonName = questdlg('OD acuity is at least one line better. Test with the right eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Right';
                        case 'Override'
                            optometric.testedEye = 'Left';
                    end

                else
                    buttonName = questdlg(['OS and OD acuity within one line. Test with the ' lower(optometric.preferredEye) ' eye.'],'Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                        	optometric.testedEye = optometric.preferredEye;
                        case 'Override'
                            if strcmp(optometric.preferredEye,'Left')
                                optometric.testedEye = 'Right';
                            else
                                optometric.testedEye = 'Left';
                            end
                    end
                end
                                
                participant.currentList{5} = ['Refraction (' optometric.testedEye ')'];
                participant.currentList{6} = ['Corrected Acuity (' optometric.testedEye ')'];  
                
            end
        end
        
    elseif selectedMeasurement==2
        % Cover test
        selectedVal = questdlg('Is heterotropia or heterophoria present?','Cover Test');
        
        if ~isempty(selectedVal) && ~strcmp(selectedVal,'Cancel')
            optometric.phoriaPresent = selectedVal;
            participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
            participant.currentList(selectedMeasurement) = strcat(program.measurementList(selectedMeasurement),...
                ' [',selectedVal,']');
            
            if strcmp(selectedVal,'Yes')
                
               selectedVals = listdlg('ListString',program.coverString,'Name','Cover Test',...
                                'PromptString','Select all that apply (command-click for multiple selections)','ListSize',program.allDialogSize(selectedMeasurement,:));
                
                if ~isempty(selectedVals)
                    optometric.phoriaType = selectedVals;
                else
                    optometric.phoriaType = 'None';
                end
                
                outVal = inputdlg('Enter additional notes below','Notes',2);
                outVal = outVal{1};

                if ~isempty(outVal)
                    optometric.phoriaNotes = outVal;
                else
                    optometric.phoriaNotes = 'N/A';
                end
                
            else
                optometric.phoriaType = 'None';
                optometric.phoriaNotes = 'N/A';
            end
        end
        
    elseif selectedMeasurement==3
        % Uncorrected OS
        selectedVal = listdlg('ListString',program.acuityString,'Name','Uncorrected Acuity (OS)',...
            'PromptString','Select left-eye acuity','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:));
        
        if ~isempty(selectedVal)
            optometric.uncorrectedOS = program.acuityList(selectedVal);
            participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
            participant.currentList(selectedMeasurement) = strcat(program.measurementList{selectedMeasurement},...
                ' [',program.acuityString(selectedVal),']');
            
            if isfield(optometric,'uncorrectedOD')&&isfield(optometric,'preferredEye')
                if ((optometric.uncorrectedOD-optometric.uncorrectedOS) >= 0.09)
                    buttonName = questdlg('OS acuity is at least one line better. Test with the left eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Left';
                        case 'Override'
                            optometric.testedEye = 'Right';
                    end
                    
                elseif ((optometric.uncorrectedOS-optometric.uncorrectedOD) >= 0.09)
                    % If OD is at least one line better, use OD
                    buttonName = questdlg('OD acuity is at least one line better. Test with the right eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Right';
                        case 'Override'
                            optometric.testedEye = 'Left';
                    end

                else
                    buttonName = questdlg(['OS and OD acuity within one line. Test with the ' lower(optometric.preferredEye) ' eye.'],'Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                        	optometric.testedEye = optometric.preferredEye;
                        case 'Override'
                            if strcmp(optometric.preferredEye,'Left')
                                optometric.testedEye = 'Right';
                            else
                                optometric.testedEye = 'Left';
                            end
                    end
                end
                                
                participant.currentList{5} = ['Refraction (' optometric.testedEye ')'];
                participant.currentList{6} = ['Corrected Acuity (' optometric.testedEye ')'];  
                
            end
        end

    elseif selectedMeasurement==4
        % Uncorrected OD
        selectedVal = listdlg('ListString',program.acuityString,'Name','Uncorrected Acuity (OD)',...
            'PromptString','Select right-eye acuity','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:));
        optometric.uncorrectedOD = program.acuityList(selectedVal);
        
        if ~isempty(selectedVal)
            optometric.uncorrectedOD = program.acuityList(selectedVal);
            participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
            participant.currentList(selectedMeasurement) = strcat(program.measurementList{selectedMeasurement},...
                ' [',program.acuityString(selectedVal),']');
            
            if isfield(optometric,'uncorrectedOS')&&isfield(optometric,'preferredEye')
                if ((optometric.uncorrectedOD-optometric.uncorrectedOS) >= 0.09)
                    buttonName = questdlg('OS acuity is at least one line better. Test with the left eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Left';
                        case 'Override'
                            optometric.testedEye = 'Right';
                    end
                    
                elseif ((optometric.uncorrectedOS-optometric.uncorrectedOD) >= 0.09)
                    % If OD is at least one line better, use OD
                    buttonName = questdlg('OD acuity is at least one line better. Test with the right eye.','Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.testedEye = 'Right';
                        case 'Override'
                            optometric.testedEye = 'Left';
                    end

                else
                    buttonName = questdlg(['OS and OD acuity within one line. Test with the ' lower(optometric.preferredEye) ' eye.'],'Tested Eye','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                        	optometric.testedEye = optometric.preferredEye;
                        case 'Override'
                            if strcmp(optometric.preferredEye,'Left')
                                optometric.testedEye = 'Right';
                            else
                                optometric.testedEye = 'Left';
                            end
                    end
                end
                                
                participant.currentList{5} = ['Refraction (' optometric.testedEye ')'];
                participant.currentList{6} = ['Corrected Acuity (' optometric.testedEye ')'];  
                
            end
            
        end
        
    elseif selectedMeasurement==5
        % Refraction (preferred)
        if ~isfield(optometric,'testedEye')
            uiwait(errordlg('Determine preferred eye and uncorrected acuity first.','modal'));
        else
      
            % Spherical power
            selectedVal = listdlg('ListString',program.powString,'Name','Refraction: Spherical Power',...
                'PromptString','Select spherical power','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:),...
                'InitialValue', program.zeroPowIndex);
            
            if ~isempty(selectedVal)
                optometric.sphericalPower = program.powList(selectedVal);
                
                % Cylindrical power
                selectedVal = listdlg('ListString',program.powString,'Name','Refraction: Cylindrical Power',...
                    'PromptString','Select cylindrical power','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:),...
                    'InitialValue', program.zeroPowIndex);

                if ~isempty(selectedVal)
                    optometric.cylindricalPower = program.powList(selectedVal);
                    
                    if abs(optometric.cylindricalPower) > 0.1
                        % Cylindrical axis
                        goodVal = 0;
                        while ~goodVal
                            outVal = inputdlg('Select cylindrical axis','Refraction: Cylindrical Axis',1);
                            outVal = str2double(outVal{1});
                            if ~isempty(outVal)
                                goodVal = 1;
                                if (outVal<=0) || (outVal>180)
                                    outVal = mod(outVal,180);
                                    uiwait(warndlg('Angle converted to range [0, 180).','modal'));
                                end
                                optometric.cylindricalAxis = round(outVal);
                                optometric.refractionString = [num2str(optometric.sphericalPower,'%+.2f')...
                                    ' ' num2str(optometric.cylindricalPower,'%+.2f')...
                                    ' × ' num2str(optometric.cylindricalAxis,'%d')];
                            end
                        end
                    else
                        optometric.cylindricalAxis = NaN;
                        optometric.refractionString = [num2str(optometric.sphericalPower,'%+.2f')...
                            ' ' num2str(optometric.cylindricalPower,'%+.2f')];
                    end
            
                    participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
                    participant.currentList{selectedMeasurement} = strcat(program.measurementList{selectedMeasurement},...
                            ' (', optometric.testedEye, ') [',optometric.refractionString,'°]');
            
                end
            end
            
        end
        
    elseif selectedMeasurement==6
        % Corrected acuity (preferred)
        
        if ~isfield(optometric,'testedEye')
            uiwait(errordlg('Determine preferred eye and uncorrected acuity first.','modal'));
        else
        
            selectedVal = listdlg('ListString',program.acuityString,'Name','Corrected Acuity',...
                'PromptString','Select corrected acuity','SelectionMode','single','ListSize',program.allDialogSize(selectedMeasurement,:));

            if ~isempty(selectedVal)
                optometric.correctedAcuity = program.acuityList(selectedVal);
                participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
                participant.currentList(selectedMeasurement) = strcat(program.measurementList{selectedMeasurement},...
                    ' [',program.acuityString(selectedVal),']');

                % Check for one-line improvement
                if strcmp(optometric.testedEye,'Left')
                    uncorrectedAcuity = optometric.uncorrectedOS;
                else
                    uncorrectedAcuity = optometric.uncorrectedOD;
                end
                
                if (uncorrectedAcuity - optometric.correctedAcuity) > 0.09
                    buttonName = questdlg('Improvement is at least one line. Apply correction.','Corrected Acuity','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.correctionApplied = 'Yes';
                        case 'Override'
                            optometric.correctionApplied = 'No';
                    end
                else
                    buttonName = questdlg('Improvement is less than one line. Do not apply correction.','Corrected Acuity','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.correctionApplied = 'No';
                        case 'Override'
                            optometric.correctionApplied = 'Yes';
                    end
                end

                % Check for criterion
                if optometric.correctedAcuity > (program.acuityCriterion +.01)
                    buttonName = questdlg('Corrected acuity is lower than criterion. Do not continue to test.','Corrected Acuity','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.continueToTest = 'No';
                        case 'Override'
                            optometric.continueToTest = 'Yes';
                    end
                else
                     buttonName = questdlg('Corrected acuity is meets criterion. Continue to test.','Corrected Acuity','Accept','Override','Accept');
                    switch buttonName
                        case 'Accept'
                            optometric.continueToTest = 'Yes';
                        case 'Override'
                            optometric.continueToTest = 'No';
                    end
                end
                
            end
            
        end

    elseif selectedMeasurement==7
        % Other notes
        outVal = inputdlg('Enter additional notes below','Notes',2);
        outVal = outVal{1};
        
        if ~isempty(outVal)
            optometric.otherNotes = outVal;
            participant.completeMeasurements = unique([participant.completeMeasurements selectedMeasurement]);
            participant.currentList{selectedMeasurement} = strcat(program.measurementList{selectedMeasurement},...
                ' [X]');
        end
        
    end

    % Save interim data
    save(participant.dataFile, 'directory', 'participant', 'optometric', 'program');

    
end

close(backgroundFigure);