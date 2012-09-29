desc "Add and change skills to what it had been on the production site"
task :migrate_teacher_video_embeds => :environment do

  Teacher.all.each do |teacher|

    # Only run if the teacher has a video embed url
    next if teacher.video_embed_url.nil? || teacher.video_embed_url.empty?

    # Get embed URL
    embed = teacher.video_embed_url

    # Create new video record
    video = Video.new
    video.teacher = teacher
    video.output_url = 'ext|' + embed
    video.video_id = embed
    video.save
  end
end