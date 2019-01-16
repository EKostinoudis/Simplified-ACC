function frameF = iAACquantizer(S, sfc, G, frameType)
%IAACQUANTIZER Utilizes the de-Quantizer state for one channel.
% Arguments:
% - S: The quantization symbols of the MDCT coeffs of the current frame.
%      (table 1024x1)
% - sfc: The Scalefactor coefficients for each scalefactor band.
%       (table Nx8 where N is the number of the bands when the frameType is
%       "ESH" or Nx1 for a non "ESH" frameType)
% - G: The Global Gain of the current frame. (1x8 for the "ESH" frameType
%       or a scalar for any other frameType)
% - frameType:  The type of this frame.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
%
% Returns:
% - frameF: The frameT at the frequency domain as MDCT coefficients.
%           A table that contains either:
%           - The channel's coefficients when frameType 
%               is 'OLS' | 'LSS' | 'LPS'. 
%             (size: 1024x1)
%           Or
%           - Eight (8) 128x1 subtables (on one table) for each subframe
%           when frameType is 'ESH'. The subtables are sorted on the
%           table's columns.
%             (size 128x8)
%

if frameType == "ESH"
    table = load('TableB219.mat', 'B219b');
    table = table.B219b;
    rows = 128;
    cols = 8;
    NB = length(table);
    S = reshape(S, [rows, cols]);
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    rows = 1024;
    cols = 1;
    NB = length(table);
end

frameF = zeros(rows, cols);

for i = 1:cols
    % Calculate a
    a = cumsum(sfc(:, i));
    
    for b = 1:NB
        indexes = wlow(b):whigh(b);
        frameF(indexes, i) = sign(S(indexes, i)) .* abs(S(indexes, i)).^(4/3) * 2^(a(b)/4);
    end
end
