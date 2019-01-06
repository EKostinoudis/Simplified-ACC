function AACSeq1 = AACoder1(fNameIn)
%AACODER1 Encodes a 2 channel wav file (Level 1).
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% Returns:
% - AACSeq1: A Kx1 struct, where K is the number of the encoded frames.
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
%       - .chl.frameF: The MDCT coefficients of the left channel. A table
%                      of size 128x8 for the "ESH" frameType or 1024x1 for
%                      any other frameType.
%       - .chr.frameF: The MDCT coefficients of the right channel. A table
%                      of size 128x8 for the "ESH" frameType or 1024x1 for
%                      any other frameType.
%

% Read the wav file 
audio = audioread(fNameIn);

% Total samples of audio
samples = length(audio);

% Frames for encoding
totalFrames = floor(samples / 1024) - 1;

% For every frame encode the data and put it on the struct vector AACSeq1
for frame = 1:totalFrames
    % Take the samples of the current frame
    currentIndex = 1024 * (frame - 1) + 1;
    frameT = audio(currentIndex:currentIndex + 2047, :);
    
    
    % Calculate the type of the frame
    if frame ~= 1 && frame ~= totalFrames
        % Take the samples of the next frame
        nextIndex = 1024 * frame + 1;
        nextFrameT = audio(nextIndex:nextIndex + 2047, :);
        AACSeq1(frame).frameType = SSC(frameT, nextFrameT, AACSeq1(frame - 1).frameType);
    elseif frame == 1
        % First frame
        AACSeq1(frame).frameType = "OLS";
    else
        % Last frame
        if AACSeq1(frame - 1).frameType == "LSS"
            AACSeq1(frame).frameType = "ESH";
        elseif AACSeq1(frame - 1).frameType == "LPS"
            AACSeq1(frame).frameType = "OLS";
        else
            % OLS or ESH
            AACSeq1(frame).frameType = AACSeq1(frame - 1).frameType;
        end
    end
        
    % TODO later (don't know the correct solution)
    AACSeq1(frame).winType = "KBD";
    
end

end

