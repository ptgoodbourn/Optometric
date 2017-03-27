function [participant, optometric] = getParticipantDataFile_VA( directory, participant, program )
%GETPARTICIPANTDATAFILE_VA Makes or retrieves a data file for optometric
%(visual acuity and refraction) data entry.
%
%   Looks in the current directory for a participant data file for the
%   current participant. If it exists, it prompts the user to either load
%   the existing data or overwrite it. If it doesn't exist already, it
%   creates a new one using the parameters passed to the function.
%   
%   Usage:
%   [participant, optometric] =
%        getParticipantDataFile_VA(directory, participant, program)
%
%   All of the input and output arguments are structures with one or more 
%   fields. 'participant' contains participant infomation. 'optometric'
%   is a structure for storing data. 'program' contains information about
%   the optometric data entry program.
%   
%   Inputs must contain (at a minimum):
%
%   directory.data (Full path to data directory)
%
%   participant.code (Partipant identifier; see getParticipantCode)
%
%   program.measurementList (cell array of strings containing the name of
%   each measurement)
%
%   09/03/17 PTG adapted it from getParticipantDataFile_CTP.

    % Check current directory for user data file
    participant.dataFile = [directory.data participant.code '_Data_VA.mat'];
    newUser = ~exist(participant.dataFile,'file');
    dontMake = 0;

    if ~ newUser
        % Ask whether to load the file or create a new one
        buttonOut = questdlg({'Data file exists.','Load existing file or create a new one?'},...
            'Load or Create?','Load Existing','Create New','Load Existing');
        
        if strcmp(buttonOut,'Load Existing')
            load(participant.dataFile);
            dontMake = 1;
        end
        
    end
        
    if ~dontMake
        
        participant.completeMeasurements = [];
        participant.currentList = program.measurementList;
        optometric = struct;

        % Save data file
        save(participant.dataFile, 'directory', 'participant', 'program', 'optometric');

    end

end