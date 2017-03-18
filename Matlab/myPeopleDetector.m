peopleDetector = vision.PeopleDetector('ClassificationThreshold',0,'MergeDetections',false);

I = imread('people.jpg');
[bbox, score] = step(peopleDetector, I);
I1 = insertObjectAnnotation(I, 'rectangle', bbox, cellstr(num2str(score)), 'Color', 'r');

[selectedBbox, selectedScore] = selectStrongestBbox(bbox, score);
I2 = insertObjectAnnotation(I, 'rectangle', selectedBbox, cellstr(num2str(selectedScore)), 'Color', 'r');

figure, imshow(I1); title('Detected people and detection scores before suppression');
figure, imshow(I2); title('Detected people and detection scores after suppression');