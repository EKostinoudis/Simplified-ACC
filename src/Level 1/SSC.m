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

% If prevFrameType has type LONG_STOP_SEQUENCE or LONG_START_SEQUENCE
% the next frame can only be ONLY_LONG_SEQUENCE or EIGHT_SHORT_SEQUENCE
% respectively
if prevFrameType == "LSS"
    frameType = "ESH";
    return
elseif prevFrameType == "LPS"
    frameType = "OLS";
    return
elseif prevFrameType ~= "OLS" && prevFrameType ~= "ESH"
    error('prevFrameType had none of the 4 possible values')
end

% If not, we check if the next frame is an EIGHT_SHORT_SEQUENCE to decide.

% Numerator and denominator coefficients of the filter
num = [0.7548 -0.7548];
den = [1 -0.5095];

% Apply the filter to each channel of nextFrameT
filteredNextFrameT = filter(num, den, nextFrameT, [], 1);

% Each segment (i) starts at 'segmentTimes(i) + 1'
% and ends at 'segmentTimes(i + 1)'
% Essentially: segmentDuration(i) = (segmentTimes(i), segmentTimes(i+1)]
segmentTimes = 576:128:1600;

% Energy estimation of each segment
segEnergy = zeros(8, 2);
for i = 1:8
    segEnergy(i, :) = sum(filteredNextFrameT(segmentTimes(i) + 1:...
                                             segmentTimes(i + 1), :).^2);
end

% Attack values of the segments 1 to 7.
attackValues = zeros(7, 2);
for i = 1:7
    attackValues(i, :) = segEnergy(i + 1,:) .* i ./ ...
                        (sum(segEnergy(1:i, :), 1));
end

% Find the type of the i+1 frame
isNextESH = any(segEnergy(2:end, :) > 1e-3 & attackValues > 10);

if prevFrameType == "ESH"
    if any(isNextESH)
        frameType = "ESH";
    else 
        frameType = "LPS";
    end
elseif prevFrameType == "OLS"
    if any(isNextESH)
        frameType = "LSS";
    else 
        frameType = "OLS";
    end
end

end

