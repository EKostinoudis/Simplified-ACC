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
            IMDCT(frameF(indexF:indexF + 127, 1)) .* W;
        frameT(indexT:indexT + 255, 2) = frameT(indexT:indexT + 255, 2) + ... 
            IMDCT(frameF(indexF:indexF + 127, 2)) .* W;
    end
else
    % apply IMDCT to each frame and mulitply it with the window function
    frameT(:, 1) = IMDCT(frameF(:, 1)) .* W;
    frameT(:, 2) = IMDCT(frameF(:, 2)) .* W;
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
w = kaiser(M+1, a * pi);

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
w = kaiser(M+1, a * pi);

% Cumulative sum of w
cumw = cumsum(w);
        
W = sqrt(cumw(end-1:-1:1) ./ cumw(end));
end

function W = sin_left(N)
W = sin(pi./N * ((0:N/2-1) + 0.5));
W = W(:); % make W column vector
end

function W = sin_right(N)
W = sin(pi./N * ((N/2:N-1) + 0.5));
W = W(:); % make W column vector
end

function s = IMDCT(X)
N2 = length(X);
N4 = N2 / 2;
N = 2 * N2;
seq = (0:N4 - 1).';

e = exp(-1i * 2 * pi / N * (seq + 1/8));

X_hat = X(2 * seq + 1) + 1i * X(N2 - 2 * seq);
X_hat = 0.5 * e .* X_hat;

sm = fft(X_hat, N4);
sm = 8 / sqrt(N) * e .* sm;

seq2 = 1:2:N - 1;
sr = zeros(N, 1);
sr(2 * seq + 1) = real(sm(seq + 1));
sr(N2 + 2 * seq + 1) = imag(sm(seq + 1));
sr(seq2 + 1) = -sr(N - seq2);

s = [sr((N4 + 1):N); -sr(1:N4)];
end
