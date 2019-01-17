function [S, sfc, G] = AACquantizer(frameF, frameType, SMR)
%AACQUANTIZER Utilizes the Quantizer state for one channel.
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
    rows = 128;
    cols = 8;
    NB = length(table);    
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    rows = 1024;
    cols = 1;
    NB = length(table);
end

wlow = table(:, 2) + 1;
whigh = table(:, 3) + 1;
P = zeros(NB, 1);    
S = zeros(rows, cols);
sfc = zeros(NB - 1, cols);
G = zeros(1, cols);

for i = 1:cols
    % Calculate the power
    for b = 1:NB
        indexes = wlow(b):whigh(b);
        P(b) = sum(frameF(indexes, i).^2);
    end
    
    % Calculate the audibility thresholds
    T = P ./ SMR(:, i);
    
    % Init scalefactor gain
    a = zeros(NB, 1) + (16 / 3 * log2(max(frameF(:, i))^(3/4) / 8191));
    
    Pe = zeros(NB, 1);
    X_hat = zeros(rows, 1);
    searching_a = true(NB, 1);
    
    % Calculate the scalefactor gain
    while any(searching_a) && max(abs(diff(a))) <= 60
        for b = 1:NB
            if searching_a(b)
                indexes = wlow(b):whigh(b);

                % Quantize and dequantize MDCT coeffs
                S(indexes, i) = sign(frameF(indexes, i)) .* round((abs(frameF(indexes, i)) * 2^(-a(b)/4)).^(3/4) + 0.4054);
                X_hat(indexes) = sign(S(indexes, i)) .* abs(S(indexes, i)).^(4/3) * 2^(a(b)/4);

                % Calculate the power of the quantization error
                Pe(b) = sum((frameF(indexes, i) - X_hat(indexes)).^2);
                
                % Check if we found a proper a value
                if Pe(b) < T(b)
                    a(b) = a(b) + 1;
                else
                    searching_a(b) = false;
                end
            end
        end
    end
    
    % Make sure max distance is 60
    if max(abs(diff(a))) > 60
        for j = 1:length(a)-1
            if abs(a(j+1) - a(j)) > 60
                [~, pos] = max([a(j); a(j+1)]);
                a(j + pos - 1) = a(j + pos - 1) - 1;
            end
        end
    end
    
    % Calculate sfc
    sfc(:, i) = round(diff(a));
    
    G(i) = a(1);
end

% Make sure S is in the correct form
if frameType == "ESH"
    S = reshape(S, [1024, 1]);
end
end

