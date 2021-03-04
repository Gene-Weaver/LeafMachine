%%%     Test Images Following CNN Training
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

%CNNTestImage(net,name,cpu_gpu,high_low,show,nClasses)
function CNNTestImage(net,name,image,cpu_gpu,show,nClasses)
    reset(gpuDevice)
    pause(1)
    myaddress = 'WW.Matlab@gmail.com';
    mypassword = '5Yc8BdsYrJd5q2DsT9yaGQ9u';
    setpref('Internet','E_mail',myaddress);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',myaddress);
    setpref('Internet','SMTP_Password',mypassword);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
        'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    %name = char(strcat(name,'.jpg'));
    addpath('SandboxFunctions');
    
%     if high_low == "high"
%         image = imread('Asteraceae_Piptocarpha_oblonga.jpg');
%     elseif high_low == "medium"
%         image = imread('Fagaceae_Quercus_alba1.JPG');
%     else
%         %image = imread('Salicacea_Populus_tremuloides_10.jpg');
%         image = imread('Fagaceae_Quercus_alba.JPG');
%     end
    %high_image = imread('Asteraceae_Piptocarpha_oblonga.jpg');
    %med_image = imread('Fagaceae_Quercus_alba1.JPG');
    %low_image = imread('Salicacea_Populus_tremuloides_10.jpg');
    image = imread(image);
    if cpu_gpu == "cpu"
        [C,~,~] = semanticseg(image,net,'ExecutionEnvironment','cpu');
    else
        [C,~,~] = semanticseg(image,net);
    end
    
    B = labeloverlay(image,C);
    
    Stem = C == 'Stem';
    Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
    Leaf = C == 'Leaf';
    Leaf = 255 * repmat(uint8(Leaf), 1, 1, 3);
    Text_Black = C == 'Text_Black';
    Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
    Text_White = C == 'Text_White';
    Text_White = 255 * repmat(uint8(Text_White), 1, 1, 3);
    Fruit_Flower = C == 'Fruit_Flower';
    Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
    Background = C == 'Background';
    Background = 255 * repmat(uint8(Background), 1, 1, 3);
    Colorblock = C == 'Colorblock';
    Colorblock = 255 * repmat(uint8(Colorblock), 1, 1, 3);
    
    if nClasses == 7
        PLOT = [image,Leaf,Stem,Text_Black,image;
            B,Text_White,Fruit_Flower,Background,Colorblock];
    elseif nClasses == 6
        PLOT = [image,Leaf,Stem,Text_Black;
            B,Text_White,Fruit_Flower,Colorblock];
    else
        PLOT = [image,Leaf,Stem,Text_Black,image;
            B,Text_White,Fruit_Flower,Background,Colorblock];
    end
    if show == "show"
        imshow(PLOT)
        imwrite(PLOT,name);
    elseif show == "email"
        imwrite(PLOT,name);
        sendmail('william.weaver@colorado.edu','Finished','',name)
    end
end




