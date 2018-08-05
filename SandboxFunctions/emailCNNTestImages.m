%%%     Email Test Images Following CNN Training
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function emailCNNTestImages(net,name,cpu_gpu,high_low)
    pause(1)
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

    name = char(strcat(name,'.jpg'));
    addpath('SandboxFunctions');
    
    testImage1 = imread('Asteraceae_Wyethia_helianthoides.jpg');
    testImage2 = imread('Cactaceae_Opuntia_phaeacantha.jpg');
    testImage3 = imread('Salicacea_Populus_tremuloides_10.jpg');
    testImage4 = imread('Poaceae_Agrostis_idahoensis.jpg');
    testImage5 = imread('Fagaceae_Quercus_alba.JPG');
    
    high_image = imread('Asteraceae_Piptocarpha_oblonga.jpg');
    low_image = testImage5;
    
    testSet = {
        testImage1
        testImage2
        testImage3
        testImage4
        testImage5};
    if cpu_gpu == "cpu"
        if high_low == "high"
            [C,~,~] = semanticseg(high_image,net,'ExecutionEnvironment','cpu');
            B = labeloverlay(high_image,C);
            imwrite(B,name);
            sendmail('william.weaver@colorado.edu',...
            'Finished','',...
            name)
        else
            [C,~,~] = semanticseg(low_image,net,'ExecutionEnvironment','cpu');
            B = labeloverlay(low_image,C);
            imwrite(B,name);
            sendmail('william.weaver@colorado.edu',...
            'Finished','',...
            name)
        end
    else
        for i = 1:length(testSet)
            image = cell2mat(testSet(i));
            [C,~,~] = semanticseg(image,net);
            B = labeloverlay(image,C);
            imwrite(B,name);
            sendmail('william.weaver@colorado.edu',...
            'Finished','',...
            name)
            pause(1)
            reset(gpuDevice)
            pause(1)
        end
    end
    
    

end




