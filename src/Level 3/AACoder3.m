function AACSeq3 = AACoder3(fNameIn, fNameAACoded)
%AACODER3 Encodes a 2 channel wav file (Level 3).
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% - fNameAACoded: The name of a ".mat" file where the returned AACSeq3 is
%                 saved.
%
% Returns:
% - AACSeq3: A Kx1 struct, where K is the number of the encoded frames.
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
%       - .chl.T: The thresholds of the psychoacoustic model of the left
%                 channel. (Nx1 where N is the number of the bands)
%       - .chr.T: The thresholds of the psychoacoustic model of the right
%                 channel. (Nx1 where N is the number of the bands)
%       - .chl.G: The quantized global gains of the left channel.
%                  (1x8 if the frameType is "ESH" or scalar if not)
%       - .chr.G: The quantized global gains of the right channel.
%                  (1x8 if the frameType is "ESH" or scalar if not)
%       - .chl.sfc: The huffman encoded sfc sequence for the left channel.
%       - .chr.sfc: The huffman encoded sfc sequence for the right channel.
%       - .chl.stream: The huffman encoded quantized MDCT coefficients of
%                      the left channel.
%       - .chr.stream: The huffman encoded quantized MDCT coefficients of
%                      the right channel.
%       - .chl.codebook: The huffman codebook that was used on the left
%                        channel.
%       - .chr.codebook: The huffman codebook that was used on the right
%                        channel.
%

% Read the wav file, from either string or char array
audio = audioread(char(fNameIn));

% Total samples of audio
samples = length(audio);

% Frames for encoding
totalFrames = floor(samples / 1024) - 1 - 2;

% AACSeq3 array's memory preallocation
AACSeq3 = struct('frameType', "  ", 'winType', "   ", 'chl', struct(), 'chr', struct());
AACSeq3(totalFrames, 1) = AACSeq3;

% For every frame encode the data and put it on the struct vector AACSeq3
for frame = 1:totalFrames
    % Take the samples of the current, prev1 and prev2 frames
    currentIndex = 1024 * (frame + 1) + 1;
    prev1Index = currentIndex - 1024;
    prev2Index = currentIndex - 2048;
    frameT = audio(currentIndex:currentIndex + 2047, :);
    frameTprev1 = audio(prev1Index:prev1Index + 2047, :);
    frameTprev2 = audio(prev2Index:prev2Index + 2047, :);
    
    % Calculate the type of the frame
    if frame ~= 1 && frame ~= totalFrames
        % Take the samples of the next frame
        nextIndex = 1024 * frame + 1;
        nextFrameT = audio(nextIndex:nextIndex + 2047, :);
        AACSeq3(frame).frameType = SSC(frameT, nextFrameT, AACSeq3(frame - 1).frameType);
    elseif frame == 1
        % First frame
        AACSeq3(frame).frameType = "OLS";
    else
        % Last frame
        if AACSeq3(frame - 1).frameType == "LSS"
            AACSeq3(frame).frameType = "ESH";
        elseif AACSeq3(frame - 1).frameType == "LPS"
            AACSeq3(frame).frameType = "OLS";
        else
            % OLS or ESH
            AACSeq3(frame).frameType = AACSeq3(frame - 1).frameType;
        end
    end
        
    % Chose window type here ("KBD" or "SIN")
    AACSeq3(frame).winType = "KBD";
    
    % Calculate the MDCT coeficients
    frameF = filterbank(frameT, AACSeq3(frame).frameType, AACSeq3(frame).winType);
    
    % Apply TNS and put frameF ans TNScoeffs into the struct
    if AACSeq3(frame).frameType == "ESH"
        [frameF_L, AACSeq3(frame).chl.TNScoeffs] = ... 
            TNS(reshape(frameF(:, 1), [128, 8]), AACSeq3(frame).frameType);
        [frameF_R, AACSeq3(frame).chr.TNScoeffs] = ... 
            TNS(reshape(frameF(:, 2), [128, 8]), AACSeq3(frame).frameType);
    else
        [frameF_L, AACSeq3(frame).chl.TNScoeffs] = ... 
            TNS(frameF(:, 1), AACSeq3(frame).frameType);
        [frameF_R, AACSeq3(frame).chr.TNScoeffs] = ... 
            TNS(frameF(:, 2), AACSeq3(frame).frameType);
    end
    
    % Calculate SMR
    SMR_L = psycho(frameT(:, 1), AACSeq3(frame).frameType, frameTprev1(:, 1), frameTprev2(:, 1));
    SMR_R = psycho(frameT(:, 2), AACSeq3(frame).frameType, frameTprev1(:, 2), frameTprev2(:, 2));    
    
    [S_L, sfc_L, AACSeq3(frame).chl.G] = AACquantizer(frameF_L, AACSeq3(frame).frameType, SMR_L);
    [S_R, sfc_R, AACSeq3(frame).chr.G] = AACquantizer(frameF_R, AACSeq3(frame).frameType, SMR_R);
    
    % Apply Huffman coding to S
    [AACSeq3(frame).chl.stream, AACSeq3(frame).chl.codebook] = encodeHuff(S_L, loadLUT());
    [AACSeq3(frame).chr.stream, AACSeq3(frame).chr.codebook] = encodeHuff(S_R, loadLUT());
    
    % Apply Huffman coding to sfc
    [AACSeq3(frame).chl.sfc, ~] = encodeHuff(sfc_L(:), loadLUT(), 12);
    [AACSeq3(frame).chr.sfc, ~] = encodeHuff(sfc_R(:), loadLUT(), 12);
    
    % Calculate the audibility thresholds
    AACSeq3(frame).chl.T = calculateT(frameF_L, SMR_L, AACSeq3(frame).frameType);
    AACSeq3(frame).chr.T = calculateT(frameF_R, SMR_R, AACSeq3(frame).frameType);
end

% Save AACSeq3
save(fNameAACoded, 'AACSeq3')
end

% This function calculates the audibility thresholds
function T = calculateT(frameF, SMR, frameType)
if frameType == "ESH"
    table = load('TableB219.mat', 'B219b');
    table = table.B219b;
    cols = 8;
    NB = length(table);    
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    cols = 1;
    NB = length(table);
end

wlow = table(:, 2) + 1;
whigh = table(:, 3) + 1;
P = zeros(NB, 1);

for i = 1:cols
    % Calculate the power
    for b = 1:NB
        indexes = wlow(b):whigh(b);
        P(b) = sum(frameF(indexes, i).^2);
    end
end

% Calculate the audibility thresholds
T = P ./ SMR;
end