function x = iAACoder2(AACSeq2, fNameOut)
%IAACODER2 Decodes a 2 channel wav file (Level 2).
% Arguments:
% - AACSeq2: A Kx1 struct, where K is the number of the encoded frames.
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
%       - .chl.frameF: The MDCT coefficients of the left channel after TNS.
%                      A table of size 128x8 for the "ESH" frameType or 
%                      1024x1 for any other frameType.
%       - .chr.frameF: The MDCT coefficients of the right channel after TNS.
%                      A table of size 128x8 for the "ESH" frameType or 
%                      1024x1 for any other frameType.
% - fNameOut: The name of a ".wav" file that will be produced. The file
%             will contain 2 sound channels with 48kHz sampling frequency.
% Returns:
% - x: If the fNameOut argument is not provided, the decoded sample
%      sequence is stored in the returned variable x.
%


end

