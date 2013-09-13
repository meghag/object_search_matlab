classdef config < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private) 
        % Nx3 matrix
        objLocations
        % List of actions taken to come to this config
        first_action
    end
    
    methods
        function cfg = config(locations,action)
            cfg.objLocations = locations;
            cfg.first_action = action;
        end
    end
    
end

