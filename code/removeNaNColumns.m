function varargout = removeNaNColumns(varargin)
    % removeNaNColumns removes columns that contain only NaN values from multiple matrices.
    % Usage:
    %   [A_clean, B_clean, ...] = removeNaNColumns(A, B, ...)
    % Inputs:
    %   varargin - Multiple matrices to be cleaned.
    % Outputs:
    %   varargout - Cleaned matrices with NaN-only columns removed.

    % Number of input matrices
    numMatrices = nargin;

    % Process each matrix
    for i = 1:numMatrices   
        A = varargin{i};  % Get the i-th matrix
        % Identify columns where all elements are NaN
        columnsToRemove = all(isnan(A), 1);
        
        % Remove those columns from the matrix
        cleanedMatrix = A(:, ~columnsToRemove);
        
        % Store cleaned matrix in output arguments
        varargout{i} = cleanedMatrix;
    end
end