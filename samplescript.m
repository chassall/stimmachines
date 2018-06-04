% Sample Script
% C. Hassall
% June, 2018

%% Standard Krigolson Lab pre-script code
close all; clear variables; clc; % Clear everything
rng('shuffle'); % Shuffle the random number generator

%% Run flags
windowed = 0; % 1 if running experiment in a smaller window (useful for testing)
useDatapixx = 1; % 1 if using the Datapixx, 0 otherwisew

%% DataPIXX Setup
if useDatapixx
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    
    % We'll make sure that all the TTL digital outputs are low before we start
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWrRd');
    
    % Configure digital input system for monitoring button box
    Datapixx('EnableDinDebounce');                          % Debounce button presses
    Datapixx('SetDinLog');                                  % Log button presses to default address
    Datapixx('StartDinLog');                                % Turn on logging
    Datapixx('RegWrRd');
end

%% Define control keys
KbName('UnifyKeyNames'); % Ensure that key names are mostly cross-platform
ExitKey = KbName('ESCAPE'); % Exit program
    
%% Display Settings
% Lab
viewingDistance = 600; % mm, approximately
screenWidth = 477; % mm
screenHeight = 268; % mm
horizontalResolution = 1920; % Pixels
verticalResolution = 1080; % Pixels

% Set up window
if windowed
    displayRect = [0 0 600 400]; % Testing window
else
    displayRect = [0 0 horizontalResolution verticalResolution];
end
windowWidth = ((displayRect(3)-displayRect(1))/horizontalResolution)*screenWidth;
windowHeight = ((displayRect(4)-displayRect(2))/verticalResolution)*screenHeight;

% Compute pixels per mm
horizontalPixelsPerMM = (displayRect(3)-displayRect(1))/windowWidth;
verticalPixelsPerMM = (displayRect(4)-displayRect(2))/windowHeight;


%% Parameters
bgColour = [0 0 0];
textColour = [255 255 255];
 
%% Experiment
try
    ListenChar(0); % Turn off character listening    
    
    if windowed
        [win, rec] = Screen('OpenWindow', 0, bgColour,displayRect, 32, 2);
    else
        Screen('Preference', 'SkipSyncTests', 1);
        [win, rec] = Screen('OpenWindow', 0, bgColour);
    end
    
    % Send several markers immediately
    DrawFormattedText(win,'press any key to send 1-10 immediately','center','center',textColour);
    Screen('Flip',win); 
    KbReleaseWait(); 
    KbPressWait();
    for t = 1:10
        sendmarker(t,useDatapixx);
    end
    WaitSecs(2);
    
    % Send several markers locked to screen refresh
    DrawFormattedText(win,'press any key to send 1-10 on refresh','center','center',textColour);
    Screen('Flip',win);
    KbReleaseWait(); 
    KbPressWait(); 
    for t = 1:10
        DrawFormattedText(win,num2str(t),'center','center',textColour);
        flipandmark(win,t,useDatapixx);
    end  
    WaitSecs(2);
    
    % Get response 
    DrawFormattedText(win,'waiting for button press...','center','center',textColour);
    Screen('Flip',win);
    thisResponse = getresponse(useDatapixx); 
    while ~thisResponse
        thisResponse = getresponse(useDatapixx);
        
        % Chec  k for escape key
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyCode(ExitKey)
            ME = MException('samplescript:escapekeypressed','Exiting script');
            throw(ME);
        end
    end
    DrawFormattedText(win,thisResponse,'center','center',textColour);
    Screen('Flip',win);
    WaitSecs(2); 
    
    % Close the Psychtoolbox window and bring back the cursor and keyboard
    Screen('CloseAll');
    ListenChar();
     
    % Close the DataPixx2
    if useDatapixx
        Datapixx('Close');
    end
  
catch e
     
    % Close the Psychtoolbox window and bring back the cursor and keyboard
    Screen('CloseAll');
    ListenChar();
     
    % Close the DataPixx2
    if useDatapixx
        Datapixx('Close');
    end
    
    rethrow(e);
end