function nondetects = find_nondetects(struct)

% This function will generate a vector containing the index of each sample
% in which a nondetect occurs. Note that when the red or green LED is not
% detected, the coordinate is listed as (255,0). Thus, all samples
% containing (255,0) for the red or green LED are defined as nondetects.

% This function written by Mehlman. March 2016.

nondetects = find((struct.data(:,2) == 255 & struct.data(:,3) == 0) | (struct.data(:,4) == 255 & struct.data(:,5) == 0));

end