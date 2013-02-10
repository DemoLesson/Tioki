ActiveAdmin.register User do     
  config.sort_order = "id_asc"

  scope :all
  scope :admin
  scope :fake

  index do 
    column :id
    column :name                           
    column :email                     
    column :last_login
    column :login_count
    column "Profile" do |model|
      link_to model.slug, model.url
    end
    default_actions                   
  end                                 

  filter :name
  filter :email                       

  form do |f|                         
    f.inputs "User Details" do
      f.input :name       
      f.input :email                  
      f.input :password               
      f.input :password_confirmation  
    end                               
    f.actions                         
  end                                 
end                                   
