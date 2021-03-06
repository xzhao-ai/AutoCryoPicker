clc; close all; clear all;

[img,path]=uigetfile('*.png','Select any cryo-EM Image...');
% open the directory box
str=strcat(path,img);

% read the MRI image from the spesific directory
originalImage=imread(str);
% originalImage=rgb2gray(originalImage);
originalImage = imresize(originalImage,.5);
imwrite(originalImage,'originalImage.png');
figure;
imshow(originalImage); title('Original Cryo-Image');
figure; imhist(originalImage);title('Histogram of the Original Cryo-Image');
%
% orginal_I = imcrop(originalImage,[761.5 280.25 111 98.9999999999999]);
% imwrite(orginal_I,'originalImage_cropped.png');

%% Pre-processing Part
% Image normalization...
z=mat2gray(originalImage);
figure;imshow(z);title('Normalized cryo-EM Image')
figure; imhist(z);title('Histogram of the Cryo-Image');
imwrite(z,'Normalized.png');
% 
% Normalized_I = imcrop(z,[761.5 280.25 111 98.9999999999999]);
% imwrite(Normalized_I,'Normalized_cropped.png');

% Contrast Enhancement Correction
Inormalized=z;
limit=stretchlim(Inormalized);
CEC_Image_Adjusment=imadjust(Inormalized,[limit(1) limit(2)]);  
figure;imshow(CEC_Image_Adjusment);title('CEC Image Adjusment')
figure; imhist(CEC_Image_Adjusment);title('Histogram of the Cryo-Image');
imwrite(CEC_Image_Adjusment,'CEC.png');

% CEC_Image_Adjusment_I = imcrop(CEC_Image_Adjusment,[761.5 280.25 111 98.9999999999999]);
% imwrite(CEC_Image_Adjusment_I,'CEC_cropped.png');

% Hostogram Equalization
Cryo_EM_Histogram_Equalization = histeq(CEC_Image_Adjusment);
figure; imshow(Cryo_EM_Histogram_Equalization); title('Cryo-EM Histogram Equalization');
figure; imhist(Cryo_EM_Histogram_Equalization);title('Histogram of the Cryo-Image');
imwrite(Cryo_EM_Histogram_Equalization,'HE.png');

% Cryo_EM_Histogram_Equalization_I = imcrop(Cryo_EM_Histogram_Equalization,[761.5 280.25 111 98.9999999999999]);
% imwrite(Cryo_EM_Histogram_Equalization_I,'HE_cropped.png');

% Cryo-EM Restoration
Cryo_EM_Restoration = wiener2(Cryo_EM_Histogram_Equalization,[5 5]);
figure; imshow(Cryo_EM_Restoration); title('Cryo-EM Restoration');
figure; imhist(Cryo_EM_Restoration);title('Histogram of the Restored Cryo-Image');
imwrite(Cryo_EM_Restoration,'Restored.png');

% Cryo_EM_Restoration_I = imcrop(Cryo_EM_Restoration,[761.5 280.25 111 98.9999999999999]);
% imwrite(Cryo_EM_Restoration_I,'Restored_cropped.png');

% Adaptive Histogram Equlaizer Cryo-Image
Adaptive_Histogram_Equlaizer = histeq(Cryo_EM_Restoration);
Adaptive_Histogram_Equlaizer=adapthisteq(Adaptive_Histogram_Equlaizer,'clipLimit',.02,'Distribution','rayleigh');
Adaptive_Histogram_Equlaizer=adapthisteq(Adaptive_Histogram_Equlaizer,'clipLimit',.99,'Distribution','rayleigh');
figure;imshow(Adaptive_Histogram_Equlaizer);title('Adaptive Cryo-EM Histo-Equal.')
figure; imhist(Adaptive_Histogram_Equlaizer);title('Histogram of the Adaptive Cryo-EM Histo-Equal.');
imwrite(Adaptive_Histogram_Equlaizer,'Adaptive_Histogram_Equlaizer.png');

% Adaptive_Histogram_Equlaizer_I = imcrop(Adaptive_Histogram_Equlaizer,[761.5 280.25 111 98.9999999999999]);
% imwrite(Adaptive_Histogram_Equlaizer_I,'Adaptive_Histogram_Equlaizer_cropped.png');

