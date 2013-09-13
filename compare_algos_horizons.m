function compare_algos_horizons(dim1,dim2,res,N,max_horizon,algo_ids)
% Given the grid size, a particular start config, num of objects, a max 
% horizon, and the algos to be compared, it compares performance of all
% algos over different values of horizons.

% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;

% legend_text = cell(length(algo_ids));
% for a = 1:length(algo_ids)
%     legend_text{a} = strcat('Algo ',num2str(algo_ids(a)))
% end
% 
% keyboard

all_indices = [1:nrows*ncols]';

allStartConfigs = nchoosek(all_indices,N);
% 
% filename = strcat('configs',int2str(dim1),'by',int2str(dim2),'objects',...
%     int2str(N),'horizon',int2str(horizon),'algoid',int2str(algo_id),'.mat')
% save(filename,'allStartConfigs');

n_iterations = zeros(max_horizon,length(algo_ids));
n_actions = zeros(max_horizon,length(algo_ids));
time_taken = zeros(max_horizon,length(algo_ids));
n_unknown = zeros(max_horizon,length(algo_ids));

i = 1;
objLocationsIndices = [1;4;7;8;10;13];

%objLocationsIndices = [allStartConfigs(i,:)]';
[objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationsIndices);

true_init_config = [(1:size(objLocations,1))',objLocations];
visible = true_init_config;
known = visible; 
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), []);
free = find_free(occupied,nrows,ncols,[]);
plot_config2(true_init_config,visible,known,occupied,free,dim1,dim2,res,'true start config',1);

%for i = 1:size(allStartConfigs,1)
for a = 1:length(algo_ids)   
    a
    %for i = 1:1
    [n_iterations(:,a),n_actions(:,a),n_unknown(:,a),time_taken(:,a)] = ...
        compare_diff_horizons(dim1,dim2,res,objLocationsIndices,1,max_horizon,algo_ids(a),0);
    %end
end

colormap autumn;

figure;
bar(n_iterations);
title({'Number of Iterations';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(n_actions);
title({'Number of Actions';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(n_unknown);
title({'Number of Unknown Cells';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});

figure;
bar(time_taken);
title({'Time Taken';strcat('Dim1 = ',int2str(dim1),', Dim2 = ',int2str(dim2),', #Objects = ', int2str(N))});
   

end

