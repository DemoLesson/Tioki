v1.1.27 - Oct 10, 2012 12:34PM deployed by Kelly Becker
=======================================================
* c746f20: Kelly Becker - rescue an exception

v1.1.26 - Oct 10, 2012 12:21PM deployed by Kelly Becker
=======================================================
* 7c4298d: Kelly Becker - connection degree

v1.1.25 - Oct 10, 2012 11:57AM deployed by Kelly Becker
=======================================================
* 099135b: Kelly Becker - ordinalized connection degrees
* b535e21: Kelly Becker - connection degree works

v1.1.24 - Oct 10, 2012 10:48AM deployed by Aleks Stanisic
=========================================================
* e8b04e4: Aleks Stanisic - changes to donor choose campaign, made slight changes to subject lines of variuos emails
* 34a932b: Elijah Green - redirect_to the correct page for profiles for linkedin imports
* 8387ab2: Elijah Green - Remove a few invalid character when created a profile url

v1.1.23 - Oct 10, 2012  2:14PM deployed by Kelly Becker
=======================================================
* 01fe959: Kelly Becker - update deploy script
* 7906b7f: Kelly Becker - update deploy script
* f7ca729: Kelly Becker - update deploy script
* 8ab17e1: Kelly Becker - update deploy script
* fd61b8c: Kelly Becker - update deploy script
* 7a10d55: Kelly Becker - update deploy script
* 1053efd: Kelly Becker - update deploy script
* 0eb932c: Kelly Becker - update deploy script

Sorry about the mess have been working on the deploy script a lot

v1.1.22 - Oct 10, 2012  1:58PM deployed by Kelly Becker
=======================================================
* 781e041: Kelly Becker - updated deploy script
* 38cf0b5: Kelly Becker - rearranged joins
* 0be5578: Kelly Becker - total results on analytics
* 5d9d912: Kelly Becker - added progress bars and data to the page
* b5c6226: Elijah Green - Fix up some problems with referrals
* 1afab8f: Kelly Becker - cleaned up how joins were processed;

2012-10-05 11:53am - Deploy by KellyLSB
=======================================
* Global averages :D

2012-10-05 11:53am - Deploy by KellyLSB
=======================================
* Analytics is coming further together needs testing with real data though.

2012-10-04 6:29pm - Deploy by KellyLSB
======================================
* User filtering on analytics

2012-10-04 4:49pm - Deploy by KellyLSB
======================================
* Bug fix with profiles breaking
* Start of analytics sorting

2012-10-04 2:34pm - Deploy by KellyLSB
======================================
* Now you can edit your avatar right on your profile
* Added [Iconic Icon Font](http://somerandomdude.com/work/iconic/)

2012-10-04 12:00pm - Deploy by KellyLSB
=======================================
* VideoJS Scrubber Fix (Again)
* Style fix for teacher dashboard caused by VideoJS Scrubber fix.
* Fix for old Zencoder jobs not returning any data

2012-10-03 7:46pm - Deploy by KellyLSB
======================================
* Added analytics pages

2012-10-03 5:40pm - Deploy by astanisic
=======================================
* Design chnages to profile and edit pages

2012-10-03 4:19pm - Deploy by astanisic
=======================================
* Profile design changes

2012-10-03 4:00pm - Deploy by astanisic
=======================================
* Replacing guestpasscode with public profile

2012-10-03 3:13pm - Deploy by astanisic
=======================================
* Style changes to Whiteboard
* Fix to teacher profile involving the connect button. 

2012-10-03 1:10pm - Deploy by astanisic
=======================================
* Fix to connections results

2012-10-03 12:43pm - Deploy by KellyLSB
=======================================
* Skill detail page now shows off the teachers and videos with that skill

2012-10-02 4:40pm - Deploy by KellyLSB
======================================
* Added skills to videos
* After a video is uploaded immediately take to edit page
* Installed the framework for video favorites

2012-10-02 4:55pm - Deploy by astanisic
=======================================
* Fixes to help box in profile

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
