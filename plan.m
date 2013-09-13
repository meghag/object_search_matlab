function [minconfig, first_action] = plan(unknown,known,free,dim1,dim2,res,target_id,prediction_success)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nrows = dim1/res;
ncols = dim2/res;

occupied = sub2ind([nrows,ncols],known(:,2),known(:,3));

U = size(unknown,1);
% V = size(visible,1);
% K = size(known,1);
C = nrows*ncols;      %Number of cells in the grid

all_indices = [1:C]';
% occupied_indices = sub2ind([nrows,ncols],known(:,2),known(:,3));
% free_indices = sub2ind([nrows,ncols],free(:,1),free(:,2));

% Locations of cells that are hidden and their state unknown
POPULATION = setdiff(all_indices,union(free,occupied));

samples = [];

if (prediction_success == 1)
    config = [known;unknown];
    [~,~,action] = bfs_class(config,known,free,dim1,dim2,res,target_id);
    minconfig = config;
    first_action = action;
    return
end
    
nperms = nchoosek(length(POPULATION),U)*factorial(U);
nsamples = max(0.0001*nperms,5);
% Now sample for locations of unknown objects
for count = 1:nsamples
    S = randsample(POPULATION',U);       %S is a row vector of indices
    %Check for validity of sample
    [sample_row,sample_col] = ind2sub([nrows,ncols],S');
    
    % Check: All elements of S are unique
    if (size(unique([sample_row,sample_col],'rows'),1) ~= length(S))
         % Discard sample
         continue;
    end
     
    % Keep the sample
    samples = [samples;S];
end

samples = unique(samples,'rows');

%Now analyze each sample

minsteps = 10000;
minconfig = [];
first_action = [];
%for s = 1:min(10,size(samples,1))
for s = 1:size(samples,1)
    % Convert sample to a configuration
    %First combine visible & sample for locations of all objects
    [sample_row,sample_col] = ind2sub([nrows,ncols],samples(s,:)');
    this_sample = [unknown(:,1),sample_row,sample_col];
    config = [known;this_sample];
      
    % Perform BFS
    [~,nsteps,action] = bfs_class(config,known,free,dim1,dim2,res,target_id);

    if (nsteps < minsteps)
        minsteps = nsteps;
        first_action = action;
        minconfig = config;
    end
end

end

