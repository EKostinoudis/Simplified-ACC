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
        frameF(index:index + 127, 1) = MDCT(z(:,1));
        frameF(index:index + 127, 2) = MDCT(z(:,2));
    end
else
    % Multiply with the window function
    z = frameT .* W;
    
    % Apply MDCT
    frameF(:, 1) = MDCT(z(:,1));
    frameF(:, 2) = MDCT(z(:,2));
end
end

% Functions
function W = KBD_left(N)
% KBD_LEFT Calculates the left Kaiser-Bessel-Derived window.
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
% KBD_RIGHT Calculates the right Kaiser-Bessel-Derived window.
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

function X = MDCT(s)
% Calculate length
N = length(s);

% Used many times
N2 = N / 2;
N4 = N / 4;
seq = (0:N4 - 1).';

% Rotate s
s_hat = zeros(N2, 1);
s_hat(seq + 1) = -s(seq + 1 + 3 * N4);
seq2 = N4:N-1;
s_hat(seq2 + 1) = s(seq2 + 1 - N4);

sk = (s_hat(2 * seq + 1) - s_hat(N - 2 * seq)) - 1i * (s_hat(N2 + 2 * seq + 1) - s_hat(N2 - 2 * seq));

e = exp(-1i * 2 * pi / N * (seq + 1/8));

se = 0.5 * e .* sk;

Xm = fft(se, N4);

Xm = (2 / sqrt(N)) * e .* Xm;

X = zeros(N2, 1);
X(2 * seq + 1) = real(Xm(seq + 1));
X(N2 - 2 * seq) = -imag(Xm(seq+ 1));
end