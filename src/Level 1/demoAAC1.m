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

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut = audioOut(1025:end - 1024, :);
audioIn = audioIn(1025:length(audioOut) + 1024, :);

% Calculate noise
noise = audioIn - audioOut;

% Calculate SNR
SNR = [snr(audioIn(:, 1), noise(:, 1)); snr(audioIn(:, 2), noise(:, 2))];
end

