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


end

