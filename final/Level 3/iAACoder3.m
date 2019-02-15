function x = iAACoder3(AACSeq3, fNameOut)
%IAACODER3 Decodes a 2 channel wav file (Level 3).
% Arguments:
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
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
%
% Returns:
% - x: If the fNameOut argument is not provided, the decoded sample
%      sequence is stored in the returned variable x.
%

totalFrames = length(AACSeq3);

% init audio
audio = zeros((totalFrames + 1) * 1024, 2);

for frame = 1:totalFrames
    % Huffman Decoding of sfc
    sfc_L = decodeHuff(AACSeq3(frame).chl.sfc, 12, loadLUT())';
    sfc_R = decodeHuff(AACSeq3(frame).chr.sfc, 12, loadLUT())';
    
    if AACSeq3(frame).frameType == "ESH"
        sfc_L = reshape(sfc_L, [41, 8]);
        sfc_R = reshape(sfc_R, [41, 8]);
    end
    
    % Huffman Decoding of the quantization symbols 
    S_L = decodeHuff(AACSeq3(frame).chl.stream, AACSeq3(frame).chl.codebook, loadLUT())';
    S_R = decodeHuff(AACSeq3(frame).chr.stream, AACSeq3(frame).chr.codebook, loadLUT())';
    
    % Apply inverse  quantizer
    frameF_L = iAACquantizer(S_L, sfc_L, AACSeq3(frame).chl.G, AACSeq3(frame).frameType);
    frameF_R = iAACquantizer(S_R, sfc_R, AACSeq3(frame).chr.G, AACSeq3(frame).frameType);
    
    % Apply iTNS
    frameFoutLeft = iTNS(frameF_L, AACSeq3(frame).frameType, AACSeq3(frame).chl.TNScoeffs);
    frameFoutRight = iTNS(frameF_R, AACSeq3(frame).frameType, AACSeq3(frame).chr.TNScoeffs);    
    
    % Construct frameF
    if AACSeq3(frame).frameType == "ESH"
        frameF = [reshape(frameFoutLeft, [1024, 1]), reshape(frameFoutRight, [1024, 1])];
    else
        frameF = [frameFoutLeft, frameFoutRight];
    end
    
    % Apply IMDCT to the current frame
    frameT = iFilterbank(frameF, AACSeq3(frame).frameType, AACSeq3(frame).winType);
    
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

