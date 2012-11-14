# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

subjects = Subject.create([
  { :name => 'Language Arts' },
  { :name => 'Mathematics' },
  { :name => 'Science' },
  { :name => 'Health' },
  { :name => 'Handwriting' },
  { :name => 'Physical Education (P.E.)' },
  { :name => 'Art' },
  { :name => 'Music' },
  { :name => 'Movement or Eurythmy' },
  { :name => 'Handwork or handcrafts' },
  { :name => 'Life Lab or gardening' },
  { :name => 'Dramatics' },
  { :name => 'Dance' },
  { :name => 'Spanish or other foreign language' },
  { :name => 'Leadership' },
  { :name => 'Special Education Day Class' },
  { :name => 'Resource Program' },
  { :name => 'Speech' },
  { :name => 'Adaptive P.E.' },
  { :name => 'Occupational Therapy' },
  { :name => 'Reading' },
  { :name => 'Speech and Debate' },
  { :name => 'English' },
  { :name => 'Basic Math' },
  { :name => 'Pre' },-{ :name => 'algebra' },
  { :name => 'Consumer Math' },
  { :name => 'Algebra' },
  { :name => 'Geometry' },
  { :name => 'Honors Math in Algebra or Geometry' },
  { :name => 'Life Science' },
  { :name => 'Earth Science' },
  { :name => 'Physical Science' },
  { :name => 'Social Studies' },
  { :name => 'Geography' },
  { :name => 'Ancient Civilizations' },
  { :name => 'Medieval and Renaissance' },
  { :name => 'U.S. History and Government' },
  { :name => 'French / Spanish / Latin' },
  { :name => 'Computer Lab' },
  { :name => 'Computer Science' },
  { :name => 'Home Economics' },
  { :name => 'Woodshop' },
  { :name => 'Metal Shop' },
  { :name => 'Business Technology' },
  { :name => 'Instrumental Music' },
  { :name => 'Band' },
  { :name => 'Choir' },
  { :name => 'Drama' },
  { :name => 'Physical Education' },
  { :name => 'Sports' },
  { :name => 'Speech Therapy' },
  { :name => 'English I' },
  { :name => 'English II' },
  { :name => 'English III' },
  { :name => 'English IV' },
  { :name => 'Remedial English' },
  { :name => 'World Literature' },
  { :name => 'Ancient Literature' },
  { :name => 'Medieval Literature' },
  { :name => 'Renaissance Literature' },
  { :name => 'Modern Literature' },
  { :name => 'British Literature' },
  { :name => 'American Literature' },
  { :name => 'Composition' },
  { :name => 'Creative Writing' },
  { :name => 'Poetry' },
  { :name => 'Grammar' },
  { :name => 'Vocabulary' },
  { :name => 'Debate' },
  { :name => 'Journalism' },
  { :name => 'Publishing Skills' },
  { :name => 'Photojournalism' },
  { :name => 'Yearbook' },
  { :name => 'Study Skills' },
  { :name => 'Research Skills' },
  { :name => 'Fine Arts' },
  { :name => 'Art I' },
  { :name => 'Art II' },
  { :name => 'Art III' },
  { :name => 'Art IV' },
  { :name => 'Art Appreciation' },
  { :name => 'Art History' },
  { :name => 'Drawing' },
  { :name => 'Painting' },
  { :name => 'Sculpture' },
  { :name => 'Ceramics' },
  { :name => 'Pottery' },
  { :name => 'Music Appreciation' },
  { :name => 'Music History' },
  { :name => 'Music Theory' },
  { :name => 'Music Fundamentals' },
  { :name => 'Orchestra' },
  { :name => 'Voice' },
  { :name => 'Classical Music Studies' },
  { :name => 'Performing Arts' },
  { :name => 'Theatre Arts' },
  { :name => 'Improvisational Theater' },
  { :name => 'Computer Aided Design' },
  { :name => 'Digital Media' },
  { :name => 'Photography' },
  { :name => 'Videography' },
  { :name => 'History of Film' },
  { :name => 'Film Production' },
  { :name => 'Leather Working' },
  { :name => 'Drafting' },
  { :name => 'Metal Work' },
  { :name => 'Small Engine Mechanics' },
  { :name => 'Auto Mechanics' },
  { :name => 'General Science' },
  { :name => 'Physics' },
  { :name => 'Chemistry' },
  { :name => 'Organic Chemistry' },
  { :name => 'Biology' },
  { :name => 'Zoology' },
  { :name => 'Marine Biology' },
  { :name => 'Botany' },
  { :name => 'Geology' },
  { :name => 'Oceanography' },
  { :name => 'Meteorology' },
  { :name => 'Astronomy' },
  { :name => 'Animal Science' },
  { :name => 'Equine Science' },
  { :name => 'Veterinary Science' },
  { :name => 'Forensic Science' },
  { :name => 'Ecology' },
  { :name => 'Environmental Science' },
  { :name => 'Gardening' },
  { :name => 'Food Science' },
  { :name => 'Spanish' },
  { :name => 'French' },
  { :name => 'Japanese' },
  { :name => 'German' },
  { :name => 'Latin' },
  { :name => 'Greek' },
  { :name => 'Hebrew' },
  { :name => 'Chinese' },
  { :name => 'Sign Language' },
  { :name => 'Remedial Math' },
  { :name => 'Fundamental Math or Basic Math' },
  { :name => 'Introduction to Algebra' },
  { :name => 'Algebra I' },
  { :name => 'Algebra II' },
  { :name => 'Intermediate Algebra' },
  { :name => 'Trigonometry' },
  { :name => 'Precalculus' },
  { :name => 'Calculus' },
  { :name => 'Statistics' },
  { :name => 'Business Math' },
  { :name => 'Accounting' },
  { :name => 'Personal Finance and Investing' },
  { :name => 'Ancient History' },
  { :name => 'Medieval History' },
  { :name => 'Greek and Roman History' },
  { :name => 'Renaissance History with US History' },
  { :name => 'Modern History with US History' },
  { :name => 'World History' },
  { :name => 'World Geography' },
  { :name => 'US History' },
  { :name => 'World Religions' },
  { :name => 'World Current Events' },
  { :name => 'Global Issues' },
  { :name => 'Government' },
  { :name => 'Civics' },
  { :name => 'Economics' },
  { :name => 'Political Science' },
  { :name => 'Social Sciences' },
  { :name => 'Psychology' },
  { :name => 'Sociology' },
  { :name => 'Anthropology' },
  { :name => 'Genealogy' },
  { :name => 'Philosophy' },
  { :name => 'Logic I' },
  { :name => 'Logic II' },
  { :name => 'Critical Thinking' },
  { :name => 'Rhetoric' },
  { :name => 'Basic First Aid and Safety' },
  { :name => 'Nutrition' },
  { :name => 'Healthful Living' },
  { :name => 'Personal Health' },
  { :name => 'Team Sports' },
  { :name => 'Gymnastics' },
  { :name => 'Track and Field' },
  { :name => 'Archery' },
  { :name => 'Fencing' },
  { :name => 'Golf' },
  { :name => 'Rock Climbing' },
  { :name => 'Outdoor Survival Skills' },
  { :name => 'Hiking' },
  { :name => 'Equestrian Skills' },
  { :name => 'Weightlifting' },
  { :name => 'Physical Fitness' },
  { :name => 'Aerobics' },
  { :name => 'Yoga' },
  { :name => 'Martial Arts' },
  { :name => 'Ice Skating' },
  { :name => 'Figure skating' },
  { :name => 'Cycling' },
  { :name => 'Bowling' },
  { :name => 'Drill Team, Honor Guard, Pageantry, Flag, Cheer' },
  { :name => 'Adapted P.E' },
  { :name => 'Keyboarding' },
  { :name => 'Word Processing' },
  { :name => 'Computer Aided Drafting' },
  { :name => 'Computer Applications' },
  { :name => 'Computer Graphics' },
  { :name => 'Digital Arts' },
  { :name => 'Photoshop' },
  { :name => 'Programming' },
  { :name => 'Computer Repair' },
  { :name => 'Web Design' },
  { :name => 'Desktop Publishing' },
  { :name => 'Culinary Arts' },
  { :name => 'Child Development' },
  { :name => 'Home Management' },
  { :name => 'Home Organization' },
  { :name => 'Basic Yard Care' },
  { :name => 'Financial Management' },
  { :name => 'Driver\'s Education' },
  { :name => 'Personal Organization' },
  { :name => 'Social Skills' },
  { :name => 'Career Planning' },
  { :name => 'SAT Prep' },
  { :name => 'Work-Study' },
  { :name => 'Lifeskills' },
  { :name => 'Special Day Class' },
  { :name => 'Campus Culture' },
  { :name => 'Character Education' }
])

