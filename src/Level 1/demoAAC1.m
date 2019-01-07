function SNR = demoAAC1(fNameIn, fNameOut)
%DEMOAAC1 Tests the Level 1 encoding.
% Arguments:
% - fNameIn: The name of a ".wav" file that is to be encoded. The file must
%            contain 2-channel sound with 48kHz sampling frequency.
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
% Returns:
% - SNR: Signal to noise ratio (in db) of the two channels after the
%        encoding-decoding of Level 1. (2x1 table)
%

audioIn = audioread(char(fNameIn));
AACSeq1 = AACoder1(fNameIn);
audioOut = iAACoder1(AACSeq1, fNameOut);

% 0-padding audioOut to match audioIn size
audioOut = [audioOut; zeros(length(audioIn) - length(audioOut), 2)];

% Calculate noise
noise = audioIn - audioOut;

% Calculate SNR
SNR = [snr(audioIn(:, 1), noise(:, 1)); snr(audioIn(:, 2), noise(:, 2))];
end

