#include <iostream>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/opencv.hpp"
#include <string>
#include <vector>

#define MAX_NUM_OBJECTS 50		//limit number of max object

using namespace cv;
using namespace std;

int thresLow = 100, thresH = 255;

void trackObject(Mat &image, Mat &orjImage, Scalar __s)
{
	vector< vector<Point> > contours;
	vector<Vec4i> hierarchy;
	Mat temp;

	findContours(image, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);		//dış kenarları bul

	if (hierarchy.size() > 0)
	{
		int numObjects = hierarchy.size();

		if (numObjects < MAX_NUM_OBJECTS)
		{
			for (int i = 0; i >= 0; i = hierarchy[i][0])
			{
				Moments moment = moments((cv::Mat)contours[i]);
				double area = moment.m00;
				//feedback
				//cout << area << endl;
				int xPos = moment.m10 / area;
				int yPos = moment.m01 / area;
				//cout << moment.m10 << "\t" << moment.m01 << endl;
				cout << xPos << "\t" << yPos << endl;
				//circle(orjImage, Point(xPos, yPos), );
				for (int i = 0; i < contours.size(); i++)
					drawContours(orjImage, contours, i, __s, 3, 8, hierarchy);

			}
		}
		else{
			putText(orjImage, "Cok Fazla Obje Var!", Point(10, 50), 1, 2, Scalar(0, 0, 255));
		}
	}

	//cout << hierarchy.data() << "\t" << hierarchy.size() << endl;
}


//tuz biber gürültüsünü engellemek amacı ile kullanılmıştır
void deliteAndErode(Mat &image)
{
	//morphological opening (remove small objects from the foreground)
	erode(image, image, getStructuringElement(MORPH_ELLIPSE, Size(3, 3)));
	dilate(image, image, getStructuringElement(MORPH_ELLIPSE, Size(8, 8)));

	//morphological closing (fill small holes in the foreground)
	dilate(image, image, getStructuringElement(MORPH_ELLIPSE, Size(8, 8)));
	erode(image, image, getStructuringElement(MORPH_ELLIPSE, Size(3, 3)));
}

int main(int argc, char** argv)
{
	/////////////////////////////////////////////
	/////RELEASE Mod da çalıştır/////////////////
	/////////////////////////////////////////////

	VideoCapture cap(0); //capture the video from web cam

	if (!cap.isOpened())  // if not success, exit program
	{
		cout << "Cannot open the web cam" << endl;
		return -1;
	}

	namedWindow("Control", CV_WINDOW_AUTOSIZE); //create a window called "Control"

	int iLowH = 88;
	int iHighH = 179;

	int iLowS = 153;
	int iHighS = 255;

	int iLowV = 143;
	int iHighV = 255;

	//Create trackbars in "Control" window
	cvCreateTrackbar("LowH", "Control", &iLowH, 179); //Hue (0 - 179)
	cvCreateTrackbar("HighH", "Control", &iHighH, 179);

	cvCreateTrackbar("LowS", "Control", &iLowS, 255); //Saturation (0 - 255)
	cvCreateTrackbar("HighS", "Control", &iHighS, 255);

	cvCreateTrackbar("LowV", "Control", &iLowV, 255); //Value (0 - 255)
	cvCreateTrackbar("HighV", "Control", &iHighV, 255);

	cvCreateTrackbar("Find", "Control", &thresLow, thresH);

	while (true)
	{
		Mat imgOriginal;
		vector<Vec3f> circles;

		bool bSuccess = cap.read(imgOriginal); // read a new frame from video

		if (!bSuccess) //if not success, break loop
		{
			cout << "Cannot read a frame from video stream" << endl;
			break;
		}

		Mat imgHSV;

		cvtColor(imgOriginal, imgHSV, COLOR_BGR2HSV); //Convert the captured frame from BGR to HSV

		Mat imgThresholded;

		inRange(imgHSV, Scalar(iLowH, iLowS, iLowV), Scalar(iHighH, iHighS, iHighV), imgThresholded);
		deliteAndErode(imgThresholded);
		trackObject(imgThresholded, imgOriginal, Scalar(0, 0, 255));

		imshow("Thresholded Image", imgThresholded); //show the thresholded image
		imshow("Original", imgOriginal); //show the original image

		if (waitKey(30) == 27) //wait for 'esc' key press for 30ms. If 'esc' key is pressed, break loop
		{
			cout << "esc key is pressed by user" << endl;
			break;
		}
	}

	return 0;

}