skill_groups = SkillGroup.create([
  {:name => 'Technology', :badge_url => '/assets/badges/technology.png', :placeholder => "This teacher is wise in the ways of technology in the classroom.  Did you know that 51% of eight graders haven't used a computer for school? Change it." }, 
  {:name => 'Lesson Plans', :badge_url => '/assets/badges/lesson-plans.png', :placeholder => "This teacher's lesson planning powers are especially skilled.  Did you know that on average Chicago teachers work 53 hour weeks?" }, 
  {:name => 'Lesson Materials', :badge_url => '/assets/badges/lesson-materials.png', :placeholder => "Developing materials and tools for class is a specialty for this teacher. Did you know that 48% of classrooms have a LCD or DLP projector in them?" }, 
  {:name => 'Assesment', :badge_url => '/assets/badges/assessment.png', :placeholder => "This teacher makes assessing students an art.  Did you know that using digital games can increase test scores? (Like, 20%!)" }, 
  {:name => 'Culture Building', :badge_url => '/assets/badges/culture-building.png', :placeholder => "This spirited teacher has great skills building a valuable learning environment.  Did you know that after-school programs increase attendance, behavior and course work?" }, 
  {:name => 'Life Skills', :badge_url => '/assets/badges/life-skills.png', :placeholder => "This teacher is an amazing guide for life and lights the way for students' futures.  Did you know that unemployment halved for college graduates?" }, 
  {:name => 'Pedagogy Themes', :badge_url => '/assets/badges/pedagogy-themes.png', :placeholder => "Innovative teaching strategies are a forte for this teacher.  Did you know that 3/4 of teachers think they need more technology in class?"}, 
  {:name => 'Career Development', :badge_url => '/assets/badges/career-development.png', :placeholder => "This teacher is ace at prepping a student to begin their career.  Did you know that college graduates, on average, earn 38% more?" }, 
  {:name => 'Teacher Leadership', :badge_url => '/assets/badges/teacher-leadership.png', :placeholder => "Leading the charge is a great strength for this teacher.  Did you know that Gene Simmons use to teach 6th grade?" }, 
  {:name => 'Specialized Training', :badge_url => '/assets/badges/specialized-training.png', :placeholder => "This teacher has been upgraded thanks to great teacher organizations.  Did you know that Teach for America has nearly 28,000 Corps Members?" }
])

