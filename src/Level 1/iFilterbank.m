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

% init frameT
frameT = zeros(2048, 2);

if frameType == "ESH"
    for i = 1:8
        % index of frameF and frameT
        indexF = 128 * (i - 1) + 1;
        indexT = indexF + 448;
        
        % apply IMDCT to each frame and mulitply it with the window function
        frameT(indexT:indexT + 255, 1) = frameT(indexT:indexT + 255, 1) + ... 
            IMDCT(frameF(indexF:indexF + 127, 1), 256) .* W;
        frameT(indexT:indexT + 255, 2) = frameT(indexT:indexT + 255, 2) + ... 
            IMDCT(frameF(indexF:indexF + 127, 2), 256) .* W;
        
        
    end
else
    % apply IMDCT to each frame and mulitply it with the window function
    frameT(:, 1) = IMDCT(frameF(:, 1), 2048) .* W;
    frameT(:, 2) = IMDCT(frameF(:, 2), 2048) .* W;
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
        
%W = sqrt([cumw(1:end-1); cumw(end:-1:2)] ./ cumw(end));
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

function s = IMDCT(X, N)
% Spectral coefficient
nSeq = 0:N-1;

% init s
s = zeros(N, 1);

% Calculate s
for n = nSeq
    s(n + 1) = 2 / N * dot(X, cos((2 * pi / N) * (n + (N/2 + 1)/2 ) ...
        * ((0:N/2-1) + 0.5)));
end
end
