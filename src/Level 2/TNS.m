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
% Load table and init size's

if frameType == "ESH"
    table = load('TableB219.mat', 'B219b');
    table = table.B219b;
    rows = 128;
    cols = 8;
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    rows = 1024;
    cols = 1;
end

% Take the band index's
indexFrom = table(:, 2) + 1;
indexTo = table(:, 3) + 1;

% Init power and the normalization factor Sw
power = zeros(length(table), cols);
Sw = zeros(rows, cols);

% Calculate the power for each frame and band
for band = 1:length(table)
    power(band, :) = sum(frameFin(indexFrom(band):indexTo(band), :) .^2, 1);
    Sw(indexFrom(band):indexTo(band), :) = repmat(sqrt(power(band, :)), indexTo(band) - indexFrom(band) + 1, 1); 
end

for k = rows - 1:-1:1
    Sw(k, :) = (Sw(k, :) + Sw(k + 1, :)) / 2;
end

for k = 2:rows
    Sw(k, :) = (Sw(k, :) + Sw(k - 1, :)) / 2;
end

% Normalize the MDCT factors
Xw = frameFin./Sw;

corr = zeros(9, cols);
a = zeros(4, cols);
TNScoeffs = zeros(4, cols);
frameFout = zeros(rows, cols);

for i = 1:cols
    % Take the correlation of Xw
    corr(:, i) = xcorr(Xw(:, i), 4);

    % Calculate the linear prediction coefficients
    a(:, i) = toeplitz(corr(5:8, i)) \ corr(6:9, i);
    
    % Quantize a
    [TNScoeffs(:, i), quants] = quantiz(a(:, i), -0.7:0.1:0.7, -0.75:0.1:0.75);
    
    % Check if the FIR filter is unstable and fix it
    [coefsOut, TNScoeffs(:, i)] = checkStability([1; -quants(:)], TNScoeffs(:, i));
    
    % Apply the filter
    frameFout(:, i) = filter(coefsOut, 1, frameFin(:, i));
end
end

% Takes the coefficients of the filter and check if they are stable
% If yes return the same
% If not produce new stable
function [coefsOut, indexesOut] = checkStability(coefsIn, indexesIn)
% Calculate the filter poles
poles = roots(coefsIn);
    
if any(abs(poles) > 1)
    R = abs(poles);
    index = R > 1;
    theta = angle(poles(index));
    R = 1 ./ R(index);

    % Calculate the new poles
    poles(index) = R.*exp(1i*theta);

    % Construct the new coefficients
    coefsOut = poly(poles);
    
    % Quantize 
    [indexes, quants] = quantiz(-coefsOut(2:5), -0.7:0.1:0.7, -0.75:0.1:0.75);
    
    % Check if the new values are stable
    [coefsOut, indexesOut] = checkStability([1; -quants(:)], indexes);
else
    coefsOut = coefsIn;
    indexesOut = indexesIn;
end
end