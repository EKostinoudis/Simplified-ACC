function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
%PSYCHO Utilizes the psychoacoustic model for one channel.
% Arguments:
% - frameT:     The frame i in the time domain. (table: 2048x1)
% - frameType:  The frame type that was of the frameT.
%       Possible Values and their meanings:
%       - "OLS": Standing for ONLY_LONG_SEQUENCE
%       - "LSS": Standing for LONG_START_SEQUENCE
%       - "ESH": Standing for EIGHT_SHORT_SEQUENCE
%       - "LPS": Standing for LONG_STOP_SEQUENCE
% - frameTprev1:     The frame i-1 in the time domain. (table: 2048x1)
% - frameTprev2:     The frame i-2 in the time domain. (table: 2048x1)
% Returns:
% - SMR: Signal to Mask Ratio. A table of size 42x8 for the "ESH"
%        frameType and 69x1 for any other fromType.
%


end

