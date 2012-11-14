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
