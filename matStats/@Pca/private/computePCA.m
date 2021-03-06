function [means, sc, ld, ev] = computePCA(this, scale)
%COMPUTEPCA  Compute PCA on input data table
%
%   output = computePCA(input)
%
%   Example
%   computePCA
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-10-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Pre-processing

% recenter data (remove mean)
means = mean(this.data, 1);
cData = bsxfun(@minus, this.data, means);

% optional scaling of data (divide each column by standard deviation)
if scale
    sigma   = sqrt(var(cData));
    sigma(sigma < 1e-10) = 1;
    cData   = cData * diag(1 ./ sigma);
end


%% Computation of Principal components

% computation of covariance matrix

transpose = false;
if size(cData, 1) < size(cData, 2) && size(cData, 2) > 50
    % If data table has large number of variables, computes the covariance
    % matrix on the transposed array.
    % Result V has dimension nind x nind
    transpose = true;
    V = cData * cData';
    
else
    % V has dimension nvar * nvar
    V = cData' * cData;  
end

% divides by the number of rows to have a covariance
V = V / (size(cData, 1) - 1);


% Diagonalisation of the covariance matrix.
% * eigenVectors: basis transform matrix
% * vl: eigen values diagonal matrix
% * coord: not used
[eigenVectors, vl, coord] = svd(V);

% In case the input table was transposed, eigen vectors need to be
% recomputed from the coord array
if transpose
    eigenVectors = cData' * coord;
    
    % Normalisation of eigen vectors, such that eigenVectors * eigenVectors
    % corresponds to identity matrix
    for i = 1:size(eigenVectors, 2)
        eigenVectors(:,i) = eigenVectors(:,i) / sqrt(sum(eigenVectors(:,i) .^ 2));
    end
end

% compute new coordinates from the eigen vectors
coord = cData * eigenVectors;

% compute array of eigen values
vl = diag(vl);
eigenValues = zeros(length(vl), 3);
eigenValues(:, 1) = vl;                         % eigen values
eigenValues(:, 2) = 100 * vl / sum(vl);         % inertia
eigenValues(:, 3) = cumsum(eigenValues(:,2));   % cumulated inertia


%% Create result data tables

% name of new columns
nCols = size(this.data, 2);
if transpose
    nCols = size(this.data, 1);
end
varNames = strtrim(cellstr(num2str((1:nCols)', 'pc%d')));

% Table object for new coordinates
if ~isempty(this.name)
    name = sprintf('Scores of %s', this.name);
else
    name = 'Scores';
end
sc = Table.create(coord, ...
    'rowNames', this.rowNames, ...
    'colNames', varNames, ...
    'name', name);

% Table object for loadings
if ~isempty(this.name)
    name = sprintf('Loadings of %s', this.name);
else
    name = 'Loadings';
end
ld = Table.create(eigenVectors, ...
    'rowNames', this.colNames, ...
    'colNames', varNames, ...
    'name', name);

% Table object for eigen values
if ~isempty(this.name)
    name = sprintf('Eigen values of %s', this.name);
else
    name = 'Eigen values';
end
ev = Table.create(eigenValues, ...
    'rowNames', varNames, ...
    'name', name, ...
    'colNames', {'EigenValues', 'Inertia', 'Cumulated'});



