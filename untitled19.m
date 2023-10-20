% Initialize a cell array to store the file paths
filePaths = {};

% Open the file for reading
fid = fopen('listData_assignSept2023.txt', 'r');
strResponse = input('Please make your choice: ', 's');
while (strcmp(strResponse,'d')~=1)
    switch (strResponse)
        case 'a'

        % Read the file line by line using fscanf
        line = fscanf(fid, '%s', 1);
        while (strcmp(line, '.') ~= 1)
            % Add the line (file path) to the cell array
            filePaths{end+1} = line;
            % Read the next line
            line = fscanf(fid, '%s', 1);
        end
        
        % Close the file
        fclose(fid);
        
        % Specify the folder where the label files are located
        labelFolder = 'labels';
        
        % Initialize a cell array to store the label data
        LabelFileArrays = cell(length(filePaths), 4);
        
        % Loop through the file paths and read the label files
        for i = 1:length(filePaths)
            % Include the ".txt" file extension when constructing filePath
            filePath = fullfile(labelFolder, [filePaths{i}, '.txt']);
            
            % Open the label file for reading
            fid = fopen(filePath, 'r');
            % Read the content of the label file line by line
            content = textscan(fid, '%s%f%f%f%s%s%f', 'Delimiter', '\t');
            fclose(fid); % Close the label file
                
            % Extract the relevant columns
            fileNames = content{1};
            startTimes = content{2};
            soundTypes = content{5};
            musicalNotes = content{6};
                
            % Store the extracted data in the LabelFileArrays cell array
            LabelFileArrays{i, 1} = fileNames;
            LabelFileArrays{i, 2} = startTimes;
            LabelFileArrays{i, 3} = soundTypes;
            LabelFileArrays{i, 4} = musicalNotes;
        end
        
        % Now we read the .wav files located in wavOrig folder
        % Specify the folder where the .wav files are located
        wavFolder = 'wavOrig';
        
        % Initialize a cell array to store the audio data
        wavFilesArray = cell(length(filePaths), 3);
        
        % Loop through the file paths and read the .wav files
        for i = 1:length(filePaths)
            % Construct the paths for the .wav file and its corresponding label file
            wavFilePath = fullfile(wavFolder, [filePaths{i}, '.wav']);
         
            % Read the .wav file
            [audioData, sampleRate] = audioread(wavFilePath);
            
            % Extract the file name
            [~, fileName, ~] = fileparts(wavFilePath);
            
            % Store the extracted data in the wavFilesArray cell array
            wavFilesArray{i, 1} = fileName;
            wavFilesArray{i, 2} = audioData;
            wavFilesArray{i, 3} = sampleRate;
        end
        
        % Initialize cell arrays to store the occurrences
        noteD4Occurrences = cell(length(LabelFileArrays), 1);
        noteC5Occurrences = cell(length(LabelFileArrays), 1);
        
        % Define the note types to search for
        noteTypeD4 = 'D4';
        noteTypeC5 = 'C5';
        
        % Loop through the label files
        for i = 1:length(LabelFileArrays)
            % Extract the sound types, musical notes, and start times for the current file
            soundTypes = LabelFileArrays{i, 3};
            musicalNotes = LabelFileArrays{i, 4};
        
            % Find indices where note D4 occurs
            d4Indices = find(strcmp(soundTypes, 'Note') & strcmp(musicalNotes, noteTypeD4));
        
            % Find indices where note C5 occurs
            c5Indices = find(strcmp(soundTypes, 'Note') & strcmp(musicalNotes, noteTypeC5));
        
            % Prepare arrays to store note occurrences
            d4OccurrenceArray = cell(length(d4Indices), 4);
            c5OccurrenceArray = cell(length(c5Indices), 4);
        
            % Extract and store note occurrences
            for j = 1:length(d4Indices)
                noteIndex = d4Indices(j);
                startTime = LabelFileArrays{i, 2}(noteIndex) + 0.03;  % Start time + 30ms
                endTime = startTime + 0.02;  % Start time + 30ms + 20ms
                d4OccurrenceArray{j, 1} = LabelFileArrays{i, 1};  % File name
                d4OccurrenceArray{j, 2} = j;  % Occurrence number
                d4OccurrenceArray{j, 3} = startTime;  % Start time
                d4OccurrenceArray{j, 4} = endTime;  % End time
            end
        
            for j = 1:length(c5Indices)
                noteIndex = c5Indices(j);
                startTime = LabelFileArrays{i, 2}(noteIndex) + 0.03;  % Start time + 30ms
                endTime = startTime + 0.02;  % Start time + 30ms + 20ms
                c5OccurrenceArray{j, 1} = LabelFileArrays{i, 1};  % File name
                c5OccurrenceArray{j, 2} = j;  % Occurrence number
                c5OccurrenceArray{j, 3} = startTime;  % Start time
                c5OccurrenceArray{j, 4} = endTime;  % End time
            end
        
            % Store the note occurrences in the result arrays
            noteD4Occurrences{i} = d4OccurrenceArray;
            noteC5Occurrences{i} = c5OccurrenceArray;
        end
        
        % Initialize structures to store the extracted segments
        noteD4Segments = struct();
        noteC5Segments = struct();
        
        % Loop through the files
        for i = 1:length(filePaths)
            % Extract the file name without the path
            [~, fileName, ~] = fileparts(filePaths{i});
        
            % Generate a valid field name from the file name
            fieldName = genvarname(fileName);
        
            % Use the audioData and sampleRate that were read earlier
            audioData = wavFilesArray{i, 2};
            sampleRate = wavFilesArray{i, 3};
        
            % Extract Note D4 segments
            d4Occurrences = noteD4Occurrences{i};
            numD4Occurrences = size(d4Occurrences, 1);
            for j = 1:numD4Occurrences
                startTime = d4Occurrences{j, 3};  % Start time
                endTime = d4Occurrences{j, 4};  % End time
                startIndex = round(startTime * sampleRate);
                endIndex = round(endTime * sampleRate);
        
                % Extract the audio segment
                segment = audioData(startIndex:endIndex);
        
                % Store the segment and information in the noteD4Segments structure
                noteD4Segments.(fieldName).(['Occurrence', num2str(j)]).Segment = segment;
                noteD4Segments.(fieldName).(['Occurrence', num2str(j)]).StartTime = startTime;
                noteD4Segments.(fieldName).(['Occurrence', num2str(j)]).EndTime = endTime;
            end
        
            % Extract Note C5 segments
            c5Occurrences = noteC5Occurrences{i};
            numC5Occurrences = size(c5Occurrences, 1);
            for j = 1:numC5Occurrences
                startTime = c5Occurrences{j, 3};  % Start time
                endTime = c5Occurrences{j, 4};  % End time
                startIndex = round(startTime * sampleRate);
                endIndex = round(endTime * sampleRate);
        
                % Extract the audio segment
                segment = audioData(startIndex:endIndex);
        
                % Store the segment and information in the noteC5Segments structure
                noteC5Segments.(fieldName).(['Occurrence', num2str(j)]).Segment = segment;
                noteC5Segments.(fieldName).(['Occurrence', num2str(j)]).StartTime = startTime;
                noteC5Segments.(fieldName).(['Occurrence', num2str(j)]).EndTime = endTime;
            end
        end
        
        % Save the constructed data structures
        save('storeSegAndInfo_noteD4andC5.mat', 'noteD4Segments', 'noteC5Segments');
        
        % Initialize an empty cell array to store all Note C5 segments
        segAllnoteC5 = {};
        
        % Loop through the fields in noteC5Segments
        fieldNames = fieldnames(noteC5Segments);
        for i = 1:length(fieldNames)
            occurrences = fieldnames(noteC5Segments.(fieldNames{i}));
            
            % Loop through the occurrences within each field
            for j = 1:length(occurrences)
                % Extract the segment from the current occurrence
                currentSegment = noteC5Segments.(fieldNames{i}).(occurrences{j}).Segment;
                
                % Append the segment to the segAllnoteC5 array
                segAllnoteC5 = [segAllnoteC5; currentSegment];
            end
        end
        
        % Transpose the segAllnoteC5 cell array
        segAllnoteC5 = cell2mat(segAllnoteC5')';
        
        % Initialize an empty cell array to store all Note D4 segments
        segAllnoteD4T = {};
        
        % Loop through the fields in noteD4Segments
        fieldNames = fieldnames(noteD4Segments);
        for i = 1:length(fieldNames)
            occurrences = fieldnames(noteD4Segments.(fieldNames{i})); 
            
            % Loop through the occurrences within each field
            for j = 1:length(occurrences)
                % Extract the segment from the current occurrence
                currentSegment = noteD4Segments.(fieldNames{i}).(occurrences{j}).Segment;
                
                % Append the segment to the segAllnoteD4 array
                segAllnoteD4T = [segAllnoteD4T; currentSegment];
            end
        end
        
        % Determine the maximum segment length
        maxSegmentLength = max(cellfun(@length, segAllnoteD4T));
        
        % Initialize an empty matrix to store the transposed segments
        segAllnoteD4 = zeros(length(segAllnoteD4T), maxSegmentLength);
        
        % Loop through the elements in segAllnoteD4
        for i = 1:length(segAllnoteD4T)
            currentSegment = segAllnoteD4T{i};
            currentLength = length(currentSegment);
            
            % Pad the segment with zeros to match the maximum length
            segAllnoteD4(i, 1:currentLength) = currentSegment';
        end
        
        % Now segAllnoteD4_transposed is a 133x883 array with padded segments
        % Save the segAllnoteC5 and segAllnoteD4 arrays into a MAT file
        save('storeSeg noteD4andC5.mat', 'segAllnoteC5', 'segAllnoteD4');
        
        % Plot first occurence of Note D4 in HardimanTheFiddler.wav file
        subplot(2,1,1)
        Plot_Segment_D4 = noteD4Segments.HardimanTheFiddler.Occurrence1.Segment; % store Segment struct in Segment variable
        % plot the occurence
        plot(Plot_Segment_D4)
        
        % Customize the plot with labels and titles as needed
        title('First Occurence of Note D4 in wavOrig/rec_other/HardimanTheFiddler.wav');
        xlabel('Sample Index'); % x axis
        ylabel('Amplitude'); % y axis 
        grid on; % for better visualization
        
        % Plot first occurence of Note C5 in HardimanTheFiddler.wav file
        subplot(2,1,2)
        Plot_Segment_C5 = noteC5Segments.HardimanTheFiddler.Occurrence1.Segment; % store Segment struct in Segment variable
        % plot the occurence
        plot(Plot_Segment_C5);
        
        % Customize the plot with labels and titles as needed
        title('First Occurence of Note C5 in wavOrig/rec_other/HardimanTheFiddler.wav'); 
        xlabel('Sample Index'); % x axis
        ylabel('Amplitude'); % y axis 
        grid on; % for better visualization
    
    
    case 'b'
        % option b
        % calculate the magnitude spectrum for segAll_NoteD4 and segAll_noteC5
        % using fft since it is faster and more efficient than dft
        
        DFT_segAllNoteD4 = 20 * log10(abs(fft(Plot_Segment_D4)));
        DFT_segAllNoteC5 = 20 * log10(abs(fft(Plot_Segment_C5)));
        
        figure;
        subplot(2,1,1)
        plot(DFT_segAllNoteD4)
        title('FFT D4');
        xlabel('Frequency Index');
        ylabel('Magnitude Spectrum (dB)');
        
        % Now C5 Plot
        subplot(2,1,2)
        plot(DFT_segAllNoteC5)
        title('FFT D5');
        xlabel('Frequency Index');
        ylabel('Magnitude Spectrum (dB)');
    end
    strResponse = input('Please make your choice: ', 's');
end




