#include <iostream>
#include <vector>
#include <stdio.h>
#include <string>

#define USE_GPU                         //if you do dnot want to use GPU make comment this line

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/video/video.hpp>
#ifdef USE_GPU
#include <opencv2/gpu/gpu.hpp>
#include <opencv2/gpu/devmem2d.hpp>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cuda.h>
#endif

using namespace std;
using namespace cv;

#define IMG_W 640
#define IMG_H 480

#define MAX_NUM_OBJECTS 10

#ifdef USE_GPU
#define CUDA_ERROR_CHECK

#define CudaSafeCall( err ) __cudaSafeCall( err, __FILE__, __LINE__ )
#define CudaCheckError()    __cudaCheckError( __FILE__, __LINE__ )

inline void __cudaSafeCall(cudaError err, const char *file, const int line)
{
#ifdef CUDA_ERROR_CHECK
    if (cudaSuccess != err)
    {
        fprintf(stderr, "cudaSafeCall() failed at %s:%i : %s\n",
            file, line, cudaGetErrorString(err));
        exit(-1);
    }
#endif

    return;
}

inline void __cudaCheckError(const char *file, const int line)
{
#ifdef CUDA_ERROR_CHECK
    cudaError err = cudaGetLastError();
    if (cudaSuccess != err)
    {
        fprintf(stderr, "cudaCheckError() failed at %s:%i : %s\n",
            file, line, cudaGetErrorString(err));
        exit(-1);
    }


    err = cudaDeviceSynchronize();
    if (cudaSuccess != err)
    {
        fprintf(stderr, "cudaCheckError() with sync failed at %s:%i : %s\n",
            file, line, cudaGetErrorString(err));
        exit(-1);
    }
#endif

    return;
}

extern "C"__global__ void gpu_inRange(const gpu::PtrStepSz<uchar3> p_src, gpu::PtrStepSzb p_dst,
                                      int lbc0, int ubc0, int lbc1, int ubc1, int lbc2, int ubc2)
{

    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < p_src.cols && y < p_src.rows)
    {
        uchar3 v = p_src(y, x);
        if (v.x >= lbc0 && v.x <= ubc0 && v.y >= lbc1 && v.y <= ubc1 && v.z >= lbc2 && v.z <= ubc2)
        {
            p_dst(y, x) = 255;
        }else{
            p_dst(y, x) = 0;
        }
    }
}

#endif

void trackObject(Mat &threshold, Mat &orjImage, Scalar __s)
{
    vector< vector<Point> > contours;
    vector<Vec4i> hierarchy;
    Mat temp;

    findContours(threshold, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);		//dış kenarları bul

    if (hierarchy.size() > 0)
    {
        int numObjects = hierarchy.size();

        if (numObjects < MAX_NUM_OBJECTS)
        {
            int biggestArea = 0, biggestIndex = -1;
            for (int i = 0; i >= 0; i = hierarchy[i][0])
            {
                Moments moment = moments((cv::Mat)contours[i]);
                double area = moment.m00;
                //feedback
                //cout << area << endl;
                if(area > biggestArea)
                {
                    biggestIndex = i;
                    biggestArea = area;
                }

                //circle(orjImage, Point(xPos, yPos), );
                for (int i = 0; i < contours.size(); i++)
                    drawContours(orjImage, contours, i, __s, 3, 8, hierarchy);

            }

            if(biggestIndex >= 0)
            {
                Moments moment = moments((cv::Mat)contours[biggestIndex]);
                double area = moment.m00;

                int xPos = moment.m10 / area;
                int yPos = moment.m01 / area;
                //cout << moment.m10 << "\t" << moment.m01 << endl;

                cout << "Biggest obj: X:" << xPos << "\tY: " << yPos << endl;
            }
        }
        else{
            putText(orjImage, "Cok Fazla Obje Var!", Point(10, 50), 1, 2, Scalar(0, 0, 255));
        }
    }

    //cout << hierarchy.data() << "\t" << hierarchy.size() << endl;
}


