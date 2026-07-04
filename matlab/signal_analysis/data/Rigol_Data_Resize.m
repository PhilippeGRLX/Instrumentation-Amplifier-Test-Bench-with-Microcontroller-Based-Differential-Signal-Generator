clear; clc;

%% Parameters

input_file  = 'PWM1kHz_unfiltered_full.csv';
output_file = 'PWM1kHz_unfiltered.csv';

N_points = 500000;     % Number of waveform samples to keep

%% Open files

fid_in = fopen(input_file, 'r');

if fid_in == -1
    error('Cannot open input file.');
end

fid_out = fopen(output_file, 'w');

if fid_out == -1
    fclose(fid_in);
    error('Cannot create output file.');
end

%% Copy the two Siglent header lines

fprintf(fid_out, '%s\n', fgetl(fid_in));
fprintf(fid_out, '%s\n', fgetl(fid_in));

%% Copy first N waveform samples

for k = 1:N_points

    line = fgetl(fid_in);

    if ~ischar(line)
        fprintf('End of file reached after %d samples.\n', k-1);
        break;
    end

    fprintf(fid_out, '%s\n', line);

end

%% Cleanup

fclose(fid_in);
fclose(fid_out);

fprintf('Done!\n');
fprintf('Copied %d waveform samples.\n', min(k,N_points));
fprintf('Output file: %s\n', output_file);