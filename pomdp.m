function [ output_args ] = pomdp(rows, cols, Nmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_cells = rows*cols;
num_states = 0;
for i = 1:Nmax
    num_states = num_states + nchoosek(num_cells,i);
end
S = 1:num_states;

num_actions = 4*num_cells;
A = 1:num_actions;

num_obs = 0;
for i = 1:Nmax
    num_obs = num_obs + nchoosek(ncols, i)*nrows;
end
O = 1:num_obs;

T = zeros(num_states,num_actions,num_states);
for i = 1:num_states
    col = i/nrows + 1;
    row = rem(i,nrows);
    if row == 0
        row = 1;
    end
    
    if row < nrows
        % Can move north
        north_action_index = (i-1)*4 + 1;
        T(i,north_action_index,i+1) = 1.0;
    end
   
    if row > 1
        % Can move south
        south_action_index = (i-1)*4 + 2;
        T(i, south_action_index, i-1) = 1.0;
    end
    
    if col > 1
        % Can move east
        east_action_index = (i-1)*4 + 3;
        T(i,east_action_index,i+nrows) = 1.0;
    end
    
    if col < ncols
        %Can move west
        west_action_index = 4*i;
        T(i,west_action_index,i-nrows) = 1.0;
    end
    
    
    
end

Z = zeros(num_states,num-ons);
for i = 1:num_states
    
        

end

