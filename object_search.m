function iteration = object_search(dim1, dim2, res, objLocationsindices, target_id)
% INSTANTIATE_ENV - describes the environment the robot is dealing with,
% contains ground truth about object locations, identities, etc.

%objLocations - Nx2 matrix with object with id i in the ith row, 1st column
%being row no., 2nd column is column no.

%dim1 - along Y
%dim2 - along X
%res - grid resolution

% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;
N = length(objLocationsindices);

[objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationsindices);

ground_truth = objLocations;

cellCentres = zeros(dim1/res,dim2/res,2);

%Calculating centres of grid cells
for i = 1:dim1/res
    for j = 1:dim2/res
        cellCentres(i,j,1) = (j-1)*res + res/2;
        cellCentres(i,j,2) = (i-1)*res + res/2;
    end
end

true_init_config = [(1:size(objLocations,1))',objLocations];

% visible - Vx3 matrix of visible objects at current time
% unknown - Ux3 matrix of objects that have never been seen and so, their locations are unknown.
% known - Kx3 matrix of objects that have been seen at least once and hence, their locations are exactly known.
[visible,unknown,known] = find_visible(true_init_config,[]);

[~,free] = find_occupied(known,nrows,ncols);

% Plotting the true intial configuration
plot_config(true_init_config,visible,known,free,dim1,dim2,res,'true start config',target_id);

true_config = true_init_config;
target_found = 0;
iteration = 0;
prediction_success = 0;

tic
while (target_found == 0)
%for itr = 1:7
    current_config = true_config;
    %[visible,unknown,known] = find_visible(current_config,known);
    if (numel(find(visible(:,1) == target_id,1)) ~= 0)
        %Target is visible
        target_found = 1
        toc
        break;
    end
    
    iteration = iteration + 1
    
    % Plan
    [chosen_config,first_action] = plan(unknown,known,free,dim1,dim2,res,target_id,prediction_success)
    known_before_action = known;
   
    if (numel(chosen_config) == 0)
        continue;
    end
    
    %Plot chosen_config
    plot_title = strcat('Iteration ',int2str(iteration),': Chosen Sample with min steps to target');
    plot_config(chosen_config,visible,known,free,dim1,dim2,res,plot_title,target_id);
    
    %keyboard
    
    %Choose chosen_config to take action. Need action sequence for this.
    %[new_config,moved,true_config,known] = take_action(chosen_config,first_action,true_config,known,free)
    moved = 0;
    new_config = chosen_config;
    new_true_config = true_config;
    move_idx = find(chosen_config(:,1) == first_action(1));    
    new_config(move_idx,2:3) = new_config(move_idx,2:3) + first_action(2:3);
    if (numel(setdiff(new_config(move_idx,2:3),true_config(:,2:3),'rows')) == 0)
        % There is an object where we want to move
        new_config = chosen_config;
    else
        new_true_config(new_true_config(:,1) == first_action(1),2:3) = ...
            new_true_config(new_true_config(:,1) == first_action(1),2:3) + first_action(2:3);
        known(known(:,1) == first_action(1),2:3) = known(known(:,1) == first_action(1),2:3) + first_action(2:3);
        
        % Update free
        now_occupied_idx = sub2ind([nrows,ncols],new_config(move_idx,2),new_config(move_idx,3));
        now_free_idx = sub2ind([nrows,ncols],chosen_config(move_idx,2),chosen_config(move_idx,3));
        free(free == now_occupied_idx) = now_free_idx;
        [visible,unknown,known] = find_visible(new_true_config,known);
        [~,new_free] = find_occupied(known,nrows,ncols);
        free = union(free,new_free);
        moved = 1;
    end
    
    [~,~,known1] = find_visible(new_config,known_before_action);
    %if (isempty(setdiff(true_config,new_config,'rows')))
    if (isempty(setdiff(known,known1,'rows')))
        %The configs match. Do not sample.
        prediction_success = 1;
    else
        prediction_success = 0;
    end
    
    %Then repeat from beginning
    true_config = new_true_config;
    plot_title = strcat('Iteration ',int2str(iteration),': Config after action');
    plot_config(true_config,visible,known,free,dim1,dim2,res,plot_title,target_id);
end

end
