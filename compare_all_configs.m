function result = compare_all_configs(dim1,dim2,res,N,horizon,algo_id)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;

all_indices = [1:nrows*ncols]';

allStartConfigs = nchoosek(all_indices,N);

filename = strcat('configs',int2str(dim1),'by',int2str(dim2),'objects',...
    int2str(N),'horizon',int2str(horizon),'algoid',int2str(algo_id),'.mat')
%save(filename,'allStartConfigs');

n_iterations = zeros(size(allStartConfigs,1),1);
n_actions = zeros(size(allStartConfigs,1),1);
time_taken = zeros(size(allStartConfigs,1),1);
n_unknown = zeros(size(allStartConfigs,1),1);

for i = 1:size(allStartConfigs,1)
%for i = 1:100
    i
    objLocationsIndices = [allStartConfigs(i,:)]';
    
    if (algo_id == 2)
        %Testing object_search2 - explore EVERYTHING
        [n_iterations(i),n_actions(i),time_taken(i),~] = ...
            adaptive_horizon_search(dim1,dim2,res,objLocationsIndices,1,horizon,0);
    elseif (algo_id == 3)
        %testing object_search3 - reveal as much as possible
        [n_iterations(i),n_actions(i),time_taken(i),n_unknown(i)] = ...
            object_search3(dim1,dim2,res,objLocationsIndices,1,horizon,0);
    elseif (algo_id == 4)
        %testing object_search3 - reveal as much as possible
        [n_iterations(i),n_actions(i),time_taken(i),n_unknown(i)] = ...
            object_search4(dim1,dim2,res,objLocationsIndices,1,horizon,0);
    elseif (algo_id == 5)
        %testing object_search3 - reveal as much as possible
        [n_iterations(i),n_actions(i),time_taken(i),n_unknown(i)] = ...
            object_search5(dim1,dim2,res,objLocationsIndices,1,horizon,0);
    elseif (algo_id == 6)
        %testing object_search3 - reveal as much as possible
        [n_iterations(i),n_actions(i),time_taken(i),n_unknown(i)] = ...
            object_search6(dim1,dim2,res,objLocationsIndices,1,horizon,0);
    end
    
    %[~,nsteps_opt,~] = bfs(objLocationsIndices,dim1,dim2,res,1);            
    %nsteps_optimal = [nsteps_optimal;nsteps_opt];
end

plot(n_iterations,'rs-');
hold on;
plot(n_actions,'bo--');
plot(n_unknown,'gx-.');
plot(time_taken,'cd:');

%ylim(0,10);
title(strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N),...
    ', Horizon = ',int2str(horizon),', Algo Id = ',int2str(algo_id)))
legend('No. of iterations','No. of actions','No. of unobserved','Time taken', 'Location','best');
hold off

avg_iterations = mean(n_iterations);
avg_actions = mean(n_actions);
avg_unknown = mean(n_unknown);
avg_time = mean(time_taken);
density = N/(dim1*dim2);
num_configs = size(allStartConfigs,1);
result = [num_configs;density;avg_iterations;avg_actions;avg_time;avg_unknown]';

%avg_gap = [avg_gap;mean(nsteps_sampling-nsteps_optimal)];
%largest_gap = [largest_gap; max(nsteps_sampling-nsteps_optimal)];
%end

end

