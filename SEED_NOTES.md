v4.1.27 - Jan 8, 2013 11:29AM PST deployed by Elijah Green
==========================================================
* 1eb72c8: Elijah Green - Gemfile.lock
* 600ad70: Elijah Green - Allow editing of titles of external videos

v4.1.26 - Jan 7, 2013  6:07PM PST deployed by Elijah Green
==========================================================
* 6c22686: Elijah Green - Fix error where avatar? was called on nil
* 91bbb1c: Elijah Green - Featured Videos
* 4c3641b: Elijah Green - Add prompt requesting users to tag the discussion
* 8ba13a4: Elijah Green - Use most popular discussions on educator dashboard

v4.1.25 - Jan 7, 2013 12:24PM PST deployed by Kelly Becker
==========================================================
* e28214c: Kelly Becker - fixed an issue with creating discussions and nil owners
* 5afc49c: Elijah Green - If a group is unauthorized redirect with a notice

v4.1.24 - Jan 7, 2013 11:22AM PST deployed by Kelly Becker
==========================================================
* c84bca3: Kelly Becker - new user records are returned on no user found for comments

v4.1.23 - Jan 7, 2013 10:28AM PST deployed by Kelly Becker
==========================================================
* 26da93c: Kelly Becker - removed non resourceful route for "my groups" @astanisic always use resourceful routing when possible
* 3916534: Aleks Stanisic - MAde it easier to create Job for orgs
* 1ba6ce3: Aleks Stanisic - adding new create group/org link in my group/org pages
* e552a97: Brian Martinez - changed to school pricing and to connections pages
* a879cb4: Elijah Green - Fix width of select in jobs/_form
* 6000f35: Kelly Becker - remove staging server

v4.1.22 - Jan 5, 2013  5:01PM PST deployed by Kelly Becker
==========================================================
* c170d09: Kelly Becker - remove www2
* 8da406f: Kelly Becker - new production instance
* ea2181d: Kelly Becker - deploy stuff and instances
* 5920808: Kelly Becker - new configurations
* ed2e21b: Kelly Becker - staging server
* f082423: Elijah Green - Fix error on orgs page calling is_admin on a nil user
* 0a496b0: Kelly Becker - updates to deploy script
* 9c7472b: Kelly Becker - newrubber_profile

v4.1.21 - Jan 5, 2013  1:53PM PST deployed by Kelly Becker
==========================================================
* c7291c2: Kelly Becker - removed the old production server
* 4a740ee: Kelly Becker - fixed upcoming events ordering
* 3834e80: Elijah Green - Allow site admins to have greater access to group discussions
* 6fc78c7: Elijah Green - Instead of HTTPStatus Unauthorized for discussions redirect_to group
* 64cd5d4: Elijah Green - Add join group button on groups/discussion
* 2bf6645: Aleks Stanisic - changing add organization flow
* c99440d: Elijah Green - Don't show current user in suggested connections
* 7e22dfa: Aleks Stanisic - style fix header through firefox
* a603802: Elijah Green - Comment on shared posts and move icons
* a9b6996: Aleks Stanisic - fixed grammer error in create organizations

v4.1.20 - Jan 4, 2013 12:38PM PST deployed by Brian Martinez
============================================================
* f1286bc: Brian Martinez - rubber 2.1.2
* 263dca4: Brian Martinez - reverting the last commit
* f0506a6: Brian Martinez - Temporily use old rubber from repository
* 7d28073: Kelly Becker - new instance

v4.1.19 - Jan 4, 2013 11:01AM PST deployed by Kelly Becker
==========================================================
* 68ca78a: Kelly Becker - fix to a heading
* 88f3d33: Kelly Becker - group permissions update
* 3414599: Brian Martinez - major changes to navigation menu
* 574db01: Aleks Stanisic - adding active job application list to admin page
* bbf7895: Elijah Green - Fix cropping with no cropping values
* 74c2713: Aleks Stanisic - adding ability for admins to esit any group and organization
* 3b10a3a: Elijah Green - Revert last commit

v4.1.18 - Jan 3, 2013  4:06PM PST deployed by Aleks Stanisic
============================================================
* 0810573: Elijah Green - Specify json in Gemfile
* 8883c36: Elijah Green - Revert "Server cannot find json 1.7.6, temporfily get gem from repository"

v4.1.17 - Jan 3, 2013  3:37PM PST deployed by Aleks Stanisic
============================================================
* 0cf70e1: Elijah Green - Server cannot find json 1.7.6, temporfily get gem from repository

v4.1.16 - Jan 3, 2013  3:06PM PST deployed by Aleks Stanisic
============================================================


v4.1.15 - Jan 3, 2013  2:56PM PST deployed by Aleks Stanisic
============================================================


v4.1.14 - Jan 3, 2013  2:53PM PST deployed by Aleks Stanisic
============================================================
* 46ea365: Aleks Stanisic - re-design of account settings
* 67bba21: Elijah Green - Cleanpup New User Flow
* cd80985: Aleks Stanisic - added my organizations page
* 43329d5: Elijah Green - Fix suggested connection find
* 830b455: Elijah Green - Must be logged in to be on the get_started page
* b6b13ef: Elijah Green - Fix job referrals
* a4b7c01: Kelly Becker - installs the bleeding edge rubber dependencies and stuff
* 8bed9fc: Kelly Becker - remove all system gems
* 90f9b73: Kelly Becker - cleanup branches
* cb533ab: Kelly Becker - update deploy script with handy method
* fe4a9f1: Brian Martinez - gemlock
* a906560: Brian Martinez - updated gitignore

v4.1.13 - Dec 31, 2012 12:49PM PST deployed by Kelly Becker
===========================================================
* 7381d87: Kelly Becker - update user organization affiliation

v4.1.12 - Dec 31, 2012 12:08PM PST deployed by Kelly Becker
===========================================================
* 2f4ea3e: Kelly Becker - gemlock
* 76ca007: Kelly Becker - groundwork for new privacy
* 4b355a9: Kelly Becker - new user privacy permissions

Removed all outdated branches... If you have any branches that have been deleted remotely please push them back to origin

v4.1.11 - Dec 31, 2012 10:33AM PST deployed by Kelly Becker
===========================================================
* 899f6f6: Elijah Green - Fix pictures uploading for groups
* 10b39c5: Elijah Green - Fix group members page
* 890a9ce: Elijah Green - Put currentUser in instance variable if loggined
* 2d5db6c: Elijah Green - Remove auto_link from technologies/show
* 7400ecb: Elijah Green - Render breaklines correctly
* 5355d79: Elijah Green - Store currentUser result into a instance variable
* e28575b: Aleks Stanisic - style changes to edit org page
* a8c1592: Aleks Stanisic - added forms to org edit page
* 462eaa3: Kelly Becker - stripping out old organizations

v4.1.10 - Dec 28, 2012 12:33PM PST deployed by Kelly Becker
===========================================================
* 2e1eff4: Kelly Becker - removed and replaced some outdated methods
* 74d0384: Aleks Stanisic - removing connection vouch split test for now
* 3954c60: Kelly Becker - removed unused zencoder class

v4.1.9 - Dec 28, 2012 11:22AM PST deployed by Kelly Becker
==========================================================
* b91a3c8: Kelly Becker - switch current_user.nil? to currentUser.new_record?
* 7f42f83: Kelly Becker - removed alternate http clients

v4.1.8 - Dec 27, 2012  5:40PM PST deployed by Kelly Becker
==========================================================
* 81746c2: Kelly Becker - remove assets group

v4.1.7 - Dec 27, 2012  5:19PM PST deployed by Kelly Becker
==========================================================
* de6b91b: Kelly Becker - mini_magick instead of rmagick

v4.1.6 - Dec 26, 2012  5:12PM PST deployed by Kelly Becker
==========================================================
* 3d51417: Elijah Green - Fix organizations not updating

v4.1.5 - Dec 24, 2012  8:51PM PST deployed by Kelly Becker
==========================================================
* b0c8e2a: Kelly Becker - fixed redirect loop of public profiles

v4.1.4 - Dec 23, 2012  2:28PM PST deployed by Kelly Becker
==========================================================
* f9bdbc8: Kelly Becker - fixed the message merge i did not know about

v4.1.3 - Dec 22, 2012  8:58PM PST deployed by Kelly Becker
==========================================================
* d49328d: Kelly Becker - readded therubyracer

v4.1.2 - Dec 22, 2012  3:36PM PST deployed by Kelly Becker
==========================================================
* 52ccdf8: Kelly Becker - removed old event machine websockets
* 602ebe6: Aleks Stanisic - redesign changes to orgs
* 3b0c3e4: Kelly Becker - gem cleanup so far
* 513bb4d: Elijah Green - Change back some things that were changed to debug performance problems
* cec0ce8: Elijah Green - Add number of messages in sent messages
* 7d43746: Elijah Green - Fix order of messages
* eca82e4: Elijah Green - Change up some text based on who is replying
* 89dfc46: Elijah Green - Display last message info
* 055c45e: Elijah Green - Index messages table, got a 5 second query down to well under a tenth of a second
* 7ecd941: Elijah Green - Almost done with message replies

v4.1.1 - Dec 22, 2012 12:17PM PST deployed by Kelly Becker
==========================================================
* ce9aabe: Elijah Green - Finih and varaibles in welcome wizard for tracking
* c22b048: Elijah Green - Slightly change video rake task
* 5e39370: Elijah Green - Store external tumbnail url and name in database

v4.1.0 - Dec 21, 2012  4:55PM PST deployed by Kelly Becker
==========================================================
* 629277a: Kelly Becker - convert profile link to link
* dcc0d9c: Kelly Becker - renamed profile_link to link

v4.0.28 - Dec 21, 2012  2:59PM PST deployed by Kelly Becker
===========================================================
* 1ea698b: Kelly Becker - count videos properly
* 87fd5be: Kelly Becker - minor cleanup

v4.0.27 - Dec 21, 2012  2:21PM PST deployed by Kelly Becker
===========================================================
* 6dab31d: Kelly Becker - haproxy update

v4.0.26 - Dec 21, 2012  1:49PM PST deployed by Kelly Becker
===========================================================
* c7a51f1: Kelly Becker - changed all find quieres to the accept rails 3.2 format which is faster since it does not have to recurse for things like counts.

v4.0.25 - Dec 21, 2012 11:08AM PST deployed by Kelly Becker
===========================================================
* aaf45df: Kelly Becker - redirect user back to the last page they were on if applicable
* dabbc61: Kelly Becker - cleaned up and documented some code and added some todos

v4.0.24 - Dec 21, 2012 10:33AM PST deployed by Kelly Becker
===========================================================
* 811f992: Kelly Becker - gitignore
* 3ff8b88: Kelly Becker - check for connection key
* 4b49e6d: Kelly Becker - check for connection key
* ca490bd: Kelly Becker - testing a fix to group sharing

v4.0.23 - Dec 20, 2012  5:26PM PST deployed by Kelly Becker
===========================================================
* 12a2837: Kelly Becker - deploy cramp update

v4.0.22 - Dec 20, 2012  5:09PM PST deployed by Kelly Becker
===========================================================
* 5db1058: Kelly Becker - cache user_id on session

