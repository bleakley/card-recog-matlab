vid = videoinput('winvideo', 1, 'YUY2_320x240');
vid.ReturnedColorSpace = 'rgb';
preview(vid);

while(1)
    img = rgb2gray(getsnapshot(vid));
    
     imshow(img);
     hold on
     plot(1:1:200,1:1:200,'g'); 
     hold off

end