%%%     Email Test Images Following CNN Training
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function sendEmailOnFailure(subject,text,image)
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

    imwrite(image,fullfile(tempdir(),'image.jpg'));
    try
    sendmail('william.weaver@colorado.edu',...
            subject,text,fullfile(tempdir(),'image.jpg'));
    catch
        sendmail('william.weaver@colorado.edu',...
            subject,text);
    end
end




