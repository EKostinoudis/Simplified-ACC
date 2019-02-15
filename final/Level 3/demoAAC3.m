function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut, fNameAACoded)
%DEMOAAC3 Tests the Level 3 encoding.
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
% - fNameAACoded: The name of a ".mat" file where the returned AACSeq3 is
%                 saved.
%
% Returns:
% - SNR: Signal to noise ratio (in db) of the two channels after the
%        encoding-decoding of Level 3. (2x1 table)
% - bitrate: Bits per second.
% - compression: the bitrate before the encoding divided by the bitrate
%                after the encoding.
%

audioIn = audioread(char(fNameIn));

% Time coding
tic
AACSeq3 = AACoder3(fNameIn, fNameAACoded);
codingTime = toc;

% Time decoding
tic
audioOut = iAACoder3(AACSeq3, fNameOut);
decodingTime = toc;

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut = audioOut(1025:end - 1024, :);
audioIn = audioIn(1025:length(audioOut) + 1024, :);

% Calculate noise
noise = audioIn - audioOut;

% Calculate SNR
SNR = [snr(audioIn(:, 1), noise(:, 1)); snr(audioIn(:, 2), noise(:, 2))];

% Calculate max possible compression in bits.
len = length(AACSeq3);
maxCompSize = 0;
maxCompSize = maxCompSize + len * 2; % FrameType fits in 2 bits
maxCompSize = maxCompSize + len * 1; % WinType fits in 1 bit.
maxCompSize = maxCompSize + len * 2 * 16; % For the 2 channels' codebooks.
maxCompSize = maxCompSize + len * 2 * 64; % For the 2 channels' G.

for i = 1:length(AACSeq3)
    maxCompSize = maxCompSize + length(AACSeq3(i).chl.stream);
    maxCompSize = maxCompSize + length(AACSeq3(i).chr.stream);
    
    maxCompSize = maxCompSize + length(AACSeq3(i).chl.sfc);
    maxCompSize = maxCompSize + length(AACSeq3(i).chr.sfc);
    
    % Add TNS coeffs size.
    maxCompSize = maxCompSize + 2 * 4 * 4 * (size(AACSeq3(i).chl.TNScoeffs,2));
end

% Display times
audioInOriginal = audioread(char(fNameIn), 'native');
inputSize = whos('audioInOriginal');
inputSize = inputSize.bytes;
fprintf('Coding: time elapsed is %.4f seconds\n', codingTime);
fprintf('Decoding: time elapsed is %.4f seconds\n', decodingTime);
fprintf('Uncompressed audio: %.4f MB (%i bits)\n', inputSize / (1024*1024), inputSize * 8);
fprintf('Compressed struct: %.4f KB (%i bits)\n', maxCompSize / (1024 * 8), maxCompSize);
fprintf('Compressed ratio: %.4f %% (x %.4f)\n', 100 * maxCompSize / (inputSize * 8), inputSize * 8 / maxCompSize);
fprintf('Channel 1 SNR: %.4f dB\n', SNR(1));
fprintf('Channel 2 SNR: %.4f dB\n', SNR(2));

% Calculate the bitrate of the compressed audio signal.
bitrate = maxCompSize / ((length(audioOut) + 1024) / 48000);

% The compression factor.
compression = inputSize * 8 / maxCompSize;

end