skills = Skill.create([
  {:name => 'Interactive Whiteboards', :skill_group_id => skill_groups.first.id},
  {:name => 'iPad', :skill_group_id => skill_groups.first.id},
  {:name => 'Tablet', :skill_group_id => skill_groups.first.id},
  {:name => 'Education Apps', :skill_group_id => skill_groups.first.id},
  {:name => '1:1 Laptop/Computer Learning', :skill_group_id => skill_groups.first.id},
  {:name => 'Flipped Classroom', :skill_group_id => skill_groups.first.id},
  {:name => 'BYOD (Bring Your Own Device)', :skill_group_id => skill_groups.first.id},
  {:name => 'Digital Portfolios', :skill_group_id => skill_groups.first.id},
  {:name => 'Virtual Classroom', :skill_group_id => skill_groups.first.id},
  {:name => 'Social Media/Web 2.0', :skill_group_id => skill_groups.first.id},
  {:name => 'learning with Mobile Devices', :skill_group_id => skill_groups.first.id},
  {:name => 'Multimedia/Video', :skill_group_id => skill_groups.first.id},
  {:name => 'Podcasting', :skill_group_id => skill_groups.first.id},
  {:name => 'Web/Internet', :skill_group_id => skill_groups.first.id},
  {:name => 'Technology Standards', :skill_group_id => skill_groups.first.id},
  {:name => 'Technology Integration', :skill_group_id => skill_groups.first.id},
  {:name => 'Vision & Goals', :skill_group_id => skill_groups[1].id},
  {:name => 'Pacing Plans', :skill_group_id => skill_groups[1].id},
  {:name => 'Standards', :skill_group_id => skill_groups[1].id},
  {:name => 'Units', :skill_group_id => skill_groups[1].id},
  {:name => 'Lessons', :skill_group_id => skill_groups[1].id},
  {:name => 'Presentations', :skill_group_id => skill_groups[2].id},
  {:name => 'Student Materials (e.g. handouts, homework)', :skill_group_id => skill_groups[2].id},
  {:name => 'Projects, Labs, Activities', :skill_group_id => skill_groups[2].id},
  {:name => 'Groupwork', :skill_group_id => skill_groups[2].id},
  {:name => 'Classroom Environment', :skill_group_id => skill_groups[3].id},
  {:name => 'Behavior/Classroom Management', :skill_group_id => skill_groups[3].id},
  {:name => 'Investment', :skill_group_id => skill_groups[3].id},
  {:name => 'Families & Communities', :skill_group_id => skill_groups[3].id},
  {:name => 'Summer Projects & Activities', :skill_group_id => skill_groups[3].id},
  {:name => 'Back-to-School', :skill_group_id => skill_groups[3].id},
  {:name => 'Field Trips & Celebrations', :skill_group_id => skill_groups[3].id},
  {:name => 'Fundraising', :skill_group_id => skill_groups[3].id},
  {:name => 'Review & Test Prep', :skill_group_id => skill_groups[4].id},
  {:name => 'Research Skills', :skill_group_id => skill_groups[4].id},
  {:name => 'Study/Test Skills', :skill_group_id => skill_groups[4].id},
  {:name => 'Rubrics', :skill_group_id => skill_groups[4].id},
  {:name => 'Standards-Aligned Assessments', :skill_group_id => skill_groups[4].id},
  {:name => 'Common Core', :skill_group_id => skill_groups[4].id},
  {:name => 'Social Skills & Character', :skill_group_id => skill_groups[5].id},
  {:name => 'College & Career', :skill_group_id => skill_groups[5].id},
  {:name => 'Entrepreneurship', :skill_group_id => skill_groups[5].id},
  {:name => 'Project, Problem, & Challenge-based Learning', :skill_group_id => skill_groups[6].id},
  {:name => 'Problem Solving & Critical Thinking', :skill_group_id => skill_groups[6].id},
  {:name => 'Social Justice/Critical Pedagogy', :skill_group_id => skill_groups[6].id},
  {:name => '21st Century Teaching/Learning', :skill_group_id => skill_groups[6].id},
  {:name => 'Digital Citizenship', :skill_group_id => skill_groups[6].id},
  {:name => 'International/Global', :skill_group_id => skill_groups[6].id},
  {:name => 'Resume Support', :skill_group_id => skill_groups[7].id},
  {:name => 'Interview Support', :skill_group_id => skill_groups[7].id},
  {:name => 'Demo Lesson', :skill_group_id => skill_groups[7].id},
  {:name => 'Teacher Observation', :skill_group_id => skill_groups[8].id},
  {:name => 'Teacher Coaching/Mentorship', :skill_group_id => skill_groups[8].id},
  {:name => 'Professional Development', :skill_group_id => skill_groups[8].id},
  {:name => 'Teach for America', :skill_group_id => skill_groups[9].id},
  {:name => 'The New Teacher Project', :skill_group_id => skill_groups[9].id},
  {:name => 'TeachPlus', :skill_group_id => skill_groups[9].id},
  {:name => 'The College Ready Promise', :skill_group_id => skill_groups[9].id}
])
                     
