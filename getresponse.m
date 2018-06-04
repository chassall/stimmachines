function [ participant_response ] = getresponse ( useDataPixx )
%GETRESPONSE Gets participant response
%   Returns a 0 if no response has been made. Otherwise, returns the
%   response. If dummy_mode == 1, just gets a key press.

% Bit locations of button inputs
dinRed = hex2dec('0000FFFE');
dinGreen = hex2dec('0000FFFB');
dinYellow = hex2dec('0000FFFD');
dinBlue = hex2dec('0000FFF7');
dinWhite = hex2dec('0000FFEF');
participant_response = 0;

% If we're not actually using the DataPixx2, just use the keyboard
if ~useDataPixx
    [madeResponse, ~, keyCode, ~] = KbCheck();
    if madeResponse
        pressedKeyIndex = find(keyCode);
        participant_response = KbName(pressedKeyIndex);
    end
else
    Datapixx('RegWrRd');
    buttonLogStatus = Datapixx('GetDinStatus');
    if (buttonLogStatus.newLogFrames > 0)
        [data, ~] = Datapixx('ReadDinLog')
        if buttonLogStatus.newLogFrames > 0 && length(data) == 1
            switch data
                case dinRed
                    participant_response = 'r';
                case dinBlue
                    participant_response = 'b';
                case dinYellow
                    participant_response = 'y';
                case dinGreen
                    participant_response = 'g';
                case dinWhite
                    participant_response = 'w';
            end
        end
    end
end

end

