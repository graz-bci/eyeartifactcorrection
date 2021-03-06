% Detects blinkds as periods during which the EOG signal is outside 
% the interval spanned by +/- threshold
%
% Copyright (C) 2019 Reinmar Kobler, Graz University of Technology, Austria
% <reinmar.kobler@tugraz.at>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
function [ blink_signal, peak_sign ] = eogblink2events( EEG, channel_idx, threshold, t_extend, label, peak_sign )
%eogblink2events Detects blinks in the EEG dataset using the channel 
%   defined by channel_idx for trials with the label 'label' that are
%   above the threshold

if nargin < 6 
    % find if the blinks are along the positive or negative direction of the
    % EOG channel during the trials with the correct label
    label_mask = EEG.etc.trial_labels == label;
    ref_sig = EEG.data(channel_idx,:, label_mask);
    
    % find the median sign of the 10% highest peaks
    [~, idxs] = sort(abs(ref_sig(:)), 'descend');
    peak_idxs = idxs(1:floor(EEG.pnts*sum(label_mask)*0.01));
    peak_sign = median(sign(EEG.data(channel_idx, peak_idxs)));
end

blink_signal = (EEG.data(channel_idx,:) * peak_sign) > threshold;

blink_signal(:,EEG.etc.trial_labels ~= label) = 0;

if t_extend > 0
    
    b = ones(round(t_extend*EEG.srate),1)';
    
    blink_signal = filtfilt(b, 1, double(blink_signal));
    
    blink_signal = blink_signal > 0;
end

blink_signal = reshape(blink_signal, 1, EEG.pnts, EEG.trials);

end

