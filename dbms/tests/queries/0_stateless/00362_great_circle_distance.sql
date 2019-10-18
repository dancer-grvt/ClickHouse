SELECT floor(greatCircleDistance(33.3, 55.3, 33.3, 55.3)) AS distance;
-- consts are from vincenty formula from geopy
-- k = '158.756175, 53.006373'
-- u = '37.531014, 55.703050'
-- y = '37.588144, 55.733842'
-- m = '37.617780, 55.755830'
-- n = '83.089598, 54.842461'
select abs(greatCircleDistance(37.531014, 55.703050, 37.588144, 55.733842) - 4964.25740448) / 4964.25740448 < 0.004
select abs(greatCircleDistance(37.531014, 55.703050, 37.617780, 55.755830) - 8015.52288508) / 8015.52288508 < 0.004
select abs(greatCircleDistance(37.588144, 55.733842, 37.617780, 55.755830) - 3075.27332275) / 3075.27332275 < 0.004
select abs(greatCircleDistance(83.089598, 54.842461, 37.617780, 55.755830) - 2837839.72863) / 2837839.72863 < 0.004
select abs(greatCircleDistance(37.617780, 55.755830, 158.756175, 53.006373) - 6802821.68814) / 6802821.68814 < 0.004
select abs(greatCircleDistance(83.089598, 54.842461, 158.756175, 53.006373) - 4727216.39539) / 4727216.39539 < 0.004
