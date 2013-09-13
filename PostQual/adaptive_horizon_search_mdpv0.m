function adaptive_horizon_search_mdpv0(dim1,dim2,res,objLocationsindices,plot_flag, id)
% ADAPTIVE_HORIZON
% Goal: reveal state of ALL voxels even if horizon length has to be increased.
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

%fid = fopen('obj_search_mdp2x2.pomdp','w');
fid = fopen(strcat('obj_search_mdp', int2str(dim1), 'x', int2str(dim2), '_', int2str(id), '.pomdp'), 'w');

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

fprintf(fid, '#%dx%d grid, %d objects at cells ', dim1, dim2, length(objLocationsindices));
for n = 1:length(objLocationsindices)
    fprintf(fid, '%d, ', objLocationsindices(n));
end
fprintf(fid, '\n');

true_init_config = [(1:size(objLocations,1))',objLocations];
n_cells = nrows*ncols;
n_states = 5^n_cells;
n_actions = 4*n_cells;  

fprintf(fid, 'discount: 0.95\n');
fprintf(fid, 'values: reward\n');
fprintf(fid, 'actions: %d\n', n_actions);
fprintf(fid, 'observations: %d\n', n_states);
fprintf(fid, 'states: %d\n\n', n_states);

% visible - Vx3 matrix of visible objects at current time
% unknown - Ux3 matrix of objects that have never been seen and so, their locations are unknown.
% known - Kx3 matrix of objects that have been seen at least once and hence, their locations are exactly known.
% free - a vector of indices taht are known to be free
[visible,known] = find_visible2(true_init_config,[]);
prev_occupied = [];
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), prev_occupied);
free = find_free(occupied,nrows,ncols,[]);

% State is a vector of cell states that vary from 0 to 4.
% Cell States: 0 = free & visible, 1 = free & hidden, 2 = occupied & visible, 
% 3 = occupied & hidden, 4 = unknown
state = 4*ones(n_cells,1);

visible_indices = sub2ind([nrows, ncols], visible(:,2), visible(:,3));
%keyboard
state(visible_indices) = 2*ones(length(visible_indices),1);
state(free) = zeros(length(free),1);

if (plot_flag == 1)
    % Plotting the true intial configuration
    plot_config2(true_init_config,visible,known,occupied,free,dim1,dim2,res,'true start config',1);
end

state
current_state_idx = state2stateidx(state)

%belief_prior = zeros(n_states,1);
%belief_prior(current_state_idx) = 1.0;

fprintf(fid, 'start include: %d\n\n', current_state_idx);
%for i = 1:length(belief_prior)
%    fprintf(fid, '%1.2f ', belief_prior(i));
%end

% for a = 0:n_actions-1
%      fprintf(fid, 'O: %d\n identity \n', a);
% end

for s = 0:n_states-1
    for a = 0:n_actions-1
        %fprintf(fid, 'T: *:\t %d:\t %d\t 1.0\n', s, s);
        fprintf(fid, 'T: %d: %d: %d %1.2f\n', a, s, s, 1.0);
        fprintf(fid, 'O: %d: %d: %d %1.2f\n', a, s, s, 1.0);
    end
end

%fprintf(fid, 'T: *\t: *\t: * 0.0\n');

