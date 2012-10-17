v1.3.17 - Oct 17, 2012 12:22PM deployed by Kelly Becker
=======================================================
* ba9e5cd: Kelly Becker - user updated avatar whiteboard post back in with new language
* d51a1ef: Kelly Becker - rate limit whiteboard posts if similar
* 688b44e: Kelly Becker - show how many favorites there are for whiteboard posts

v1.3.16 - Oct 17, 2012  9:49AM deployed by Aleks Stanisic
=========================================================
* ceb9aaf: Kelly Becker - fixed twitter images
* 2995b96: Brian Martinez - splash page changes to text and scroll wheel
* d9d7ecb: Brian Martinez - Splash page changes, New Splash Header with links, changes to press page
* 6ff673e: Kelly Becker - favoriting whiteboard posts
* a96448d: Kelly Becker - gemlock
* 706ea83: Kelly Becker - destroyed staging

v1.3.15 - Oct 15, 2012  4:45PM deployed by Aleks Stanisic
=========================================================
* 9c804dc: Elijah Green - Fix picture uploading for schools and technologies

v1.3.14 - Oct 15, 2012  4:26PM deployed by Aleks Stanisic
=========================================================
* a8c088b: Elijah Green - Can now also upload pngs
* bc64392: Elijah Green - Fix file uploads for user avatars

v1.3.13 - Oct 15, 2012  1:16PM deployed by Aleks Stanisic
=========================================================
* 64f8d39: Aleks Stanisic - slight bug fixes to twitter links
* 19a439e: Elijah Green - Make technologies public

v1.3.12 - Oct 13, 2012  9:03PM deployed by Aleks Stanisic
=========================================================
* 331efda: Aleks Stanisic - added help windows to dashboard, technologies, skills pages

v1.3.11 - Oct 13, 2012  5:58PM deployed by Kelly Becker
=======================================================
* c44f626: Kelly Becker - allow logging of analytics from a url get var as well as ab test. we gotta find better ways to do this when were not so overloaded
* a2cacb3: Kelly Becker - added group (namespaces) to analytics. by default it is root its mostly for querying purposes
* 4efcc9b: Elijah Green - If my_Conections is viewed and that it has happened in the session
* 22e242e: Elijah Green - Add simple editing like hyperlinks to presentation descriptions
* 2b1671b: Kelly Becker - when you click the login button lets auto focus the email box

v1.3.10 - Oct 13, 2012  2:17PM deployed by Kelly Becker
=======================================================
* 875aa0e: Kelly Becker - gemlock
* 8408914: Kelly Becker - daemons gem
* 48f30b8: Kelly Becker - staging server and allow deploying alternate branches if not deploying production
* b618f8e: Kelly Becker - db schema
* d4db734: Kelly Becker - fix to a rubber update
* f028746: Kelly Becker - changes
* 7b12d88: Elijah Green - Add starting delayed_job to deploy
* 75b8c5e: Elijah Green - fix user_mailer crashing because of errors
* 897059f: Elijah Green - Add all functional aspects of the delayed vouch emails

v1.3.9 - Oct 12, 2012 12:14PM deployed by Kelly Becker
======================================================
* 11c31f8: Kelly Becker - destroyed staging instance
* 12c433d: Kelly Becker - updates to deploy script that allow for rolling back code and deploying without restartig nginx
* fd3b702: Kelly Becker - updates to deploy script that allow for rolling back code and deploying without restartig nginx
* 514fc40: Kelly Becker - pointing nginx at the symlink instead
* 3247df7: Kelly Becker - testing rollback

v1.3.8 - Oct 12, 2012 11:10AM deployed by Kelly Becker
======================================================
* 846c9cb: Kelly Becker - fix to analytics breaking when log was made by a guest
* a5f1fe4: Kelly Becker - session_id not session

v1.3.7 - Oct 12, 2012 10:56AM deployed by Kelly Becker
======================================================
* f3b2a9c: Kelly Becker - Added session ids to logs
* 6c5c98d: Elijah Green - when changing email show errors and redirect to root
* 681379a: Kelly Becker - pathfile
* 4e34804: Kelly Becker - got xlsx export working on users pagination removal is proving troublesome though.
* 168ef76: Kelly Becker - label alterations

