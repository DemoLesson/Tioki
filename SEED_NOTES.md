2012-10-02 4:40pm - Deploy by KellyLSB
======================================
* Added ability to feature videos
* Update snippet creation page
* Removed video_embed_code/url from teachers table

2012-10-02 3:44pm - Deploy by astanisic
=======================================
* Changes to twitter share fucntion on invite conenctions page. 

2012-10-02 2:00pm - Deploy by KellyLSB
======================================
* Testing version bumping

2012-10-02 1:17pm - Deploy by astanisic
======================================== 
* Fix to invite connections page

2012-10-02 12:09pm - Deploy by astanisic
======================================== 
* Bugs
	- array access on nill class fixed
	- teacher on nil class fixed
	- strptime format issues fixed
	- teacher not found error (in progress)
	- Northgravity imagemagick issue fixed
	
* Profile urls now go to /profile/:url
* Awards added to teachers
* Presentations added to teachers
* Profile and credential design changes
* Variuos static page design changes 

2012-10-01 8:17pm - Deploy by astanisic
======================================== 
* Changed placeholder text in events serach bar. 

2012-10-01 7:00pm - Deploy by KellyLSB
======================================
* Videos now have thumbnails generated if zencoder

2012-10-01 5:09pm - Deploy by KellyLSB
======================================
* Admin page updates by Elijah Green
* Jcrop by Elijah Green
* Metrics and Ab language testing
* New users with id's divisible by 2 will have 'follow' abtest

2012-10-01 12:40pm - Deploy by astanisic
======================================== 
* Users adding connections will be redirected to the page where connection was requested. 

2012-10-01 12:23pm - Deploy by astanisic
======================================== 
* Adding language structure
* Fixing credential error

2012-10-01 12:15pm - Deploy by astanisic
========================================
* Connections on profile page do not show pending connections
* Changes to connections search engine

2012-10-01 10:00am - Deploy by KellyLSB
=======================================
* Deployed a fix by Elijah Green emptying the @my_connections array if not logged in.
* Fixed an issue with allowing embedding bad video urls

2012-09-29 6:33pm - Deploy by astanisic
======================================= 
* Style fix to teacher dashboard. 

2012-09-29 6:16pm - Deploy by astanisic
======================================= 
* Reverting last deploy. 

2012-09-29 6:04pm - Deploy by astanisic
======================================= 
* Fixes to video model

2012-09-29 3:48pm - Deploy by KellyLSB
======================================
* Added title and description editing for videos
* Allowing deletion of videos

2012-09-29 1:33pm - Deploy by KellyLSB
======================================
* Added multiple videos
* Added global video library
* Added user video library

### Todo
* Allow featuring a video
* Video comments, and starring
* Video privacy (connections, schools, members)

2012-09-28 9:31pm - Deploy by astanisic
=======================================
* Added Brian's changes to Proifle and Edit profile
* Commented out content from video library page

2012-09-28 5:44pm - Deploy by KellyLSB
======================================
* Introduced the framework for multiple videos
	- Made all the videos (including youtube) Video models
	- Re organized the video model / working on slimming the code down
* Re setup video.js after fixing the css bug breaking it
