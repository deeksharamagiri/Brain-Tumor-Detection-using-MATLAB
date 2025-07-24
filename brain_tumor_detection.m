classdef brain_tumor_detection < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        TumorDetectionButton   matlab.ui.control.Button
        EdgeDetectionButton    matlab.ui.control.Button
        MedianFilteringButton  matlab.ui.control.Button
        Image4                 matlab.ui.control.Image
        Image3                 matlab.ui.control.Image
        Image2                 matlab.ui.control.Image
        Image                  matlab.ui.control.Image
        UploadimageButton      matlab.ui.control.Button
    end

    
    properties (Access = public)
        loadedImage            % Property to store the loaded image
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadimageButton
        function UploadimageButtonPushed(app, event)
      % Open a dialog for the user to select an image file
    % Open a dialog for the user to select an image file
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an Image');
    if isequal(file, 0)
        % User canceled the operation
        return;
    end

    % Read the selected image file
    image = imread(fullfile(path, file));
    % Convert image to RGB if it's grayscale
    if size(image, 3) == 1
        image = cat(3, image, image, image);
    end
    % Display the image
    app.Image.ImageSource = image; % Assign image directly to ImageSource
    % Store the original image
    app.loadedImage = image; % Store the image in app object
        end

        % Button pushed function: MedianFilteringButton
        function MedianFilteringButtonPushed(app, event)
    if isempty(app.loadedImage)
        % Display error message if no image is uploaded
        errordlg('Please upload an image first.', 'Error');
        return;
    end
    
    % Convert the RGB image to grayscale
    gray_img = rgb2gray(app.loadedImage);
    
    % Apply median filtering to the grayscale image
    filtered_img = medfilt2(gray_img);
    
    % Convert the filtered grayscale image back to RGB
    filtered_rgb_img = cat(3, filtered_img, filtered_img, filtered_img);
    
    % Display the result in Image2
    app.Image2.ImageSource = filtered_rgb_img;
        end

        % Button pushed function: EdgeDetectionButton
        function EdgeDetectionButtonPushed(app, event)
% Check if an image is loaded
if isempty(app.loadedImage)
    % Display error message if no image is uploaded
    errordlg('Please upload an image first.', 'Error');
    return;
end

% Convert the loaded image to grayscale
gray_img = rgb2gray(app.loadedImage);

% Apply edge detection to the grayscale image
edge_img = edge(gray_img, 'sobel');

% Convert the logical array to an RGB image matrix
edge_img_rgb = cat(3, edge_img, edge_img, edge_img) * 255;

% Convert the RGB image matrix to uint8 data type
edge_img_rgb = uint8(edge_img_rgb);

% Display the edge-detected image in Image3
app.Image3.ImageSource = edge_img_rgb;


        end

        % Button pushed function: TumorDetectionButton
        function TumorDetectionButtonPushed(app, event)
% Check if edge detection has been performed
if isempty(app.Image3.ImageSource)
    % Display error message if no edge detection is performed
    errordlg('Please apply edge detection first.', 'Error');
    return;
end

% Perform additional preprocessing or segmentation to refine tumor detection
% For demonstration, let's assume a simple method of filling holes in the binary edge-detected image
tumor_mask = imfill(app.Image3.ImageSource, 'holes');

% Convert the tumor mask to a logical array
tumor_mask_logical = logical(tumor_mask);

% Initialize an array to store the highlighted image
highlighted_img = zeros(size(app.loadedImage), 'like', app.loadedImage);

% Loop through each pixel
for row = 1:size(app.loadedImage, 1)
    for col = 1:size(app.loadedImage, 2)
        % Check if the pixel is within the tumor region
        if tumor_mask_logical(row, col)
            % Highlight the pixel in yellow (255 for all channels)
            highlighted_img(row, col, :) = [255, 255, 0];
        else
            % Copy the pixel values from the original image
            highlighted_img(row, col, :) = app.loadedImage(row, col, :);
        end
    end
end

% Display the original image with detected tumor regions highlighted in yellow in Image4
app.Image4.ImageSource = uint8(highlighted_img);

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 708 483];
            app.UIFigure.Name = 'MATLAB App';

            % Create UploadimageButton
            app.UploadimageButton = uibutton(app.UIFigure, 'push');
            app.UploadimageButton.ButtonPushedFcn = createCallbackFcn(app, @UploadimageButtonPushed, true);
            app.UploadimageButton.Position = [40 220 100 22];
            app.UploadimageButton.Text = 'Upload image';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [16 259 147 140];

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [185 258 142 142];

            % Create Image3
            app.Image3 = uiimage(app.UIFigure);
            app.Image3.Position = [354 258 149 142];

            % Create Image4
            app.Image4 = uiimage(app.UIFigure);
            app.Image4.Position = [533 256 144 146];

            % Create MedianFilteringButton
            app.MedianFilteringButton = uibutton(app.UIFigure, 'push');
            app.MedianFilteringButton.ButtonPushedFcn = createCallbackFcn(app, @MedianFilteringButtonPushed, true);
            app.MedianFilteringButton.Position = [206 220 100 22];
            app.MedianFilteringButton.Text = 'Median Filtering';

            % Create EdgeDetectionButton
            app.EdgeDetectionButton = uibutton(app.UIFigure, 'push');
            app.EdgeDetectionButton.ButtonPushedFcn = createCallbackFcn(app, @EdgeDetectionButtonPushed, true);
            app.EdgeDetectionButton.Position = [379 220 100 22];
            app.EdgeDetectionButton.Text = 'Edge Detection';

            % Create TumorDetectionButton
            app.TumorDetectionButton = uibutton(app.UIFigure, 'push');
            app.TumorDetectionButton.ButtonPushedFcn = createCallbackFcn(app, @TumorDetectionButtonPushed, true);
            app.TumorDetectionButton.Position = [553 220 103 22];
            app.TumorDetectionButton.Text = 'Tumor Detection';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = brain_tumor_detection

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end