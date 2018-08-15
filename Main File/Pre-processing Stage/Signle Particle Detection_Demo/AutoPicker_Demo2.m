clc; close all; clear all;

[img,path]=uigetfile('*.png','Select any cryo-EM Image...');
% open the directory box
str=strcat(path,img);

% read the MRI image from the spesific directory
originalImage=imread(str);
% originalImage=rgb2gray(originalImage);
originalImage = imresize(originalImage,.5);
imwrite(originalImage,'test.tiff');
figure;imshow(originalImage); title('Original Cryo-Image');
figure; imhist(originalImage);title('Histogram of the Original Cryo-Image');
%
%% Pre-processing Part
z=mat2gray(originalImage);
figure;imshow(z);title('Normalized cryo-EM Image')
figure; imhist(z);title('Histogram of the Cryo-Image');
% imwrite(z,'test.tiff');
Inormalized=z;
limit=stretchlim(Inormalized);
ad=imadjust(Inormalized,[limit(1) limit(2)]);  
figure;imshow(ad);title('CTF Image Adjusment')
figure; imhist(ad);title('Histogram of the Cryo-Image');
%
% imwrite(Inormalized,'DM3.tif');
I = histeq(ad);
figure; imshow(I); title('Cryo-EM Hostogram Equalization');
figure; imhist(I);title('Histogram of the Cryo-Image');
%
K = wiener2(I,[5 5]);
figure; imshow(K); title('Cryo-EM Restoration');
figure; imhist(K);title('Histogram of the Restored Cryo-Image');
% imwrite(K,'Test.tif');
%
I = histeq(K);
figure; imshow(I); title('Histogram Equlaizer of Cryo-Image');
figure; imhist(I);title('Histogram of the Equalization Cryo-Image');
%
g=adapthisteq(I,'clipLimit',.02,'Distribution','rayleigh');
figure; imshow(I); title('Adaptive Histogram Equlaizer Cryo-Image');
figure; imhist(I);title('Histogram of the Equalization Cryo-Image');
%
im=adapthisteq(g,'clipLimit',.99,'Distribution','rayleigh');
figure;imshow(im);title('Adaptive Cryo-EM Histo-Equal.')
figure; imhist(im);title('Histogram of the Adaptive Cryo-EM Histo-Equal.');
% 
% im=imguidedfilter(im);im=imguidedfilter(im);
% im=imguidedfilter(im);im=imguidedfilter(im);
% im=imadjust(im);
figure;imshow(im);title('Gaudided Filtering')
figure; imhist(im);title('Histogram of the Gaudided Filtering');
% %
% SE=strel('disk',5);J = imclose(im,SE);J2=imadjust(J,[.5,.9]);
% figure;imshow(J2,[]);title('Post-processing Morphological Operation')
% figure; imhist(J2);title('Histogram of the ost-processing Morphological Operation');
% imwrite(im,'DM3_tested.tif');
imcl=imopen(im,strel('disk',1));
imcl=imopen(imcl,strel('disk',1));
imcl=imopen(imcl,strel('disk',1));
imcl=imopen(imcl,strel('disk',1));
imcl=imopen(imcl,strel('disk',1));
%
figure;imshow(imcl);title('Morphological Image Operation')
figure; imhist(imcl);title('Histogram of Morphological Image Operation');
J2=imcl;
%
% [centers, radii, metric] = imfindcircles(J2,[7 25]);
% imshow(originalImage);
% hold on;
% viscircles(centers, radii,'EdgeColor','b');
% plot(centers(:,1), centers(:,2), 'r+')
%
%% Clustering....
disp('_______________________________________________________________________');
disp('                                                                       ');
disp('        S I N G L E - P A R T I C L E - D E T E C T I O N ');
disp('                                                                       ');
disp('_______________________________________________________________________');
disp(' ');
disp('         1: Our Clustering Approach              ');
disp('         2: K-means Clustering Approach              ');
disp('         3: FCM Clustering Approach              ');
disp('         4: Exit ');
disp('_______________________________________________________________________');
disp(' ');
% choice=input('Selct your choice : ');
% if choice==1
% Our Approach
    tic;
    [cluster1] = Our_Clustering1(J2);
    time1=toc;
    figure;imshow(cluster1);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Detection using Our Approach is : %f\n', time1);
    pause;
% elseif choice==2
% K-Means
    tic;
    [cluster2] = K_means_Clustering1(J2);
    time2=toc;
    figure;imshow(cluster1);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Detection using K-means is : %f\n', time2);
    pause;    
% elseif choice==3
% FCM
     tic;
    [cluster3] = FCM_Clustering1(J2);
    time3=toc;
    figure;imshow(cluster1);title('Cryo-EM Binary Mask');
    fprintf(' Time consuming for Particle Detection using FCM is : %f\n', time3);
    pause;    
% end

%% Particles Picking using Our Approach....
% 
% figure;imshowpair(c1,im,'blend');title(['Number of Detected Cells= ' num2str(numb1)]); 
[img1,path]=uigetfile('*.png','Select a MRI Brain Tumor Image');
% open the directory box
str=strcat(path,img1);
% read the MRI image from the spesific directory
Cryp_EM_Image=imread(str);
%13 65
figure, imshow(Cryp_EM_Image);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)'); 
[centers1, radii1, metric1] = imfindcircles(cluster1,[13 85]);
hold on;
viscircles(centers1, radii1,'EdgeColor','b');
plot(centers1(:,1), centers1(:,2), 'k+')
%
figure, imshow(z);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)');
hold on;
r=round(max(radii1(:,1)));
% imwrite(Inormalized,'DM3.tif');
for k = 1 : length(centers1)
  % extract the box diemnsions
    x=round(centers1(k,1));
    y=round(centers1(k,2));
    x1=x-r;
    y1=y-r;
    rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','g','LineWidth',1 );
end
% Compute the accuracy
TP=0;FP=0;TN=0;
I1=double(imbinarize(Cryp_EM_Image(:,:,1)));
% figure;imshow(I1);
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
[ acc1,sen1,pre1,FP_rate1,TP_rate1,Miss_class1,F_1_score1] = evaluation( confusion_matrix1 );
% 
%% Particles Picking using K-means....
% 
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
figure, imshow(z);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)');
hold on;
r=round(max(radii1(:,1)));
% imwrite(Inormalized,'DM3.tif');
for k = 1 : length(centers1)
  % extract the box diemnsions
    x=round(centers1(k,1));
    y=round(centers1(k,2));
    x1=x-r;
    y1=y-r;
    rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','g','LineWidth',1 );
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
[ acc2,sen2,pre2,FP_rate2,TP_rate2,Miss_class2,F_1_score2] = evaluation( confusion_matrix2 );
% 
%% Particles Picking using FCM....
%
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
figure, imshow(z);title('AutoCryoPicker:Fully Automated Single Particle Picking in Cryo-EM Images (Our Algorithm)');
hold on;
r=round(max(radii1(:,1)));
% imwrite(Inormalized,'DM3.tif');
for k = 1 : length(centers1)
  % extract the box diemnsions
    x=round(centers1(k,1));
    y=round(centers1(k,2));
    x1=x-r;
    y1=y-r;
    rectangle('Position', [x1 y1 2*r 2*r],'EdgeColor','g','LineWidth',1 );
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
[ acc3,sen3,pre3,FP_rate3,TP_rate3,Miss_class3,F_1_score3] = evaluation( confusion_matrix3 );
%


