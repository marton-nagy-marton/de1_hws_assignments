use birdstrikes;

-- EXERCISE 1:
select aircraft, airline, speed,
	if(speed is null,'0_speed not defined',
		if(speed = 0,'1_stationary',
			if(speed > 0 and speed < (select avg(speed) from birdstrikes),'2_under average speed','3_above average speed')))
    as speed_category
from birdstrikes
order by speed_category, speed ASC;

-- EXERCISE 2:
select count(distinct aircraft) from birdstrikes;
-- 3

-- EXERCISE 3:
select min(speed) from birdstrikes where aircraft like 'h%';
-- 9

-- EXERCISE 4:
select phase_of_flight, count(*) as count from birdstrikes group by phase_of_flight order by count limit 1;
-- Taxi, 2

-- EXERCISE 5:
select phase_of_flight, round(avg(cost),0) as avg_cost_round from birdstrikes group by phase_of_flight order by avg_cost_round desc limit 1;
-- climb, 54673

-- EXERCISE 6:
select state, avg(speed) as avg_speed from birdstrikes group by state having length(state) < 5 order by avg_speed desc limit 1;
-- Iowa, 2862.5