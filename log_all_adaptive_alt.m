function log_all_adaptive_alt(dim1,dim2,res,max_N,target_id,horizon)
% Given a start config and the algos to be compared, compare performance
% over different horizon lengths.
% Horizon varies from 1 to max_horizon. 

%%%% Record this:
% For a given grid and a given N and a given config:
% 1) num_iter, num_actions, num_unknown, time_taken
% 2) for each planning iter, horizon planned at and num_actions actually
% executed. Also, planning time for each iter

all_indices = [1:dim1*dim2]';

%num = min(500, nchoosek(dim1*dim2,N))
num_trials = 20;
%horizon = 1;

log_array = cell((max_N-4+1)*num_trials, 3);

for N = 4:max_N
    N
    allStartConfigs = nchoosek(all_indices,N);
    
    for i = 1:num_trials
        i
        objLocationsIndices = [allStartConfigs(i,:)]';
        %explore EVERYTHING with adaptive horizon when needed
        %[n_iterations,n_actions,time_taken,n_unknown, horizon_distribution] = ...
        log{1} = objLocationsIndices;
        log{2} = [dim1;dim2];
        log{3} = adaptive_horizon_search_alt(dim1, dim2, res, objLocationsIndices, [], target_id, horizon, 0);
        log_array((N-4)*num_trials+i, :) = log;
    end
end

save('log_4by4_horizon1_20trials_scattered.mat', 'log_array');
end
