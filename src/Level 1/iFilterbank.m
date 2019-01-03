function frameT = iFilterbank(frameF, frameType, winType)
%FILTERBANK Utilizes the inverse Filterbank section.
% Arguments:
% - frameF: The frameT at the frequency domain as MDCT coefficients.
%           A table that contains either:
%           - The 2 channel's coefficients when frameType 
%               is 'OLS' | 'LSS' | 'LPS'. 
%             (size: 1024x2)
%           Or
%           - Eight (8) 128x2 subtables (on one table) for each subframe
%           when frameType is 'ESH'. The subtables are sorted on the
%           table's columns.
%             (size 128x16)
% - frameType:  The type of this frame.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
% - winType:    The type of the weight window chosen for this frame.
%       Possible Values:
%       - "KBD"
%       - "SIN"
%
% Returns:
% - frameT:     The frame in the time domain.
%

end

