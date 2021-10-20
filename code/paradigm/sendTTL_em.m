function ttlLog = sendTTL_em(message,serialPort,dio,eyelink,timeSinceStart,ttlLog,maxTTL)
if ~exist('maxTTL','var') || isempty(maxTTL)
    maxTTL = 100;
end
daqNum = mod(size(ttlLog,1),maxTTL);
if daqNum==0;daqNum = maxTTL;end

%% print message and timestamp to screen, for diary
disp([message,' at ',num2str(timeSinceStart),', (',num2str(daqNum),')'])

%% send message via serial port
if ~isempty(serialPort);
    % ensure it's a string
    if isempty(message)
        message = char('.');
        disp('empty!');
    else
        if ~ischar(message)
            if isnumeric(message)
                message=char(num2str(message)); % ensure numeric messages get converted to strings. Otherwise ASCII format will be messed up
                %if empty message is sent in, just send in a dot.
            elseif islogical(message)
                if message
                    message =char('true');
                else
                    message =char('false');
                end
            else
                display('undefined message type...');% send
            end
        end
        
    end
    message2 = [char(2),message];
    
    % send mac or pc ttls
    if(strfind(computer,'WIN'))             
        fprintf(serialPort,message2);
    else (strfind(computer,'MAC'));        
        [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime]=...
            IOPort('Write',serialPort,message2,1); % write message to serial port. CHECK IF THIS FINISHES BEFORE NEXT MATLAB COMMAND OR RUNS IN PARALLEL (so dont have to wait for whole thing to send)
%         if(isempty(errmsg))
%             error(errmsg);
%         end
    end

end;

%% send message to eye tracker
if ~isempty(eyelink)
    Eyelink('Message', message); % send info about block #
    Eyelink('command', ['record_status_message "',message,'"']);% This supplies the title at the bottom of the eyetracker display
end

%% send a backup timestamp via daq in case serial port TTLs get dropped
if ~isempty(dio)
    DaqDOut(dio,0,daqNum); WaitSecs(0.03); DaqDOut(dio,0,0);
end
%% add TTL to ttlLog
ttlLog{end+1,1} = timeSinceStart;
ttlLog{end,2} = message;
ttlLog{end,3} = daqNum;