v4.0.21 - Dec 20, 2012  4:44PM PST deployed by Kelly Becker
===========================================================
* 5dd2291: Kelly Becker - creating notifications with the wrong comments

v4.0.20 - Dec 20, 2012  3:52PM PST deployed by Kelly Becker
===========================================================
* c222235: Kelly Becker - sse

v4.0.19 - Dec 20, 2012  2:00PM PST deployed by Kelly Becker
===========================================================
* 08c43d8: Kelly Becker - some cramp updates getting ready for cramp notifications
* b00baf5: Aleks Stanisic - sharting added to groups header

v4.0.18 - Dec 20, 2012 11:04AM PST deployed by Kelly Becker
===========================================================
* 95d9479: Kelly Becker - ha proxy config

v4.0.17 - Dec 20, 2012 10:42AM PST deployed by Kelly Becker
===========================================================
* 4fb397d: Kelly Becker - save
* 2003fa0: Elijah Green - Speed up the messages/index
* 060f642: Elijah Green - Store current_user in an instance variable

v4.0.16 - Dec 19, 2012  7:21PM PST deployed by Kelly Becker
===========================================================
* cdd28ea: Kelly Becker - cramp rubber config
* a2a8810: Kelly Becker - update script
* 5eb8d1d: Elijah Green - More fixes to the massives user loads
* 86ae7cd: Kelly Becker - update script
* 743d2c3: Kelly Becker - update script
* 8d61b6d: Kelly Becker - cramp config
* 76ede32: Elijah Green - Fix places on profile where every connected user is loaded
* 8327385: Kelly Becker - adding cramp test
* 6ae7bb5: Elijah Green - When checking if connected with a user, use their id

v4.0.15 - Dec 19, 2012  6:13PM PST deployed by Kelly Becker
===========================================================
* 0e6c43e: Kelly Becker - default user id

v4.0.14 - Dec 19, 2012  6:05PM PST deployed by Kelly Becker
===========================================================
* c82934a: Kelly Becker - get connection ids
* 9e6d41d: Elijah Green - Remove a query on all connnections by just getting the ids
* 95cf842: Elijah Green - Format last commit differently in case no if statement is true
* cecb8fa: Elijah Green - Fix picture uploading
* a9b1648: Elijah Green - Change text on the get_started page

v4.0.13 - Dec 19, 2012  4:03PM PST deployed by Kelly Becker
===========================================================
* 7065b13: Kelly Becker - teacher user list filter works now
* 0fee917: Elijah Green - Remove some uneeded queries and use includes instead of  joins on profile
* 84f87e8: Kelly Becker - user not found
* 95b21d3: Kelly Becker - limit
* ca7a60c: Aleks Stanisic - adding vouching to connection request flow for odd users

v4.0.12 - Dec 19, 2012 11:23AM PST deployed by Kelly Becker
===========================================================
* edfa7ac: Kelly Becker - is profile mine
* 8caaa36: Kelly Becker - is profile mine
* 089e15e: Kelly Becker - profile whiteboard load will always default to a page of one

v4.0.11 - Dec 19, 2012 11:08AM PST deployed by Kelly Becker
===========================================================
* 740c9f5: Kelly Becker - whoops varible name is not right

v4.0.10 - Dec 19, 2012 10:56AM PST deployed by Kelly Becker
===========================================================
* 9fc7fd3: Kelly Becker - cleaning up some and fixing some bugs on the profile
* e77e443: Kelly Becker - added connected_to? to user.rb
* 89f6599: Kelly Becker - assume that the user will want to recveive new discussion notification on a group

v4.0.9 - Dec 19, 2012 10:07AM PST deployed by Kelly Becker
==========================================================
* 9bc7c49: Kelly Becker - added the ability to add more discussions after one has been created on a group

v4.0.8 - Dec 19, 2012  9:55AM PST deployed by Kelly Becker
==========================================================
* d3b3bab: Kelly Becker - cleanup connections better

v4.0.7 - Dec 18, 2012  5:50PM PST deployed by Kelly Becker
==========================================================
* 09dad8c: Kelly Becker - added notification for new discussions on a group
* 099ec01: Kelly Becker - added notification for new discussions on a group

v4.0.6 - Dec 18, 2012  4:47PM PST deployed by Kelly Becker
==========================================================
* 5bc4588: Kelly Becker - added not id attr access to interview
* c3190b8: Kelly Becker - group notification settings
* 059dd8a: Elijah Green - Add ajax add connection to educator dashboard and skills/show

v4.0.5 - Dec 18, 2012  3:43PM PST deployed by Kelly Becker
==========================================================
* 46fe22c: Kelly Becker - some minor bug fixes and sweeping sessions again
* 6e149c9: Elijah Green - For interview messages, put link for the applications page
* 7ddaf82: Kelly Becker - disabled the websockets for now
* d6b1855: Kelly Becker - log all connection access

v4.0.4 - Dec 18, 2012 12:28PM PST deployed by Kelly Becker
==========================================================
* 673f3d0: Kelly Becker - organization owner count GAH! that was a pain!
* d450f42: Kelly Becker - cache the organization check

v4.0.3 - Dec 17, 2012  6:39PM PST deployed by Kelly Becker
==========================================================
* be32ff8: Elijah Green - Use tags to change how some messages are displayed
* 1bb2130: Kelly Becker - Update SEED_NOTES.md

v4.0.2 - Dec 17, 2012  5:20PM PST deployed by Kelly Becker
==========================================================
* 32d5745: Kelly Becker - fix to old activifies being gone
* 0c8b26e: Elijah Green - Remove unused methods for messages
* 9603b3f: Elijah Green - Fix a XSS vulnerability
* 5ad811c: Elijah Green - Remove warning that ruby -wc was showing about shadowed variables
* 65bf387: Elijah Green - Only show ubsmitted applications
* b9bf219: Elijah Green - Fix a jobs/show xss vulnerability
* 45ee961: Elijah Green - School Signup
* 3fb045b: Kelly Becker - removed staging
* b36faef: Elijah Green - Gemfile.lock

v4.0.1 - Dec 17, 2012 12:45PM PST deployed by Kelly Becker
==========================================================
* 49d3a50: Kelly Becker - you can now display multiple banners

v4.0.0 - Dec 17, 2012 12:21PM PST deployed by Kelly Becker
==========================================================
* 7bfdec8: Kelly Becker - added group_id to accessible
* e9dc8f2: Kelly Becker - fixed some source issues
* c7a9716: Kelly Becker - merge_organizations
* c30a08b: Kelly Becker - proper error messages on unauthorized discussions
* c5dbe01: Kelly Becker - pretty errors on staging
* 1a55dd4: Kelly Becker - if the amount of jobs on an org is none then dont throw exception
* 3ce7c51: Kelly Becker - dont show interview tiems that are unset
* 7500293: Elijah Green - Only get submitted applications on job/show
* 9567136: Kelly Becker - added +job
* 48a6fe6: Elijah Green - Commenting out some dead code in user.rb
* 0d122bb: Kelly Becker - new staging server configuration
* f2f8b20: Kelly Becker - trying a different nginx config
* d47f251: Kelly Becker - staging instances and nginx hack
* fed3588: Kelly Becker - made organizations not hidden during migration but otherwise hidden by default
* 2e98706: Kelly Becker - docs
* c8a7c4b: Kelly Becker - just added the job disabling script needs to be run nightly the script is JobPack.jobAllowance.disableExpired you can also call Group.find(:id).ajobs which will run that and return the still active jobs.
* 5e8b722: Kelly Becker - message on accept interview page is optional
* a8b11ab: Kelly Becker - schools removed from admin menu
* e2dc807: Kelly Becker - add job packs to organizations
* a513e5f: Kelly Becker - fixed members not showing on group members page
* 2ec569a: Kelly Becker - freebie job pack
* 8ce4ad1: Kelly Becker - recruiter dashboard
* 9e9ad42: Kelly Becker - yay interview stuff seems to work
* 361b0c0: Kelly Becker - running some cleanup and debugging
* 388aec2: Kelly Becker - removing duplicate files ?
* caa601b: Kelly Becker - creating and posting new jobs seems to be working from the new organizations pane
* 9b31ff8: Kelly Becker - jobs editing
* 1c91f56: Kelly Becker - rewriting jobs controllers and views
* b6863a1: Kelly Becker - organzations custom route going bye bye
* ceb6d3e: Kelly Becker - cleaning up jobs controller for use
* c969845: Kelly Becker - have made some progress started moving to removing activity and merging into notifications.
* 9ec5db7: Kelly Becker - getting rid of the docs foler
* d1e55ff: Kelly Becker - progress is slow and hard. Moving towards getting the dashboard working again
* fa05d2c: Kelly Becker - interviews :D
* b37f37f: Kelly Becker - interviews pretty much working
* ec4273c: Kelly Becker - source items around the exceptions displays
* a5fad0f: Kelly Becker - makeing some progress @astanisic @elijahgreen when this branch gets merged back into develop we need to work towards migrating current_user.nil to currentUser.new_record?
* 3712311: Kelly Becker - interviews are almost working
* 3a8a053: Kelly Becker - ordinalized dates and default formats
* 39af900: Kelly Becker - new permissions style :D
* 63e9911: Kelly Becker - jobs listing updates
* a7a9bdd: Kelly Becker - making some more progress
* 1288ace: Kelly Becker - added school / job migrator
* 6c1e1ac: Kelly Becker - schools migration
* a565bd7: Kelly Becker - fix to the organization removal problem
* c1304a0: Kelly Becker - making progress fixing interviews
* 2dda477: Kelly Becker - convert group into an org
* 879e029: Kelly Becker - application process fixes
* ff809ba: Kelly Becker - whoops
* b92ad2e: Kelly Becker - cleaned up some bugs
* b12b6a7: Kelly Becker - show job posting
* 515661a: Kelly Becker - jobs progress
* 82f0d57: Kelly Becker - got a working drag n drop credit system
* 092e5b7: Kelly Becker - got drag n drop working
* e03a352: Kelly Becker - styleing for drag n drop
* 5bf7d8d: Kelly Becker - progress so far with droppable

v3.1.8 - Dec 15, 2012  4:14PM PST deployed by Aleks Stanisic
============================================================
* 06ec753: Elijah Green - Fix activity on profile page
* 277dbdc: Elijah Green - Fix videos page

v3.1.7 - Dec 14, 2012  5:49PM PST deployed by Aleks Stanisic
============================================================
* 371babb: Elijah Green - Sort users correctly
* 6c23d8b: Elijah Green - Fix location search on connections pages
* ba840d4: Elijah Green - Fix error where the a message's sender wasn't returned properly
* 64486f5: Elijah Green - Ajax add connections on connections/index

v3.1.6 - Dec 14, 2012 12:58PM PST deployed by Aleks Stanisic
============================================================
* 465edf5: Elijah Green - Speed up my_connections page with some eager loading of users

v3.1.5 - Dec 14, 2012 11:56AM PST deployed by Aleks Stanisic
============================================================
* 4a1e1d9: Elijah Green - Eager load connected user when getting connections

v3.1.4 - Dec 14, 2012 11:40AM PST deployed by Aleks Stanisic
============================================================
* 4ce4dc7: Aleks Stanisic - changes to video profile page
* 244ebcb: Elijah Green - Eager load users for comments on discussions/show

