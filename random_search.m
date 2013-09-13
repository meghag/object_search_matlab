function [iteration,n_actions_taken,time_taken,unknown_state] = random_search(dim1,dim2,res,objLocationsindices,target_id,horizon,plot_flag)
% RANDOM_SEARCH
% Goal: reveal state of ALL voxels by choosing actions randomly.
% Let us see how different horizon lengths affect no. of actions and time
% taken to explore everything.

% INPUT:
% dim1 - along Y
% dim2 - along X
% res - grid resolution
% objLocationIndices - indices of true object locations
% horizon - no. of steps to look ahead while planning

% OUTPUT:
% iteration - no. of iterations taken to reveal as much as possible.
% n_actions - no. of actions *executed* (not planned) to reveal as much as
% possible. executed <= planned.
% time_taken - time taken to run the algo.
% unknown_state - no. of voxels whose state could not be revealed (always
% zero in this case).

%***************************************************************************%


% Each object is assumed to fit within a grid cell.
nrows = dim1/res;
ncols = dim2/res;
%N = length(objLocationsindices);

[objLocations(:,1),objLocations(:,2)] = ind2sub([nrows,ncols],objLocationsindices);

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
[visible,known] = find_visible2(true_init_config,[]);

prev_occupied = [];
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), prev_occupied);
free = find_free(occupied,nrows,ncols,[]);

if (plot_flag == 1)
    % Plotting the true intial configuration
    plot_config2(true_init_config,visible,known,occupied,free,dim1,dim2,res,'true start config',target_id);
end

true_config = true_init_config;
target_found = 0;
iteration = 0;
n_actions_taken = 0;
unknown_state = 0;

tic
%If the goal is to know identity and location of each object
%while (nrows*ncols - (size(known,1) + length(free)) > 0)

%If the goal is only to know state of each voxel - free or occupied
while (nrows*ncols - (length(occupied) + length(free)) > 0)
%for itr = 1:1
    %current_config = true_config;
    if (numel(find(visible(:,1) == target_id,1)) ~= 0)
        %Target is visible
        target_found = 1;
        
        %If the goal is just to find target
        %break;
    end
    
    iteration = iteration + 1;
    
    % Plan
    %Goal: To observe every voxel even if it means increasing horizon
    random_action_seq = random_plan(visible,known,occupied,free,dim1,dim2,res,horizon);
    
    if (isempty(random_action_seq))
        disp('No more moves possible.');
        time_taken = toc;
        return;
    end
    
    %Take chosen action
    %for act = 1:1
    for act = 1:size(random_action_seq,1)
        action = random_action_seq(act,:);
       % known_before_action = known;
        
        [~,new_true_config,moved,visible,known,occupied,free,~,no_new_findings] = ...
            take_action2(true_config,action,true_config,visible,known,occupied,free,nrows,ncols);
        n_actions_taken = n_actions_taken+1;
                
        true_config = new_true_config;
        if (plot_flag == 1)
            plot_title = strcat('Iteration ',int2str(iteration),': Config after action ',int2str(act), ', Horizon =', int2str(horizon));
            plot_config2(true_config,visible,known,occupied,free,dim1,dim2,res,plot_title,target_id);
        end
        %keyboard;
        
        if (moved == 0)
            %Replan.
            break;
        end
        
        %Did you see what you expected to?
        
        %If the goal is only to know state of each voxel - free or occupied
        if (no_new_findings == 0)
            %Something new was seen that we didn't expected to see.
            %Replan for the same horizon.
            %no_new_findings
            break;
        end
%       Else everything is as expected. Continue executing actions.        
    end
end
time_taken = toc;

end
