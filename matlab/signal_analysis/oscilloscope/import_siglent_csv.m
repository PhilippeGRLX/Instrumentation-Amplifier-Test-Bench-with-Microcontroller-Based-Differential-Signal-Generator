function data = import_siglent_csv(filename)
%IMPORT_SIGLENT_CSV Import Siglent oscilloscope CSV waveform data.
%
%   data = import_siglent_csv(filename)
%
%   Output structure:
%       data.filename
%       data.channel
%       data.unit
%       data.start
%       data.increment
%       data.sequence
%       data.time
%       data.voltage
%       data.fs

    if ~isfile(filename)
        error('File not found: %s', filename);
    end

    %% Read header lines

    fid = fopen(filename, 'r'); %ReadOnly open
    
    % If unable to open file with matlab.
    if fid == -1
        error('Could not open file: %s', filename);
    end

    header1 = fgetl(fid); % Reads the first line
    header2 = fgetl(fid); % Reads the second line

    fclose(fid);

    h1 = split(string(header1), ',');
    h2 = split(string(header2), ',');

    % Example:
    % Line 1: X,CH1,Start,Increment,
    % Line 2: Sequence,Volt,-1.200000e-04,2.000000e-07

    channel = strtrim(h1(2));
    unit    = strtrim(h2(2));

    start_time = str2double(h2(3));
    increment  = str2double(h2(4));

    %% Read numeric waveform data

    raw = readmatrix(filename, 'NumHeaderLines', 2);

    sequence = raw(:,1);
    voltage  = raw(:,2);

    % Remove rows containing missing values (typically trailing empty CSV rows)
    valid = ~isnan(sequence) & ~isnan(voltage);

    sequence = sequence(valid);
    voltage  = voltage(valid);

    %% Reconstruct time vector

    time = start_time + sequence * increment;

    %% Output structure

    data.filename  = filename;
    data.channel   = channel;
    data.unit      = unit;
    data.start     = start_time;
    data.increment = increment;
    data.sequence  = sequence;
    data.time      = time;
    data.voltage   = voltage;
    data.fs        = 1/increment;
end