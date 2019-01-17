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

if frameType == "ESH"
    table = load('TableB219.mat', 'B219b');
    table = table.B219b;
    rows = 256;
    bval = table(:, 5);
    NB = length(table);
    
    % Put all subFrames into the subFrames matrix
    subFrames = zeros(256, 10);
    subFrames(:, 1) = frameTprev1(1217:1472);
    subFrames(:, 2) = frameTprev1(1345:1600);
    for i = 1:8
        index = 448 + (i - 1) * 128;
        subFrames(:, i + 2) = frameT(index + 1:index + 256);
    end
    
    % For every subframe of frameT calculate SMR
    SMR = zeros(length(table), 8);
    for i = 1:8
        % Calculate the complex spectrum of the input signals
        sw = subFrames(:, i + 2) .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));
        swprev1 = subFrames(:, i + 1) .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));
        swprev2 = subFrames(:, i) .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));

        % Apply FFT to the signals
        swT = fft(sw);
        swprev1T = fft(swprev1);
        swprev2T = fft(swprev2);

        % Take the polar representation of the transform (for the first 1024 points)
        [f, r] = cart2pol(real(swT(1:rows/2)), imag(swT(1:rows/2)));
        [fprev1, rprev1] = cart2pol(real(swprev1T(1:rows/2)), imag(swprev1T(1:rows/2)));
        [fprev2, rprev2] = cart2pol(real(swprev2T(1:rows/2)), imag(swprev2T(1:rows/2)));

        % Calculate the predicted r and f
        rpred = 2 * rprev1 - rprev2;
        fpred = 2 * fprev1 - fprev2;

        % Calculate the unpredictability measure
        c = sqrt((r .* cos(f) - rpred .* cos(fpred)).^2 + (r .* sin(f) - rpred .* sin(fpred)).^2) ./ (r + abs(rpred));

        % Calculate the energy and unpredictability in the threshold calculation partitions
        wlow = table(:, 2) + 1;
        whigh = table(:, 3) + 1;
        e = zeros(NB, 1);
        c2 = zeros(NB, 1);

        for b = 1:NB
            indexes = wlow(b):whigh(b);
            e(b) = sum(r(indexes).^2);
            c2(b) = sum(c(indexes) .* r(indexes).^2);
        end

        % Convolve the partitioned energy and unpredictability with the spreading function
        input = repmat(1:NB, NB, 1);
        sp = arrayfun(@(bb, b) spreadingfun(bval(bb), bval(b)), input, input');

        ecb = sp * e;
        ct = sp * c2;

        % Normalize ecb ans ct
        cb = ct ./ ecb;
        en = ecb ./ sum(sp, 2);

        % Tonality index
        tb = -0.299 - 0.43 * log(cb);

        % Calculate SNR
        SNR = tb * 18 + (1 - tb) * 6;

        % Calculate the power ratio
        bc = 10.^(-SNR / 10);

        % Calculate of actual energy threshold
        nb = en .* bc;

        % Calculate the noise level
        qthrHat = eps() * rows / 2 * 10.^(table(:, 6) / 10);
        npart = max([nb, qthrHat], [], 2);

        % Calculate SMR
        SMR(:, i) = e ./ npart;
    end
else
    table = load('TableB219.mat', 'B219a');
    table = table.B219a;
    rows = 2048;
    bval = table(:, 5);
    NB = length(table);

    % Calculate the complex spectrum of the input signals
    sw = frameT .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));
    swprev1 = frameTprev1 .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));
    swprev2 = frameTprev2 .* (0.5 - 0.5 * cos(pi * ((0:rows - 1) + 0.5) / rows));

    % Apply FFT to the signals
    swT = fft(sw);
    swprev1T = fft(swprev1);
    swprev2T = fft(swprev2);

    % Take the polar representation of the transform (for the first 1024 points)
    [f, r] = cart2pol(real(swT(1:rows/2)), imag(swT(1:rows/2)));
    [fprev1, rprev1] = cart2pol(real(swprev1T(1:rows/2)), imag(swprev1T(1:rows/2)));
    [fprev2, rprev2] = cart2pol(real(swprev2T(1:rows/2)), imag(swprev2T(1:rows/2)));

    % Calculate the predicted r and f
    rpred = 2 * rprev1 - rprev2;
    fpred = 2 * fprev1 - fprev2;

    % Calculate the unpredictability measure
    c = sqrt((r .* cos(f) - rpred .* cos(fpred)).^2 + (r .* sin(f) - rpred .* sin(fpred)).^2) ./ (r + abs(rpred));

    % Calculate the energy and unpredictability in the threshold calculation partitions
    wlow = table(:, 2) + 1;
    whigh = table(:, 3) + 1;
    e = zeros(NB, 1);
    c2 = zeros(NB, 1);
    
    for b = 1:NB
        indexes = wlow(b):whigh(b);
        e(b) = sum(r(indexes).^2);
        c2(b) = sum(c(indexes) .* r(indexes).^2);
    end

    % Convolve the partitioned energy and unpredictability with the spreading function
    input = repmat(1:NB, NB, 1);
    sp = arrayfun(@(bb, b) spreadingfun(bval(bb), bval(b)), input, input');

    ecb = sp * e;
    ct = sp * c2;

    % Normalize ecb ans ct
    cb = ct ./ ecb;
    en = ecb ./ sum(sp, 2);

    % Tonality index (0<tb<1)
    tb = -0.299 - 0.43 * log(cb);
tb(tb<=0) = eps();
tb(tb>=1) = 1 - eps();
    % Calculate SNR
    SNR = tb * 18 + (1 - tb) * 6;

    % Calculate the power ratio
    bc = 10.^(-SNR / 10);

    % Calculate of actual energy threshold
    nb = en .* bc;

    % Calculate the noise level
    qthrHat = eps() * rows / 2 * 10.^(table(:, 6) / 10);
    npart = max([nb, qthrHat], [], 2);

    % Calculate SMR
    SMR = e ./ npart;
end

end

function x = spreadingfun(i, j)
if j >= i
    tmpx = 3 * (j - i);
else
    tmpx = 1.5 * (j - i);
end

tmpz = 8 * min([(tmpx - 0.5)^2 - 2 * (tmpx - 0.5), 0]);
tmpy = 15.811389 + 7.5 * (tmpx + 0.474) - 17.5 * sqrt(1 + (tmpx + 0.474)^2);

if tmpy < -100
    x = 0;
else
    x = 10^((tmpz + tmpy) / 10);
end
end