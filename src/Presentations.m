%% Demo1 -- Data
fNameIn = 'LicorDeCalandraca.wav';
audioIn_1 = audioread(char(fNameIn));
AACSeq1 = AACoder1(fNameIn);
audioOut_1 = iAACoder1(AACSeq1, 'demo1.wav');

% Remove the frames that aren't overlapping in audioIn and audioOut
audioOut_1 = audioOut_1(1025:end - 1024, :);
audioIn_1 = audioIn_1(1025:length(audioOut_1) + 1024, :);

% Calculate noise
noise_1 = audioIn_1 - audioOut_1;

% Calculate SNR
SNR_1 = [snr(audioIn_1(:, 1), noise_1(:, 1)); snr(audioIn_1(:, 2), noise_1(:, 2))];

%% Demo1 -- Plots (Requires: Demo1 -- Data)
% Shall the plots be saved? And where.
save_files = 1;
plotpath = './plots/';

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