v3.1.3 - Dec 13, 2012  8:40PM PST deployed by Aleks Stanisic
============================================================
* 51a9dbf: Aleks Stanisic - changes to public profiles

v3.1.2 - Dec 13, 2012  7:53PM PST deployed by Aleks Stanisic
============================================================
* 543c0db: Aleks Stanisic - fix to about page

v3.1.1 - Dec 13, 2012  7:35PM PST deployed by Aleks Stanisic
============================================================
* ca0b13f: Aleks Stanisic - fix to profile about page

v3.1.0 - Dec 13, 2012  6:28PM PST deployed by Aleks Stanisic
============================================================
* e5db58d: Aleks Stanisic - changes to profile part billion
* ad10161: Brian Martinez - changes to profile resume video display
* f52da1a: Aleks Stanisic - changes to profile video page
* 55aad07: Elijah Green - Redirect on video deletion based on referrer
* b9cd16d: Elijah Green - When there is no bounding box use viewport to search by location
* 78b6238: Aleks Stanisic - profile changes
* 82744e6: Elijah Green - Fix being able to click add twice get an accepted connection
* 4523221: Aleks Stanisic - adding javascript to about profile page
* 659904b: Brian Martinez - changed to user video page
* cc32d6c: Brian Martinez - profile redesign files
* 7f9c1b1: Brian Martinez - changes to profile pages

v3.0.57 - Dec 13, 2012  1:13PM PST deployed by Aleks Stanisic
=============================================================
* 9959525: Elijah Green - Catch BadGateway erors on twitter direct messages

v3.0.56 - Dec 13, 2012 11:31AM PST deployed by Aleks Stanisic
=============================================================
* 15f3686: Elijah Green - Allow some html tags when showing and event's location

v3.0.55 - Dec 13, 2012 11:21AM PST deployed by Aleks Stanisic
=============================================================
* 7804bf3: Elijah Green - Fix discussion invite messages

v3.0.54 - Dec 12, 2012  8:09PM PST deployed by Aleks Stanisic
=============================================================
* 9c6b4ac: Elijah Green - Fix search on skills when no skills are found

v3.0.53 - Dec 12, 2012  7:53PM PST deployed by Aleks Stanisic
=============================================================
* 7f7c3b9: Brian Martinez - Splash Page Changes
* a200b66: Elijah Green - Redirect_to back un video deletion
* bc8f672: Elijah Green - Bring back the skills page
* c8738be: Elijah Green - Sort users by connections_count on skills page
* 7bef415: Elijah Green - Add connections_count to users
* 591ad9f: Elijah Green - Fix some cases where search would not work correctly
* 4a3801d: Elijah Green - Change search bar on connections/index
* c60f07c: Elijah Green - Add search bar to top right of page

v3.0.52 - Dec 12, 2012 10:31AM PST deployed by Aleks Stanisic
=============================================================
* e824db3: Elijah Green - Fix the link to an inviters profile

v3.0.51 - Dec 11, 2012  5:24PM PST deployed by Aleks Stanisic
=============================================================
* cd7e16a: Elijah Green - Make note of possible race condition

v3.0.50 - Dec 11, 2012  4:57PM PST deployed by Aleks Stanisic
=============================================================
* 0119577: Elijah Green - Don't allow urls to be blank

v3.0.49 - Dec 11, 2012  4:32PM PST deployed by Aleks Stanisic
=============================================================
* ca77372: Elijah Green - Undo adding presence validation

v3.0.48 - Dec 11, 2012  4:25PM PST deployed by Aleks Stanisic
=============================================================
* 8ee42c8: Elijah Green - Fix profile url being set to blank

v3.0.47 - Dec 11, 2012  3:48PM PST deployed by Aleks Stanisic
=============================================================
* 9c92411: Elijah Green - Fix applications/index where users position is null

v3.0.46 - Dec 11, 2012  2:14PM PST deployed by Aleks Stanisic
=============================================================
* 4537c60: Elijah Green - User User.none instead of empty array to represent no users

v3.0.45 - Dec 11, 2012  2:04PM PST deployed by Aleks Stanisic
=============================================================
* c0c27a2: Aleks Stanisic - removed teacher.id from awards form and changed url in team page

v3.0.44 - Dec 11, 2012  1:47PM PST deployed by Aleks Stanisic
=============================================================
* f4b57e7: Aleks Stanisic - changing urls in static pages

v3.0.43 - Dec 11, 2012  1:10PM PST deployed by Aleks Stanisic
=============================================================
* ce7420b: Aleks Stanisic - my schema
* 9c0f4b2: Elijah Green - Send email on application submit
* 8c674c2: Elijah Green - Fix link to new applicants
* f79e151: Elijah Green - Clean up a fix to migration
* 1a2aaf7: Elijah Green - Change some things in geocode.rake
* b9524ef: Elijah Green - Location search complete
* a94945b: Elijah Green - Change some names in tbhe geocode rake task
* 792f4bc: Elijah Green - Geocoding can now populate location fields
* e52a365: Elijah Green - Temporarily add back teacher files to fix a bad migration
* a077779: Elijah Green - Fix a broken migration
* 8d8f35b: Elijah Green - Get started with location on new connections page
* 377e810: Elijah Green - Remove reverse geocode on user
* 47a219d: Elijah Green - Use bounding box instead of radius for connection search

v3.0.42 - Dec 10, 2012  5:54PM PST deployed by Aleks Stanisic
=============================================================


v3.0.41 - Dec 10, 2012  5:48PM PST deployed by Aleks Stanisic
=============================================================
* a2fa4d8: Elijah Green - Make sure presence always links to Mandela's profile
* 3c0a6fb: Elijah Green - Fix technology errors
* 4f4030f: Elijah Green - Fix skill page errors
* 930dfb8: Kelly Becker - updated some bundles (like bitswitch)
* a305b09: Brian Martinez - changing customers on school splash, featured jobs on dashboard, twitter link on stats

v3.0.40 - Dec 8, 2012 12:42PM PST deployed by Aleks Stanisic
============================================================
* c001cc2: Elijah Green - Fix some formatting on my_connections
* 10de569: Elijah Green - Fix current_job_string
* 415cfea: Elijah Green - Only show profile whiteboard javascript if there are whiteboard posts
* 2a9923d: Elijah Green - Fix the pagination of my_connections
* e7d80e4: Elijah Green - Fix up connection search

v3.0.39 - Dec 7, 2012  1:26PM PST deployed by Aleks Stanisic
============================================================
* 2817666: Elijah Green - Remove invites div on group members page
* 4bb6fcc: Elijah Green - Only collect user_ids once on group members page
* a3d9c6d: Elijah Green - Add location search on my_connections

v3.0.38 - Dec 7, 2012 12:24AM PST deployed by Kelly Becker
==========================================================
* b86dda6: Kelly Becker - parameterize
* 5162625: Kelly Becker - allow changing of urls and added an availability notifier

Removed empty deploy logs 

v3.0.37 - Dec 6, 2012  7:40PM PST deployed by Aleks Stanisic
============================================================
* 6f68cf0: Aleks Stanisic - changes to profile activity
* 225273b: Aleks Stanisic - changes to activity on profile
* 3c5f5ef: Aleks Stanisic - changes to activity feed in profile
* 4703088: Aleks Stanisic - added activity
* b4d4cb9: Aleks Stanisic - style changes
* 01ffe8f: Aleks Stanisic - changes to profile
* 026235f: Brian Martinez - slight changes to the profile
* 33eef48: Aleks Stanisic - profile changes- added video
* 2d1390c: Aleks Stanisic - changes to profile
* b63a9a2: Aleks Stanisic - more additions to info box on profile page
* 12c44ed: Aleks Stanisic - adding info box to profile

v3.0.34 - Dec 6, 2012  6:51PM PST deployed by Aleks Stanisic
============================================================
* fc5e0c3: Aleks Stanisic - new gem.lock


v3.0.31 - Dec 6, 2012  6:45PM PST deployed by Elijah Green
==========================================================
* cb67916: Elijah Green - Gemfile.lock
* bd4d986: Elijah Green - Check if current job is nil on educator_dashboard
* 4fbf532: Elijah Green - Readd location on profile_edit and fix user validations
* 39d9a73: Brian Martinez - changes to suggested areas of dashboard, add group button on group heading, and jobs on the header
* 4cbc61a: Elijah Green - Use a callback that will actaully work
* bc2d098: Elijah Green - Add Geocoder fields to user
* 0fa2bbb: Elijah Green - Remove geokit

v3.0.29 - Dec 6, 2012  1:49PM PST deployed by Kelly Becker
==========================================================
* 462e690: Kelly Becker - popdown new results

v3.0.28 - Dec 6, 2012 12:47PM PST deployed by Aleks Stanisic
============================================================
* 8a632ee: Aleks Stanisic - changes to profile links in our team page
* be586e4: Elijah Green - Remove create_teacher in welcome_Wizard step 1
* eab2a33: Elijah Green - Fix link on splash page
* 0ff7fc8: Elijah Green - Gemfile.lock
* a525abb: Brian Martinez - update to the featured groups section

v3.0.27 - Dec 5, 2012  7:05PM PST deployed by Aleks Stanisic
============================================================
* 41ff54d: Aleks Stanisic - adding ability for users to see ou liked their whitboard posts
* 50bda1a: Elijah Green - Fix XSS vulnerabilty user.rb:profile_link
* 7796525: Elijah Green - Fix XSS vulnerability in messages/show
* eff463f: Elijah Green - Fix XSS vulnerability in events_helper.rb
* 1e3f911: Elijah Green - Fix XSS vulnerability in video.rb
* d84bda1: Kelly Becker - removed conflicting method

v3.0.26 - Dec 5, 2012  3:26PM PST deployed by Kelly Becker
==========================================================
* 7086b7d: Kelly Becker - cleanup scripts

v3.0.25 - Dec 5, 2012  3:16PM PST deployed by Kelly Becker
==========================================================
* 96faf95: Kelly Becker - discussions before save callback
* 7437300: Elijah Green - Fix discussion.owner getting set to empty string
* 3e7a607: Elijah Green - Lower the number of queries on the profile
* 5f08651: Elijah Green - Fix XSS vulnerability on the whiteboard

v3.0.24 - Dec 5, 2012  1:09PM PST deployed by Kelly Becker
==========================================================
* c746a3a: Kelly Becker - try and solve the new discussions without groups not showing up with nil owner columns
* be38650: Elijah Green - Set login email field value to nil
* 33a1643: Elijah Green - Fix event.rb XSS vulnerability
* fc07b8d: Elijah Green - Fix XSS vulnerability in discussion.rb
* 125f48b: Elijah Green - Add yahoo invite and fix up twitter invite

v3.0.23 - Dec 5, 2012 10:41AM PST deployed by Kelly Becker
==========================================================
* ea8f5e7: Kelly Becker - fix discussions creation
* feaad9d: Kelly Becker - fix discussions creation

v3.0.22 - Dec 4, 2012  8:35PM PST deployed by Aleks Stanisic
============================================================
* 2014420: Brian Martinez - changes to the new job form

