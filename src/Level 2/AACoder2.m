function AACSeq2 = AACoder2(fNameIn)
%AACODER2 Encodes a 2 channel wav file (Level 2).
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% Returns:
% - AACSeq2: A Kx1 struct, where K is the number of the encoded frames.
%       Each element contains:
%       - .frameType: The type of the frame
%                     Possible Values and their meanings:
%                     - "OLS": Standing for ONLY_LONG_SEQUENCE
%                     - "LSS": Standing for LONG_START_SEQUENCE
%                     - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%                     - "LPS": Standing for LONG_STOP_SEQUENCE
%       - .winType: The type of the weight window chosen for the frame.
%                     Possible Values:
%                     - "KBD"
%                     - "SIN"
%       - .chl.TNScoeffs: The TNS quantized coefficients of the L channel.
%                      (4x8 for "ESH" or 4x1 for any other frameType)
%       - .chr.TNScoeffs: The TNS quantized coefficients of the R channel.
%                      (4x8 for "ESH" or 4x1 for any other frameType)
%       - .chl.frameF: The MDCT coefficients of the left channel after TNS.
%                      A table of size 128x8 for the "ESH" frameType or 
%                      1024x1 for any other frameType.
%       - .chr.frameF: The MDCT coefficients of the right channel after TNS.
%                      A table of size 128x8 for the "ESH" frameType or 
%                      1024x1 for any other frameType.
%

% Read the wav file, from either string or char array
audio = audioread(char(fNameIn));

% Total samples of audio
samples = length(audio);

% Frames for encoding
totalFrames = floor(samples / 1024) - 1;

% AACSeq2 array's memory preallocation
AACSeq2 = struct('frameType', "  ", 'winType', "   ", 'chl', struct('frameF', zeros(1024,1)), 'chr', struct('frameF', zeros(1024,1)));
AACSeq2(totalFrames, 1) = AACSeq2;

% For every frame encode the data and put it on the struct vector AACSeq2
for frame = 1:totalFrames
    % Take the samples of the current frame
    currentIndex = 1024 * (frame - 1) + 1;
    frameT = audio(currentIndex:currentIndex + 2047, :);
    
    
    % Calculate the type of the frame
    if frame ~= 1 && frame ~= totalFrames
        % Take the samples of the next frame
        nextIndex = 1024 * frame + 1;
        nextFrameT = audio(nextIndex:nextIndex + 2047, :);
        AACSeq2(frame).frameType = SSC(frameT, nextFrameT, AACSeq2(frame - 1).frameType);
    elseif frame == 1
        % First frame
        AACSeq2(frame).frameType = "OLS";
    else
        % Last frame
        if AACSeq2(frame - 1).frameType == "LSS"
            AACSeq2(frame).frameType = "ESH";
        elseif AACSeq2(frame - 1).frameType == "LPS"
            AACSeq2(frame).frameType = "OLS";
        else
            % OLS or ESH
            AACSeq2(frame).frameType = AACSeq2(frame - 1).frameType;
        end
    end
        
    % Chose window type here ("KBD" or "SIN")
    AACSeq2(frame).winType = "KBD";
    
    % Calculate the MDCT coeficients
    frameF = filterbank(frameT, AACSeq2(frame).frameType, AACSeq2(frame).winType);
    
    % Apply TNS and put frameF ans TNScoeffs into the struct
    if AACSeq2(frame).frameType == "ESH"
        [AACSeq2(frame).chl.frameF, AACSeq2(frame).chl.TNScoeffs] = ... 
            TNS(reshape(frameF(:, 1), [128, 8]), AACSeq2(frame).frameType);
        [AACSeq2(frame).chr.frameF, AACSeq2(frame).chr.TNScoeffs] = ... 
            TNS(reshape(frameF(:, 2), [128, 8]), AACSeq2(frame).frameType);
    else
        [AACSeq2(frame).chl.frameF, AACSeq2(frame).chl.TNScoeffs] = ... 
            TNS(frameF(:, 1), AACSeq2(frame).frameType);
        [AACSeq2(frame).chr.frameF, AACSeq2(frame).chr.TNScoeffs] = ... 
            TNS(frameF(:, 2), AACSeq2(frame).frameType);
    end
end
end