int main(int argc, char *argv[])
{
    Mat readImg, hsvImg;
    VideoCapture cap(1);
    if(!cap.isOpened())
    {
      cerr << "Cam cannot open" << endl;
      return -1;
    }

    int iLowH = 19;
    int iHighH = 27;

    int iLowS = 204;
    int iHighS = 255;

    int iLowV = 153;
    int iHighV = 255;

    namedWindow("Control");

    //Create trackbars in "Control" window
    createTrackbar("LowH", "Control", &iLowH, 179); //Hue (0 - 179)
    createTrackbar("HighH", "Control", &iHighH, 179);

    createTrackbar("LowS", "Control", &iLowS, 255); //Saturation (0 - 255)
    createTrackbar("HighS", "Control", &iHighS, 255);

    createTrackbar("LowV", "Control", &iLowV, 255);//Value (0 - 255)
    createTrackbar("HighV", "Control", &iHighV, 255);

#ifdef USE_GPU
    int gpuIdVal = gpu::getDevice();

    if(gpuIdVal >= 0)
    {
        gpu::printShortCudaDeviceInfo(gpuIdVal);
        gpu::setDevice(gpuIdVal);
    }
#endif

    while (1) {

      cv::TickMeter t_meter;
      t_meter.start();

      cap >> readImg;
      if(readImg.empty())
      {
        cerr << "Frame empty!" << endl;
        return -1;
      }

      Mat showImg = Mat::zeros(readImg.size(), readImg.type()), contoursImg = Mat::zeros(readImg.size(), readImg.type());

#ifdef USE_GPU
      gpu::GpuMat readGpuImg(readImg);
      gpu::GpuMat filteredImg, inRangeDst(readImg.rows, readImg.cols, CV_8UC1);

      if(readGpuImg.empty())
      {
          cerr << "Gpu Frame empty!" << endl;
          return -1;
      }

      gpu::cvtColor(readGpuImg, readGpuImg, COLOR_BGR2HSV);

      const int m = 16;
      int numRows = readGpuImg.rows, numCols = readGpuImg.cols;
      if (numRows == 0 || numCols == 0) return;

      const dim3 gridSize(ceil((float)numCols / m), ceil((float)numRows / m), 1);
      const dim3 blockSize(m, m, 1);

      gpu_inRange<<<gridSize, blockSize>>>(readGpuImg, inRangeDst,
                                           iLowH, iHighH, iLowS, iHighS,
                                           iLowV, iHighV);
      //gpu_inRange<<<gridSize, blockSize>>>(readGpuImg, inRangeDst);


      cudaDeviceSynchronize(); CudaCheckError();

      int k_size = 11;

      gpu::bilateralFilter(inRangeDst, filteredImg, k_size, 150, 150);

      filteredImg.download(showImg);
      readGpuImg.download(hsvImg);
#else
      Mat threshImg;
      cvtColor(readImg, hsvImg, CV_BGR2HSV);
      inRange(hsvImg, Scalar(iLowH, iLowS, iLowV), Scalar(iHighH, iHighS, iHighV), threshImg);

      erode(threshImg, threshImg, getStructuringElement(MORPH_ELLIPSE, Size(3, 3)));
      dilate(threshImg, threshImg, getStructuringElement(MORPH_ELLIPSE, Size(8, 8)));

      //morphological closing (fill small holes in the foreground)
      dilate(threshImg, threshImg, getStructuringElement(MORPH_ELLIPSE, Size(8, 8)));
      erode(threshImg, threshImg, getStructuringElement(MORPH_ELLIPSE, Size(3, 3)));

      showImg = threshImg.clone();
#endif

      trackObject(showImg, contoursImg, Scalar(0, 0, 255));

      //imshow("Org Frame", readImg);
      imshow("Obj Frame", readImg);
      //imshow("HSV Frame", hsvImg);
      imshow("Proc Frame", showImg);
      imshow("Contours Frame", contoursImg);

      t_meter.stop();

      cout << "FPS: " <<  1000 / (t_meter.getTimeMilli()) << endl;

      waitKey(10);
    }

    cudaDeviceReset();

    return 0;
}
