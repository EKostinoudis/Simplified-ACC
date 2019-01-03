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


end

