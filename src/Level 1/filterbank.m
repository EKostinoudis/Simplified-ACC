function frameF = filterbank(frameT, frameType, winType)
%FILTERBANK Utilizes the Filterbank section.
% Arguments:
% - frameT:     The frame in the time domain.
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
%

% Calculate the window fuction (W) for each frameType
if frameType == "OLS"
    if winType == "KBD"
        W = [KBD_left(2048); KBD_right(2048)];
    else
        W = [sin_left(2048); sin_right(2048)];
    end
elseif frameType == "LSS"
    if winType == "KBD"
        W = [KBD_left(2048); ones(448,1); KBD_right(256); zeros(448,1)];
    else
        W = [sin_left(2048); ones(448,1); sin_right(256); zeros(448,1)];
    end
elseif frameType == "LPS"
    if winType == "KBD"
        W = [zeros(448,1); KBD_left(256); ones(448,1); KBD_right(2048)];
    else
        W = [zeros(448,1); sin_left(256); ones(448,1); sin_right(2048)];
    end 
elseif frameType == "ESH"
    if winType == "KBD"
        W = [KBD_left(256); KBD_right(256)];
    else
        W = [sin_left(256); sin_right(256)];
    end
end

% init frameF
frameF = zeros(1024, 2);    

if frameType == "ESH"
    % For every of the eight overlapping segments
    frameIndex = (448:128:1344) + 1;
    for i = 1:8
        % Segment of the frameT
        x = frameT(frameIndex(i):frameIndex(i) + 255, :);
        
        % Multiply with the window function
        z = x .* W;
        
        % index of frameF
        index = 128 * (i - 1) + 1;
        
        % Apply MDCT
        frameF(index:index + 127, 1) = MDCT(z(:,1), 256);
        frameF(index:index + 127, 2) = MDCT(z(:,2), 256);
    end
else
    % Multiply with the window function
    z = frameT .* W;
    
    % Apply MDCT
    frameF(:, 1) = MDCT(z(:,1), 2048);
    frameF(:, 2) = MDCT(z(:,2), 2048);
end
end

% Functions
function W = KBD_left(N)
M = N/2;

if N == 2048 
    a = 4;
else
    a = 6;
end

% M+1-point Kaiser window
w = kaiser(M+1, a);

% Cumulative sum of w
cumw = cumsum(w);
        
W = sqrt(cumw(1:end-1) ./ cumw(end));
end

function W = KBD_right(N)
M = N/2;

if N == 2048 
    a = 4;
else
    a = 6;
end

% M+1-point Kaiser window
w = kaiser(M+1, a);

% Cumulative sum of w
cumw = cumsum(w);
        
W = sqrt(cumw(end:-1:2) ./ cumw(end));
end

function W = sin_left(N)
W = sin(pi./N * ((0:N/2-1) + 0.5));
W = W(:); % make W column vector
end

function W = sin_right(N)
W = sin(pi./N * ((N/2:N-1) + 0.5));
W = W(:); % make W column vector
end

function X = MDCT(s, N)
% Spectral coefficient
kSeq = 0:N/2-1;

% init X
X = zeros(N/2, 1);

% Calculate X
for k = kSeq
    X(k + 1) = 2 * dot(s, cos((2 * pi / N) * ((0:N-1) + (N/2 + 1)/2 ) ...
        * (k + 0.5)));
end
end