topics = Eventtopic.create([
  { :name => '1:1 Classrooms and Schools' },
  { :name => 'Behavior management' },
  { :name => 'Bring Your Own Device (BYOD)' },
  { :name => 'College & career preparation' },
  { :name => 'Edtech' },
  { :name => 'Entrepreneurship' },
  { :name => 'Family/Community' },
  { :name => 'Flipped Classroom' },
  { :name => 'Home schooling' },
  { :name => 'Humanities' },
  { :name => 'Investment/culture building' },
  { :name => 'International education' },
  { :name => 'Job support' },
  { :name => 'Lesson and assessment planning' },
  { :name => 'Life/social skills' },
  { :name => 'Networking' },
  { :name => 'Political Advocacy' },
  { :name => 'Professional development' },
  { :name => 'Project-based learning' },
  { :name => 'School Leadership' },
  { :name => 'Social Justice/critical pedagogy' },
  { :name => 'Standards-based teaching and grading' },
  { :name => 'STEM' },{ :name => 'Virtual learning' }
])

format = Eventformat.create([
  { :name => "Conference", :virtual => 0 },
  { :name => "Course/Class", :virtual => 0 },
  { :name => "Exhibit/Expo", :virtual => 0 },
  { :name => "Forum/Panel Discussion", :virtual => 0 },
  { :name => "Meet-up", :virtual => 0 },
  { :name => "Professional Learning Network (PLN)", :virtual => 0 },
  { :name => "Presentation", :virtual => 0 },
  { :name => "Online Course/Class", :virtual => 1 },
  { :name => "Phone conference", :virtual => 1 },
  { :name => "Podcast", :virtual => 1 },
  { :name => "Twitter", :virtual => 1 },
  { :name => "Television", :virtual => 1 },
  { :name => "Webinar", :virtual => 1 }
])