v1.3.6 - Oct 11, 2012  4:15PM deployed by Kelly Becker
======================================================
* a05d0c1: Kelly Becker - made the query a bit more accurate with dates

v1.3.5 - Oct 11, 2012  3:28PM deployed by Kelly Becker
======================================================
* b68369b: Kelly Becker - slugs analytics page

v1.3.4 - Oct 11, 2012  2:35PM deployed by Kelly Becker
======================================================
* 357e204: Kelly Becker - converted file to tabs
* e994faa: Kelly Becker - technology analytics now being collected
* 829b518: Kelly Becker - branch is being determined proeprly now

v1.3.3 - Oct 11, 2012  1:58PM deployed by Aleks Stanisic
========================================================
* 35b66cc: Aleks Stanisic - changes to edit, profile, technologies
* 3efa11b: Kelly Becker - update to deploy script
* 5b0a2db: Kelly Becker - undo rolling restarts
* 7e17f9e: Kelly Becker - trying something new (for deploying faster)
* 40a2bfc: Kelly Becker - trying this again (to make deploys faster)
* 676a672: Kelly Becker - testing making deploys faster

v1.3.2 - Oct 11, 2012 11:50AM deployed by Kelly Becker
======================================================
* fbaf9ce: Kelly Becker - videos admin searching and sorting

v1.3.1 - Oct 11, 2012 11:08AM deployed by Kelly Becker
======================================================
* 0085884: Kelly Becker - edit videos

v1.3.0 - Oct 10, 2012  9:46PM deployed by Aleks Stanisic
========================================================
* 11dd88e: Aleks Stanisic - adding function to tech suggestion
* 1f7ecc2: Brian Martinez - tech tags and teacherskills pages
* 74f9b1e: Brian Martinez - technology changes for site
* ae8e012: Elijah Green - Add technology suggestion
* b32ae8b: Elijah Green - Slight changes for the technologies on some pages
* 37bc466: Elijah Green - Add technologies to profile
* b80f028: Elijah Green - Add the rest of the technology pages
* befe419: Elijah Green - add picture and add an index of technologies
* 9575974: Elijah Green - Add functions for teahers to add technologies
* ef21a27: Elijah Green - Add tags to technology
* 4b26c5c: Elijah Green - Add technology creation
* abf666e: Elijah Green - Add form to create and has_many associations.
* e8815e4: Elijah Green - Add migrations for technologies

v1.2.12 - Oct 10, 2012  6:31PM deployed by Aleks Stanisic
=========================================================
* f57176f: Elijah Green - Add search on skills
* 10e3926: Elijah Green - Add chosen select drop downs

v1.2.11 - Oct 10, 2012  5:14PM deployed by Kelly Becker
=======================================================
* e843e6f: Kelly Becker - whoops this fixes the issue with connections

v1.2.10 - Oct 10, 2012  4:36PM deployed by Kelly Becker
=======================================================
* a9e45a7: Kelly Becker - connection suggestion analytic is now being saved
* 481a691: Kelly Becker - staging server terminated
* d5f3534: Kelly Becker - deploy script update to allow developing during a deploy
* 6cffcfc: Kelly Becker - fire.js
* 6e1651d: Kelly Becker - working on fire
* 198f841: Kelly Becker - skills suggestions based on skills

v1.2.9 - Oct 10, 2012  2:47PM deployed by Aleks Stanisic
========================================================
* a603c89: Kelly Becker - deploy tasks
* 7cc54cf: Kelly Becker - deploy script updates
* ca07d3e: Kelly Becker - working on deploy changes
* ff0a81a: Kelly Becker - save

v1.2.8 - Oct 10, 2012  1:08PM deployed by Aleks Stanisic
========================================================
* 84bad23: Kelly Becker - renamed all test to staging
* cd28e0f: Kelly Becker - edited some items
* 26e2d2b: Elijah Green - Change date formatting on admin pages
* fac0ee0: Kelly Becker - logout fix
* e1d5a7f: Kelly Becker - logout fix
* a4f2925: Kelly Becker - remove dump

v1.2.7 - Oct 10, 2012 10:20AM deployed by Kelly Becker
======================================================
* 13bc937: Kelly Becker - user.current works now

v1.2.6 - Oct 10, 2012  9:52AM deployed by Kelly Becker
======================================================
* abd0dc5: Kelly Becker - require user to be logged in to vouch for a skill

