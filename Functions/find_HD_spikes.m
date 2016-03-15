function HD_spikes = find_HD_spikes(struct)

% This function will generate a vector of the animal's head direction
% during each spike, taking into account samples that contain multiple
% spikes. This vector can be used to generate FR x HD plots.

% This function written by Mehlman. March 2016.

HD_spikes = [];

for iSample = 1:length(struct.data(:,6))
    
    if struct.data(iSample,6) == 1 % if 1 spike, add HD once
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        
    elseif struct.data(iSample,6) == 2 % if 2 spikes, add HD twice
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        
    elseif struct.data(iSample,6) == 3 % if 3 spikes, add HD 3 times
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        
    elseif struct.data(iSample,6) == 4 % if 4 spikes, add HD 4 times
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        HD_spikes(length(HD_spikes)+1) = struct.data(iSample,10);
        
    end
    
end