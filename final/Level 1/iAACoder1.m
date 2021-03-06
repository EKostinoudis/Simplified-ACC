function x = iAACoder1(AACSeq1, fNameOut)
%IAACODER1 Decodes a 2 channel wav file (Level 1).
% Arguments:
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
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
% Returns:
% - x: If the fNameOut argument is not provided, the decoded sample
%      sequence is stored in the returned variable x.

totalFrames = length(AACSeq1);

% init audio
audio = zeros((totalFrames + 1) * 1024, 2);

for frame = 1:totalFrames
    % Construct frameF
    if AACSeq1(frame).frameType == "ESH"
        frameF = [reshape(AACSeq1(frame).chl.frameF, [1024, 1]), ...
            reshape(AACSeq1(frame).chr.frameF, [1024, 1])];
    else
        frameF = [AACSeq1(frame).chl.frameF, AACSeq1(frame).chr.frameF];
    end
    
    % Apply IMDCT to the current frame
    frameT = iFilterbank(frameF, AACSeq1(frame).frameType, AACSeq1(frame).winType);
    
    % Add the frameT to the audio
    currentIndex = 1024 * (frame - 1) + 1;
    audio(currentIndex:currentIndex + 2047, :) = audio(currentIndex:currentIndex + 2047, :) ...
        + frameT;
end

% Write the audio to the file
audiowrite(char(fNameOut), audio, 48000);

if nargout == 1
    x = audio;
end

end