v3.0.21 - Dec 4, 2012  7:17PM PST deployed by Kelly Becker
==========================================================
* 2c37e32: Kelly Becker - groups new style
* 4f57687: Kelly Becker - groups redesign
* 970ca9c: Kelly Becker - added inception date
* 9a13137: Kelly Becker - long about page
* 55d7af9: Elijah Green - Add gmail invite page
* 484c215: Kelly Becker - group members update
* 27e598a: Kelly Becker - job infrastructure.
* 71e0a04: Kelly Becker - group orgs redesign so far;
* 6a052fc: Kelly Becker - making quite a bit of progress

v3.0.20 - Dec 4, 2012  5:15PM PST deployed by Aleks Stanisic
============================================================
* d9aceb9: Elijah Green - Deal with non-authenticated users on invite_facebook
* 7d341f2: Elijah Green - Add facebook invite

v3.0.19 - Dec 3, 2012  7:24PM PST deployed by Aleks Stanisic
============================================================
* b40b247: Aleks Stanisic - fixes to images in invite connections

v3.0.18 - Dec 3, 2012  7:05PM PST deployed by Aleks Stanisic
============================================================
* 1c7f388: Elijah Green - Add twitter to inviteconnections
* 51fc853: Brian Martinez - changes to invite pages and other connections pages
* 09c2b51: Kelly Becker - recruiter dashboard updates
* 8453038: Kelly Becker - user in home cotnroller gloablly

v3.0.17 - Dec 3, 2012  5:05PM PST deployed by Aleks Stanisic
============================================================
* 3a33c84: Elijah Green - Append hidden twitter input on search

v3.0.16 - Dec 3, 2012  4:51PM PST deployed by Aleks Stanisic
============================================================
* 37d8bef: Elijah Green - Move the twitter input attachments outside of ajax call

v3.0.15 - Dec 3, 2012  4:27PM PST deployed by Aleks Stanisic
============================================================


v3.0.14 - Dec 3, 2012  4:25PM PST deployed by Aleks Stanisic
============================================================
* 32ccd5b: Elijah Green - Use key value pairs for twitter
* ed213b3: Elijah Green - Finish up invite search
* a9a44e1: Aleks Stanisic - displaying 20 connections on my connections page
* 1179e8d: Kelly Becker - educator and recruiter dashbaords
* f10427b: Kelly Becker - squeeze names
* d2e5bb0: Elijah Green - lowercase assets so it works on all browsers
* 881fda2: Brian Martinez - images for welcome wizard 4
* a5d8a57: Brian Martinez - changes to the wizard flow step 4
* a5f8711: Brian Martinez - changes to wizard 4 buttons
* fa6788c: Elijah Green - Remove some extra things
* d8baf5c: Elijah Green - Correctly detect emails
* b07d7bc: Elijah Green - Can authenticate with twitter on step4
* 1bd5ff6: Elijah Green - Remove undetected email button
* efc94b8: Elijah Green - Highlight already selected contacts
* 86498db: Elijah Green - Reset arrays when changing invite methods
* 712ec39: Elijah Green - Finish the twitter direct messages
* c10b348: Elijah Green - Add extra invite and skip button
* 04ca0e9: Elijah Green - Add tweet about us on step4
* 19cc093: Elijah Green - Changes to the header when clicking twitter or facebook
* 32772a9: Elijah Green - Add search for contacts
* 0b3200e: Elijah Green - Finish up twitter function
* ded51e1: Elijah Green - Fix some visual things with twitter invites
* 9549c45: Elijah Green - Add twitter screen_name and empty div on invite type change
* 9d861d8: Elijah Green - Can now display twitter followers
* c0405f8: Elijah Green - Seperate email contacs out and add facebook
* aca30f1: Elijah Green - Fix nil names cauing errors in step4

v3.0.13 - Dec 3, 2012 12:57PM PST deployed by Kelly Becker
==========================================================
* 91c7042: Kelly Becker - name and slug normalizer
* 73909aa: Elijah Green - Add pasteword button to presentations/_form and index
* 8917399: Elijah Green - Add paste plugin to tinymce in presentations/_form

v3.0.12 - Dec 3, 2012  9:16AM PST deployed by Kelly Becker
==========================================================
* 9028244: Kelly Becker - user slugs

v3.0.11 - Dec 2, 2012 11:22PM PST deployed by Aleks Stanisic
============================================================
* 922b7d8: Aleks Stanisic - message fix

v3.0.10 - Dec 2, 2012  4:55PM PST deployed by Aleks Stanisic
============================================================
* 798b934: Elijah Green - fix video watch snippet
* 6c56a0a: Aleks Stanisic - added analytics to messages
* 56db5b9: Aleks Stanisic - added analytics to discussions
* c9d0431: Aleks Stanisic - adding analytics for connection requests
* 00cb825: Brian Martinez - changes to invite pages

v3.0.9 - Dec 1, 2012  7:14PM PST deployed by Aleks Stanisic
===========================================================
* 2da27c1: Aleks Stanisic - added analytics to groups
* 8de0212: Elijah Green - Differentiate educators and recruiters on admin page

v3.0.8 - Dec 1, 2012  5:27PM PST deployed by Aleks Stanisic
===========================================================
* e5114b7: Aleks Stanisic - table fix for grades

v3.0.7 - Dec 1, 2012  4:33PM PST deployed by Aleks Stanisic
===========================================================
* 5d3897e: Elijah Green - Fix donors_choose_list
* a20da6a: Elijah Green - Fix technologies/show
* 53b5ed2: Elijah Green - Remove accidently commited file

v3.0.6 - Dec 1, 2012  3:33PM PST deployed by Kelly Becker
=========================================================
* 51e4d54: Kelly Becker - more discussions issues
* 04accdd: Elijah Green - Fix referral user list
* c2891a9: Elijah Green - remove reference to teacher in presentations
* e0b5faf: Elijah Green - Fix discussions/show (was checkin for teacher)
* 2086b6a: Elijah Green - Fix linkedin import

v3.0.5 - Dec 1, 2012  3:15PM PST deployed by Kelly Becker
=========================================================
* 2ce23ec: Kelly Becker - merge
* 521bc71: Kelly Becker - updated links
* 654d2a3: Elijah Green - fix some bad links on the profile

v3.0.4 - Dec 1, 2012  3:02PM PST deployed by Aleks Stanisic
===========================================================
* 191e424: Elijah Green - Fix admin page
* 2cfe5e0: Elijah Green - Fix non-discussion comments

v3.0.3 - Dec 1, 2012  2:09PM PST deployed by Kelly Becker
=========================================================
* 5644a10: Kelly Becker - profile stats update
* 88bb90f: Kelly Becker - merge cleanup
* e7e2538: Kelly Becker - merge teachers
* e7c40fe: Kelly Becker - skip creating a notification if user.nil?
* bff0635: Elijah Green - Fix credentials on step4 of application wizard
* 78e105c: Elijah Green - Check if user is deleted when notifing for disucssions

v3.0.2 - Dec 1, 2012  1:26PM PST deployed by Kelly Becker
=========================================================
* 15380c1: Kelly Becker - newrelic config
* dfc9ee2: Kelly Becker - newrelic
* b78eb56: Elijah Green - Fix checking for authorizations

v3.0.1 - Nov 30, 2012 11:51PM PST deployed by Kelly Becker
==========================================================
* 51eb703: Kelly Becker - aleks broke something

v3.0.0 - Nov 30, 2012 11:26PM PST deployed by Kelly Becker
==========================================================
* a213962: Kelly Becker - staging instance
* 4db34ff: Kelly Becker - notme fix
* 0e8f3b0: Kelly Becker - skills fix
* 0370ab3: Kelly Becker - rake
* bdba340: Kelly Becker - removed trash from the capfile
* e0ce5bb: Kelly Becker - lets go for the staging server
* 0b91e47: Kelly Becker - signup flow works :D
* 8c5497c: Kelly Becker - connection search
* 9611b92: Elijah Green - Add watch snippet and attachments to applications
* a2fe4ce: Elijah Green - Add appattachments
* 0d52487: Kelly Becker - userconnections now works with a new route.
* c8dc700: Kelly Becker - userconnections now works with a new route.
* 813fbd4: Kelly Becker - whiteboard migration works
* 90f0372: Kelly Becker - profile stats now on migrated slug
* eebf0ce: Kelly Becker - requre login for profiel stats
* d87499d: Elijah Green - fix to jobs/show page
* 1e70918: Kelly Becker - whoops made the db nulls go the wrong way
* 854cf3e: Kelly Becker - profile stats and bump updated_at in sessions
* 851091c: Elijah Green - Change application teacher references to users
* 40dd58f: Elijah Green - parameterize user slugs and fix add vouches
* e6033c3: Elijah Green - vouches
* ab87dfe: Kelly Becker - teacherid nullable
* 4e74dc4: Elijah Green - Change alter_column to change_column
* 2667dd6: Kelly Becker - teacher -> user migration for videos
* 51cc521: Kelly Becker - attachments now work
* 472f39f: Kelly Becker - technologies and skills
* 0f82dcb: Kelly Becker - skills information page all good :D
* 0bac85d: Kelly Becker - editing skills now works. skills info pages i dont think do
* 535a4b5: Kelly Becker - credentials work!
* 020bd35: Kelly Becker - educations and experience are working
* 25802f2: Elijah Green - Remove extra education files
* 8e07cb2: Elijah Green - Homepage, profile, edit educations
* fe34ca8: Kelly Becker - migrations are done lets get started on debugging
* 7966dba: Kelly Becker - migrations are moving along were almost ready to test!
* a903ee7: Kelly Becker - migration progress
* 3a78f5f: Kelly Becker - removing c9revisions
* db38130: Elijah Green - technologies
* 6068a30: Elijah Green - messages
* 8821b9a: Elijah Green - connections and whiteboards
* 8c8c851: Elijah Green - Skills, groups, slight changes to home_controller
* 0e80a88: Kelly Becker - committing so elijah can try on local
* 93b7083: Kelly Becker - we are migrating on cloud9 like a team! save point
* 90ba8cd: Aleks Stanisic - credentials teachers
* d5934c6: Kelly Becker - updated gem file
* 121bf79: Kelly Becker - migration so far
* 0fb6449: Kelly Becker - migrations work
* f26051f: Kelly Becker - case senativiy
* 2acd8f6: Kelly Becker - kvpairs
* 77f8d38: Kelly Becker - some amazing headway

v2.1.19 - Nov 30, 2012  7:12PM PST deployed by Aleks Stanisic
=============================================================
* 6d639b9: Aleks Stanisic - profile design fix

v2.1.18 - Nov 30, 2012  9:35AM PST deployed by Aleks Stanisic
=============================================================
* c3653df: Kelly Becker - gitignore and gemlock
* 1d2095e: Elijah Green - Fix adding groups

v2.1.17 - Nov 28, 2012  8:54PM PST deployed by Aleks Stanisic
=============================================================


v2.1.16 - Nov 28, 2012  8:51PM PST deployed by Aleks Stanisic
=============================================================
* f08757c: Brian Martinez - suggested groups on groups pages
* 30dc978: Brian Martinez - adding prompts to join group to disucss
* f3765b4: Brian Martinez - changes to application flow

v2.1.15 - Nov 28, 2012  1:15PM PST deployed by Kelly Becker
===========================================================
* 262840c: Kelly Becker - whoops commenting out not a good plan

