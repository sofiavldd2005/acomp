% Importar a imagem para a WORKSPACE do MATLAB
n=200;
m=200;

A = imread('image_test_4.jpg');

if size(A, 3) == 3
    gA = rgb2gray(A);
end

Ar = imresize(gA, [n m]);

B = Ar > 115;  %modify for better imahge

figure(1);
imshow(A);
figure(2);
imshow(B);

C=string.empty;

for i=1:n
    for j=1:m
       
       if B(i,j)==0

           C(i,j)="0x01";

       else 
           C(i,j)="0x00";
       end
    end
end

C(:, m+1)="0xff";

D = reshape(C.',1,[]);


