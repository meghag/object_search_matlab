function [largest_gap, avg_gap] = compare_to_optimal(dim1, dim2, res, N, visibleLocationIndices)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;
n_unseen = N - length(visibleLocationIndices);
n_visible = length(visibleLocationIndices);

[visibleLocations(:,1),visibleLocations(:,2)] = ind2sub([nrows,ncols],visibleLocationIndices);

visible = [(1:length(visibleLocationIndices))',visibleLocations];

known = visible;

[occupied,free] = find_occupied(known,nrows,ncols);

plot_config(visible,visible,known,free,dim1,dim2,res,'Visible Objects',6);

allIndices = (1:dim1*dim2)';

unseenIndices = setdiff(allIndices,union(occupied,free));
       
allStartConfigs = nchoosek(unseenIndices,n_unseen);

nsteps_sampling = [];
nsteps_optimal = [];
avg_gap = [];
largest_gap = [];

figure
%for runs = 1:20
    for i = 1:size(allStartConfigs,1)
        all_perms = perms((allStartConfigs(i,:))');
        for j = 1:size(all_perms,1)
            objLocationIndices = [visibleLocationIndices;(all_perms(j,:))'];
            [objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationIndices);
            config = [(1:N)',objLocations(:,1),objLocations(:,2)];
            target_id = n_visible+1;
            
            nsteps_sampling = [nsteps_sampling;object_search(dim1,dim2,res,objLocationIndices,target_id)];
            [~,nsteps_opt,~] = bfs(config,dim1,dim2,res,target_id);
            nsteps_optimal = [nsteps_optimal;nsteps_opt];
        end
    end
    plot(nsteps_optimal,'rs','MarkerSize',10);
    hold on;
    plot(nsteps_sampling,'bo','MarkerSize',10);
    hold off
    
    avg_gap = [avg_gap;mean(nsteps_sampling-nsteps_optimal)];
    largest_gap = [largest_gap; max(nsteps_sampling-nsteps_optimal)];  
%end


end