% Gaudided Filtering
Gaudided_Filtering=imguidedfilter(Adaptive_Histogram_Equlaizer);
Gaudided_Filtering=imguidedfilter(Gaudided_Filtering);
Gaudided_Filtering=imguidedfilter(Gaudided_Filtering);
Gaudided_Filtering=imguidedfilter(Gaudided_Filtering);
Gaudided_Filtering=imadjust(Gaudided_Filtering);
figure;imshow(Gaudided_Filtering);title('Gaudided Filtering')
figure; imhist(Gaudided_Filtering);title('Histogram of the Gaudided Filtering');
imwrite(Gaudided_Filtering,'Gaudided.png');

% Gaudided_Filtering_I = imcrop(Gaudided_Filtering,[761.5 280.25 111 98.9999999999999]);
% imwrite(Gaudided_Filtering_I,'Gaudided_Filtering_cropped.png');

% Morphological Image Operation
Morphological_Image=imopen(Gaudided_Filtering,strel('disk',1));
Morphological_Image=imopen(Morphological_Image,strel('disk',1));
Morphological_Image=imopen(Morphological_Image,strel('disk',1));
Morphological_Image=imopen(Morphological_Image,strel('disk',1));
Morphological_Image=imopen(Morphological_Image,strel('disk',1));
figure;imshow(Morphological_Image);title('Morphological Image Operation')
figure; imhist(Morphological_Image);title('Histogram of Morphological Image Operation');
imwrite(Morphological_Image,'Morphological.png');

Morphological_Image_I = imcrop(Morphological_Image,[381 140 56 50]);
imwrite(Morphological_Image_I,'Morphological_cropped.png');
%
close all;
%% Particles Picking using Our Approach (ICB)....
% 
% Clustering....
disp('_______________________________________________________________________');
disp('                                                                       ');
disp('        S I N G L E - P A R T I C L E - D E T E C T I O N ');
disp('                            USING ICB                                  ');
disp('_______________________________________________________________________');
disp(' ');
    tic;
    [cluster1] = Our_Clustering1(Morphological_Image);
    time1=toc;
    figure;imshow(cluster1);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Clustering using Our Approach is : %f\n', time1);
    pause;
    
    % remove the non-cercular object
    % Label the blobs.
    labeledImage = bwlabel(cluster1);
    measurements = regionprops(labeledImage,'Area','Perimeter');
    % Do size filtering and roundness filtering.
    % Get areas and perimeters of all the regions into single arrays.
    allAreas = [measurements.Area]
    allPerimeters = [measurements.Perimeter]
    % Compute circularities.
    circularities = allPerimeters.^2 ./ (4*pi*allAreas)
    % Find objects that have "round" values of circularities.
    maxAllowableArea = 500000;
    keeperBlobs = circularities < 5 & allAreas < maxAllowableArea; % Whatever values you want.
    % Get actual index numbers instead of a logical vector
    % so we can use ismember to extract those blob numbers.
    roundObjects = find(keeperBlobs);
    % Compute new binary image with only the small, round objects in it.
    binaryImage = ismember(labeledImage, roundObjects) > 0;
    % Extract the Average area of the bolobs in th eimage
    stats = regionprops('table',labeledImage,'Area',...
        'MajorAxisLength','MinorAxisLength');
    All_Area = stats.Area
    Average_Area = round(mean(All_Area));
    cluster2=bwareaopen(binaryImage,0);
    imshow(cluster2);title('Final Cleaned Image');
    
    % figure;imshowpair(c1,im,'blend');title(['Number of Detected Cells= ' num2str(numb1)]); 
    [img1,path]=uigetfile('*.png','Select a MRI Brain Tumor Image');
    % open the directory box
    str=strcat(path,img1);
    % read the MRI image from the spesific directory
    Cryp_EM_Image=imread(str);
    %13 65
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)'); 
    [centers1, radii1, metric1] = imfindcircles(cluster2,[13 85]);
    hold on;
    viscircles(centers1, radii1,'EdgeColor','b');
    plot(centers1(:,1), centers1(:,2), 'k+')
    %
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)');
    hold on;
    r=round(max(radii1(:,1)));
    % imwrite(Inormalized,'DM3.tif');
    for k = 1 : length(centers1)
      % extract the box diemnsions
        x=round(centers1(k,1));
        y=round(centers1(k,2));
        x1=x-r;
        y1=y-r;
        rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','g','LineWidth',2 );
    end
    % Compute the accuracy
    TP=0;FP=0;TN=0;
    I1=double(imbinarize(Cryp_EM_Image(:,:,1)));
