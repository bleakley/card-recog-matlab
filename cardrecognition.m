clear all;

spadeFiles = dir(fullfile('spades','*.bmp'));
diamondFiles = dir(fullfile('diamonds','*.bmp'));
clubFiles = dir(fullfile('clubs','*.bmp'));
heartFiles = dir(fullfile('hearts','*.bmp'));

for i = 1:length(spadeFiles)
    spadeImages{i} = rgb2gray(imread(strcat('spades/',spadeFiles(i).name)));
end
for i = 1:length(diamondFiles)
    diamondImages{i} = rgb2gray(imread(strcat('diamonds/',diamondFiles(i).name)));
end
for i = 1:length(clubFiles)
    clubImages{i} = rgb2gray(imread(strcat('clubs/',clubFiles(i).name)));
end
for i = 1:length(heartFiles)
    heartImages{i} = rgb2gray(imread(strcat('hearts/',heartFiles(i).name)));
end

% http://opencv-code.com/tutorials/automatic-perspective-correction-for-quadrilateral-objects/

% http://www.mathworks.com/help/images/ref/regionprops.html
% do this instead

% do a perspective correction so that all playing cards are the
% same 

vid = videoinput('winvideo', 2, 'YUY2_320x240');
vid.ReturnedColorSpace = 'rgb';
preview(vid);

src_obj = getselectedsource(vid)

bestSuitGuess = 0; % heart 1, club 2, diamond 3, spade 4
highestCorr = 0;

while(1)
    orig = getsnapshot(vid);
    img = rgb2gray(orig);
    
    %make it bw
    threshold = graythresh(img);
    img = im2bw(img, threshold);
    img = imfill(img,'holes');
    [B,L] = bwboundaries(img, 'noholes');
    %STATS = regionprops(L, 'all');
    STATS = regionprops(L, 'Centroid','Orientation','MajorAxisLength','MinorAxisLength');
    
    %BW = edge(img,'canny',0.5);
    
    imshow(img);
    hold on
    
    
    for i = 1 : length(STATS)
      %extrema = STATS(i).Extrema;
     % plot(extrema(:,1), extrema(:,2),'rX');

