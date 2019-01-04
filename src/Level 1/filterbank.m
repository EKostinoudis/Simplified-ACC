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

% init W
W = zeros(2048, 1);

if frameType == "OLS"
    if winType == "KBD"
        W = [KDB_left(2048, 6); KDB_right(2048, 6)];
    else
        W = [sin_left(2048); sin_right(2048)];
    end
elseif frameType == ""
    
elseif frameType == ""
        
elseif frameType == ""
    
end

end

% Functions
function W = KBD_left(N, a)
M = N/2;

% M+1-point Kaiser window
w = kaiser(M+1, a);

% Cumulative sum of w
cumw = cumsum(w);
        
%W = sqrt([cumw(1:end-1); cumw(end:-1:2)] ./ cumw(end));
W = sqrt(cumw(1:end-1) ./ cumw(end));
end

function W = KBD_right(N, a)
M = N/2;

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