for i = 0:n_states-1
    state = stateidx2state(i, n_cells);
    %find_visible(state);
    
    % Find validity of state
    expanded_state = zeros(n_cells,3);
    [expanded_state(:,1), expanded_state(:,2)] = ind2sub([nrows,ncols],1:n_cells);
    expanded_state(:,3) = state;
    
    % If state is invalid, no need to find actions
    for c = 1:ncols
        current_col_state = expanded_state(expanded_state(:,2) == c,:);
        if isempty(find(current_col_state(:,3) == 0, 1))
            if current_col_state(1,3) ~= 2
                %Invalid state
                continue;
            end
        elseif (isempty(find(current_col_state(:,3) == 2, 1)))
            if isempty(find(current_col_state(:,3) ~= 0, 1))
                % Invalid state
                continue;
            end
        else
            last_visible_free_cell = find(current_col_state(:,3) == 0, 1, 'last' );
            first_visible_occupied_cell = find(current_col_state(:,3) == 2, 1 );
            if (current_col_state(first_visible_occupied_cell,1) < current_col_state(last_visible_free_cell,1))
                % Invalid state
                continue;
            end
        end
    end
    
    %if (i == 560)
    actions = find_actions(state, nrows, ncols);
    n_valid_actions = size(actions,1);
    
    n_valid_actions;
    
    if (n_valid_actions > 0)
        valid_action_indices = (actions(:,1) - ones(n_valid_actions,1)) * 4 + actions(:,2);
        end_state_indices = zeros(n_valid_actions,1);
        
        for a = 1:n_valid_actions
            end_state_indices(a) = state2stateidx(actions(a,3:end)');
        end
        
        [unique_actions, ~, ~] = unique(valid_action_indices);
        
        for u = 1:length(unique_actions)
            fprintf(fid, 'T: %d: %d: %d %1.2f\n', unique_actions(u), i, i, 0.0);
        end
        
        for a = 1: n_valid_actions
            %action_idx = unique_actions(u);
            action_idx = valid_action_indices(a);
            end_states_with_this_action = end_state_indices(valid_action_indices == action_idx);
            num_unique_end_states_with_this_action = length(unique(end_states_with_this_action));
            %        num_same_end_state_with_this_action = ...
            %           length(nonzeros((valid_action_indices == action_idx) & (end_state_indices == end_state_indices(a))));
            fprintf(fid, 'T: %d: %d: %d %1.5f\n', action_idx, i, end_state_indices(a), 1/num_unique_end_states_with_this_action);
        end
    end

    %If end state doesn't have any cell state as 4, then it is a goal state.
    if (isempty(find(state == 4, 1)))
        fprintf(fid, 'R: *: *: %d: * %f\n', i, 100);
    end
    
    %end
end

fclose(fid);

end

function actions = find_actions(state, nrows, ncols)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

occupied_indices = find(state > 1 & state ~= 4);
[occupied(:,1),occupied(:,2)] = ind2sub([nrows,ncols],occupied_indices);
occupied_or_unknown_indices = find(state > 1);
[occupied_or_unknown(:,1),occupied_or_unknown(:,2)] = ind2sub([nrows,ncols],occupied_or_unknown_indices);
visible_indices = find(state == 2);        % Visible means movable
[visible(:,1),visible(:,2)] = ind2sub([nrows,ncols],visible_indices);
unknown_indices = find(state == 4);
[unknown(:,1),unknown(:,2)] = ind2sub([nrows,ncols],unknown_indices);

actions = [];

% if (nnz(state == [0;2;2;4]) == length(state))
%     occupied
%     visible_indices
%     unknown_indices
%     visible
%     unknown
% end

for obj = 1:size(visible,1)
    objRow = visible(obj,1);
    objCol = visible(obj,2);
    source_idx = sub2ind([nrows,ncols],objRow, objCol);
    %# Find valid moves
    if (objRow >= 1 && objRow ~= nrows && ...
            numel(setdiff([objRow+1,objCol], occupied_or_unknown,'rows')) ~= 0)
        %# Can move back (away from camera)
        destination_idx = sub2ind([nrows, ncols], objRow+1, objCol);
        end_state = state;
        
        %# The move only affects the state of source and destination cells in this case.
        end_state(source_idx) = 0;
        end_state(destination_idx) = 2;
            
        %# this_action = [start_cell, dirn (N,S,E,W = 0,1,2,3), end state]
        this_action = [source_idx, 0, end_state'];
        actions = [actions;this_action];
    end
    
    if (objRow <= nrows && objRow ~= 1 && ...
            numel(setdiff([objRow-1,objCol], occupied_or_unknown,'rows')) ~= 0)
        %# Can move forward (closer to camera)    
        destination_idx = sub2ind([nrows, ncols], objRow-1, objCol);
        
        %# The move only affects the state of source and destination cells in this case.
        end_state = state;
        end_state(source_idx) = 1;
        end_state(destination_idx) = 2;
       
        %# this_action = [start_cell, dirn (N,S,E,W = 0,1,2,3), end state]
        this_action = [source_idx, 1, end_state'];
        actions = [actions;this_action];
    end  
   
    if (objCol ~= ncols && objCol >= 1 && ...
            numel(setdiff([objRow,objCol+1], occupied_or_unknown,'rows')) ~= 0)
        %# Can move right
        %destination_idx = sub2ind([nrows, ncols], objRow, objCol+1);
        %dest_col_obj = occupied(occupied(:,2) == objCol+1, :); %Objects in the same col as destination cell.
        
        %# The move may affect the state of cells other than the source and destination cells too.
%         end_state = state;
%         end_state(source_idx) = 0;      % Source cell becomes free & visible.
%         
%         if (isempty(find(dest_col_obj(:,1) < objRow, 1)))
%             end_state(destination_idx) = 2;     % No object in front => occupied & visible.
%         else 
%             end_state(destination_idx) = 3;     % Object in front => occupied but hidden.
%         end
        
        %# There may be other possible changes in cell states.
        actions = changes_in_cells_behind_source_cell(occupied, unknown, nrows, ncols, objRow, objCol, source_idx, 2, actions, state);
    end
    
    if (objCol <= ncols && objCol ~= 1 && ...
            numel(setdiff([objRow,objCol-1], occupied_or_unknown,'rows')) ~= 0)
        %Can move left
        %destination_idx = sub2ind([nrows, ncols], objRow, objCol-1);
        %dest_col_obj = occupied(occupied(:,2) == objCol-1, :); %Objects in the same col as destination cell.
        
        %# The move may affect the state of cells other than the source and destination cells too.
%         end_state = state;
%         end_state(source_idx) = 0;      % Source cell becomes free & visible.
%         
%         if (isempty(find(dest_col_obj(:,1) < objRow, 1)))
%             end_state(destination_idx) = 2;     % No object in front => occupied & visible.
%         else 
%             end_state(destination_idx) = 3;     % Object in front => occupied but hidden.
%         end
%         
        %# There may be other possible changes in cell states.
        actions = changes_in_cells_behind_source_cell(occupied, unknown, nrows, ncols, objRow, objCol, source_idx, 3, actions, state);
    end
end

%actions
%end

end

function actions = changes_in_cells_behind_source_cell(occupied, unknown, nrows, ncols, objRow, objCol, source_idx, direction, actions, state)
    %# There may be other possible changes in cell states.
    
    dest_col = 0;
    if (direction == 2)
        dest_col = objCol+1;
    elseif (direction == 3)
        dest_col = objCol-1;
    end
        
    destination_idx = sub2ind([nrows, ncols], objRow, dest_col);
    dest_col_obj = occupied(occupied(:,2) == dest_col, :); %Objects in the same col as destination cell.
    
    end_state = state;
    end_state(source_idx) = 0;      % Source cell becomes free & visible.
    
    if (isempty(find(dest_col_obj(:,1) < objRow, 1)))
        end_state(destination_idx) = 2;     % No object in front => occupied & visible.
    else
        end_state(destination_idx) = 3;     % Object in front => occupied but hidden.
    end
    
    source_col_obj = occupied(occupied(:,2) == objCol, :); %Objects in the same col as source cell.
    source_col_unknown = unknown(unknown(:,2) == objCol, :); %Unknown cells in the same col as source cell.
    known_objects_behind = occupied(source_col_obj(:,1) > objRow,:);

    if (numel(known_objects_behind) ~= 0)
        % There are known objects behind the source cell
        known_objects_behind = sort(known_objects_behind,1);    % Sort by rows
    end
    unknown_cells_behind = source_col_unknown;
    if (numel(source_col_unknown) > 0)
        % There are unknown state cells behind the source cell
        unknown_cells_behind = sort(source_col_unknown, 1);     % Sort by rows
    end

    if (numel(known_objects_behind) > 0 && numel(unknown_cells_behind) > 0)
        % There are both known objects AND unknown cells behind the source cell
        if (known_objects_behind(1,1) < unknown_cells_behind(1,1))
            % the front-most known object will become visible. Any known cells between this and the source cell
            % will also become visible & free.
            this_action = frontmost_known_object_visible(known_objects_behind(1,1), objRow, objCol, ...
                nrows, ncols, end_state, source_idx, direction);
            actions = [actions;this_action];
        else
            % Many possibilities - each unknown cell may be free or occupied, thus affecting possible state of every unknown cell behind it.
            for r = objRow+1:unknown_cells_behind(1,1)-1
                % These cells must be free but hidden.
                end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
            end

            actions = find_end_states(actions, end_state, unknown_cells_behind(1,1), known_objects_behind(1,1), objCol, nrows, ncols, source_idx, 2);
            for r = unknown_cells_behind(1,1):known_objects_behind(1,1)-1
                % Case when all unknown cells are free
                end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
            end
            end_state(sub2ind([nrows, ncols], known_objects_behind(1,1), objCol)) = 2;  % Occupied & visible
            this_action = [source_idx, direction, end_state'];
            actions = [actions;this_action];
        end
    elseif (numel(known_objects_behind) > 0)
        % the front-most known object will become visible. Any known cells between this and the source cell
        % will also become visible & free.
        this_action = frontmost_known_object_visible(known_objects_behind(1,1), objRow, objCol, ...
            nrows, ncols, end_state, source_idx, direction);
        actions = [actions;this_action];
    elseif (numel(unknown_cells_behind) > 0)
        % Many possibilities - each unknown cell may be free or occupied, thus affecting possible state
        % of every unknown cell behind it.
        for r = objRow+1:unknown_cells_behind(1,1)-1
            % These cells must be free but hidden.
            end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
        end
        actions = find_end_states(actions, end_state, unknown_cells_behind(1,1), nrows+1, objCol, nrows, ncols, source_idx, direction);
        for r = unknown_cells_behind(1,1):nrows
            % Case when all unknown cells are free
            end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
        end
        this_action = [source_idx, direction, end_state'];
        actions = [actions;this_action];
    else
        % All cells behind source cell will be free & visible
        for r = objRow+1:nrows
            end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
        end
    end
end

function this_action = frontmost_known_object_visible(frontmost_object_row, objRow, objCol, nrows, ncols, end_state, source_idx, direction)
    % the front-most known object will become visible. Any known
    % cells between this and the source cell will also become
    % visible & free.
    end_state(sub2ind([nrows, ncols], frontmost_object_row, objCol)) = 2;  % Occupied & visible
    for r = objRow+1:frontmost_object_row-1
        end_state(sub2ind([nrows, ncols], r, objCol)) = 0;  % Free & visible
    end
    this_action = [source_idx, direction, end_state'];
    %actions = [actions;this_action];
end

function actions = find_end_states(actions, state, start_row, end_row, objCol, nrows, ncols, source_idx, direction)
    
    end_state = state;

    % if occupied
    end_state(sub2ind([nrows, ncols], start_row, objCol)) = 2;  % occupied & visible
    this_action = [source_idx, direction, end_state'];
    actions = [actions; this_action];

    if (start_row+1 < end_row)
        % if free
        end_state(sub2ind([nrows, ncols], start_row, objCol)) = 0;  % free & visible
        actions = find_end_states(actions, end_state, start_row+1, end_row, objCol, nrows, ncols, source_idx, direction);
    end
    %end
end

% Note: State indices start at 0.
function idx = state2stateidx(state)
    %idx = 1;
    idx = 0;
    for i = 1:length(state)
        idx = idx + state(i)*(5^(i-1));
    end
end

% Note: State indices start at 0.
function state = stateidx2state(state_idx, n_cells)
    %quotient = state_idx-1;
    quotient = state_idx;
    state = zeros(n_cells,1);
    curr = 1;
    while (quotient > 0)
        remainder = rem(quotient,5);
        quotient = idivide(quotient,int32(5));      % 'idivide' gives the quotient
        state(curr) = remainder;
        curr = curr+1;
    end
end


