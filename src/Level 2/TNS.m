function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
%TNS Utilizes the Temporal Noise Shaping (TNS) section for one channel.
% Arguments:
% - frameFin: The MDCT coefficients of the frame. 
%               (128x8 for "ESH" or 1024x1 for any other frameType)
% - frameType:  The type of this frame.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
%
% Returns:
% - frameFout:  The MDCT coefficients after the Temporal Noise Shaping.
%               (128x8 for "ESH" or 1024x1 for any other frameType)
% - TNScoeffs: The Temporal Noise Shaping quantized coefficients.
%               (4x8 for "ESH" or 4x1 for any other frameType)
%


end

