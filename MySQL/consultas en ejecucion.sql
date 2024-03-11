SELECT id, user, host, time, state, info 
FROM information_schema.processlist 
WHERE command != 'Sleep' ORDER BY time asc, id;

SELECT user, time, state, LEFT(info,40) 
FROM information_schema.processlist 
WHERE command != 'Sleep' 
AND time >= 2 
ORDER BY time DESC, id;

