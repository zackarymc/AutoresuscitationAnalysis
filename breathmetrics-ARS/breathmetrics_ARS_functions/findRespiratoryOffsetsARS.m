function [inhaleOffsets,exhaleOffsets] = findRespiratoryOffsetsARS(resp, ...
    inhaleOnsets, exhaleOnsets, inhalePauseOnsets, exhalePauseOnsets)

%FIND_RESPIRATORY_OFFSETS Finds where each inhale and exhale ends
    
inhaleOffsets = zeros(size(inhaleOnsets));
exhaleOffsets = zeros(size(exhaleOnsets));

% finding inhale offsets
for bi = 1:length(exhaleOnsets)
    if isnan(inhalePauseOnsets(bi))
        if exhaleOnsets(bi) == 1
            peakToPeak = resp(inhaleOnsets(bi):inhaleOnsets(bi+1));
            SIMPLE_ZERO_CROSS = mean(resp);
            inhaleOffsetInd = find(peakToPeak < SIMPLE_ZERO_CROSS,1,'first');

            inhaleOffsets(1,bi) = inhaleOnsets(bi) + inhaleOffsetInd;
        else
            inhaleOffsets(1, bi) = exhaleOnsets(bi)-1;
        end
    else
        inhaleOffsets(1, bi) = inhalePauseOnsets(bi)-1;
    end
end

% finding exhale offsets
for bi = 1:length(exhaleOnsets) - 1
    if isnan(exhalePauseOnsets(bi))
        if exhaleOnsets(bi) == 1
            exhaleOffsets(1, bi) = 1;
        else
            exhaleOffsets(1, bi) = inhaleOnsets(bi+1)-1;
        end
    else
        exhaleOffsets(1, bi) = exhalePauseOnsets(bi)-1;
    end
end

% last exhale is different because there is no following inhale
final_window = resp(exhaleOnsets(end):end);
putativeExhaleOffset = find(final_window > 0, 1, 'first');

% check that there is a real exhale end that it isn't artifact
avgExhaleLen = mean(exhaleOffsets(1, 1:end-1) - exhaleOnsets(1, 1:end-1));
lowerLim = avgExhaleLen / 4;
upperLim = avgExhaleLen * 1.75;
if isempty(putativeExhaleOffset) || putativeExhaleOffset < lowerLim || ...
        putativeExhaleOffset >= upperLim
    % end of exhale cannot be calculated
    exhaleOffsets(1,end) = 1;
else
    exhaleOffsets(1,end) = exhaleOnsets(1,end) + putativeExhaleOffset - 1;
end

