function res = transform(this, data)
%TRANSFORM Transform new data to canonical space
%
%   RES = transform(PCA, DATA)
%
%   Example
%     resPca = Pca(iris(:,1:4));
%     scores = transform(resPca, iris(:,1:4));
%
%   See also
%     Pca
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-11-03,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2017 INRA - Cepia Software Platform.


% name of new columns
nDims = size(this.loadings, 2);
varNames = strtrim(cellstr(num2str((1:nDims)', 'pc%d')));

% compute new name
name = 'Coords';
if ~isempty(this.tableName)
    name = sprintf('Coords of %s', this.tableName);
end

% Table object for canonical coordinates
res = Table.create(data.data * this.loadings.data, ...
    'rowNames', data.rowNames, ...
    'colNames', varNames, ...
    'name', name);
