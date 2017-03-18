cmake_minimum_required(VERSION 2.8)

project(colorDetectCuda)

aux_source_directory(./src SRC_LIST)

find_package(OpenCV 2.4.13)
find_package(CUDA REQUIRED)

set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    )

include_directories(include ${OpenCV_INCLUDE_DIRS} ${CUDA_INCLUDE_DIRS})
cuda_add_executable(${PROJECT_NAME} src/main.cu)

#cuda_add_library(LBP ${LIB_SOURCES} ${LIB_HEADERS} )
target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBRARIES} ${CUDA_LIBRARIES})

file( GLOB LIB_SOURCES lib/*.cpp )
file( GLOB LIB_HEADERS lib/*.h )
file( GLOB LIB_SOURCES lib/*.cu )

set(CMAKE_BUILD_TYPE Debug)

#add_library(PID ${LIB_SOURCES} ${LIB_HEADERS} )
