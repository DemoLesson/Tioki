desc "Remove second flipped classroom skill"
task :remove_flipped_classroom => :environment do
	current_skill = Skill.where("name = 'Flipped Classroom'").first
	skill_to_delete = Skill.where("name = 'Flipped Classroom'").last

	if current_skill.id == skill_to_delete.id
		#protection from running twice
		return
	end

	# Skill claims
	user_ids = SkillClaim.where("skill_id = ?", current_skill.id).collect(&:user_id)
	skill_claims = SkillClaim.where("skill_id = ?", skill_to_delete.id)

	skill_claims.each do |skill_claim|
		if !user_ids.include?(skill_claim.user_id)
			SkillClaim.create(:user_id => skill_claim.user_id, :skill_id => current_skill.id )
		end
	end

	# Vouched Skills
	user_ids = VouchedSkill.where("skill_id = ?", current_skill.id).collect(&:user_id)
	skill_vouches = SkillClaim.where("skill_id = ?", skill_to_delete.id)

	skill_vouches.each do |skill_vouch|
		if !user_ids.include?(skill_claim.user_id)
			SkillVouch.create(:user_id => skill_vouch.user_id, :skill_id => current_skill.id, :vouch_id => skill_vouch.vouch_id, :voucher_id => skill_vouch.voucher_id )
		end
	end

	# Technologies
	technology_ids = TechnologyTag.where("skill_id = ?", current_skill.id).collect(&:technology_id)
	technology_tags = TechnologyTag.where("skill_id = ?", skill_to_delete.id)

	technology_tags.each do |technology_tag|
		if !technology_ids.include?(technology_tag.technology_id)
			TechnologyTag.create(:technology_id => technology_tag.technology_id, :skill_id => current_skill.id)
		end
	end

	# Discussions
	discussion_ids = DiscussionTag.where("skill_id = ?", current_skill.id).collect(&:discussion_id)
	discussion_tags = DiscussionTag.where("skill_id = ?", skill_to_delete.id)

	discussion_tags.each do |discussion_tag|
		if !discussion_ids.include?(discussion_tag.disucssion_id)
			DiscussionTag.create(:discussion_id => discussion_tag.discussion_id, :skill_id => current_skill.id)
		end
	end

	skill_to_delete.destroy
end

desc "Add and change skills 02/18/2013"
task :change_skills3 => :environment do
	#Technology
  if ((skill_group = SkillGroup.where("name = ?", "Technology").first) != nil)
		Skill.create!(:skill_group_id => skill_group.id, :name => "MOOCs")
		Skill.create!(:skill_group_id => skill_group.id, :name => "Digital Presentation")
  end
	
	# Culture Building
  if ((skill_group = SkillGroup.where("name = ?", "Culture Building").first) != nil)
  end

	# Assessment
  if ((skill_group = SkillGroup.where("name = ?", "Assessment").first) != nil)
  end

	# Life Skills
  if ((skill_group = SkillGroup.where("name = ?", "Life Skills").first) != nil)
		# Dependent detroy
		skill_group.destroy
  end

	# Pedagogy Themes
  if ((skill_group = SkillGroup.where("name = ?", "Pedagogy Themes").first) != nil)
  end

	# Specialized Training
  if ((skill_group = SkillGroup.where("name = ?", "Specialized Training").first) != nil)
  end

	# Whatever this is
  if ((skill_group = SkillGroup.where("name = ?", "Life Skills").first) != nil)
  end

	# Lesson Plans & materials
  if ((skill_group = SkillGroup.where("name = ?", "Lesson Plans & Materials").first) != nil)
  end
end

desc "Add and change skills to what it had been on the production site"
task :change_skills1 => :environment do

  if ((skill_group = SkillGroup.where("name = ?", "Teacher Leadership").first) != nil)
    skill_group.update_attribute(:name, "Teacher Professsional Development" )
  end

  if ((skill_group = SkillGroup.where("name = ?", "Career Development").first) != nil)
    skill_group.update_attribute(:name, "Career Enhancement" )
  end

  if ((skill_group1 = SkillGroup.where("name = ?", "Assesment").first) != nil)
    if ((skill_group2 = SkillGroup.where("name = ?", "Culture Building").first) != nil)
      skill_group1.update_attribute(:name, "Culture Building")
      skill_group2.update_attribute(:name, "Assessment")
    end
  end
end