v2.1.14 - Nov 28, 2012  1:03PM PST deployed by Kelly Becker
===========================================================
* ee72216: Kelly Becker - commented out connection degree

v2.1.13 - Nov 28, 2012 12:15PM PST deployed by Aleks Stanisic
=============================================================
* 63533c2: Aleks Stanisic - profile changes

v2.1.12 - Nov 27, 2012  8:40PM PST deployed by Kelly Becker
===========================================================
* 633fd11: Kelly Becker - remove www2
* d5164a9: Kelly Becker - group fix
* 5f1b583: Kelly Becker - fix to a group permis thing
* af25a49: Brian Martinez - profile changes
* 86ab852: Kelly Becker - fix to a minor bug
* 3c1fc56: Kelly Becker - gemlock
* 0546aea: Brian Martinez - blog and website for teachers
* 776df2f: Aleks Stanisic - new profile addition
* cd8ed2e: Brian Martinez - changes to make Brian's Mac work
* 2298ecc: Kelly Becker - config overrides
* e735707: Kelly Becker - instances
* 9260b47: Kelly Becker - instances

v2.1.11 - Nov 27, 2012  3:37PM PST deployed by Kelly Becker
===========================================================
* 383a656: Kelly Becker - gemlock

v2.1.10 - Nov 27, 2012  3:35PM PST deployed by Kelly Becker
===========================================================
* 68efa4c: Kelly Becker - git repo for bitswitch

v2.1.9 - Nov 27, 2012  2:01PM PST deployed by Kelly Becker
==========================================================
* d697be1: Kelly Becker - group permissions
* 647691e: Kelly Becker - make group admin
* e776c38: Kelly Becker - group make admin
* 1320bde: Aleks Stanisic - gem file
* 2ffa193: Brian Martinez - school side design changes

v2.1.8 - Nov 26, 2012  3:38PM PST deployed by Aleks Stanisic
============================================================


v2.1.7 - Nov 26, 2012  3:25PM PST deployed by Aleks Stanisic
============================================================
* 0020053: Elijah Green - Call create_teacher in application controller now that there is no callback
* bd37db5: Elijah Green - Only show submitted applications on school admin page

v2.1.6 - Nov 26, 2012  2:53PM PST deployed by Kelly Becker
==========================================================
* 1f3314b: Kelly Becker - application wizard url steps

v2.1.5 - Nov 26, 2012 12:57PM PST deployed by Kelly Becker
==========================================================
* 5780cbb: Kelly Becker - sweep session
* 620e215: Kelly Becker - lowered worker processes

v2.1.4 - Nov 26, 2012 12:08PM PST deployed by Kelly Becker
==========================================================
* 122da92: Kelly Becker - firewall rules
* 731d1ef: Kelly Becker - rearranging some files
* 35caabc: Kelly Becker - www2,3??
* 012ef6c: Kelly Becker - some updates to the deploy scripting
* ce12e66: Kelly Becker - haproxy restart
* c95e48c: Kelly Becker - rvm in deploy setup
* 8f6eeb9: Kelly Becker - rvm instead of ruby-build (for now)
* 40ecc80: Kelly Becker - rvm instead of ruby-build (for now)
* bd37cdf: Kelly Becker - whoops made a mistake in the deploy functionality
* 046f6ce: Kelly Becker - new instance
* 8be852f: Kelly Becker - new instance
* dea7c3a: Kelly Becker - trying to free up the stack
* 219991c: Kelly Becker - new deploy config
* 1f7c6c4: Kelly Becker - instance
* c4239f1: Kelly Becker - haproxy
* 459c4ca: Kelly Becker - tracer and refresh
* 92bb5b1: Kelly Becker - proc trace
* d9e47ca: Kelly Becker - ruby active trace
* 20705bf: Kelly Becker - red
* e97f1ca: Kelly Becker - red
* 108e614: Kelly Becker - proc trace
* d180432: Kelly Becker - new instance
* 102f3ab: Kelly Becker - medium instance
* fd2c203: Kelly Becker - updated config
* 75c527f: Kelly Becker - hmmm lets try this
* 63a44f3: Kelly Becker - readded base rubber config
* 73060b5: Kelly Becker - forgot the script
* bdd9b14: Kelly Becker - rebuilding rubber (by deleting)
* 00b04c9: Kelly Becker - added new server

v2.1.3 - Nov 21, 2012  4:55PM PST deployed by Aleks Stanisic
============================================================
* 1cc766c: Elijah Green - Groups message has link to the group

v2.1.2 - Nov 21, 2012  4:35PM PST deployed by Aleks Stanisic
============================================================
* bca2c12: Aleks Stanisic - commenting out Brian's group changes
* 2bf7c67: Elijah Green - Add favorite to discussion comments
* 68aab8e: Elijah Green - redirect_to back to inviteconnections when inviting people
* 324da84: Brian Martinez - changes to group members, dashboard, customers, and support

v2.1.1 - Nov 20, 2012  5:08PM PST deployed by Kelly Becker
==========================================================
* 7f8636b: Kelly Becker - adding more workers
* 520910c: Kelly Becker - new window

v2.1.0 - Nov 20, 2012  4:33PM PST deployed by Kelly Becker
==========================================================
* bcd7e18: Kelly Becker - dun dun dun.... job application walkthrouhg
* be2a717: Kelly Becker - almost done
* 74656a3: Kelly Becker - added step6 to the source needs a bit more work though *yawn*
* a87a049: Kelly Becker - attachments for applications
* ad8afcb: Kelly Becker - credentials in the wizard
* 2497302: Kelly Becker - step4 application process (education)
* 1a113c6: Kelly Becker - updated js
* b479ee6: Kelly Becker - progress;
* c591f77: Kelly Becker - progress
* 406cb5c: Kelly Becker - got import from linkedin working for the application wizard

v2.0.38 - Nov 20, 2012  2:40PM PST deployed by Aleks Stanisic
=============================================================
* af570ec: Brian Martinez - changes to profile edits and prompts

v2.0.37 - Nov 20, 2012  2:23PM PST deployed by Aleks Stanisic
=============================================================
* 60ce7a3: Aleks Stanisic - adding email sharing to discussions, fixed address in all emails
* 3c0ab31: Brian Martinez - adding pronounciation to what is tioki page

v2.0.36 - Nov 20, 2012 10:22AM PST deployed by Kelly Becker
===========================================================
* a407ca0: Kelly Becker - destory video exceptions

v2.0.35 - Nov 20, 2012 10:11AM PST deployed by Kelly Becker
===========================================================
* cb634c6: Kelly Becker - if a youtube video has been deleted then remove the video locally

v2.0.34 - Nov 19, 2012  5:55PM PST deployed by Aleks Stanisic
=============================================================
* c869492: Aleks Stanisic - adding school sign up
* 661488a: Elijah Green - Don't automatically create a teacher for each user created
* 70259e5: Brian Martinez - Revamp of the school side

v2.0.33 - Nov 19, 2012  3:41PM PST deployed by Aleks Stanisic
=============================================================
* 1e6d9a3: Aleks Stanisic - fix to tech page

v2.0.32 - Nov 19, 2012  3:00PM PST deployed by Aleks Stanisic
=============================================================
* f9661c7: Aleks Stanisic - changes to connection action in tech page

v2.0.31 - Nov 19, 2012  2:15PM PST deployed by Aleks Stanisic
=============================================================
* 37d58c2: Aleks Stanisic - changes to dashboard and presentations

v2.0.30 - Nov 19, 2012  1:04PM PST deployed by Aleks Stanisic
=============================================================
* a5e6b71: Aleks Stanisic - changes to awards are presentations time input/output

v2.0.29 - Nov 19, 2012 10:54AM PST deployed by Aleks Stanisic
=============================================================
* 46159e5: Aleks Stanisic - style change to schedule button

v2.0.28 - Nov 19, 2012 10:34AM PST deployed by Aleks Stanisic
=============================================================
* d2a1a3f: Aleks Stanisic - adding link the schedule of events to teacher home page
* 189e2ac: Elijah Green - Add user_id as a getActivity condition

v2.0.27 - Nov 17, 2012  6:11PM PST deployed by Aleks Stanisic
=============================================================
* 6197244: Aleks Stanisic - changes to events

v2.0.26 - Nov 17, 2012  2:30PM PST deployed by Aleks Stanisic
=============================================================
* 81e0a30: Aleks Stanisic - fix to message emails

v2.0.25 - Nov 17, 2012  1:43PM PST deployed by Aleks Stanisic
=============================================================
* 9e8d698: Aleks Stanisic - changes to dashboard
* 3820efe: Elijah Green - Fix referrals only given a single vouch

v2.0.24 - Nov 16, 2012  7:20PM PST deployed by Aleks Stanisic
=============================================================
* f141c4b: Elijah Green - Remove uniqunes validation for now, not working

v2.0.23 - Nov 16, 2012  6:57PM PST deployed by Aleks Stanisic
=============================================================
* 708960b: Elijah Green - Fix add referral add vouches
* 161331c: Elijah Green - Fix the tioki technology being added twice
* 4a22016: Elijah Green - paginate the userconnections page
* f069591: Elijah Green - change how skill vouch are displayed
* 7f8d082: Elijah Green - Referred user vouch for referring user

v2.0.22 - Nov 16, 2012  3:09PM PST deployed by Kelly Becker
===========================================================
* 5e77174: Kelly Becker - commented out a callback that was interfering with paperclip @astanisic @elijahgreen we need to fix this.
* aaa3a36: Kelly Becker - new user.rb
* f69d6c0: Kelly Becker - moved some stuff into the model

v2.0.21 - Nov 16, 2012 11:43AM PST deployed by Aleks Stanisic
=============================================================
* 480f6e9: Aleks Stanisic - chnages to group notification
* fc58d66: Kelly Becker - deploy script fix
* 3b8cb5e: Elijah Green - fix profile for not loggined users

v2.0.20 - Nov 16, 2012 10:08AM PST deployed by Aleks Stanisic
=============================================================
* eb3147e: Aleks Stanisic - making changes to welcome wizard

v2.0.19 - Nov 15, 2012  5:57PM PST deployed by Aleks Stanisic
=============================================================


v2.0.18 - Nov 15, 2012  5:41PM PST deployed by Kelly Becker
===========================================================
* 19bb1cc: Kelly Becker - remember session

v2.0.17 - Nov 15, 2012  5:01PM PST deployed by Kelly Becker
===========================================================
* abb161b: Kelly Becker - dismiss banners
* 73ad495: Kelly Becker - deploy script updates

v2.0.16 - Nov 15, 2012 12:59PM PST deployed by Kelly Becker
===========================================================
* 24c606e: Kelly Becker - graylog new server info

v2.0.15 - Nov 15, 2012 11:40AM PST deployed by Aleks Stanisic
=============================================================
* 995547a: Elijah Green - Profiles fixed for not logined users

v2.0.14 - Nov 14, 2012  6:19PM PST deployed by Aleks Stanisic
=============================================================
* 19ccb93: Elijah Green - Delete whiteboards corresponding to deleted event

v2.0.13 - Nov 14, 2012  5:23PM PST deployed by Kelly Becker
===========================================================
* 8601f29: Kelly Becker - connecting grades and subjects now works
* cd2e0d7: Kelly Becker - tokeninput is not styled properly
* 94a08e0: Kelly Becker - we have tokens!
* 2c77075: Kelly Becker - for the new stuff in place and updated the old js code to coffeescript

