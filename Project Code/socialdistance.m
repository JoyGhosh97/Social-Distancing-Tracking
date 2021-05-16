%• Detect people present in this image
%For Images
[filename,pathname]=uigetfile('*.*','Select the Input Image');
filewithpath=strcat(pathname,filename);
I = imread(filewithpath);

detector = peopleDetectorACF('caltech-50x21');
%Read the image 

%• Detect the image IR on the script
[bboxes,scores]=detect(detector,I);

%•	Create a loop to check for all available boxes
cond = zeros(size(bboxes,1),1);
if ~isempty(bboxes)
    for i=1:(size(bboxes,1)-1)
        for j=(i+1):(size(bboxes,1)-1)
             dis1_v = abs(bboxes(i,1)+bboxes(i,3)-bboxes(j,1));
             dis2_v = abs(bboxes(j,1)+bboxes(j,3)-bboxes(i,1));
             dis1_h = abs(bboxes(i,2)-bboxes(j,2));
             dis2_h = abs(bboxes(i,2)+bboxes(i,4)-bboxes(j,2)-bboxes(j,4));
             if((dis1_v<75 || dis2_v<75) && (dis1_h<50 || dis2_h<50))
                cond(i)=cond(i)+1;
                cond(j)=cond(j)+1;
             else
                cond(i)=cond(i)+0; 
             end
        end
    end
end
I = insertObjectAnnotation(I,'rectangle',bboxes((cond>0),:),'danger','color','r');
I = insertObjectAnnotation(I,'rectangle',bboxes((cond<=0),:),'safe','color','g');

imshow(I);

%Video player
%For check any video
[filename,pathname]=uigetfile('*.*','Select the Input Video');
filewithpath=strcat(pathname,filename);

videoReader = vision.VideoFileReader(filewithpath);

%Create a video player using vision.VideoPlayer that is palys it [300 100] width and height of [1000 500]
videoPlayer = vision.VideoPlayer('Position',[300 100 1000 500]);

%Create the detector
detector = peopleDetectorACF('caltech-50x21');


%While file reader is completed get a frame from the videoReader
while ~isDone(videoReader)
    frame = step(videoReader);
    
    I = double(frame);   %Change the image to double
    
    [bboxes, scores] = detect(detector, I);  %Step the image to detectpr to find the bboxes and scores
    
    cond = zeros(size(bboxes,1),1);    %Make the condition matrix with size equal to the number of bboxes detected
    if ~isempty(bboxes)
        for i = 1:(size(bboxes,1)-1)
            for j = (i+1):(size(bboxes,1)-1)
                dis1_v = abs(bboxes(i,1)+bboxes(i,3)-bboxes(j,1));
                dis2_v = abs(bboxes(j,1)+bboxes(j,3)-bboxes(i,1));
                dis1_h = abs(bboxes(i,2)-bboxes(j,2));
                dis2_h = abs(bboxes(i,2)+bboxes(i,4)-bboxes(j,2)-bboxes(j,4));
                
                if((dis1_v<75 || dis2_v<75) && (dis1_h<50 || dis2_h<50))
                cond(i)=cond(i)+1;
                cond(j)=cond(j)+1;
             else
                cond(i)=cond(i)+0; 
             end
        end
    end
end

I = insertObjectAnnotation(I,'rectangle',bboxes((cond>0),:),'danger','color','r');

I = insertObjectAnnotation(I,'rectangle',bboxes((cond==0),:),'safe','color','g');


step(videoPlayer, I);

end

%Release them at the end
release(videoReader);
release(videoPlayer);