%     figure;imshow(I1);
    [~, NumBlobs] = bwlabel(I1);
    for i=1:length(centers1)
        x=round(centers1(i,1));
        y=round(centers1(i,2));
        if I1(y,x)==1
            % Ture Postive Detection
            TP=TP+1;
        else
             % False Postive Detection
            FP=FP+1;
        end
    end
    % False Nagative Detection
     FN=abs(NumBlobs-TP);
    % Total number of particles
    total_number_particles=NumBlobs;
    % bulid the confusion matrix
    confusion_matrix1 = zeros(2, 2);
    confusion_matrix1(1)=TP;
    confusion_matrix1(4)=TN;
    confusion_matrix1(3)=FP;
    confusion_matrix1(2)=FN;
    clc;
    disp('=====================================================================================');
    disp(' --------------  E X P E R M E N T A L - R E S U L T S ( I C B )  ------------------');
    disp('=====================================================================================');
    %
    disp('_________________________________________________________');
    disp(' '); 
    disp('           C O N F U S I O N  -  M A T R I X   ');
    disp('_________________________________________________________');
    disp(' '); 
    fprintf('True Positive  =\t %d\n',confusion_matrix1(1));
    fprintf('False Negative  =\t %d\n',confusion_matrix1(2));
    fprintf('False Positive  =\t %d\n',confusion_matrix1(3));
    fprintf('True Negative  =\t %d\n',confusion_matrix1(4));
    disp('_________________________________________________________');
    disp(' ');
    disp('_________________________________________________________');
    disp(' '); 
    disp('       P E R F O R M A N C E - R E S U L T S  ');
    disp('_________________________________________________________');
    disp(' '); 
    [ acc1,sen1,pre1,FP_rate1,TP_rate1,Miss_class1,F_1_score1] = evaluation( confusion_matrix1 );
    % 
    fprintf('Particle Detection and Picking using ICB is done.... PRESS ENTER TO CONTINUE...\n');
    pause;
%% Particles Picking using K-means....
% Clustering....
clc; close all;
disp('_______________________________________________________________________');
disp('                                                                       ');
disp('        S I N G L E - P A R T I C L E - D E T E C T I O N ');
disp('                        USING K-MEANS                                  ');
disp('_______________________________________________________________________');
disp(' ');
    tic;
    [cluster2] = K_means_Clustering1(Morphological_Image);
    time2=toc;
    figure;imshow(cluster2);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Detection using K-means is : %f\n', time2);
    pause;  
    % figure;imshowpair(c1,im,'blend');title(['Number of Detected Cells= ' num2str(numb1)]); 
    [img1,path]=uigetfile('*.png','Select a MRI Brain Tumor Image');
    % open the directory box
    str=strcat(path,img1);
    % read the MRI image from the spesific directory
    Cryp_EM_Image=imread(str);
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (K-means Algorithm)'); 
    [centers2, radii2, metric2] = imfindcircles(cluster2,[13 65]);
    hold on;
    viscircles(centers2, radii2,'EdgeColor','r');
    plot(centers2(:,1), centers2(:,2), 'k+')
    %
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (K-means Algorithm)');
    hold on;
    r=round(max(radii2(:,1)));
    % imwrite(Inormalized,'DM3.tif');
    for k = 1 : length(centers2)
      % extract the box diemnsions
        x=round(centers2(k,1));
        y=round(centers2(k,2));
        x1=x-r;
        y1=y-r;
        rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','r','LineWidth',2 );
    end
    % Compute the accuracy
    TP=0;FP=0;TN=0;
    I1=double(imbinarize(Cryp_EM_Image(:,:,1)));
    % figure;imshow(I1);
    [~, NumBlobs] = bwlabel(I1);
    for i=1:length(centers2)
        x=round(centers2(i,1));
        y=round(centers2(i,2));
        if I1(y,x)==1
            % Ture Postive Detection
            TP=TP+1;
        else
             % False Postive Detection
            FP=FP+1;
        end
    end
    % False Nagative Detection
     FN=abs(NumBlobs-TP);
    % Total number of particles
    total_number_particles2=NumBlobs;
    % bulid the confusion matrix
    confusion_matrix2 = zeros(2, 2);
    confusion_matrix2(1)=TP;
    confusion_matrix2(4)=TN;
    confusion_matrix2(3)=FP;
    confusion_matrix2(2)=FN;
    clc;
    disp('=====================================================================================');
    disp(' --------------  E X P E R M E N T A L - R E S U L T S ( K-MEANS ) ------------------');
    disp('=====================================================================================');
    %
    disp('_________________________________________________________');
    disp(' '); 
    disp('           C O N F U S I O N  -  M A T R I X   ');
    disp('_________________________________________________________');
    disp(' '); 
    fprintf('True Positive  =\t %d\n',confusion_matrix2(1));
    fprintf('False Negative  =\t %d\n',confusion_matrix2(2));
    fprintf('False Positive  =\t %d\n',confusion_matrix2(3));
    fprintf('True Negative  =\t %d\n',confusion_matrix2(4));
    disp('_________________________________________________________');
    disp(' ');
    disp('_________________________________________________________');
    disp(' '); 
    disp('       P E R F O R M A N C E - R E S U L T S  ');
    disp('_________________________________________________________');
    disp(' '); 
    [ acc2,sen2,pre2,FP_rate2,TP_rate2,Miss_class2,F_1_score2] = evaluation( confusion_matrix2 );
    % 
    fprintf('Particle Detection and Picking using K-Means is done.... PRESS ENTER TO CONTINUE...\n');
    pause;