v2.0.12 - Nov 14, 2012  5:06PM PST deployed by Aleks Stanisic
=============================================================
* 6fab88d: Brian Martinez - changes to profile and user dropdown menu
* 694d10e: Elijah Green - Log error if not an oauth error
* 6428691: Elijah Green - Checks whether oauth keys are invalid
* c7671ec: Aleks Stanisic - db
* d1e6a73: Brian Martinez - couple more changes to groups to adjust for really long names and descriptions
* 3f3d82e: Brian Martinez - changes to the groups images and headings
* edb7601: Elijah Green - Fix facebook share if the we aren't authenticated wiht facebook yet
* f533672: Kelly Becker - forgot connection tables
* 5013dc4: Kelly Becker - sweep session and reset on logout;
* 1e67805: Kelly Becker - fix the subject table
* 24f8468: Elijah Green - Add share on facebook
* 2e49d3d: Kelly Becker - added new subjects to the seeds
* 214a16f: Elijah Green - Show rails errors in development

v2.0.11 - Nov 14, 2012 11:36AM PST deployed by Kelly Becker
===========================================================
* ca3a190: Kelly Becker - gemlock

v2.0.10 - Nov 14, 2012 11:28AM PST deployed by Kelly Becker
===========================================================
* 276b397: Kelly Becker - gemlock

v2.0.9 - Nov 14, 2012 11:20AM PST deployed by Kelly Becker
==========================================================
* 480cf21: Kelly Becker - pathfile, chronic mod, and localtime
* beb37f6: Brian Martinez - style change on the twitter share on whiteboard
* 4422159: Kelly Becker - added .path file useful if you have multiple versions of rails installed like me

v2.0.8 - Nov 13, 2012 11:56PM PST deployed by Aleks Stanisic
============================================================
* 06c5157: Brian Martinez - changes to the messaging system

v2.0.7 - Nov 13, 2012  7:11PM PST deployed by Aleks Stanisic
============================================================
* 1f1a42e: Elijah Green - Remove tags from twitter message

v2.0.6 - Nov 13, 2012  6:08PM PST deployed by Aleks Stanisic
============================================================
* 382ea45: Elijah Green - Remove some test code from whiteboard.rb

v2.0.5 - Nov 13, 2012  5:48PM PST deployed by Kelly Becker
==========================================================
* 50a74bb: Kelly Becker - banners
* 714647a: Elijah Green - Escape javascript on groups/show page
* f345ab2: Elijah Green - Escape javascript on discussions/show
* ab11dde: Elijah Green - Instead of localhost ip use our domain
* ce58a2e: Elijah Green - Deal with the possibility that the oauth keys are invalid
* 790f3b0: Elijah Green - Some change in wording
* dd00436: Elijah Green - Fix possible bug twitter authorization is canceled
* b6c21a5: Elijah Green - Get twitter oauth keys if we don't have them
* d35a77f: Elijah Green - Have Whiteboard.createActivty return either the saved model or nil if post_always
* 1d4dd50: Elijah Green - Can now tweet whiteboard posts

v2.0.4 - Nov 13, 2012 12:46PM PST deployed by Kelly Becker
==========================================================
* fcdb345: Kelly Becker - graylog

v2.0.3 - Nov 13, 2012 10:33AM PST deployed by Aleks Stanisic
============================================================
* 121e069: Aleks Stanisic - Tioki Tuesday Banner
* a1ce200: Kelly Becker - commented out filter

v2.0.2 - Nov 13, 2012  9:05AM PST deployed by Kelly Becker
==========================================================
* 58b4ac9: Kelly Becker - removed tools
* a0411ce: Kelly Becker - rubber config
* 9b86d96: Kelly Becker - nginx not passenger_nginx
* 454051c: Kelly Becker - made nginx a req
* 16300bd: Kelly Becker - web_tools config
* 7b8e0a4: Kelly Becker - tools server redone

v2.0.1 - Nov 12, 2012 12:09PM PST deployed by Aleks Stanisic
============================================================
* 382ecec: Aleks Stanisic - changes to banner url

v2.0.0 - Nov 12, 2012 11:53AM PST deployed by Aleks Stanisic
============================================================
* db106f4: Aleks Stanisic - gemlock
* b50073e: Aleks Stanisic - changes to tioki banner
* 4b4cc0a: Kelly Becker - production instances now on Unicorn!
* c255023: Brian Martinez - changes to new message
* fdaacd2: Kelly Becker - hozproxy
* 9df9716: Brian Martinez - fix to job description
* 880cb40: Kelly Becker - server instances and added libcurl
* dc37d2c: Kelly Becker - added app permissions
* caf44d5: Kelly Becker - added app permissions
* 7f1c204: Kelly Becker - load rails config into websocket intializer
* 1f532b2: Kelly Becker - shoot was trying to bind to an already bound port
* ce79365: Kelly Becker - whoops this might have made that last comment a failure... removing spawner
* 7d2ab10: Kelly Becker - got a working configuration now fix compile assets
* 03479fb: Kelly Becker - trying to fix an issue with ports conflicting
* df1abcb: Kelly Becker - trying to fix an issue with ports conflicting
* 4dfad4d: Kelly Becker - changing permissions
* 957956f: Kelly Becker - some fixes and the new instance
* 24a4429: Kelly Becker - lets retroactively try an old configuration again ^_^
* 3ae7875: Kelly Becker - update haproxy
* b601c0c: Kelly Becker - hqproxy config update
* 427f0bf: Kelly Becker - I think i got websockets working!
* 0e0e548: Kelly Becker - em-websocket
* c780715: Kelly Becker - faye? .... maybe?
* b987b16: Kelly Becker - lets see if this remotely works xD ... added HaProxy
* 224a5b4: Kelly Becker - deploy script upgrades
* 11641e4: Kelly Becker - massive deploy script upgrades;
* 11a5881: Kelly Becker - massive deploy script upgrades;
* 4a6cbcb: Kelly Becker - big config rewrite
* 8b01b91: Kelly Becker - config dirs now adjustable
* 6d9c507: Kelly Becker - much simpler deploys
* 8067ede: Kelly Becker - much simpler deploys
* 4948be2: Kelly Becker - trying to make the deploy smaller
* 25c5df5: Kelly Becker - show errors on staging
* 9e34df9: Kelly Becker - dependencies
* c56ecb3: Kelly Becker - save
* 6db1064: Kelly Becker - unicorn configuration
* 875b116: Kelly Becker - unicorn configuration

v1.6.9 - Nov 12, 2012  9:42AM PST deployed by Aleks Stanisic
============================================================
* a40f9f5: Aleks Stanisic - flash notice for Tioki Monday
* 81d6d26: Elijah Green - Fix check on whiteboard posts on get_started

v1.6.8 - Nov 12, 2012  9:03AM PST deployed by Aleks Stanisic
============================================================
* 9588a83: Brian Martinez - commenting out donors choose
* e8c1d4e: Brian Martinez - changes to Get Started page

v1.6.7 - Nov 10, 2012  6:56PM PST deployed by Aleks Stanisic
============================================================
* 8fbc4b7: Brian Martinez - changes to signup and login pages

v1.6.6 - Nov 10, 2012  6:25PM PST deployed by Aleks Stanisic
============================================================
* ae8813e: Aleks Stanisic - chages to getting started and tioki bucks
* eaadb2c: Elijah Green - Set tioki_bucks date
* 4e1bf5a: Elijah Green - Some fix and go to get_started on next step
* 389e3dd: Elijah Green - Place get started button in the correct place
* 3854228: Elijah Green - Add get started link to the profile
* 0475927: Elijah Green - Strikeout completed get started tasks
* d6974ee: Elijah Green - Get started actions can happen anytime and create getstarted
* da22083: Elijah Green - Add tioki coins admin list
* 767f005: Elijah Green - Start get adding a tioki coins admin list
* 8645355: Elijah Green - Finished the tioki_bucks page
* 6644d34: Elijah Green - Add tioki_bucks page
* a713913: Elijah Green - Add facebook auth
* 72363dd: Elijah Green - Successfully following tioki
* 3954d35: Elijah Green - Add code for twitter following and twitter tweeting
* ab39bb6: Elijah Green - Add twitter auth

v1.6.5 - Nov 10, 2012  5:56PM PST deployed by Aleks Stanisic
============================================================
* 50360d6: Elijah Green - Add groups search

v1.6.4 - Nov 10, 2012  5:42PM PST deployed by Aleks Stanisic
============================================================
* 4eaf9b0: Aleks Stanisic - fixes to groups

v1.6.3 - Nov 10, 2012  5:24PM PST deployed by Aleks Stanisic
============================================================
* 0975d30: Aleks Stanisic - changes to group members page
* c036bd8: Brian Martinez - groups index public view
* cae50f9: Brian Martinez - public discussion page changes
* d2defab: Brian Martinez - groups changes
* c4a1a6e: Aleks Stanisic - changes to group pages
* 44919f1: Elijah Green - Uncomment css for section#list and remove list id from whiteboard
* 96e0348: Brian Martinez - header changes
* 1436cee: Elijah Green - Set the expiration date for the pop up cookies
* 441679b: Brian Martinez - facebook and twitter like on splash page

v1.6.2 - Nov 9, 2012  1:12PM PST deployed by Kelly Becker
=========================================================
* 18d5dfc: Kelly Becker - excalmation point!

v1.6.1 - Nov 9, 2012 12:56PM PST deployed by Aleks Stanisic
===========================================================
* 6fbd574: Aleks Stanisic - changing groups back

v1.6.0 - Nov 9, 2012 12:40PM PST deployed by Kelly Becker
=========================================================
* 66000d3: Kelly Becker - fixed a style bug and a shre bug
* 4ee4d73: Kelly Becker - comments redesign
* 7c795ef: Kelly Becker - added icons just need to hook em up
* c8529e8: Kelly Becker - whiteboard articles
* e810c99: Kelly Becker - move something into a switch
* b9058dd: Brian Martinez - group changes

v1.5.1 - Nov 8, 2012  1:35PM PST deployed by Kelly Becker
=========================================================
* e0081b0: Kelly Becker - js fix to objects passed by ref

v1.5.0 - Nov 8, 2012  1:21PM PST deployed by Kelly Becker
=========================================================
* a347709: Kelly Becker - got connections working in their own things
* 4021ff9: Elijah Green - Search on teachers on admin
* 16adf2e: Kelly Becker - allow restriction of whiteboard posts
* ac41f71: Kelly Becker - cleanup discussion
* 0a86bfc: Kelly Becker - gem and schema

v1.4.58 - Nov 8, 2012 11:00AM PST deployed by Kelly Becker
==========================================================
* 0a2c38e: Kelly Becker - undid a git commit
* eb2067c: Kelly Becker - cleanup of favorite model
* d75d67b: Kelly Becker - recurse through arrays

v1.4.57 - Nov 7, 2012  7:07PM PST deployed by Aleks Stanisic
============================================================
* a351ac4: Elijah Green - Removing notification bar for now

