% FLIPANDMARK Krigolson Lab version of flip.
% Sends a marker synced to a flip.


function [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = flipandmark( window, marker, useDataPixx )
    
    if marker < 1 || marker > 255
        disp('Warning: Marker should range from 1 to 255.');
    end

    % Convert input marker to 24 bit number for the DataPixx2 digital output
    temp = de2bi(marker);
    dp_marker = zeros(1,2*length(temp) + 1);
    dp_marker(3:2:length(dp_marker)) = temp;
    dp_marker = bi2de(dp_marker);

    pixel_colour = [floor(marker/100) floor(mod(marker,100)/10) floor(mod(marker,10))]; % Assign a pixel value for this marker
    pixel_rect = [0, 0, 1, 1]; % Top left pixel
    Screen('FillRect', window, pixel_colour, pixel_rect) % Add the pixel

    if useDataPixx
        Datapixx('SetDoutValues', dp_marker);
        Datapixx('RegWrPixelSync', pixel_colour');

        % Flip the display
        [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip',window);

        % Check that what was displayed matched what we set
        actual_colour = Datapixx('GetVideoLine', 1);
        if ~isequal(actual_colour', pixel_colour)
            disp('Error: something went wrong with the target pixel.');
        end

        % Zero the digital out
        WaitSecs(0.004); % Wait 4 ms (twice the sampling rate) before zeroing
        Datapixx('SetDoutValues', 0); % Set output to 0
        Datapixx('RegWrRd'); % Do it right away

    else 
        [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip',window);
    end

end

