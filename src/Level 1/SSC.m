function frameType = SSC(frameT, nextFrameT, prevFrameType)
%SSC Utilizes the Sequence Segmentation Control.
% Arguments:
% - frameT:     The frame i in the time domain. (table: 2048x2)
% - nextFrameT: The frame i+1 in the time domain. Used for the window
%               selection. (table: 2048x2)
% - prevFrameType: The frameType of the previous (i-1) frame. For the
%                possible values check the values of the "frameType" below.
%
% Returns:
% - frameType: The frame type that was chosed for the frameT.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
%   

% Numerator and denominator coefficients of the filter
num = [0.7548 -0.7548];
den = [1 -0.5095];

% Apply the filter to each channel of nextFrameT
filteredNextFrameT = filter(num, den, nextFrameT, [], 2);

% Each segment (i) starts at 'segmentTimes(i) + 1'
% and ends at 'segmentTimes(i + 1)'
segmentTimes = 576:128:1600;

% Energy of each segment
segEnergy = zeros(8, 2);
for i = 1:8
    segEnergy(i, :) = sum(filteredNextFrameT(segmentTimes(i) + 1: ...
        segmentTimes(i + 1), :).^2);
end

% Attack values 
attackValues = zeros(7, 2);
for i = 1:7
    attackValues(i, :) = segEnergy(i + 1,:) .* i ./ (sum(segEnergy(1:i, :)));
end

% Find the type of the i+1 frame 
isNextESH = any(segEnergy(2:end, :) > 1e-3 & attackValues > 10);



end

