/* =====================================================================
   SOCIAL MEDIA (IG CLONE) — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE ig_clone;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1.
-- Are there any tables with duplicate or missing null values? If so, how
-- would you handle them?

	-- code 
    -- 1. Duplicate check
    USE ig_clone;
    SELECT 
		id, COUNT(*) AS duplicate_count 
	FROM users
	GROUP BY id
	HAVING COUNT(*) > 1;

-- 2 null check 

SELECT
SUM(CASE WHEN username IS NULL THEN 1 ELSE 0 END) AS null_usernames,
SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_date
FROM users;

-- O2.
-- What is the distribution of user activity levels (e.g., number of posts,
-- likes, comments) across the user base?

-- Code part: 
USE ig_clone;
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(DISTINCT p.id) AS post_counts,
    COUNT(DISTINCT l.photo_id) AS like_counts,
    COUNT(DISTINCT c.id) AS comment_counts
	FROM users u
	LEFT JOIN photos p ON u.id = p.user_id
	LEFT JOIN likes l ON u.id = l.user_id
	LEFT JOIN comments c ON u.id = c.user_id
	GROUP BY u.id, u.username
	ORDER BY post_counts DESC;



-- O3.
-- Calculate the average number of tags per post (photo_tags and photos
-- tables).

-- Code part :
USE ig_clone;
SELECT round(AVG(tag_count),2) AS avg_tags_per_post
FROM (
    SELECT p.id,
           COUNT(pt.tag_id) AS tag_count
    FROM photos p
    LEFT JOIN photo_tags pt ON pt.photo_id = p.id
    GROUP BY p.id
) AS photo_tag_counts


-- O4.
-- Identify the top users with the highest engagement rates (likes, comments)
-- on their posts and rank them.
-- code part
USE ig_clone;

SELECT 
username,
    total_likes,
    total_comments,
    total_likes + total_comments AS total_engagement,
    RANK() OVER (
        ORDER BY total_likes + total_comments DESC
    ) AS user_rank
FROM (
    SELECT
        u.id,
        u.username,
        COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
        COUNT(DISTINCT c.id) AS total_comments
    FROM users u
    JOIN photos p ON u.id = p.user_id
    LEFT JOIN likes l ON p.id = l.photo_id
    LEFT JOIN comments c ON p.id = c.photo_id
    GROUP BY u.id, u.username
) AS user_engagement
ORDER BY user_rank
LIMIT 15;



-- O5.
-- Which users have the highest number of followers and followings?
-- Code part : 
USE ig_clone;
SELECT 
	  u.id AS user_id,
	  u.username,
	  COUNT(DISTINCT f.followee_id) AS following_count,
	  COUNT(DISTINCT f2.follower_id) AS follower_count
	FROM users u
	LEFT JOIN follows f ON u.id = f.follower_id
	LEFT JOIN follows f2 ON u.id = f2.followee_id
	GROUP BY u.id, u.username
	ORDER BY follower_count desc;



-- O6.
-- Calculate the average engagement rate (likes, comments) per post for each
-- user.

-- Code part :
USE ig_clone;
SELECT 
		u.id AS user_id,
		u.username,
		AVG(post_engagement) AS avg_engagement_rate
	FROM (
		SELECT p.user_id, p.id AS post_id,
			   (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS post_engagement
		FROM photos p
		LEFT JOIN likes l ON p.id = l.photo_id
		LEFT JOIN comments c ON p.id = c.photo_id
		GROUP BY p.user_id, p.id
	) AS engagement_summary
	JOIN users u ON u.id = engagement_summary.user_id
	GROUP BY u.id, u.username
	ORDER BY avg_engagement_rate DESC;




-- O7.
-- Get the list of users who have never liked any post (users and likes
-- tables)

-- Code part :
USE ig_clone;
SELECT 
	id,
	username
FROM users
WHERE id NOT IN (SELECT user_id FROM likes);


-- O8.
-- How can you leverage user-generated content (posts, hashtags, photo tags)
-- to create more personalized and engaging ad campaigns?

-- Code part:
USE ig_clone;
SELECT u.id AS user_id,
       u.username,
       t.tag_name,
       COUNT(p.id) AS tag_usage,
       SUM((SELECT COUNT(*) FROM likes l 
       WHERE l.photo_id = p.id))AS total_likes_received,
       SUM((SELECT COUNT(*) FROM comments c 
       WHERE c.photo_id = p.id))AS total_comments_received,
       SUM((SELECT COUNT(*) FROM likes l 
       WHERE l.photo_id = p.id))
     + SUM((SELECT COUNT(*) FROM comments c 
     WHERE c.photo_id = p.id))AS total_engagement
FROM users u
JOIN photos p
ON p.user_id = u.id
JOIN photo_tags pt 
ON pt.photo_id = p.id
JOIN tags t
ON t.id = pt.tag_id
GROUP BY u.id, u.username, t.tag_name
ORDER BY total_engagement DESC, tag_usage DESC;



-- O9.
-- Are there any correlations between user activity levels and specific
-- content types (e.g., photos, videos, reels)? How can this information
-- guide content creation and curation strategies?

-- Code Part
USE ig_clone;
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(DISTINCT p.id) AS total_photos,
    COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments,
    ROUND(
        (COUNT(DISTINCT l.user_id, l.photo_id) 
        + COUNT(DISTINCT c.id)) 
        / NULLIF(COUNT(DISTINCT p.id), 0),
        2
    ) AS avg_engagement_per_photo
FROM users u
LEFT JOIN photos p 
    ON u.id = p.user_id
LEFT JOIN likes l 
    ON p.id = l.photo_id
LEFT JOIN comments c 
    ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY avg_engagement_per_photo DESC; 


-- O10.
-- Calculate the total number of likes, comments, and photo tags for each
-- user.
-- code part
USE ig_clone;
SELECT 
	u.id AS user_id,
    u.username,
    COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments,
    COUNT(DISTINCT pt.tag_id, pt.photo_id) AS total_photo_tags
FROM users u
LEFT JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
LEFT JOIN photo_tags pt
    ON p.id = pt.photo_id
GROUP BY u.id, u.username
ORDER BY u.id;



-- O11.
-- Rank users based on their total engagement (likes, comments, shares) over a
-- month.
-- code part 
USE ig_clone;
	SELECT 
		u.id AS user_id,
		u.username,
		COUNT(DISTINCT l.photo_id) AS total_likes,
		COUNT(DISTINCT c.id) AS total_comments,
		(COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id)) AS total_engagement,
		RANK() OVER (ORDER BY (COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id)) DESC) AS engagement_rank
	FROM users u
	LEFT JOIN photos p ON u.id = p.user_id
	LEFT JOIN likes l ON p.id = l.photo_id
	LEFT JOIN comments c ON p.id = c.photo_id
	GROUP BY u.id, u.username
	ORDER BY total_engagement DESC;

-- O12.
-- Retrieve the hashtags that have been used in posts with the highest average
-- number of likes. Use a CTE to calculate the average likes for each
-- hashtag first.

-- code part 
USE ig_clone;
WITH hashtag_likes AS (
    SELECT
        t.id AS tag_id,
        t.tag_name,
        p.id AS photo_id,
        COUNT(l.user_id) AS like_count
    FROM tags t
    JOIN photo_tags pt
        ON t.id = pt.tag_id
    JOIN photos p
        ON pt.photo_id = p.id
    LEFT JOIN likes l
        ON p.id = l.photo_id
    GROUP BY t.id, t.tag_name, p.id
),
avg_hashtag_likes AS (
    SELECT
        tag_id,
        tag_name,
        AVG(like_count) AS avg_likes
    FROM hashtag_likes
    GROUP BY tag_id, tag_name
)
SELECT
    tag_name,
    ROUND(avg_likes, 2) AS avg_likes
FROM avg_hashtag_likes
ORDER BY avg_likes DESC
LIMIT 10;


-- O13.
-- Retrieve the users who have started following someone after being followed
-- by that person.

-- code part 
USE ig_clone;
SELECT
    f1.follower_id AS user_id,
    f1.followee_id AS followed_back_user
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id;

/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1.
-- Based on user engagement and activity levels, which users would you
-- consider the most loyal or valuable? How would you reward or incentivize
-- these users?

-- code part 
USE ig_clone;
SELECT
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments,
    COUNT(DISTINCT l.user_id, l.photo_id)
        + COUNT(DISTINCT c.id) AS engagement_score
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY engagement_score DESC
LIMIT 10;

-- S2.
-- For inactive users, what strategies would you recommend to re-engage them
-- and encourage them to start posting or engaging again?
-- code part 
USE ig_clone;
SELECT u.id, u.username
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
WHERE p.id IS NULL
  AND l.user_id IS NULL
  AND c.user_id IS NULL;


-- S3.
-- Which hashtags or content topics have the highest engagement rates? How can
-- this information guide content strategy and ad campaigns?

-- code part 
USE ig_clone;
SELECT
    t.tag_name,
    COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments,
    ROW_NUMBER() OVER (
        ORDER BY COUNT(DISTINCT l.user_id, l.photo_id)
               + COUNT(DISTINCT c.id) DESC
    ) AS row_num
FROM tags t
JOIN photo_tags pt ON t.id = pt.tag_id
LEFT JOIN likes l ON pt.photo_id = l.photo_id
LEFT JOIN comments c ON pt.photo_id = c.photo_id
GROUP BY t.id, t.tag_name
ORDER BY row_num
LIMIT 10;



-- S4.
-- Are there any patterns or trends in user engagement based on demographics
-- (age, location, gender) or posting times? How can these insights inform
-- targeted marketing campaigns?
-- code part 
USE ig_clone;
SELECT
    HOUR(p.created_dat) AS post_hour,
    COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY post_hour
ORDER BY total_likes + total_comments DESC;

-- S5.
-- Based on follower counts and engagement rates, which users would be ideal
-- candidates for influencer marketing campaigns? How would you approach
-- and collaborate with these influencers?

-- code part 
USE ig_clone;
SELECT
    username,
    followers,
    total_likes,
    total_comments,
    ROUND(
        (total_likes + total_comments) * 100.0
        / NULLIF(followers, 0), 2
    ) AS engagement_rate
FROM (
    SELECT
        u.id,
        u.username,
        (SELECT COUNT(*)
         FROM follows f
         WHERE f.followee_id = u.id) AS followers,

        (SELECT COUNT(*)
         FROM likes l
         JOIN photos p ON p.id = l.photo_id
         WHERE p.user_id = u.id) AS total_likes,

        (SELECT COUNT(*)
         FROM comments c
         JOIN photos p ON p.id = c.photo_id
         WHERE p.user_id = u.id) AS total_comments

    FROM users u
) AS user_stats
ORDER BY engagement_rate DESC
LIMIT 10;


-- S6.
-- Based on user behavior and engagement data, how would you segment the user
-- base for targeted marketing campaigns or personalized recommendations?

-- code part 
USE ig_clone;
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS posts,
    COUNT(DISTINCT l.user_id, l.photo_id) AS likes,
    COUNT(DISTINCT c.id) AS comments,
    CASE
        WHEN COUNT(DISTINCT p.id)
           + COUNT(DISTINCT l.user_id, l.photo_id)
           + COUNT(DISTINCT c.id) = 0 THEN 'Inactive'
        WHEN COUNT(DISTINCT p.id)
           + COUNT(DISTINCT l.user_id, l.photo_id)
           + COUNT(DISTINCT c.id) <= 10 THEN 'Low Activity'
        ELSE 'Active'
    END AS user_segment
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username;


-- S7.
-- If data on ad campaigns (impressions, clicks, conversions) is available,
-- how would you measure their effectiveness and optimize future campaigns?

-- Answer
-- Since my current database does not contain ad campaign data such as impressions,
-- clicks, and conversions, I cannot calculate campaign effectiveness directly using this database.

-- I have prepared a detailed approach, insights, recommendations, and conclusion for this question in a Word document file.


-- S8.
-- How can you use user activity data to identify potential brand ambassadors
-- or advocates who could help promote Instagram's initiatives or events?

-- code part
USE ig_clone;
SELECT
    u.id AS user_id,
    u.username,
    (
        SELECT COUNT(*)
        FROM follows f
        WHERE f.followee_id = u.id
    ) AS follower_count,
    (
        SELECT COUNT(*)
        FROM likes l
        JOIN photos p ON l.photo_id = p.id
        WHERE p.user_id = u.id
    ) AS total_likes,
    (
        SELECT COUNT(*)
        FROM comments c
        JOIN photos p ON c.photo_id = p.id
        WHERE p.user_id = u.id
    ) AS total_comments,
    (
        SELECT COUNT(*)
        FROM likes l
        JOIN photos p ON l.photo_id = p.id
        WHERE p.user_id = u.id
    ) +
    (
        SELECT COUNT(*)
        FROM comments c
        JOIN photos p ON c.photo_id = p.id
        WHERE p.user_id = u.id
    ) AS engagement_score
FROM users u
ORDER BY engagement_score DESC, follower_count DESC
LIMIT 10;

-- S9.
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?

-- code part 
USE ig_clone;
WITH follower_counts AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS follower_count
    FROM follows
    GROUP BY followee_id
),
post_counts AS (
    SELECT
        user_id,
        COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
),
like_counts AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_likes
    FROM photos p
    JOIN likes l ON p.id = l.photo_id
    GROUP BY p.user_id
),
comment_counts AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_comments
    FROM photos p
    JOIN comments c ON p.id = c.photo_id
    GROUP BY p.user_id
)
SELECT
    u.id AS user_id,
    u.username,
    COALESCE(f.follower_count, 0) AS follower_count,
    COALESCE(p.total_posts, 0) AS total_posts,
    COALESCE(l.total_likes, 0) AS total_likes,
    COALESCE(c.total_comments, 0) AS total_comments,
    COALESCE(l.total_likes, 0)
        + COALESCE(c.total_comments, 0) AS engagement_score
FROM users u
LEFT JOIN follower_counts f ON u.id = f.user_id
LEFT JOIN post_counts p ON u.id = p.user_id
LEFT JOIN like_counts l ON u.id = l.user_id
LEFT JOIN comment_counts c ON u.id = c.user_id
ORDER BY engagement_score DESC, follower_count DESC
LIMIT 10;

-- S10.
-- Assuming there's a "User_Interactions" table tracking user engagements, how
-- can you update the "Engagement_Type" column to change all instances of
-- "Like" to "Heart" to align with Instagram's terminology?

-- Answer:

-- The User_Interactions table is not available in my current database. Therefore,
-- I am unable to update the Engagement_Type column. A detailed explanation of this limitation
-- and the proposed solution is included in my Question & Answer Word document.

/* ===================================== END OF FILE ===================================== */
