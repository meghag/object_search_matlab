function [visible,unknown,known] = find_voxel_states(config,nrows,ncols,prev_known)
%FIND_VISIBLE - Given a config, finds the set of visible objects

% config is an Nx3 matrix with row = [obj_id cellRow cellCol]
% visible is a matrix with #rows = #visible objects, #cols = 3

%First sort objects by their rows - objects closest to the camera are on
%top.
[~, idx] = sort(config(:,2));
sortedObjLocations = config(idx,:);
occCol = [];
visible = [];

% Fx2 matrix of grid cells that are known to be free. The two columns are
% row and column
%free = prev_free;

for obj = 1:size(sortedObjLocations,1)
    %find(occCol == sortedObjLocations(obj,3))
    if (isempty(find(occCol == sortedObjLocations(obj,3), 1)))
        visible = [visible; sortedObjLocations(obj,:)];
        occCol = [occCol; sortedObjLocations(obj,3)];
    end
end

occupied = sub2ind([nrows,ncols],known(:,2),known(:,3));
free = [];

for col = 1:ncols
    occupied_row = min(known(col == known(:,3),2));
    if isempty(occupied_row)
        free = [free;sub2ind([nrows,ncols],(1:nrows)',col*ones(nrows,1))];
    else
        for i = 1:occupied_row-1
            free = [free;sub2ind([nrows,ncols],i,col)];
        end
    end
end

% Objects that can't be seen at current time
hidden = setdiff(sortedObjLocations,visible,'rows');

% Voxels whose state is unknown.
n_voxels = nrows*ncols;
if (isempty(prev_known))
    unknown = hidden;
elseif (isempty(setdiff(hidden(:,1),prev_known(:,1))))
    % None of the hidden objects are unknown
    unknown = [];
else
    unknown_ids = setdiff(hidden(:,1),prev_known(:,1));
    unknown_indices = [];
    for j = 1:length(unknown_ids)
        unknown_indices = [unknown_indices;find(hidden(:,1) == unknown_ids(j))];
    end
    unknown = hidden(unknown_indices,:);
end

% Voxels that are 'known' to be occupied or free.
if (isempty(prev_known))
    known = visible;
else
    known = union(visible,prev_known,'rows');
end

end

