function frameFout = iTNS(frameFin, frameType, TNScoeffs)
%ITNS Reverses the Temporal Noise Shaping (TNS) section of one channel.
% Arguments:
% - frameFin:  The MDCT coefficients after the Temporal Noise Shaping.
%               (128x8 for "ESH" or 1024x1 for any other frameType)
% - frameType:  The type of this frame.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
% - TNScoeffs: The Temporal Noise Shaping quantized coefficients.
%               (4x8 for "ESH" or 4x1 for any other frameType)
%
% Returns:
% - frameFout: The MDCT coefficients of the frame. 
%               (128x8 for "ESH" or 1024x1 for any other frameType)
%

if frameType == "ESH"
    rows = 128;
    cols = 8;
else
    rows = 1024;
    cols = 1;
end

% Init framFout
frameFout = zeros(rows, cols);

for i = 1:cols
    quants = (double(TNScoeffs(:, i)) * 0.1) - 0.75;
    
    % Apply the inverse filter
    frameFout(:, i) = filter(1, [1; -quants], frameFin(:, i));
end
end

