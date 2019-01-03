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


end

