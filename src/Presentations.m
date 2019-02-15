%% Init (Always run this section)
% Input
fNameIn = 'LicorDeCalandraca.wav';
audioIn = audioread(char(fNameIn));

% Shall the plots be saved? And where.
save_files = 1;
plotpath = './plots/';

%% Demo1 -- Data
AACSeq1 = AACoder1(fNameIn);
audioOut_1 = iAACoder1(AACSeq1, 'demo1.wav');

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut_1 = audioOut_1(1025:end - 1024, :);
audioIn_1 = audioIn(1025:length(audioOut_1) + 1024, :);

% Calculate noise
noise_1 = audioIn_1 - audioOut_1;

% Calculate SNR
SNR_1 = [snr(audioIn_1(:, 1), noise_1(:, 1)); snr(audioIn_1(:, 2), noise_1(:, 2))];

%% Demo1 -- Plots (Requires: Demo1 -- Data)
% --- Error plot ---
figure('name', 'Demo 1 - Error plot')
plot(noise_1)
title('Error plot')
legend(['Channel 1'; 'Channel 2'], 'Location', 'best')
if save_files == 1
    print([plotpath 'Demo 1 - Error plot'], '-dpng')
end

% --- Frame Type bar plot ---
figure('name', 'Demo 1 - Frame Types')
frameTypes = categorical(["OLS", "LSS", "ESH", "LPS"]);
frameTypeSums = zeros(4,1);
for i = 1 : length(AACSeq1)
    for j = 1 : length(frameTypes)
        if AACSeq1(i).frameType == frameTypes(j)
            frameTypeSums(j) = frameTypeSums(j) + 1;
        end
    end
end

bar(frameTypes, frameTypeSums)
title('Frame types in the sample')
if save_files == 1
    print([plotpath 'Demo 1 - Frame Types'], '-dpng')
end

%% Demo2 -- Data
AACSeq2 = AACoder2(fNameIn);
audioOut_2 = iAACoder2(AACSeq2, 'demo2.wav');

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut_2 = audioOut_2(1025:end - 1024, :);
audioIn_2 = audioIn(1025:length(audioOut_2) + 1024, :);

% Calculate noise
noise_2 = audioIn_2 - audioOut_2;

% Calculate SNR
SNR_2 = [snr(audioIn_2(:, 1), noise_2(:, 1)); snr(audioIn_2(:, 2), noise_2(:, 2))];

%% Demo2 -- Plots (Requires: Demo2 -- Data)
% --- Error plot ---
figure('name', 'Demo 2 - Error plot')
plot(noise_2)
title('Error plot')
legend(['Channel 1'; 'Channel 2'], 'Location', 'best')
if save_files == 1
    print([plotpath 'Demo 2 - Error plot'], '-dpng')
end

%% Demo1-Demo2 -- Plots (Requires: Demo1 -- Data AND Demo2 -- Data)
% --- TNS diff ---
frame = 51;
% Apply iTNS
frameFoutLeft = iTNS(AACSeq2(frame).chl.frameF, AACSeq2(frame).frameType, AACSeq2(frame).chl.TNScoeffs);
frameFoutRight = iTNS(AACSeq2(frame).chr.frameF, AACSeq2(frame).frameType, AACSeq2(frame).chr.TNScoeffs);    

% Construct frameF
if AACSeq2(frame).frameType == "ESH"
    frameF_demo2 = [reshape(frameFoutLeft, [1024, 1]), reshape(frameFoutRight, [1024, 1])];
else
    frameF_demo2 = [frameFoutLeft, frameFoutRight];
end


% Construct frameF of Demo1
if AACSeq1(frame).frameType == "ESH"
    frameF_demo1 = [reshape(AACSeq1(frame).chl.frameF, [1024, 1]), ...
        reshape(AACSeq1(frame).chr.frameF, [1024, 1])];
else
    frameF_demo1 = [AACSeq1(frame).chl.frameF, AACSeq1(frame).chr.frameF];