%       xs = [extrema(3,1),extrema(2,1)];
%       ys = [extrema(3,2),extrema(2,2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
%       
%       xs = [extrema(4,1),extrema(5,1)];
%       ys = [extrema(4,2),extrema(5,2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
%       
%       xs = [extrema(7,1),extrema(6,1)];
%       ys = [extrema(7,2),extrema(6,2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
%       
%       xs = [extrema(1,1),extrema(8,1)];
%       ys = [extrema(1,2),extrema(8,2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
      
      center = STATS(i).Centroid;
      major = STATS(i).MajorAxisLength;
      minor = STATS(i).MinorAxisLength;
      angle = -STATS(i).Orientation;
      ratio = major/minor;
      
      if(ratio < 1.25)
          continue
      end
      if(ratio > 1.5)
          continue
      end
      if(major < 75)
          continue
      end
      
      scale = 0.9;
      major = major*scale;
      minor = minor*scale;
      
      c=cosd(angle);
      s=sind(angle);
      rotation = [[c -s]; [s c];];
      
%       %major axis
%       xs = [cosd(angle)*major/2 + center(1),-cosd(angle)*major/2 + center(1)];
%       ys = [-sind(angle)*major/2 + center(2),sind(angle)*major/2 + center(2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
%       
%       %minor axis
%       xs = [sind(angle)*minor/2 + center(1),-sind(angle)*minor/2 + center(1)];
%       ys = [cosd(angle)*minor/2 + center(2),-cosd(angle)*minor/2 + center(2)];
%       plot(xs, ys,'LineWidth',2,'Color','green');
      
      corner1 = [major/2; minor/2;];
      corner2 = [major/2; -minor/2;];
      corner3 = [-major/2; -minor/2;];
      corner4 = [-major/2; minor/2;];
      
      rcorner1 = rotation*corner1+center.';
      rcorner2 = rotation*corner2+center.';
      rcorner3 = rotation*corner3+center.';
      rcorner4 = rotation*corner4+center.';

      plot(rcorner1(1),rcorner1(2),'x','LineWidth',2,'Color','yellow');%tr
      plot(rcorner2(1),rcorner2(2),'x','LineWidth',2,'Color','yellow');%tl
      plot(rcorner3(1),rcorner3(2),'x','LineWidth',2,'Color','yellow');%bl
      plot(rcorner4(1),rcorner4(2),'x','LineWidth',2,'Color','yellow');%br
      
      plot([rcorner1(1) rcorner2(1)],[rcorner1(2) rcorner2(2)],'LineWidth',2,'Color','green');
      plot([rcorner2(1) rcorner3(1)],[rcorner2(2) rcorner3(2)],'LineWidth',2,'Color','green');
      plot([rcorner3(1) rcorner4(1)],[rcorner3(2) rcorner4(2)],'LineWidth',2,'Color','green');
      plot([rcorner4(1) rcorner1(1)],[rcorner4(2) rcorner1(2)],'LineWidth',2,'Color','green');
      
      text(center(1),center(2),'CARD');
      
      %This is WRONG fix it
      ex = STATS(i).Extrema;
      leftmost = min(ex(7,1),ex(7,2));
      rightmost = max(ex(3,1),ex(4,2));
      topmost = min(ex(1,1),ex(2,2));
      bottommost = max(ex(5,1),ex(6,2));
      
      movingPoints = [[rcorner1(1) rcorner1(2)];[rcorner2(1) rcorner2(2)];[rcorner3(1) rcorner3(2)];[rcorner4(1) rcorner4(2)];];
      %fixedPoints = [[0 0]; [0 10]; [20 0]; [20 10];];
      fixedPoints = [[0 10]; [0 0]; [20 0]; [20 10];];
      tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');
      imref = imref2d([20 10]);
      warped = imwarp(orig,tform,'OutputView',imref);
      %warped = imwarp(orig,tform);
      imshow(warped);
      
    end
    
    
    
%     [H,T,R] = hough(BW);
% 
%     P  = houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
%     x = T(P(:,2)); y = R(P(:,1));
%     % Find lines and plot them
%     lines = houghlines(BW,T,R,P,'FillGap',20,'MinLength',40);
%     
%     for k = 1:length(lines)
%        xy = [lines(k).point1; lines(k).point2];
%        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%        % Plot beginnings and ends of lines
%        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%     end
%     
%     % now generate all the intersections of pairs of lines
%     intersections = zeros(2,nchoosek(length(lines),2));
%     counter = 0;
%     for k = 1:length(lines)
%         otherlines = lines;
%         otherlines(k) = [];
%         for kk = 1:length(otherlines)
%             newIntersection = intersection(lines(k), otherlines(kk));
%             % i should check here that the intersection is relatively near
%             % one terminus from each line, or else throw it away
%             counter = counter + 1;
%             intersections(:,counter)=newIntersection;
%         end
%     end
%     intersections = unique(intersections);
%     
%     %plot the intersections
%     if(length(intersections))
%         plot(intersections(1), intersections(2), 'x', 'LineWidth',2,'Color','green');
%     end
    
    
    % Create a point tracker and enable the bidirectional error constraint to
    % make it more robust in the presence of noise and clutter.
    %pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

    % Initialize the tracker with the initial point locations and the initial
    % video frame.
    %points = [lines(1) lines(2)];
    %points = points.Location;
    %initialize(pointTracker, points, videoFrame);
    
    
    
    
    
     %plot on live video feed
     
     %hold on
     
     hold off
     drawnow

%     clubishness = max( [max(max(normxcorr2(clubImages{1}, img))), max(max(normxcorr2(clubImages{2}, img))), max(max(normxcorr2(clubImages{3}, img))), max(max(normxcorr2(clubImages{4}, img)))] );
%     spadishness = max( max(max(normxcorr2(spadeImages{1}, img))), max(max(normxcorr2(spadeImages{2}, img))) );
%     heartishness = max( max(max(normxcorr2(heartImages{1}, img))), max(max(normxcorr2(heartImages{2}, img))) );
%     diamondishness = max( max(max(normxcorr2(diamondImages{1}, img))), max(max(normxcorr2(diamondImages{2}, img))) );
% 
%     if (max([clubishness,spadishness,heartishness,diamondishness]) < 0.8)
%         highestCorr = 0;
%     end
%         
%     highestCorr = max([highestCorr,clubishness,spadishness,heartishness,diamondishness]);
%     
%     switch highestCorr
%         case heartishness
%             bestSuitGuess = 1;
%         case clubishness
%             bestSuitGuess = 2;
%         case diamondishness
%             bestSuitGuess = 3;
%         case spadishness
%             bestSuitGuess = 4;
%     end
%     
%     clc
%     if(highestCorr >= 0.8)
%         switch bestSuitGuess
%             case 1
%                 disp('Heart')
%             case 2
%                 disp('Club')
%             case 3
%                 disp('Diamond')
%             case 4
%                 disp('Spade')
%         end
%     end
%     
%     if (highestCorr >= 0.95)
%         disp('Certain!')
%     elseif (highestCorr >= 0.89)
%         disp('Probably')
%     elseif (highestCorr >= 0.8)
%         disp('Maybe??')
%     end

end

 closepreview(vid);
 delete(vid);
 clear vid
 close(gcf)