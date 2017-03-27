function [pointSize, mmSize, logMAR] = calculateOptotypeFontSize( viewingDistance, logMAR, outputOff )
%CALCULATEOPTOTYPEFONTSIZE Calculate the required Sloan font size (in
%points) to produce optotypes suitable for a default or specified set of
%log minimum angles of resolution (logMAR).
%
%   pointSize = CALCULATEOPTOTYPEFONTSIZE will return the font sizes in
%   points to produce optotypes from -0.3 to 1.3 logMAR in increments of
%   0.1 logMAR at a default viewing distance of 4.0 m.
%
%   pointSize = CALCULATEOPTOTYPEFONTSIZE(viewingDistance) allows you to
%   specify the viewing distance in metres (defaults to 4.0 m).
%
%   pointSize = CALCULATEOPTOTYPEFONTSIZE(viewingDistance, logMAR) lets you
%   specify a list of logMAR values at which to provide the required point
%   size.
%
%   pointSize = CALCULATEOPTOTYPEFONTSIZE(viewingDistance, logMAR,
%   outputOff) lets you turn off the output to the command window by
%   setting 'outputOff' to a non-zero value.
%
%   [pointSize, mmSize] = CALCULATEOPTOTYPEFONTSIZE also returns the list
%   of sizes in mm.
%
%   [pointSize, mmSize, logMAR] = CALCULATEOPTOTYPEFONTSIZE additionally
%   returns the list of logMAR values for the point size.
%
%   The MAR is specified as the angular subtense of the gap in the Landolt
%   ring, which is the C in the Sloan alphabet, in minutes of arc. The 
%   outer diameter of the Landolt ring is five times the angular subtense
%   of the gap. Standard optotypes are C, D, H, K, N, O, R, S, V and Z.
%   Sloan font is available from https://github.com/denispelli/Eye-Chart-Fonts.
%   

    if (nargin < 1) || isempty(viewingDistance)
        viewingDistance = 4.0;
    end

    if (nargin < 2) || isempty(logMAR)
        logMAR = -0.3:0.1:1.3;
    end

    if (nargin < 3) || isempty(outputOff)
        outputOff = 0;
    end

    size_min = 5*(10.^logMAR); % Angular subtense of the character is five times the MAR
    size_deg = size_min/60;
    mmSize = tan(deg2rad(size_deg))*(viewingDistance*1000);

    pointSize = mmSize * 2.83465;

    if ~outputOff

        nSizes = numel(logMAR);
        fprintf('\n\n-------------------------------------------------');
        fprintf('\nlogMAR\t\tSize (points)\tSize (mm)');
        fprintf('\n-------------------------------------------------');

        for thisSize = 1:nSizes
            fprintf('\n%1.2f\t\t%.2f\t\t%.2f', logMAR(thisSize), pointSize(thisSize), mmSize(thisSize));
        end

        fprintf('\n-------------------------------------------------\n\n');
    end

end