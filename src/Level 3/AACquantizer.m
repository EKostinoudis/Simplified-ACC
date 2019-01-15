function [S, sfc, G] = AACquantizer(frameF, frameType, SMR)
%AACQUANTIZER Calculates the threshold T(b) and utilizes the Quantizer
%state for one channel.
% Arguments:
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
% - frameType:  The type of this frame.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
% - SMR: Signal to Mask Ratio. A table of size 42x8 for the "ESH"
%        frameType and 69x1 for any other fromType.
%
% Returns:
% - S: The quantization symbols of the MDCT coeffs of the current frame.
%      (table 1024x1)
% - sfc: The Scalefactor coefficients for each scalefactor band.
%       (table Nx8 where N is the number of the bands when the frameType is
%       "ESH" or Nx1 for a non "ESH" frameType)
% - G: The Global Gain of the current frame. (1x8 for the "ESH" frameType
%       or a scalar for any other frameType)
%

if frameType == "ESH"
    table = load('TableB219.mat', 'B219b');
    table = table.B219b;
    rows = 256;
    NB = length(table);
    
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    rows = 2048;
    NB = length(table);
    
    % Calculate the power
    wlow = table(:, 2) + 1;
    whigh = table(:, 3) + 1;
    P = zeros(NB, 1);
    
    for b = 1:NB
        indexes = wlow(b):whigh(b);
        P(b) = sum(frameF(indexes).^2);
    end
    
    % Calculate the audibility thresholds
    T = P ./ SMR;
    
    % Init scalefactor gain
    a = ones(NB, 1) * (16 / 3 * log2(max(frameF)^(3/4) / 8191));
    
    
end
end