%% Particles Picking using FCM....
% Clustering....
clc; close all;
disp('_______________________________________________________________________');
disp('                                                                       ');
disp('        S I N G L E - P A R T I C L E - D E T E C T I O N ');
disp('                           USING FCM                                   ');
disp('_______________________________________________________________________');
disp(' ');
    tic;
    [cluster3] = FCM_Clustering1(Morphological_Image);
    time3=toc;
    figure;imshow(cluster3);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Detection using FCM is : %f\n', time3);
    pause;    
    % figure;imshowpair(c1,im,'blend');title(['Number of Detected Cells= ' num2str(numb1)]); 
    [img1,path]=uigetfile('*.png','Select a MRI Brain Tumor Image');
    % open the directory box
    str=strcat(path,img1);
    % read the MRI image from the spesific directory
    Cryp_EM_Image=imread(str);
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images FCM'); 
    [centers3, radii3, metric3] = imfindcircles(cluster3,[13 65]);
    hold on;
    viscircles(centers3, radii3,'EdgeColor','m');
    plot(centers3(:,1), centers3(:,2), 'k+')
    %
    figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)');
    hold on;
    r=round(max(radii3(:,1)));
    % imwrite(Inormalized,'DM3.tif');
    for k = 1 : length(centers3)
      % extract the box diemnsions
        x=round(centers3(k,1));
        y=round(centers3(k,2));
        x1=x-r;
        y1=y-r;
        rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','c','LineWidth',2 );
    end

    % Compute the accuracy
    TP=0;FP=0;TN=0;
    I1=double(imbinarize(Cryp_EM_Image(:,:,1)));
    % figure;imshow(I1);
    [~, NumBlobs] = bwlabel(I1);
    for i=1:length(centers3)
        x=round(centers3(i,1));
        y=round(centers3(i,2));
        if I1(y,x)==1
            % Ture Postive Detection
            TP=TP+1;
        else
             % False Postive Detection
            FP=FP+1;
        end
    end

    % False Nagative Detection
     FN=abs(NumBlobs-TP);
    % Total number of particles
    total_number_particles3=NumBlobs;
    % bulid the confusion matrix
    confusion_matrix3 = zeros(2, 2);
    confusion_matrix3(1)=TP;
    confusion_matrix3(4)=TN;
    confusion_matrix3(3)=FP;
    confusion_matrix3(2)=FN;
    %
    clc;
    disp('=====================================================================================');
    disp(' ----------------  E X P E R M E N T A L - R E S U L T S ( FCM ) --------------------');
    disp('=====================================================================================');
    %
    disp('_________________________________________________________');
    disp(' '); 
    disp('           C O N F U S I O N  -  M A T R I X   ');
    disp('_________________________________________________________');
    disp(' '); 
    fprintf('True Positive  =\t %d\n',confusion_matrix3(1));
    fprintf('False Negative  =\t %d\n',confusion_matrix3(2));
    fprintf('False Positive  =\t %d\n',confusion_matrix3(3));
    fprintf('True Negative  =\t %d\n',confusion_matrix3(4));
    disp('_________________________________________________________');
    disp(' ');
    disp('_________________________________________________________');
    disp(' '); 
    disp('       P E R F O R M A N C E - R E S U L T S  ');
    disp('_________________________________________________________');
    disp(' '); 
    [ acc3,sen3,pre3,FP_rate3,TP_rate3,Miss_class3,F_1_score3] = evaluation( confusion_matrix3 );
    % 
    fprintf('Particle Detection and Picking using FCM is done.... PRESS ENTER TO CONTINUE...\n');
    pause;
    %