desc "Add and change skills 09/11/2012"
task :change_skills2 => :environment do
  #Erase Skills Tag Section
  if ((skill_group = SkillGroup.where("name = ?", "Career Enhancement").first) != nil)
    skill_group.destroy
  end

  #Teacher Professional Development
  if ((skill_group = SkillGroup.where("name = ?", "Teacher Professional Development").first) != nil)
    skill_group.update_attribute(:name, "Teacher Leadership")
    skill_group.skills.each do |skill|
      skill.destroy
    end
    Skill.create(:name => "Lead or Facilitate PD", :skill_group_id => skill_group.id)
    Skill.create(:name => "Lead/Master Teacher", :skill_group_id => skill_group.id)
    Skill.create(:name => "Coach/Mentor to Teachers", :skill_group_id => skill_group.id)
  end

  #Technology
  if ((skill_group = SkillGroup.where("name = ?", "Technology" ).first) != nil)
    #1. Add Texas Instruments
    Skill.create(:name => "Texas Instruments", :skill_group_id => skill_group.id)

    #2. Change "1:1 Laptop Computer Learning" to "1:1 Laptop/Computer"
    if((skill = Skill.where("name = ?", "1:1 Laptop/Computer Learning").first) != nil)
      skill.update_attribute(:name, "1:1 Laptop/Computer")
    end

    #3. Change "1.1 Laptop Computer Learning" to "1:1 Laptop/Computer"
    if((skill = Skill.where("name = ?", "BYOD (Bring Your Own Device)".first)) != nil)
      skill.update_attribute(:name, "BYOD")
    end

    #4. Change "Learning with Mobile Devices to "Mobile Devices"
    if((skill = Skill.where("name = ?", "learning with Mobile Devices".first)) != nil)
      skill.update_attribute(:name, "Mobile Devices")
    end

    #5. Remove "Technology Integration"
    if((skill = Skill.where("name = ?", "Technology Integration").first) != nil)
      skill.destroy
    end
  end

  #Pedagogy themes
  if ((skill_group = SkillGroup.where("name = ?", "Pedagogy Themes" ).first) != nil)
    #1. Add "Flipped Classroom"
    Skill.create(:name => "Flipped Classroom", :skill_group_id => skill_group.id)

    #2. Add "Problem-based Learning"
    Skill.create(:name => "Problem-based Learning", :skill_group_id => skill_group.id)

    #3. Change "Project, Problem, & Challenge Based Learning" to "Project Based Learning"
    if((skill = Skill.where("name = ?", "Project, Problem, & Challenge-based Learning").first) != nil)
      skill.update_attribute(:name, "Project Based Learning")
    end

    #4. Change "Problem Solving & Critical Thinking" to "Critical Thinking"
    if((skill = Skill.where("name = ?", "Problem Solving & Critical Thinking").first) != nil)
      skill.update_attribute(:name, "Critical Thinking")
    end

    #5. Change "Social Justice/Critical Pedagogy" to "social Justice"
    if((skill = Skill.where("name = ?", "Social Justice/Critical Pedagogy").first) != nil)
      skill.update_attribute(:name, "Social Justice")
    end

    #6. Change "21st Century Teaching/Learning" to "21st Century Skills"
    if((skill = Skill.where("name = ?", "21st Century Teaching/Learning").first) != nil)
      skill.update_attribute(:name, "21st Century Skills")
    end
  end

  #Specializaed Training
  if ((skill_group = SkillGroup.where("name = ?", "Specialized Training" ).first) != nil)
    Skill.create(:name => "National Board Certified", :skill_group_id => skill_group.id)
  end

  #Lesson Plans
  if ((skill_group1 = SkillGroup.where("name = ?", "Lesson Plans" ).first) != nil)
    if ((skill_group2 = SkillGroup.where("name = ?", "Lesson Materials" ).first) != nil)
      skill_group2.destroy
    end
    skill_group1.update_attribute(:name, "Lesson Plans & Materials")
    skill_group1.skills.each do |skill|
      skill.destroy
    end
    Skill.create(:name => "Common Core Standards", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Pacing Plans", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Unit Plans", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Lesson Plans", :skill_group_id => skill_group1.id)
    Skill.create(:name => "PowerPoint/Keynote", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Materials (e.g. worksheets)", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Projects", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Activities and Games", :skill_group_id => skill_group1.id)
    Skill.create(:name => "Groupwork", :skill_group_id => skill_group1.id)
  end

  #Assessment
  if ((skill_group = SkillGroup.where("name = ?", "Assessment").first) != nil)
    if((skill = Skill.where("name = ?", "Standards-Aligned Assessments").first) != nil)
      skill.update_attribute(:name, "Standards-Aligned")
    end
  end

  #Culture Building
  if ((skill_group = SkillGroup.where("name = ?", "Assessment").first) != nil)
    #1. Change "Behavior/Classroom Management" to "Behavior Management"
    if((skill = Skill.where("name = ?", "Behavior/Classroom Management").first) != nil)
      skill.update_attribute(:name, "Behavior Management")
    end

    #2. Change "Summer Projects & Activities" to "Summer Projects"
    if((skill = Skill.where("name = ?", "Summer Projects & Activities").first) != nil)
      skill.update_attribute(:name, "Summer Projects")
    end

    #3. Change "Field Trips  Celebrations" to "Field Trips & Events"
    if((skill = Skill.where("name = ?", "Field Trips & Celebrations").first) != nil)
      skill.update_attribute(:name, "Field Trips & Events")
    end
  end

  #Life Skills
  if ((skill_group = SkillGroup.where("name = ?", "Life Skills").first) != nil)
    #1. Add "Interpersonal & Public Speaking
    Skill.create(:name => "Interpersonal & Public Speaking", :skill_group_id => skill_group.id)

    #2. Add "Social Skills & Character" to "Character Building"
    if((skill = Skill.where("name = ?", "Social Skills & Character").first) != nil)
      skill.update_attribute(:name, "Character Building")
    end
  end
end