v1.4.56 - Nov 7, 2012  4:02PM PST deployed by Kelly Becker
==========================================================
* b2c9d7e: Kelly Becker - notifications created unless you created it
* 99f3cb3: Elijah Green - Re-add swapping newlines with breaks on group_email
* 5a6ab41: Kelly Becker - fix to notification allocation
* 0981c13: Elijah Green - show breaks in group invite correctly
* 43bcfdb: Aleks Stanisic - changes to group emails
* 1c5cb6a: Kelly Becker - aplication layout fix

v1.4.55 - Nov 7, 2012  1:56PM PST deployed by Kelly Becker
==========================================================
* d210e8a: Kelly Becker - notifications w00t
* 2ad91cf: Kelly Becker - notifications w00t
* 5db7230: Kelly Becker - updates to defercall and kmodal
* 8ace467: Kelly Becker - notifications popup

v1.4.54 - Nov 7, 2012  1:13PM PST deployed by Aleks Stanisic
============================================================
* 7055961: Elijah Green - On edit experience, output experience like on profile
* a950378: Elijah Green - Add twitter follow and facebook like buttons
* 1e8f2fc: Kelly Becker - application layout cleanup
* 9d6a041: Kelly Becker - added notification icon
* 0d75bb0: Kelly Becker - deploy script updates (now shows timezone of the deployer)

v1.4.53 - Nov 6, 2012  1:32PM PST deployed by Kelly Becker
==========================================================
* 8fdd1c9: Kelly Becker - typo
* 8e67c2c: Elijah Green - Rename twitter initializer and remove global oauth keys

v1.4.52 - Nov 6, 2012  1:11PM deployed by Kelly Becker
======================================================
* 37e4c1e: Kelly Becker - fixes to privacy settings
* 45dff36: Kelly Becker - more fixes and cleanliness
* 574e61f: Kelly Becker - fix some naming issues
* b36950f: Kelly Becker - fix an issue with overriding model methods
* fb29e8d: Kelly Becker - db schema

v1.4.51 - Nov 5, 2012  7:52PM deployed by Aleks Stanisic
========================================================
* 873660b: Brian Martinez - fix to header and groups page

v1.4.50 - Nov 5, 2012  7:25PM deployed by Aleks Stanisic
========================================================
* a214b0a: Brian Martinez - edit and profile changes for icons
* 0a3b2eb: Aleks Stanisic - fixing bug with tech suggestions

v1.4.49 - Nov 5, 2012  4:26PM deployed by Aleks Stanisic
========================================================
* 91fb7d0: Elijah Green - Message all members of a group
* b9dc24a: Brian Martinez - pinterest for teachers and school placeholder
* bdba36e: Elijah Green - Hide the invite checkbox until the box is clicked

v1.4.48 - Nov 5, 2012  1:46PM deployed by Aleks Stanisic
========================================================
* 156f01a: Elijah Green - Add email permissions for emailing comments

v1.4.47 - Nov 5, 2012 11:08AM deployed by Aleks Stanisic
========================================================
* 28b5cf5: Elijah Green - Don't email people the creator of a comment

v1.4.46 - Nov 3, 2012  7:10PM deployed by Aleks Stanisic
========================================================
* 9d42cbd: Aleks Stanisic - pics are now on 5 wide in discussions
* 4b5579e: Elijah Green - If message is from a teacher, link to their profile

v1.4.45 - Nov 3, 2012  5:06PM deployed by Aleks Stanisic
========================================================
* 8fce030: Elijah Green - Messages can only be seen by eitheir the sender or receiver

v1.4.44 - Nov 3, 2012  3:31PM deployed by Aleks Stanisic
========================================================
* 0ba11e5: Elijah Green - Add index on url for teachers
* d0799ca: Elijah Green - Change session to cookies on pages with an intro.

v1.4.43 - Nov 3, 2012  2:19PM deployed by Aleks Stanisic
========================================================
* 967d555: Elijah Green - Fix message notifications

v1.4.42 - Nov 2, 2012  5:08PM deployed by Aleks Stanisic
========================================================
* 5755d1a: Elijah Green - Add notify to delaye job
* 6902cab: Elijah Green - Discussion comments are now emailed

v1.4.41 - Nov 1, 2012  6:20PM deployed by Aleks Stanisic
========================================================
* bc3214c: Elijah Green - Fixing notifications for likes
* 4642c79: Elijah Green - Fix various pages for not logged in users
* 0621d13: Elijah Green - Don't show share with tioki connections if there is no currently logged user
* 32e73ab: Elijah Green - Seperate the likes on different whiteboard post
* d23ef0d: Elijah Green - Set the correct ids for notifications
* 7540bce: Elijah Green - Add more to the notification emailer
* 21658cc: Elijah Green - Link directly to comments of a whiteboard post.
* 4221f82: Elijah Green - Added whiteboard post notification
* 0c7013b: Elijah Green - Add functions for notification mailers
* 0922501: Elijah Green - Finish notifications for discusions and whiteboard
* 0c81249: Elijah Green - Use map tag instead of polymorphic types
* 786f1f7: Elijah Green - Add basic model for notifications

v1.4.40 - Nov 1, 2012 12:04PM deployed by Aleks Stanisic
========================================================
* 9eb5a19: Elijah Green - Add groups/invite to routes

v1.4.39 - Oct 31, 2012  8:19PM deployed by Aleks Stanisic
=========================================================
* 1c7b304: Aleks Stanisic - adding email invites for groups

v1.4.38 - Oct 31, 2012  2:07PM deployed by Aleks Stanisic
=========================================================
* bed5822: Aleks Stanisic - sharing for groups
* 0d30018: Elijah Green - Fix assets uploading
* 9beb2dc: Brian Martinez - Job Posting changes
* 8d467f1: Elijah Green - Fix search by skill

v1.4.37 - Oct 31, 2012  1:17AM deployed by Aleks Stanisic
=========================================================
* b38dfc6: Aleks Stanisic - fixing school profile pictures

v1.4.36 - Oct 31, 2012  1:08AM deployed by Aleks Stanisic
=========================================================
* 1ae87ed: Brian Martinez - school profile page changes

v1.4.35 - Oct 31, 2012 12:42AM deployed by Aleks Stanisic
=========================================================
* 6b5897b: Elijah Green - Make sure only members of a group can comment
* 8a95f95: Elijah Green - Make sure school admins can't use groups
* f526810: Elijah Green - Actaully fix rest of pictures and finish up groups
* 9614c77: Elijah Green - Fix rest of picture uploading
* 07e568c: Elijah Green - Add more things to groups and fix uploading
* 938f75a: Brian Martinez - admin dashboard changes
* 30bd39e: Kelly Becker - groups
* d30c845: Kelly Becker - bitwise conditions for bitswitch
* 0d4741f: Kelly Becker - stripped the repo of agility
* b827976: Kelly Becker - making progress now have saving models through api
* f04e613: Kelly Becker - api
* 314ef94: Kelly Becker - added agility

v1.4.34 - Oct 30, 2012  2:51PM deployed by Aleks Stanisic
=========================================================
* 8d6eb7a: Elijah Green - Have git ignore ctags file
* 6eebdcf: Elijah Green - Deal with deactivated users on specific pages
* afe4437: Elijah Green - Fix typo on whiteboard for links to discussions

v1.4.33 - Oct 30, 2012 10:08AM deployed by Kelly Becker
=======================================================
* 773e886: Kelly Becker - delete connections if the record does not exist and then commented cleanup

v1.4.32 - Oct 29, 2012  4:57PM deployed by Kelly Becker
=======================================================
* 3ead197: Kelly Becker - fix to avatars i hope

v1.4.31 - Oct 29, 2012  4:30PM deployed by Kelly Becker
=======================================================
* 04b439e: Kelly Becker - buckets now using subdomain access

v1.4.30 - Oct 29, 2012  3:56PM deployed by Kelly Becker
=======================================================
* c4e2e56: Kelly Becker - DLEncodedVideo not tioki-video-encoded

v1.4.29 - Oct 29, 2012  3:19PM deployed by Aleks Stanisic
=========================================================


v1.4.28 - Oct 29, 2012  3:18PM deployed by Aleks Stanisic
=========================================================
* 5850fef: Elijah Green - Anchor tag for for clicking on reply to discussion
* 6569681: Elijah Green - If the current user is not logged in don't show email and phone
* baf3c65: Aleks Stanisic - bug fix to wizard step 1 and minor design change to discover page
* b869106: Kelly Becker - migrates all video buckets to the new location
* 1cc40c9: Brian Martinez - press and static changes
* 6131280: Elijah Green - Switch back to old way of uploading pictures.
* d3b2dd5: Kelly Becker - renamed some s3 buckets during transfer to oregon
* 5ba1708: Kelly Becker - added missing jquery icons

v1.4.27 - Oct 25, 2012  9:24PM deployed by Aleks Stanisic
=========================================================
* 75f0b04: Aleks Stanisic - changes to dashboard

v1.4.26 - Oct 25, 2012  8:52PM deployed by Aleks Stanisic
=========================================================


v1.4.25 - Oct 25, 2012  8:43PM deployed by Aleks Stanisic
=========================================================
* fccbddd: Aleks Stanisic - adding discussions to teacher dashboard

v1.4.24 - Oct 25, 2012  6:05PM deployed by Aleks Stanisic
=========================================================
* 8e0c0f3: Elijah Green - Fix uploading by rolling back some gems.
* 98bf1c2: Kelly Becker - added app02

v1.4.23 - Oct 25, 2012  4:27PM deployed by Kelly Becker
=======================================================
* 8de8fbd: Kelly Becker - added discussions to the whiteboard
* 21236d4: Elijah Green - Fix adding full and limited admins
* efa9771: Kelly Becker - discussions style change
* 9d7b630: Aleks Stanisic - adding search filter title

v1.4.22 - Oct 25, 2012  3:41PM deployed by Kelly Becker
=======================================================
* 98660c1: Kelly Becker - sharing discussions to connections
* 5c440cc: Kelly Becker - making progress
* 4e7990f: Elijah Green - Don't show rsvp buttons if a user is not logged in
* 0159d59: Elijah Green - Don't link to invite friends for not logged in users
* ab90135: Elijah Green - Fix search on school not being rest correctly
* d3d690f: Elijah Green - Small fix to connections searching on schools
* 50ded49: Elijah Green - Add school search
* 61e63e4: Elijah Green - Got search on skills working.
* 634d65a: Elijah Green - Add some javascript for removing the original elements and make sure if there is no input don't show anything
* 446c24d: Elijah Green - Add search dropdowns
* ee07221: Elijah Green - actaully have the search function correclt
* ff983e0: Elijah Green - add new search function for connections
* aa215a5: Kelly Becker - added tioki icon and link

v1.4.21 - Oct 24, 2012  7:46PM deployed by Aleks Stanisic
=========================================================
* c21a477: Aleks Stanisic - changing suggested connections number to 3

v1.4.20 - Oct 24, 2012 12:57PM deployed by Aleks Stanisic
=========================================================
* a1d9d22: Elijah Green - Deal with removing bad url characters from from teacher urls better
* 099581d: Elijah Green - Fix error on events/show when user is not logged in

v1.4.19 - Oct 24, 2012 11:37AM deployed by Aleks Stanisic
=========================================================
* 7ee1a28: Elijah Green - If an error occurs in our version of Hash.collect, use the orginal version

