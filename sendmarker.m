%SENDMARKER Sends a marker, either right away or synced to a display
%   Sends a marker from 1 to 255 to the actiChamp. If syncmode is 1, the
%   marker will be sent on the next flip command. Note that if syncmode ==
%   1, a PTB window also has to be provided so that the appropriate red
%   pixel can be added. If sync_mode == 0, the marker will be sent right
%   away (and no red pixel drawn).
%   August, 2015

function [ ] = sendmarker( marker, useDataPixx)

    % Marker should be from 1 to 255
    if marker < 1 || marker > 255
        disp('Warning: Marker should range from 1 to 255.');
    end

    if useDataPixx
        % Convert input marker to 24 bit number for the DataPixx2 digital output
        % TODO document this!!
        temp = de2bi(marker);
        dp_marker = zeros(1,2*length(temp) + 1);
        dp_marker(3:2:length(dp_marker)) = temp;
        dp_marker = bi2de(dp_marker);

        Datapixx('SetDoutValues', dp_marker);
        Datapixx('RegWrRd');

        % Zero the digital out
        WaitSecs(0.004); % Wait 4 ms (twice the sampling rate) before zeroing
        Datapixx('SetDoutValues', 0); % Set output to 0
        Datapixx('RegWrRd'); % Do it right away
        
    else
        % Do nothing
    end
end

