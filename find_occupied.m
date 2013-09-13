function [occupied,free] = find_occupied(known,nrows,ncols)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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



end