v1.4.18 - Oct 23, 2012  6:01PM deployed by Aleks Stanisic
=========================================================
* cdcf9b9: Aleks Stanisic - changing twitter share on discussions

v1.4.17 - Oct 23, 2012  5:32PM deployed by Aleks Stanisic
=========================================================
* e3d36d3: Brian Martinez - who's viewed your profile and invitation notifications

v1.4.16 - Oct 23, 2012  5:18PM deployed by Aleks Stanisic
=========================================================
* dadb164: Aleks Stanisic - changing welcome emails
* 81284c7: Elijah Green - Speed up discussions pages

v1.4.15 - Oct 23, 2012  4:41PM deployed by Kelly Becker
=======================================================
* 8d1993a: Elijah Green - Fix styling of discussions
* b1eabb7: Elijah Green - Fix to broken is statement on discussions/show

v1.4.14 - Oct 23, 2012  4:40PM deployed by Kelly Becker
=======================================================


v1.4.13 - Oct 23, 2012  4:18PM deployed by Kelly Becker
=======================================================
* 49facbf: Kelly Becker - facebook js api fix
* 5305dc6: Elijah Green - If a replying user isn't loggined send send them to step 1 of welcome wizard

v1.4.12 - Oct 23, 2012  3:52PM deployed by Kelly Becker
=======================================================
* ec4470e: Kelly Becker - share discussions
* 74a75ee: Kelly Becker - sort events on discover page by start_time asc

v1.4.11 - Oct 23, 2012  2:21PM deployed by Aleks Stanisic
=========================================================
* 71b6625: Aleks Stanisic - changes to discovery page' '
* a270eb0: Elijah Green - Fix error where users that weren't logged in couldn't see a discussion
* cb56055: Elijah Green - Fix error where users that weren't logged in couldn't see a discussion

v1.4.10 - Oct 23, 2012  1:25PM deployed by Aleks Stanisic
=========================================================
* 960f21b: Elijah Green - Fix donors choose and referral page

v1.4.9 - Oct 23, 2012 12:52PM deployed by Kelly Becker
======================================================
* a7853a5: Kelly Becker - updated discover page

v1.4.8 - Oct 23, 2012 12:35PM deployed by Aleks Stanisic
========================================================
* 742cc9f: Aleks Stanisic - wizard step 1 redesign
* 550433b: Elijah Green - Fix a few typos
* cb2138b: Elijah Green - Allow unfollowing of discussions

v1.4.7 - Oct 23, 2012 11:44AM deployed by Kelly Becker
======================================================
* cb4a4dd: Kelly Becker - whiteboard comments
* ae5a860: Aleks Stanisic - changes to wizard step 1
* 57cfde0: Kelly Becker - whiteboard comments

v1.4.6 - Oct 23, 2012 11:22AM deployed by Aleks Stanisic
========================================================
* 01c413f: Elijah Green - Only show reply if there is a current user and they are a teacher
* 4530f8a: Elijah Green - Add width auto to discussion comments
* 34b41a4: Elijah Green - Only show referrals where users were created after donors choose

v1.4.5 - Oct 23, 2012 10:22AM deployed by Kelly Becker
======================================================
* 26691c8: Kelly Becker - favoriting fix

v1.4.4 - Oct 22, 2012  6:09PM deployed by Aleks Stanisic
========================================================
* 5e50664: Aleks Stanisic - changes to profile completion guide
* fe37d29: Elijah Green - End donorschoose
* 8557558: Elijah Green - redirect to the profile correctly

v1.4.3 - Oct 22, 2012  3:43PM deployed by Kelly Becker
======================================================
* 889ef5d: Elijah Green - fix javascript on discussions form
* 66926ad: Kelly Becker - updated hide/delete methods of whiteboard posts
* bed63f1: Elijah Green - remove ifve refferals emails on account creation
* 0b3764f: Kelly Becker - updated hide/delete methods of whiteboard posts
* 5de9c2d: Kelly Becker - remove tooltips after removing the parent element
* 41f0907: Elijah Green - add connections like header to discussions

v1.4.2 - Oct 22, 2012  1:17PM deployed by Aleks Stanisic
========================================================
* 313814f: Aleks Stanisic - fix to favorite.rb

v1.4.1 - Oct 22, 2012  1:07PM deployed by Aleks Stanisic
========================================================
* 6fd06ff: Kelly Becker - figure out favorite not found issue
* e082cd3: Kelly Becker - figure out favorite not found issue
* f0a9b3f: Kelly Becker - technology comments
* 5e47225: Kelly Becker - technology comments
* b3aa273: Kelly Becker - deleting and favoriting of event comments as well as the fix for NaN on favorites

v1.4.0 - Oct 22, 2012 12:22PM deployed by Aleks Stanisic
========================================================
* d5e3979: Kelly Becker - comments are now ajax
* 5c42009: Elijah Green - Add replies to button of comments and add links and paragraphs
* 5c41fa0: Aleks Stanisic - changes to header
* b4806e4: Aleks Stanisic - changes to vouch email, bug fixes to dashboard and wizard
* 507c496: Aleks Stanisic - changes to donor choose wording
* 0f436e5: Brian Martinez - discussions changes
* 76a6fb1: Elijah Green - Add comment form ondiscussion show
* 01dcc36: Kelly Becker - event comments
* 8fa1149: Kelly Becker - added whiteboard comments
* cb60866: Kelly Becker - favorites
* 46b047e: Kelly Becker - favorites
* db6c1ec: Kelly Becker - favorites working ish
* 769d2d1: Elijah Green - Add name of an event to the url
* 5ceddc3: Kelly Becker - debugging some code for you
* 8e8a498: Elijah Green - Add title to url
* 8d99b9b: Elijah Green - If user is deleted don't show name or avatar
* 51b20da: Elijah Green - Fix other users able to link to edit and delete to other users comments
* a3ef728: Elijah Green - Make sure site admins can update other users comments
* 1e8e1bb: Elijah Green - Add discussion to skills page and fix edit comment.
* d51f663: Elijah Green - Fix up some pages and link to profile for all names and images
* 69ce560: Elijah Green - Editing skills of discussions
* 454d5e5: Elijah Green - Allow the user to  edit and delete their message
* 61b8dc4: Elijah Green - Add some more controller methods for deletion and resotring of messages
* 58ecfc0: Elijah Green - Can't only reply if teacher
* 29e67e6: Elijah Green - Add the ui for skills
* 87ddc0f: Elijah Green - Add some style to discussions
* 0db01cf: Kelly Becker - schema gemlock
* 465be4f: Elijah Green - Add some more things to migrations and finish up replies
* 7204892: Elijah Green - Add comments and replying to discussion
* 0c66cdd: Elijah Green - Add tables for discussions

v1.3.35 - Oct 19, 2012  2:25PM deployed by Kelly Becker
=======================================================
* 555c58b: Kelly Becker - event invite redesign
* 95e2c45: Elijah Green - Remove old login tokens
* c590af7: Kelly Becker - event rsvps no longer have deadlines
* 4256fa0: Kelly Becker - tz removal

v1.3.34 - Oct 19, 2012  1:04PM deployed by Kelly Becker
=======================================================
* 17f9ecd: Elijah Green - Add stay signed in checkbox for logins

v1.3.33 - Oct 19, 2012 12:54PM deployed by Kelly Becker
=======================================================
* fd3b401: Kelly Becker - possible speed up to nginx might also crash it
* f395c70: Kelly Becker - fix to a format

v1.3.32 - Oct 19, 2012 12:41PM deployed by Kelly Becker
=======================================================
* ca2cfa9: Kelly Becker - events redesign
* 06bce1d: Elijah Green - Change some links to skills/show instead of teacher_skills
* 034fc10: Elijah Green - Replace teacherskills with show and the skill name as part of the url

v1.3.31 - Oct 19, 2012 10:46AM deployed by Kelly Becker
=======================================================
* 7d437c4: Aleks Stanisic - changes to whiteboard
* 7b3daef: Kelly Becker - show stuff other then shares again
* 487306e: Elijah Green - Add name of technology to the technology_url
* 034e53a: Kelly Becker - removed chosen because it was not working properly and isnt 100% needed.

v1.3.30 - Oct 19, 2012  9:57AM deployed by Kelly Becker
=======================================================
* 96df16b: Kelly Becker - whiteboard timeline
* d5b3b37: Brian Martinez - how it works changes plus header fixes

v1.3.29 - Oct 18, 2012  6:33PM deployed by Aleks Stanisic
=========================================================
* 22d05f1: Aleks Stanisic - changes to teacher dashboard

v1.3.28 - Oct 18, 2012  5:50PM deployed by Kelly Becker
=======================================================
* 8fc6ed5: Kelly Becker - add skills to events
* 11ca4b0: Kelly Becker - added rsvping for remote events

v1.3.27 - Oct 18, 2012  2:34PM deployed by Kelly Becker
=======================================================
* e1768e2: Kelly Becker - tooltips and ajaxed whiteboard functions
* aba9e51: Kelly Becker - staring is now ajaxified
* 9bbb592: Kelly Becker - delete button now has a wider li if deleteable
* 5559a1b: Kelly Becker - tooltips and delete button
* 0541d6d: Kelly Becker - made rubber use us-west-2c to save money for now

v1.3.26 - Oct 18, 2012 10:54AM deployed by Kelly Becker
=======================================================
* e7f6115: Kelly Becker - fixed issues with schools showing up on technologies page breaking things, also paginate the teacher list.

v1.3.25 - Oct 18, 2012 10:33AM deployed by Kelly Becker
=======================================================
* 6a1b258: Kelly Becker - migration script to connect all users to tioki if they are not already. as well as auto connecting on registration
* 7198172: Kelly Becker - migration script to connect all users to tioki if they are not already. as well as auto connecting on registration

v1.3.24 - Oct 18, 2012 10:12AM deployed by Kelly Becker
=======================================================
* ffa7967: Kelly Becker - removed follow language
* a812686: Brian Martinez - splash and what is tioki changes

v1.3.23 - Oct 17, 2012  6:59PM deployed by Aleks Stanisic
=========================================================
* 010db8e: Brian Martinez - GeGe's City Update

v1.3.22 - Oct 17, 2012  5:01PM deployed by Kelly Becker
=======================================================
* 43a3d38: Kelly Becker - fix for css break for suggested connections and also added all shares, event rsvps, and event creations to the dashboard

v1.3.21 - Oct 17, 2012  4:44PM deployed by Kelly Becker
=======================================================
* 9a840e0: Kelly Becker - hide post

v1.3.20 - Oct 17, 2012  3:05PM deployed by Kelly Becker
=======================================================
* ce2a801: Kelly Becker - whiteboard posting is now limited by an hour. If you want a post to always go through regardless of this limiting pass the slug as a string instead of a symbol

v1.3.19 - Oct 17, 2012  2:26PM deployed by Kelly Becker
=======================================================
* eba440d: Kelly Becker - fixed the suggested connection query @astanisic while this works we REALLY need to look into caching these results. the query takes 59ms!!! this is a little over the top. If it is feasible newrelic might be a good add on to our platform to help us with optimization

v1.3.18 - Oct 17, 2012  1:58PM deployed by Kelly Becker
=======================================================
* 102938b: Kelly Becker - fix to skill 130 not existing
* 47ca101: Brian Martinez - changes to splash page

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
