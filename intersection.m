function intersectionPoint = intersection( line1 , line2 )
%INTERSECTION Given two lines returns the intersection point
%   Detailed explanation goes here

x1 = line1.point1(1);
x2 = line1.point2(1);
x3 = line2.point1(1);
x4 = line2.point2(1);
y1 = line1.point1(2);
y2 = line1.point2(2);
y3 = line2.point1(2);
y4 = line2.point2(2);

intersectionPoint(1) = ((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
intersectionPoint(2) = ((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));

end