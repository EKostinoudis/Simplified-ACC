function SNR = demoAAC2(fNameIn, fNameOut)
%DEMOAAC2 Tests the Level 2 encoding.
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
% Returns:
% - SNR: Signal to noise ratio (in db) of the two channels after the
%        encoding-decoding of Level 2. (2x1 table)
%

audioIn = audioread(char(fNameIn));

% Time coding
tic
AACSeq2 = AACoder2(fNameIn);
codingTime = toc;

% Time decoding
tic
audioOut = iAACoder2(AACSeq2, fNameOut);
decodingTime = toc;

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut = audioOut(1025:end - 1024, :);
audioIn = audioIn(1025:length(audioOut) + 1024, :);

% Calculate noise
noise = audioIn - audioOut;

% Calculate SNR
SNR = [snr(audioIn(:, 1), noise(:, 1)); snr(audioIn(:, 2), noise(:, 2))];

% Display times
fprintf('Coding: time elapsed is %.4f seconds\n', codingTime);
fprintf('Decoding: time elapsed is %.4f seconds\n', decodingTime);
fprintf('Channel 1 SNR: %.4f dB\n', SNR(1));
fprintf('Channel 2 SNR: %.4f dB\n', SNR(2));
end