end

% Maybe plot something.

%% Demo3 -- Data (Use this if you do not have an updated "AACSeq3.mat" file)
% !!!Warning: This section will need 3-30 minutes to complete depending on
% the computer !!!
AACSeq3 = AACoder3(fNameIn, 'AACSeq3.mat');
audioOut_3 = iAACoder3(AACSeq3, 'demo3.wav');

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut_3 = audioOut_3(1025:end - 1024, :);
audioIn_3 = audioIn(1025:length(audioOut_3) + 1024, :);

% Calculate noise
noise_3 = audioIn_3 - audioOut_3;

% Calculate SNR
SNR_3 = [snr(audioIn_3(:, 1), noise_3(:, 1)); snr(audioIn_3(:, 2), noise_3(:, 2))];

%% Demo3 -- Data (Use this if you have an updated "AACSeq3.mat" file.)
load AACSeq3
audioOut_3 = iAACoder3(AACSeq3, 'demo3.wav');

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut_3 = audioOut_3(1025:end - 1024, :);
audioIn_3 = audioIn(1025:length(audioOut_3) + 1024, :);

% Calculate noise
noise_3 = audioIn_3 - audioOut_3;

% Calculate SNR
SNR_3 = [snr(audioIn_3(:, 1), noise_3(:, 1)); snr(audioIn_3(:, 2), noise_3(:, 2))];

%% Demo3 -- Plots (Requires: Demo3 -- Data)
% --- Error plot ---
figure('name', 'Demo 3 - Error plot')
subplot(2,1,1)
hold on
plot(audioIn_3(:, 1))
plot(noise_3(:, 1))
title('Signal and noise plot: Channel 1')
legend('Signal', 'Noise', 'Location', 'best')

subplot(2,1,2)
hold on
plot(audioIn_3(:,2))
plot(noise_3(:, 2))
title('Signal and noise plot: Channel 2')
legend('Signal', 'Noise', 'Location', 'best')
if save_files == 1
    print([plotpath 'Demo 3 - Signal and noise plot'], '-dpng')
end

% --- Bitrate plot ---
figure('name', 'Demo 3 - Bitrate')
frameTypes = [AACSeq3(:).frameType];
ESHframes = frameTypes == "ESH";
bitrate = calculateBitrate(AACSeq3);

hold on
plot(bitrate./1024, 'HandleVisibility', 'off')
scatter(find(ESHframes == true), bitrate(ESHframes)./1024)
title('Bits per frame')
ylabel('Kbits')
xlabel('frame')
lg = legend('ESH', 'Location', 'best');
title(lg, 'Frame Type')

if save_files == 1
    print([plotpath 'Demo 3 - Bitrate'], '-dpng')
end

bitrate_mean = mean(bitrate./1024);
fprintf('Mean bitrate is: %f\n', bitrate_mean);

%% ----------------------------------------------------------- %%


%% Functions
function bitrate = calculateBitrate(AACSeq3)
constBits = 0;
constBits = constBits + 2; % FrameType fits in 2 bits
constBits = constBits + 1; % WinType fits in 1 bit.
constBits = constBits + 2 * 16; % For the 2 channels' codebooks.
constBits = constBits + 2 * 64; % For the 2 channels' G.

bitrate = zeros(length(AACSeq3), 1) + constBits;

for i = 1:length(AACSeq3)
    bitrate(i) = bitrate(i) + length(AACSeq3(i).chl.stream);
    bitrate(i) = bitrate(i) + length(AACSeq3(i).chr.stream);
    
    bitrate(i) = bitrate(i) + length(AACSeq3(i).chl.sfc);
    bitrate(i) = bitrate(i) + length(AACSeq3(i).chr.sfc);
    
    % Add TNS coeffs size.
    bitrate(i) = bitrate(i) + 2 * 4 * 4 * (size(AACSeq3(i).chl.TNScoeffs,2));
end
end