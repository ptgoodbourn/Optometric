function [ participantCode ] = getParticipantCodePopup( nChars )
%GETPARTICIPANTCODE Gets a participant code from a popup dialogue.
%   Displays a popup dialogue for entering a participant
%   identifier. Returns the code with letters capitalised. By default, it 
%   expects a five-character alphanumeric code and will continue to prompt
%   for a code until that is received. Checks that all characters are
%   letters or numbers (or underscore).
%
%   participantCode = GETPARTICIPANTCODE gives the default behaviour.
%
%   participantCode = GETPARTICIPANTCODE(nChars) specifies the number of
%   characters to expect. Rounds to the nearest integer. Defaults to 5; set
%   to 0 if you want to turn off length-checking.
%
%   31/08/16 PTG wrote it.

if nargin < 1
    nChars = 5;
end

nChars = round(nChars);

tryAgain = 1;

while tryAgain==1
    
    if nChars >=1
        promptString = ['Enter participant code (' num2str(nChars) '  characters)'];
    else
        promptString = 'Enter participant code';
    end

    newCode = inputdlg(promptString, 'Participant code', 1);
    participantCode = newCode{1};
    
    % Check length
    tryAgain = 0;
    codeLength = length(participantCode);
    
    if nChars >=1

        if codeLength ~= nChars
            uiwait(errordlg('Wrong number of characters!','Length error','modal'))
            tryAgain = 1;
        end
        
    end
    
    % Check for alphanumeric characters
    for thisChar = 1:codeLength
        if ~isalpha_num(participantCode(thisChar))
            errorString = [participantCode(thisChar) ' is not an alphanumeric character!'];
            uiwait(errordlg(errorString,'Character error','modal'));
            tryAgain = 1;
        end
    end
    
    participantCode = upper(participantCode);

end