v1.2.5 - Oct 9, 2012  5:51PM deployed by Aleks Stanisic
=======================================================
* 7967901: Elijah Green - Add redirect_to my_connections instead of pending when going through the userconnect email

v1.2.4 - Oct 9, 2012  5:40PM deployed by Aleks Stanisic
=======================================================
* 2e8ec97: Elijah Green - Add my_connections to new_connections controller function.

v1.2.3 - Oct 9, 2012  5:25PM deployed by Aleks Stanisic
=======================================================
* 670de82: Elijah Green - Remove order from search page

v1.2.2 - Oct 9, 2012  4:30PM deployed by Aleks Stanisic
=======================================================
* a7af6a9: Elijah Green - Add findconnections page
* 9dd9670: Elijah Green - Add if links on profile do not include protocol, add one
* 864f3b6: Elijah Green - Go to correct links on the navbar on the inviteconnections page
* ed88a3a: Aleks Stanisic - profile changes to skill tage
* e1cf048: Elijah Green - Add connections navigation bar to inviteconnections

v1.2.1 - Oct 9, 2012 11:44AM deployed by Kelly Becker
=====================================================
* 14dc805: Kelly Becker - conenction degree
* 1fac967: Kelly Becker - db schema
* 26e800f: Kelly Becker - caching some connections
* c9b244b: Kelly Becker - WORKING CONNECTION DEGREES!!!!
* 3fc870f: Kelly Becker - working on connection degree *bump* i hit a wall

Finally got this working right were only displaying up to third degree right now otherwise it takes to long

v1.2.0 - Oct 9, 2012 10:06AM deployed by Aleks Stanisic
=======================================================
* af88932: Aleks Stanisic - fix to vouch pictures
* c951119: Elijah Green - Add better search for connections
* 2d89532: Elijah Green - Don't used the created_at date for referrals
* 78f2e78: Elijah Green - Add overlay to my_connections
* 7ba6d04: Elijah Green - Add correct language to my_Connections page
* 753649b: Elijah Green - Add rest of my_connections page functionality
* f0c9eed: Elijah Green - Add data to my_connections
* b1180c5: Elijah Green - Add findconnections and add things to my_connections
* af3530f: Elijah Green - Add data to my_connections
* 1049148: Elijah Green - Fix the rest of the styling
* bf91d5a: Elijah Green - Actaully remove pending this time
* 9f54909: Elijah Green - Add new m_connections and remove pending
* 3e95950: Elijah Green - Add assets except for main.css and style.css that may need to be merged with ours
* 35a1449: Aleks Stanisic - more changes to profile
* ceb673e: Aleks Stanisic - some minor changes to profile page
* 0f8be2f: Elijah Green - Changes to profile for new branches

v1.1.29 - Oct 8, 2012  1:05PM deployed by Kelly Becker
======================================================
* 082993c: Kelly Becker - class variable
* 0d2c551: Kelly Becker - changed from using a global class to a local class variable when connection distance searching

Sorry about all this I'm having issues with class variable inheritance

v1.1.28 - Oct 8, 2012 12:36PM deployed by Kelly Becker
======================================================
* 6055f2d: Kelly Becker - fixed date on deploy script

v1.1.27 - Oct 8, 2012 12:34PM deployed by Kelly Becker
=======================================================
* c746f20: Kelly Becker - rescue an exception

v1.1.26 - Oct 8, 2012 12:21PM deployed by Kelly Becker
=======================================================
* 7c4298d: Kelly Becker - connection degree

v1.1.25 - Oct 8, 2012 11:57AM deployed by Kelly Becker
=======================================================
* 099135b: Kelly Becker - ordinalized connection degrees
* b535e21: Kelly Becker - connection degree works

v1.1.24 - Oct 8, 2012 10:48AM deployed by Aleks Stanisic
=========================================================
* e8b04e4: Aleks Stanisic - changes to donor choose campaign, made slight changes to subject lines of variuos emails
* 34a932b: Elijah Green - redirect_to the correct page for profiles for linkedin imports
* 8387ab2: Elijah Green - Remove a few invalid character when created a profile url

v1.1.23 - Oct 6, 2012  2:14PM deployed by Kelly Becker
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

v1.1.22 - Oct 6, 2012  1:58PM deployed by Kelly Becker
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
